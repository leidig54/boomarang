/* eslint-disable operator-linebreak */
/* eslint-disable quotes */
import * as crypto from "crypto";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import * as functions from "firebase-functions";
import { setGlobalOptions } from "firebase-functions/v2/options";
import nodemailer from "nodemailer";
import serviceAccount from "./serviceKey.json";
import admin = require("firebase-admin");

// TODO: improve templating
// TODO: add feedback space

const isEmulator = process.env.FUNCTIONS_EMULATOR === "true";

setGlobalOptions({ region: "europe-west2" });

if (isEmulator) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
    storageBucket: "boomarang-ac130.appspot.com",
  });
} else {
  admin.initializeApp();
}

export const sendConsentAppWhenRequestSubmitted = functions
  .region("europe-west2")
  .firestore.document("requests/{requestId}")
  .onWrite(async (change, context) => {
    // we need to check if to see if the isSubmitted field is true when the request is created or updated (i.e. when the request is submitted), but we only want to send the email once, so we need to check if the isSubmitted field is true and the request has not been submitted before
    const before = change.before.data();
    const request = change.after.data();

    console.log("IsDemo: ", request?.isDemo);

    // if the subject email hasn't changed, return
    if (before?.subjectEmail === request?.subjectEmail) {
      console.log("Subject email has not changed. Exiting...");
      return null;
    }

    console.log("Request has been submitted. Sending email to subject...");

    // generate a unique token for the consenting process
    const token = crypto.randomBytes(20).toString("hex");

    // create an expiry date for the token, 24 hours from now
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 24);

    // save the token to a new document in a consent tokens collection
    await admin
      .firestore()
      .collection("consent_tokens")
      .doc(context.params.requestId)
      .set({
        token,
        createdAt: FieldValue.serverTimestamp(),
        expiresAt: Timestamp.fromDate(expiresAt),
      });

    // if isDemo, dont send email
    if (request?.isDemo) {
      return "Demo request";
    }

    // get the subject email from the request
    const subjectEmail = request?.subjectEmail;

    const address = isEmulator
      ? "http://localhost:53079"
      : "https://boomarang-consent.web.app";

    // the website url is booomarang-consent.web.app. append the request id to the url with the name requestId.
    const emailMessageHtml = `<p>Dear Subject,</p>
    <p>A new consent application has been submitted. Please review the request and provide your consent.</p>
    <p>Request ID: ${context.params.requestId}</p>
    <p>Click <a href="${address}?requestId=${context.params.requestId}&token=${token}">here</a> to provide your consent.</p>
    <p>Thank you.</p>`;

    sendEmail(subjectEmail, "Consent Application", emailMessageHtml);

    return null;
  });

export const createUserDocument = functions
  .region("europe-west2")
  .auth.user()
  .onCreate(async (user) => {
    // if already email verified, return
    if (user.emailVerified) {
      console.log("User email already verified. Is a demo user. Exiting...");
      return null;
    }

    // create the user document
    const userDoc = admin.firestore().collection("users").doc(user.uid);
    await userDoc.set({
      id: user.uid,
      email: user.email,
      emailVerified: false,
      createdAt: FieldValue.serverTimestamp(),
    });
    console.log("User document created for: ", user.email);

    // send a verification email to the user
    await sendVerificationEmail(user.uid);

    return null;
  });

// when a request is updated and the recipientEmail field is no longer null or has changed, check to see if the user with that recipientEmail already exists.
// if it does, assign the userId to the recipientUserId field in the request
// if it doesn't, email the recipient email to create an account
export const assignRecipientToRequestOnRequestCreate = functions
  .region("europe-west2")
  .firestore.document("requests/{requestId}")
  .onWrite(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before?.recipientEmail !== after?.recipientEmail) {
      console.log("Recipient email has changed. Checking if user exists...");
      const recipientEmail = after?.recipientEmail;
      if (!recipientEmail) {
        console.log("Recipient email is null. Exiting...");
        return null;
      }
      try {
        const user = await admin.auth().getUserByEmail(recipientEmail);
        console.log("User exists. Assigning recipientUserId to request...");
        await change.after.ref.update({
          recipientUserId: user.uid,
        });

        // get the user document and get the organisationId
        const userDoc = admin.firestore().collection("users").doc(user.uid);
        const userDocData = await userDoc.get();
        const organisationId = userDocData.data()?.organisationId;

        // if the organisationId is null, return
        if (!organisationId) {
          console.log("OrganisationId is null. Exiting...");
          return null;
        }

        // get the organisation document
        const organisationDoc = admin
          .firestore()
          .collection("organisations")
          .doc(organisationId);

        // get the organisation name
        const organisation = await organisationDoc.get();
        const organisationName = organisation.data()?.name;

        // assign the organisationId to the request
        await change.after.ref.update({
          recipientOrganisationId: organisationId,
          recipientOrganisationName: organisationName,
        });
      } catch (error) {
        // Assert 'error' as an object with a 'code' property
        const errorCode = (error as { code?: string }).code;
        // If the user is not found, send an email to the recipient to create an account
        if (errorCode === "auth/user-not-found") {
          console.log(
            "User does not exist. Sending email to recipient to create an account..."
          );

          if (change.after.data()?.isDemo) {
            return "Is Demo";
          }

          // Email the recipient to create an account
          // TODO: attach the email to the link to create an account
          const emailMessageHtml = `<p>Dear Recipient,</p>
          <p>A new request has been created for you. Please create an account with this email to view and manage the request.</p>
          <p>Click <a href="https://boomarang.web.app">here</a> to create an account.</p>
          <p>Thank you.</p>`;

          sendEmail(
            recipientEmail,
            "Create an account to view your request",
            emailMessageHtml
          );
        } else {
          // Log other errors
          console.error("Error fetching user:", error);
        }
      }
    } else {
      console.log("Recipient email has not changed. Exiting...");
    }
    return null;
  });

// when a request is added by a recipient and the sender already exists, assign the senderUserId to the request.
// otherwise email them to create an account
// this is for manually adding paper requests
export const assignSenderToRequestOnRequestCreate = functions
  .region("europe-west2")
  .firestore.document("requests/{requestId}")
  .onWrite(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before?.senderEmail !== after?.senderEmail) {
      console.log("Sender email has changed. Checking if user exists...");
      const senderEmail = after?.senderEmail;
      if (!senderEmail) {
        console.log("Sender email is null. Exiting...");
        return null;
      }
      try {
        const user = await admin.auth().getUserByEmail(senderEmail);
        console.log("User exists. Assigning senderUserId to request...");
        await change.after.ref.update({
          senderUserId: user.uid,
        });
      } catch (error) {
        // Assert 'error' as an object with a 'code' property
        const errorCode = (error as { code?: string }).code;
        // If the user is not found, send an email to the sender to create an account
        if (errorCode === "auth/user-not-found") {
          console.log(
            "User does not exist. Sending email to sender to create an account..."
          );

          if (change.after.data()?.isDemo) {
            return "Is Demo";
          }

          // get the recipient email from the request
          const recipientEmail = after?.recipientEmail;
          // get the subject first and last name from the request
          const subjectFirstName = after?.subjectFirstName;
          const subjectLastName = after?.subjectLastName;

          // Email the sender to create an account
          // TODO: replace the email with the org name once we have it
          const emailMessageHtml = `<p>Dear Sender,</p>
  <p>Thank you for submitting a request to ${recipientEmail} on behalf of ${subjectFirstName} ${subjectLastName}. A new request has been created for you. Please create an account with this email to finish submitting your request.</p>
  <p>Click <a href="https://boomarang.web.app">here</a> to create an account.</p>
  <p>Thank you.</p>`;

          console.log("Email message: ", senderEmail);

          sendEmail(
            senderEmail,
            "Create an account to view your request",
            emailMessageHtml
          );

          return null;
        }
      }
    }
    return null;
  });

// when a user is verified, check if the user has a request with a recipientEmail that matches the user's email.
// if it does, assign the userId to the recipientUserId field in the request
export const assignRequestToUserOnUserVerification = functions
  .region("europe-west2")
  .firestore.document("users/{userId}")
  .onWrite(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    // see if the email verification status has changed to true from null or false
    if (before?.emailVerified !== true && after?.emailVerified === true) {
      console.log("User email verified. Checking if user has any requests...");
      const userEmail = after?.email;
      if (!userEmail) {
        console.log("User email is null. Exiting...");
        return null;
      }
      try {
        const recipientRequests = await admin
          .firestore()
          .collection("requests")
          .where("recipientEmail", "==", userEmail)
          .get();
        recipientRequests.forEach(async (request) => {
          console.log("Request found. Assigning recipientUserId to request...");
          await request.ref.update({
            recipientUserId: change.after.id,
          });
        });

        const senderRequests = await admin
          .firestore()
          .collection("requests")
          .where("senderEmail", "==", userEmail)
          .get();
        senderRequests.forEach(async (request) => {
          console.log("Request found. Assigning senderUserId to request...");
          await request.ref.update({
            senderUserId: change.after.id,
          });
        });
      } catch (error) {
        console.error("Error fetching requests:", error);
      }
    } else {
      console.log("User email not verified. Exiting...");
    }
    return null;
  });

export const sendVerificationEmail = async (userId: string) => {
  console.log("Sending verification email to user...");

  // get the user document
  const userDoc = admin.firestore().collection("users").doc(userId);
  const user = await userDoc.get();
  if (!user.exists) {
    console.log("User does not exist");
    throw new Error("User does not exist");
  }
  if (!user.data()?.email) {
    console.log("User email is null");
    throw new Error("User email is null");
  }

  // if isDemo, dont send email
  if (user.data()?.isDemo) {
    return "Demo user";
  }

  // send a verification code (6 digits) to the users email
  const code = Math.floor(100000 + Math.random() * 900000);
  const expiresIn = 25 * 60 * 1000; // 20 minutes in milliseconds
  const expirationTime = new Date(Date.now() + expiresIn);

  // save the code to a secure collection in firestore
  const verificationCodeDoc = admin
    .firestore()
    .collection("verification_codes")
    .doc(userId);

  await verificationCodeDoc.set({
    code: code.toString(),
    createdAt: FieldValue.serverTimestamp(),
    expiresAt: Timestamp.fromDate(expirationTime),
  });
  console.log("Verification code saved to firestore");

  // save the expiration time to the user document
  await userDoc.update({
    verificationCodeExpiresAt: Timestamp.fromDate(expirationTime),
  });

  // Construct email verification template, embed the link and send
  const emailMessageHtml = `<p>Dear User,</p>
  <p>Thank you for creating an account with Boomarang. Please verify your email address by entering the following code:</p>
  <p>${code}</p>
  <p>Thank you.</p>`;

  sendEmail(user.data()?.email, "Verify your email address", emailMessageHtml);

  // return a success message
  if (isEmulator) {
    return `Verification code: ${code}`;
  }
  return "Verification email sent";
};

export const sendVerificationEmailCallable = functions
  .region("europe-west2")
  .https.onCall(async (data, context) => {
    // check if the user is authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to send verification email"
      );
    }

    // get the user id from the authenticated user
    const userId = context.auth.uid;

    // send the verification email
    await sendVerificationEmail(userId);

    return "Verification email sent";
  });

export const checkEmailVerificationCode = functions
  .region("europe-west2")
  .https.onCall(async (data, context) => {
    // check if the user is authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to verify email"
      );
    }

    // get the user id from the authenticated user
    const userId = context.auth.uid;

    // get the verification code from the request
    const code = data.code;

    // get the verification code document
    const verificationCodeDoc = admin
      .firestore()
      .collection("verification_codes")
      .doc(userId);
    const verificationCode = await verificationCodeDoc.get();
    if (!verificationCode.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "Verification code not found"
      );
    }
    console.log(
      "Verification code found: ",
      verificationCode.data()?.code.length
    );
    console.log("Submitted code: ", code.length);

    // check if the code is correct
    if (verificationCode.data()?.code !== code) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invalid verification code"
      );
    }

    // check if the code has expired
    if (verificationCode.data()?.expiresAt.toMillis() < Date.now()) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Verification code has expired"
      );
    }

    // update the user document to mark the email as verified
    const userDoc = admin.firestore().collection("users").doc(userId);
    await userDoc.update({
      emailVerified: true,
    });

    admin.auth().updateUser(userId, {
      emailVerified: true,
    });

    // delete the verification code document
    await verificationCodeDoc.delete();

    return "Email verified";
  });

export const getFirstandLastName = functions
  .region("europe-west2")
  .https.onCall(async (data) => {
    // given the requestId, get the subjectFirstName and subjectLastName from the request document
    const requestId = data.requestId;
    const requestDoc = admin.firestore().collection("requests").doc(requestId);
    const request = await requestDoc.get();
    if (!request.exists) {
      throw new functions.https.HttpsError("not-found", "Request not found");
    }
    const subjectFirstName = request.data()?.subjectFirstName;
    const subjectLastName = request.data()?.subjectLastName;
    return { subjectFirstName, subjectLastName };
  });

export const verifyDateOfBirth = functions
  .region("europe-west2")
  .https.onCall(async (data) => {
    // get the dateOfBirth and requestId from the call data, then get the dateOfBirth from the request document, and compare the two. return the result as 'verified' key in the response
    const requestId = data.requestId;
    const submittedDOB = data.dateOfBirth;

    const requestDoc = admin.firestore().collection("requests").doc(requestId);
    const request = await requestDoc.get();
    if (!request.exists) {
      throw new functions.https.HttpsError("not-found", "Request not found");
    }

    // Convert millis to Timestamp
    const submittedDateOfBirth = new Date(submittedDOB);

    // Get the subjectDOB from the request document and convert it to Date object
    const subjectDOB = request.data()?.subjectDOB;
    if (subjectDOB == null) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "subjectDOB is missing"
      );
    }

    // convert timestamp to date
    const requestDateOfBirth = subjectDOB.toDate();

    // Normalize dates to the start of the day in UTC for accurate day comparison
    const normalizeDateToUTCStartOfDay = (date: Date) => {
      return new Date(
        Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate())
      );
    };

    const requestDOBNormalized =
      normalizeDateToUTCStartOfDay(requestDateOfBirth);
    const submittedDOBNormalized =
      normalizeDateToUTCStartOfDay(submittedDateOfBirth);

    // Compare the normalized dates
    const verified =
      requestDOBNormalized.getTime() === submittedDOBNormalized.getTime();

    // update the request document to mark the date of birth as verified
    if (verified) {
      await requestDoc.update({
        subjectDOBVerified: true,
      });
    }

    console.log("Normalized Request DOB: ", requestDateOfBirth);
    console.log("Normalized Submitted DOB: ", submittedDateOfBirth);
    console.log("Date of birth verified: ", verified);

    return { verified };
  });

export const verifyConsent = functions
  .region("europe-west2")
  .https.onCall(async (data) => {
    // get the consent token and requestId from the call data, then get the token from the consent tokens collection and compare the two. return the result as 'verified' key in the response
    const requestId = data.requestId;
    const token = data.token;
    const consentTokenDoc = admin
      .firestore()
      .collection("consent_tokens")
      .doc(requestId);
    const consentToken = await consentTokenDoc.get();
    if (!consentToken.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "Consent token not found"
      );
    }

    // check it hasn't expired
    if (consentToken.data()?.expiresAt.toMillis() < Date.now()) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Consent token has expired"
      );
    }

    // update the request document to mark the consent as given
    const requestDoc = admin.firestore().collection("requests").doc(requestId);
    await requestDoc.update({
      consentVerified: true,
    });

    const verified = consentToken.data()?.token === token;

    return { verified };
  });

export const confirmEmailAddress = functions
  .region("europe-west2")
  .https.onCall(async (data) => {
    // get the requestId and the token and check if the token matches the token in the consent_tokens collection
    const requestId = data.requestId;
    const token = data.token;
    const consentTokenDoc = admin
      .firestore()
      .collection("consent_tokens")
      .doc(requestId);
    const consentToken = await consentTokenDoc.get();
    if (!consentToken.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "Consent token not found"
      );
    }

    // check it hasn't expired
    if (consentToken.data()?.expiresAt.toMillis() < Date.now()) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Consent token has expired"
      );
    }

    const verified = consentToken.data()?.token === token;
    console.log("Email verified: ", verified);

    // if verified, update the subjectEmailVerified field in the request document
    if (verified) {
      const requestDoc = admin
        .firestore()
        .collection("requests")
        .doc(requestId);
      await requestDoc.update({
        subjectEmailVerified: true,
      });
    } else {
      throw new functions.https.HttpsError("invalid-argument", "Invalid token");
    }

    return { verified };
  });

export const requestBoomarang = functions
  .region("europe-west2")
  .https.onCall(async (data, context) => {
    // get the recipient id from the context
    const userId = context.auth?.uid;

    // get the sender email from the data
    const senderEmail = data.senderEmail;

    // create a new request document
    const requestDoc = admin.firestore().collection("requests").doc();

    // create a new request
    const request = {
      id: requestDoc.id,
      recipientUserId: userId,
      recipientEmail: context.auth?.token.email,
      subjectFirstName: data.subjectFirstName,
      subjectLastName: data.subjectLastName,
      senderEmail: senderEmail,
      dateCreated: FieldValue.serverTimestamp(),
      requestStatus: "pending_completion",
    };

    // set the request document
    await requestDoc.set(request);

    return requestDoc.id;
  });

export const submitResponse = functions
  .region("europe-west2")
  .https.onCall(async (data, context) => {
    // get the request id from the data
    const requestId = data.requestId;

    // get the request document
    const requestDoc = admin.firestore().collection("requests").doc(requestId);

    // check that the user uid is the same as the recipientUserId in the request
    const request = await requestDoc.get();
    if (!request.exists) {
      throw new functions.https.HttpsError("not-found", "Request not found");
    }

    // get the recipientUserId from the request
    const recipientUserId = request.data()?.recipientUserId;

    // check if the user is authenticated
    if (context.auth?.uid !== recipientUserId) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "User does not have permission to save a response"
      );
    }

    // save the response data to the request document
    await requestDoc.update({
      response: data.response,
      responseDate: FieldValue.serverTimestamp(),
      requestStatus: "response_submitted",
    });

    return "Response saved";
  });

// updateOrganisationRole
export const updateOrganisationRole = functions
  .region("europe-west2")
  .https.onCall(async (data, context) => {
    // check the request is coming from an admin

    // get the user id from the context
    const userId = context.auth?.uid;

    // if the user is not authenticated, throw an error
    if (!userId) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to update organisation role"
      );
    }

    // get the user document and check if the user is an admin
    const userDoc = admin.firestore().collection("users").doc(userId);
    const user = await userDoc.get();
    if (!user.exists) {
      throw new functions.https.HttpsError("not-found", "User not found");
    }

    // check if the user is an admin
    if (user.data()?.organisationRole !== "admin") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "User is not an admin"
      );
    }

    // get the organisation id and the id of the person and the new role we're updating from the data
    const organisationId = data.organisationId;
    const userIdToUpdate = data.id;
    const newRole = data.role;

    // if any of the fields are missing, throw an error
    if (!organisationId || !userIdToUpdate || !newRole) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing fields"
      );
    }

    // get the user document
    const userToUpdateDoc = admin
      .firestore()
      .collection("users")
      .doc(userIdToUpdate);
    const userToUpdate = await userToUpdateDoc.get();
    if (!userToUpdate.exists) {
      throw new functions.https.HttpsError("not-found", "User not found");
    }

    // update the user document with the new role
    await userToUpdateDoc.update({
      organisationRole: newRole,
    });

    return "Role updated";
  });

// each time the senderUserId field is updated (or created) in a request, update the senderOrganisationId field in the request
export const updateSenderOrganisationId = functions
  .region("europe-west2")
  .firestore.document("requests/{requestId}")
  .onWrite(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before?.senderUserId !== after?.senderUserId) {
      console.log("Sender user id has changed. Checking if user exists...");
      const senderUserId = after?.senderUserId;
      if (!senderUserId) {
        console.log("Sender user id is null. Exiting...");
        return null;
      }
      try {
        const user = await admin.auth().getUser(senderUserId);
        console.log(
          "User exists. Assigning senderOrganisationId to request..."
        );

        // get the user document and get the organisationId
        const userDoc = admin.firestore().collection("users").doc(user.uid);
        const userDocData = await userDoc.get();
        const organisationId = userDocData.data()?.organisationId;

        // if the organisationId is null, return
        if (!organisationId) {
          console.log("OrganisationId is null. Exiting...");
          return null;
        }

        // get the organisation name
        const organisationDoc = admin
          .firestore()
          .collection("organisations")
          .doc(organisationId);

        const organisation = await organisationDoc.get();
        const organisationName = organisation.data()?.name;

        // assign the organisationId to the request
        await change.after.ref.update({
          senderOrganisationId: organisationId,
          senderOrganisationName: organisationName,
        });
      } catch (error) {
        console.error("Error fetching user:", error);
      }
    } else {
      console.log("Sender user id has not changed. Exiting...");
    }
    return null;
  });

// each time the recipientUserId field is updated (or created) in a request, update the recipientOrganisationId field in the request
export const updateRecipientOrganisationId = functions
  .region("europe-west2")
  .firestore.document("requests/{requestId}")
  .onWrite(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before?.recipientUserId !== after?.recipientUserId) {
      console.log("Recipient user id has changed. Checking if user exists...");
      const recipientUserId = after?.recipientUserId;
      if (!recipientUserId) {
        console.log("Recipient user id is null. Exiting...");
        return null;
      }
      try {
        const user = await admin.auth().getUser(recipientUserId);
        console.log(
          "User exists. Assigning recipientOrganisationId to request..."
        );

        // get the user document and get the organisationId
        const userDoc = admin.firestore().collection("users").doc(user.uid);
        const userDocData = await userDoc.get();
        const organisationId = userDocData.data()?.organisationId;

        // if the organisationId is null, return
        if (!organisationId) {
          console.log("OrganisationId is null. Exiting...");
          return null;
        }

        // get the organisation name
        const organisationDoc = admin
          .firestore()
          .collection("organisations")
          .doc(organisationId);

        const organisation = await organisationDoc.get();
        const organisationName = organisation.data()?.name;

        // assign the organisationId to the request
        await change.after.ref.update({
          recipientOrganisationId: organisationId,
          recipientOrganisationName: organisationName,
        });
      } catch (error) {
        console.error("Error fetching user:", error);
      }
    } else {
      console.log("Recipient user id has not changed. Exiting...");
    }
    return null;
  });

// each time a users organisationId is updated, update the organisationId in the users requests (both sender and recipient)
export const updateOrganisationIdInRequests = functions
  .region("europe-west2")
  .firestore.document("users/{userId}")
  .onUpdate(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before?.organisationId !== after?.organisationId) {
      console.log(
        "OrganisationId has changed. Updating organisationId in requests..."
      );

      const userId = change.after.id;
      const organisationId = after?.organisationId;

      // get all the requests where the senderUserId is the user id
      const senderRequests = await admin
        .firestore()
        .collection("requests")
        .where("senderUserId", "==", userId)
        .get();
      senderRequests.forEach(async (request) => {
        console.log("Request found. Updating senderOrganisationId...");

        // get the new organisation name too and update the request
        const organisationDoc = admin
          .firestore()
          .collection("organisations")
          .doc(organisationId);
        const organisation = await organisationDoc.get();
        const organisationName = organisation.data()?.name;

        await request.ref.update({
          senderOrganisationId: organisationId,
          senderOrganisationName: organisationName,
        });
      });

      // get all the requests where the recipientUserId is the user id
      const recipientRequests = await admin
        .firestore()
        .collection("requests")
        .where("recipientUserId", "==", userId)
        .get();
      recipientRequests.forEach(async (request) => {
        console.log("Request found. Updating recipientOrganisationId...");

        // get the new organisation name too and update the request
        const organisationDoc = admin
          .firestore()
          .collection("organisations")
          .doc(organisationId);

        const organisation = await organisationDoc.get();
        const organisationName = organisation.data()?.name;

        await request.ref.update({
          recipientOrganisationId: organisationId,
          recipientOrganisationName: organisationName,
        });
      });
    } else {
      console.log("OrganisationId has not changed. Exiting...");
    }
    return null;
  });

// create an organisation with the name provided. add the creater to the list of users and set the user document with the organisation role as admin
export const createOrganisation = functions
  .region("europe-west2")
  .https.onCall(async (data, context) => {
    // get the user id from the context
    const userId = context.auth?.uid;

    // if the user is not authenticated, throw an error
    if (!userId) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to create an organisation"
      );
    }

    // get the organisation name from the data
    const organisationName = data.name;

    // create a new organisation document
    const organisationDoc = admin.firestore().collection("organisations").doc();

    // create a new organisation
    const organisation = {
      id: organisationDoc.id,
      name: organisationName,
      createdAt: FieldValue.serverTimestamp(),
      users: [userId],
    };

    // set the organisation document
    await organisationDoc.set(organisation);

    // get the user document
    const userDoc = admin.firestore().collection("users").doc(userId);
    const user = await userDoc.get();
    if (!user.exists) {
      throw new functions.https.HttpsError("not-found", "User not found");
    }

    // update the user document with the organisation id and the organisation role as admin
    await userDoc.update({
      organisationId: organisationDoc.id,
      organisationRole: "admin",
    });

    return organisationDoc.id;
  });

// process an invite code and add the user to the organisation
export const joinOrganisation = functions
  .region("europe-west2")
  .https.onCall(async (data, context) => {
    // get the user id from the context
    const userId = context.auth?.uid;

    // if the user is not authenticated, throw an error
    if (!userId) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to process an invite code"
      );
    }

    // get the invite code from the data
    const inviteCode = data.inviteCode;

    // get the invite document
    const inviteDoc = admin.firestore().collection("invites").doc(inviteCode);
    const invite = await inviteDoc.get();
    if (!invite.exists) {
      throw new functions.https.HttpsError("not-found", "Invite not found");
    }

    // check the invite hasn't expired
    if (invite.data()?.expiresAt.toMillis() < Date.now()) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Invite has expired"
      );
    }

    // get the organisation id from the invite
    const organisationId = invite.data()?.organisationId;

    // get the organisation role
    const recipientRole = invite.data()?.recipientRole;

    // get the organisation document
    const organisationDoc = admin
      .firestore()
      .collection("organisations")
      .doc(organisationId);
    const organisation = await organisationDoc.get();
    if (!organisation.exists) {
      throw new functions.https.HttpsError(
        "not-found",
        "Organisation not found"
      );
    }

    // get the user document
    const userDoc = admin.firestore().collection("users").doc(userId);
    const user = await userDoc.get();
    if (!user.exists) {
      throw new functions.https.HttpsError("not-found", "User not found");
    }

    // check the users email matches the recipient email by looking them up in the authentication system
    const recipientEmail = invite.data()?.recipientEmail;
    const recipientUser = await admin
      .auth()
      .getUserByEmail(recipientEmail)
      .catch((error) => {
        if (error.code === "auth/user-not-found") {
          throw new functions.https.HttpsError(
            "not-found",
            "Recipient not has not registered"
          );
        } else {
          throw new functions.https.HttpsError(
            "internal",
            "Error checking if user exists"
          );
        }
      });

    if (recipientUser.uid !== userId) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "User does not have permission to join the organisation"
      );
    }

    // add the user to the organisation
    await organisationDoc.update({
      users: FieldValue.arrayUnion(userId),
    });

    // update the user document with the organisation id
    await userDoc.update({
      organisationId: organisationId,
      organisationRole: recipientRole,
    });

    // delete the invite document
    await inviteDoc.delete();

    return "User added to organisation";
  });

// send an invite to join an organisation. create an invite document with the organisation id and the organisation role, and send an email to the recipient with the invite code
export const sendInvite = functions
  .region("europe-west2")
  .https.onCall(async (data, context) => {
    // get the user id from the context
    const userId = context.auth?.uid;

    // if the user is not authenticated, throw an error
    if (!userId) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to send an invite"
      );
    }

    // get the user document
    const userDoc = admin.firestore().collection("users").doc(userId);
    const user = await userDoc.get();
    if (!user.exists) {
      throw new functions.https.HttpsError("not-found", "User not found");
    }

    // get the organisation id from the user document
    const organisationId = user.data()?.organisationId;
    if (!organisationId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "User is not part of an organisation"
      );
    }

    // get the recipient email and the organisation role from the data
    const recipientEmail = data.recipientEmail;
    const recipientRole = data.recipientRole;

    // check if the recipient email is already a user
    const userExists = await admin
      .auth()
      .getUserByEmail(recipientEmail)
      .catch((error) => {
        if (error.code === "auth/user-not-found") {
          return false;
        } else {
          throw new functions.https.HttpsError(
            "internal",
            "Error checking if user exists"
          );
        }
      });

    if (userExists) {
      throw new functions.https.HttpsError(
        "already-exists",
        "User already exists"
      );
    }

    // check if the recipient email is already invited
    const inviteExists = await admin
      .firestore()
      .collection("invites")
      .where("recipientEmail", "==", recipientEmail)
      .get();

    if (!inviteExists.empty) {
      throw new functions.https.HttpsError(
        "already-exists",
        "Invite already exists"
      );
    }

    // create a new invite document
    const inviteDoc = admin.firestore().collection("invites").doc();

    // set it to expire in 24 hours
    const expiresIn = 24 * 60 * 60 * 1000; // 24 hours in milliseconds
    const expirationTime = new Date(Date.now() + expiresIn);

    // create a new invite
    const invite = {
      id: inviteDoc.id,
      organisationId: organisationId,
      recipientRole: recipientRole,
      recipientEmail: recipientEmail,
      createdAt: FieldValue.serverTimestamp(),
      expiresAt: Timestamp.fromDate(expirationTime),
    };

    // set the invite document
    await inviteDoc.set(invite);

    // Construct email verification template, embed the link and send the invite code in the email
    const emailMessageHtml = `<p>Dear Recipient,</p>
    <p>You have been invited to join an organisation. Please click the link below to join:</p>
    <p><a href="https://boomarang.web.app">Join Organisation</a></p>
    <p>Invite Code: ${inviteDoc.id}</p>
    <p>Thank you.</p>`;

    await sendEmail(
      recipientEmail,
      "You have been invited to join an organisation",
      emailMessageHtml
    );
  });

// Extract send email function so we can call it from multiple functions
const sendEmail = async (
  email: string,
  subject: string,
  emailMessageHtml: string
) => {
  // Configure the email transport using the provided SMTP server.
  const smtpEmail = "george@joinoto.com";
  const password = "GHD9XULrYSFwdOKM"; // Ensure you're securely handling passwords and sensitive information
  const mailTransport = nodemailer.createTransport({
    host: "smtp-relay.brevo.com",
    port: 587,
    auth: {
      user: smtpEmail,
      pass: password,
    },
  });

  const mailOptions = {
    from: '"Support" <support@boomarang.com>',
    to: email,
    subject: subject,
    html: emailMessageHtml,
  };

  try {
    await mailTransport.sendMail(mailOptions);
    console.log(`Email sent to: ${mailOptions.to}`);
    return null;
  } catch (error) {
    console.error("There was an error while sending the email:", error);
    return null;
  }
};
