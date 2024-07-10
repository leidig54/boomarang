import { generate } from "@genkit-ai/ai";
import { configureGenkit } from "@genkit-ai/core";
import { firebase } from "@genkit-ai/firebase";
import { firebaseAuth } from "@genkit-ai/firebase/auth";
import { onFlow } from "@genkit-ai/firebase/functions";
import { gemini15ProPreview, vertexAI } from "@genkit-ai/vertexai";
import * as crypto from "crypto";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import * as functions from "firebase-functions";
import { setGlobalOptions } from "firebase-functions/v2/options";
import nodemailer from "nodemailer";
import * as z from "zod";
import serviceAccount from "./serviceKey.json";
import admin = require("firebase-admin");


// TODO: improve templating
// TODO: add feedback space
// TODO: payments - should we set the prices?


const isEmulator = process.env.FUNCTIONS_EMULATOR === "true";


setGlobalOptions({ region: "europe-west2" });


if (isEmulator) {
  admin.initializeApp(
    {
      credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
      storageBucket: "boomarang-ac130.appspot.com",
    }
  );
} else {
  admin.initializeApp();
}


configureGenkit({
  plugins: [
    firebase(),
    vertexAI({ location: "europe-west2" }),
  ],
  logLevel: "error",
  enableTracingAndMetrics: true,
});

export const generateReport = onFlow({
  name: "generateReport",
  httpsOptions: {
    cors: true,
  },
  inputSchema: z.object({
    requestData: z.object({
      requestType: z.string(),
      text: z.string().nullable(),
      fileUrl: z.string().nullable(),
    }),
    consultationData: z.object({
      text: z.string().nullable(),
      fileUrl: z.string().nullable(),
    }),
    id: z.string(),
  }),
  outputSchema: z.string(),
  authPolicy: firebaseAuth((user) => {
    if (user.uid === null) {
      throw new Error("Verified email required to run flow");
    }
  }),
},
async (subject) => {
  console.log("Generating report...");
  // get the user id
  const userId = subject.id;

  // get the user document
  const userDoc = admin.firestore().collection("users").doc(userId);

  // get the title, firstName and lastName from the user document
  const user = await userDoc.get();
  if (!user.exists) {
    throw new Error("User not found");
  }
  const title = user.data()?.title;
  const firstName = user.data()?.firstName;
  const lastName = user.data()?.lastName;


  // create the prompt for the model, given the text or the urls can be null
  const prompt = [];
  prompt.push({ text: "You are a report writing assistant. You have to write a report based on the following request details:" });
  if (subject.requestData.text) {
    prompt.push({ text: subject.requestData.text });
  }
  // the report type is
  prompt.push({ text: `The report type is ${subject.requestData.requestType}` });
  if (subject.requestData.fileUrl) {
    prompt.push({ media: { url: subject.requestData.fileUrl, contentType: "application/pdf" } });
  }

  prompt.push({ text: "You have to include the following consultation details in the report:" });
  if (subject.consultationData.text) {
    prompt.push({ text: subject.consultationData.text });
  }
  if (subject.consultationData.fileUrl) {
    prompt.push({ media: { url: subject.consultationData.fileUrl, contentType: "application/pdf" } });
  }
  prompt.push({ text: "Respond in raw html. Do not use ** etc. Make good use of headings or bold text to separate the components. Sign with the following details: " });
  prompt.push({ text: `${title} ` });
  prompt.push({ text: `${firstName} ` });
  prompt.push({ text: `${lastName}` });


  let result;
  try {
    result = await generate({
      model: gemini15ProPreview,
      prompt: prompt,
    });
  } catch (error) {
    console.error("Error generating report:", error);
    // Handle the error here
    // For example, you can throw a custom error or return an error message
    throw new Error("Failed to generate report");
  }

  return result.text();
}
);

export const sendConsentAppWhenRequestSubmitted = functions.region("europe-west2").firestore.document("requests/{requestId}").onCreate(async (change, context) => {
  // we need to check if to see if the isSubmitted field is true when the request is created or updated (i.e. when the request is submitted), but we only want to send the email once, so we need to check if the isSubmitted field is true and the request has not been submitted before

  const request = change.data();

  console.log("IsDemo: ", request?.isDemo);

  // if isDemo, dont send email
  if (request?.isDemo) {
    return "Demo request";
  }

  console.log("Request has been submitted. Sending email to subject...");


  // generate a unique token for the consenting process
  const token = crypto.randomBytes(20).toString("hex");

  // create an expiry date for the token, 24 hours from now
  const expiresAt = new Date();
  expiresAt.setHours(expiresAt.getHours() + 24);


  // save the token to a new document in a consent tokens collection
  await admin.firestore().collection("consent_tokens").doc(context.params.requestId).set({
    token,
    createdAt: FieldValue.serverTimestamp(),
    expiresAt: Timestamp.fromDate(expiresAt),
  });


  // get the subject email from the request
  const subjectEmail = request?.subjectEmail;

  // email the subject with the request id
  // Configure the email transport using the provided SMTP server.
  const email = "george@joinoto.com";
  const password = "GHD9XULrYSFwdOKM";
  const mailTransport = nodemailer.createTransport({
    host: "smtp-relay.brevo.com",
    port: 587,
    auth: {
      user: email,
      pass: password,
    },
  });

  const address = isEmulator ? "http://localhost:62409" : "https://boomarang-consent.web.app";

  // the website url is booomarang-consent.web.app. append the request id to the url with the name requestId.
  const emailMessageHtml = `<p>Dear Subject,</p>
    <p>A new consent application has been submitted. Please review the request and provide your consent.</p>
    <p>Request ID: ${context.params.requestId}</p>
    <p>Click <a href="${address}?requestId=${context.params.requestId}&token=${token}">here</a> to provide your consent.</p>
    <p>Thank you.</p>`;


  const mailOptions = {
    from: "\"George\" <george@boomarang.com>",
    to: subjectEmail,
    subject: "Consent requested",
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
});

export const createUserDocument = functions.region("europe-west2").auth.user().onCreate(async (user) => {
  // if already email verified, return
  if (user.emailVerified) {
    console.log("User email already verified. Is a demo user. Exiting...");
    return null;
  }

  // create the user document
  const userDoc = admin.firestore().collection("users").doc(user.uid);
  await userDoc.set({
    email: user.email,
    emailVerified: false,
    createdAt: FieldValue.serverTimestamp(),
  });
  console.log("User document created for: ", user.email);

  // send a verification email to the user
  await sendVerificationEmail(user.uid);

  return null;
});

// when a request is updated and the holderEmail field is no longer null or has changed, check to see if the user with that holderEmail already exists. if it does, assign the userId to the holderUserId field in the request
export const assignHolderToRequestOnRequestCreate = functions.region("europe-west2").firestore.document("requests/{requestId}")
  .onWrite(async (change) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before?.holderEmail !== after?.holderEmail) {
      console.log("Holder email has changed. Checking if user exists...");
      const holderEmail = after?.holderEmail;
      if (!holderEmail) {
        console.log("Holder email is null. Exiting...");
        return null;
      }
      try {
        const user = await admin.auth().getUserByEmail(holderEmail);
        console.log("User exists. Assigning holderUserId to request...");
        await change.after.ref.update({
          holderUserId: user.uid,
        });
      } catch (error) {
        // Assert 'error' as an object with a 'code' property
        const errorCode = (error as { code?: string }).code;
        // If the user is not found, send an email to the holder to create an account
        if (errorCode === "auth/user-not-found") {
          console.log("User does not exist. Sending email to holder to create an account...");
          // Configure the email transport using the provided SMTP server.
          const email = "george@joinoto.com";
          const password = "GHD9XULrYSFwdOKM"; // Ensure you're securely handling passwords and sensitive information
          const mailTransport = nodemailer.createTransport({
            host: "smtp-relay.brevo.com",
            port: 587,
            auth: {
              user: email,
              pass: password,
            },
          });

          // Email the holder to create an account
          const emailMessageHtml = `<p>Dear Holder,</p>
          <p>A new request has been created for you. Please create an account with this email to view and manage the request.</p>
          <p>Click <a href="https://boomarang.web.app">here</a> to create an account.</p>
          <p>Thank you.</p>`;

          const mailOptions = {
            from: "\"George\" <george@boomarang.com>",
            to: holderEmail,
            subject: "Create an account to view your request",
            html: emailMessageHtml,
          };

          try {
            await mailTransport.sendMail(mailOptions);
            console.log(`Email sent to: ${mailOptions.to}`);
          } catch (emailError) {
            console.error("There was an error while sending the email:", emailError);
          }
        } else {
          // Log other errors
          console.error("Error fetching user:", error);
        }
      }
    } else {
      console.log("Holder email has not changed. Exiting...");
    }
    return null;
  });

// when a user is verified, check if the user has a request with a holderEmail that matches the user's email. if it does, assign the userId to the holderUserId field in the request
export const assignRequestToHolderOnUserVerification = functions.region("europe-west2").firestore.document("users/{userId}").onWrite(async (change) => {
  const before = change.before.data();
  const after = change.after.data();

  // see if the email verification status has changed to true from null or false
  if (before?.emailVerified !== true && after?.emailVerified === true) {
    console.log("User email verified. Checking if user has any requests...");
    const holderEmail = after?.email;
    if (!holderEmail) {
      console.log("Holder email is null. Exiting...");
      return null;
    }
    try {
      const requests = await admin.firestore().collection("requests").where("holderEmail", "==", holderEmail).get();
      requests.forEach(async (request) => {
        console.log("Request found. Assigning holderUserId to request...");
        await request.ref.update({
          holderUserId: change.after.id,
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

export const sendVerificationEmail = async (userId: string, ) => {
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
  const verificationCodeDoc = admin.firestore().collection("verification_codes").doc(userId);

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

  // Configure the email transport using the provided SMTP server.
  const email = "george@joinoto.com";
  const password = "GHD9XULrYSFwdOKM"; // Ensure you're securely handling passwords and sensitive information
  const mailTransport = nodemailer.createTransport({
    host: "smtp-relay.brevo.com",
    port: 587,
    auth: {
      user: email,
      pass: password,
    },
  });

  const mailOptions = {
    from: "\"Boomarang Verification\" <verificaton@boomarang.com>",
    to: user.data()?.email,
    subject: "Create an account to view your request",
    html: emailMessageHtml,
  };

  try {
    await mailTransport.sendMail(mailOptions);
    console.log(`Email sent to: ${mailOptions.to}`);
  } catch (emailError) {
    console.error("There was an error while sending the email:", emailError);
    throw new Error("Failed to send verification email");
  }

  // return a success message
  if (isEmulator) {
    return `Verification code: ${code}`;
  }
  return "Verification email sent";
};

export const sendVerificationEmailCallable = functions.region("europe-west2").https.onCall(async (data, context) => {
  // check if the user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated to send verification email");
  }

  // get the user id from the authenticated user
  const userId = context.auth.uid;

  // send the verification email
  await sendVerificationEmail(userId);

  return "Verification email sent";
});

export const checkEmailVerificationCode = functions.region("europe-west2").https.onCall(async (data, context) => {
  // check if the user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated to verify email");
  }

  // get the user id from the authenticated user
  const userId = context.auth.uid;

  // get the verification code from the request
  const code = data.code;

  // get the verification code document
  const verificationCodeDoc = admin.firestore().collection("verification_codes").doc(userId);
  const verificationCode = await verificationCodeDoc.get();
  if (!verificationCode.exists) {
    throw new functions.https.HttpsError("not-found", "Verification code not found");
  }
  console.log("Verification code found: ", verificationCode.data()?.code.length);
  console.log("Submitted code: ", code.length);

  // check if the code is correct
  if (verificationCode.data()?.code !== code) {
    throw new functions.https.HttpsError("invalid-argument", "Invalid verification code");
  }

  // check if the code has expired
  if (verificationCode.data()?.expiresAt.toMillis() < Date.now()) {
    throw new functions.https.HttpsError("invalid-argument", "Verification code has expired");
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

export const markRequestAsCompleteWhenResponseSubmitted = functions.region("europe-west2").firestore.document("responses/{responseId}").onCreate(async (change) => {
  // when a response is created, mark the request as complete
  const response = change.data();
  const requestId = response.id;
  const requestDoc = admin.firestore().collection("requests").doc(requestId);
  await requestDoc.update({
    requestStatus: "complete",
  });
  return null;
}
);

export const getFirstandLastName = functions.region("europe-west2").https.onCall(async (data) => {
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
}
);

export const verifyDateOfBirth = functions.region("europe-west2").https.onCall(async (data) => {
  // get the dateOfBirth and requestId from the call data, then get the dateOfBirth from the request document, and compare the two. return the result as 'verified' key in the response
  const requestId = data.requestId;
  const dateOfBirthISO = data.dateOfBirth;
  const requestDoc = admin.firestore().collection("requests").doc(requestId);
  const request = await requestDoc.get();
  if (!request.exists) {
    throw new functions.https.HttpsError("not-found", "Request not found");
  }

  // Convert ISO 8601 string to Timestamp
  const submittedDateOfBirthTimestamp = new Date(dateOfBirthISO);

  // Convert Firestore Timestamp to Date object
  const requestDateOfBirthTimestamp = request.data()?.subjectDOB.toDate();

  // Normalize dates to the start of the day in UTC for accurate day comparison
  const normalizeDateToUTCStartOfDay = (date: Date) => {
    return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
  };

  const requestDOBNormalized = normalizeDateToUTCStartOfDay(requestDateOfBirthTimestamp);
  const submittedDOBNormalized = normalizeDateToUTCStartOfDay(submittedDateOfBirthTimestamp);

  // Compare the normalized dates
  const verified = requestDOBNormalized.getTime() === submittedDOBNormalized.getTime();

  // update the request document to mark the date of birth as verified
  if (verified) {
    await requestDoc.update({
      subjectDOBVerified: true,
    });
  }


  console.log("Normalized Request DOB: ", requestDOBNormalized);
  console.log("Normalized Submitted DOB: ", submittedDOBNormalized);
  console.log("Date of birth verified: ", verified);

  return { verified };
}
);

export const verifyConsent = functions.region("europe-west2").https.onCall(async (data) => {
  // get the consent token and requestId from the call data, then get the token from the consent tokens collection and compare the two. return the result as 'verified' key in the response
  const requestId = data.requestId;
  const token = data.token;
  const consentTokenDoc = admin.firestore().collection("consent_tokens").doc(requestId);
  const consentToken = await consentTokenDoc.get();
  if (!consentToken.exists) {
    throw new functions.https.HttpsError("not-found", "Consent token not found");
  }

  // check it hasn't expired
  if (consentToken.data()?.expiresAt.toMillis() < Date.now()) {
    throw new functions.https.HttpsError("invalid-argument", "Consent token has expired");
  }

  // update the request document to mark the consent as given
  const requestDoc = admin.firestore().collection("requests").doc(requestId);
  await requestDoc.update({
    consentVerified: true,
  });

  const verified = consentToken.data()?.token === token;

  return { verified };
}
);

export const confirmEmailAddress = functions.region("europe-west2").https.onCall(async (data) => {
  // get the requestId and the token and check if the token matches the token in the consent_tokens collection
  const requestId = data.requestId;
  const token = data.token;
  const consentTokenDoc = admin.firestore().collection("consent_tokens").doc(requestId);
  const consentToken = await consentTokenDoc.get();
  if (!consentToken.exists) {
    throw new functions.https.HttpsError("not-found", "Consent token not found");
  }

  // check it hasn't expired
  if (consentToken.data()?.expiresAt.toMillis() < Date.now()) {
    throw new functions.https.HttpsError("invalid-argument", "Consent token has expired");
  }


  const verified = consentToken.data()?.token === token;
  console.log("Email verified: ", verified);

  // if verified, update the subjectEmailVerified field in the request document
  if (verified) {
    const requestDoc = admin.firestore().collection("requests").doc(requestId);
    await requestDoc.update({
      subjectEmailVerified: true,
    });
  } else {
    throw new functions.https.HttpsError("invalid-argument", "Invalid token");
  }

  return { verified };
}
);


