import { generate } from "@genkit-ai/ai";
import { configureGenkit } from "@genkit-ai/core";
import { firebase } from "@genkit-ai/firebase";
import { firebaseAuth } from "@genkit-ai/firebase/auth";
import { onFlow } from "@genkit-ai/firebase/functions";
import { gemini15ProPreview, vertexAI } from "@genkit-ai/vertexai";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import * as functions from "firebase-functions";
import nodemailer from "nodemailer";
import * as z from "zod";
import serviceAccount from "./serviceKey.json";
import admin = require("firebase-admin");

const isEmulator = process.env.FUNCTIONS_EMULATOR === "true";


admin.initializeApp(
  {
    credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
    storageBucket: "boomarang-ac130.appspot.com",
  }
);

configureGenkit({
  plugins: [
    firebase(),
    vertexAI({ location: "europe-west2" }),
  ],
  logLevel: "debug",
  enableTracingAndMetrics: true,
});

export const generateReport = onFlow({
  name: "generateReport",
  httpsOptions: {
    cors: true,
  },
  inputSchema: z.object({
    requestData: z.object({
      text: z.string().nullable(),
      fileUrl: z.string().nullable(),
    }),
    consultationData: z.object({
      text: z.string().nullable(),
      fileUrl: z.string().nullable(),
    }),
  }),
  outputSchema: z.string(),
  authPolicy: firebaseAuth((user) => {
    if (user.uid === null) {
      throw new Error("Verified email required to run flow");
    }
  }),
},
async (subject) => {
  // create the prompt for the model, given the text or the urls can be null
  const prompt = [];
  prompt.push({ text: "You are a report writing assistant. You have to write a report based on the following request details:" });
  if (subject.requestData.text) {
    prompt.push({ text: subject.requestData.text });
  }
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
  prompt.push({ text: "Respond in raw html. Do not use ** etc. Make good use of headings or bold text to separate the components." });


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

export const sendConsentAppWhenRequestSubmitted = functions.firestore.document("requests/{requestId}").onWrite(async (change, context) => {
  // we need to check if to see if the isSubmitted field is true when the request is created or updated (i.e. when the request is submitted), but we only want to send the email once, so we need to check if the isSubmitted field is true and the request has not been submitted before
  if (change.after.data()?.isSubmitted === true && change.before.data()?.isSubmitted !== true) {
    const request = change.after.data();

    // get the authoriser email from the request
    const authoriserEmail = request?.authoriserEmail;

    // email the authoriser with the request id
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

    const address = isEmulator ? "http://localhost:54919" : "https://booomarang-consent.web.app";

    // the website url is booomarang-consent.web.app. append the request id to the url with the name requestId.
    const emailMessageHtml = `<p>Dear Authoriser,</p>
    <p>A new consent application has been submitted. Please review the request and provide your consent.</p>
    <p>Request ID: ${context.params.requestId}</p>
    <p>Click <a href="${address}?requestId=${context.params.requestId}">here</a> to review the request.</p>
    <p>Thank you.</p>`;


    const mailOptions = {
      from: "\"George\" <george@boomarang.com>",
      to: authoriserEmail,
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
  }

  return null;
});

export const createUserDocument = functions.auth.user().onCreate(async (user) => {
  // create the user document
  const userDoc = admin.firestore().collection("users").doc(user.uid);
  await userDoc.set({
    email: user.email,
    emailVerified: user.emailVerified,
    createdAt: FieldValue.serverTimestamp(),
  });
  console.log("User document created for: ", user.email);

  // send a verification email to the user
  await sendVerificationEmail(user.uid);

  return null;
});

// when a request is updated and the holderEmail field is no longer null or has changed, check to see if the user with that holderEmail already exists. if it does, assign the userId to the holderUserId field in the request
export const assignHolderIdToRequest = functions.firestore.document("requests/{requestId}")
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
          <p>Click <a href="https://boomarang-consent.web.app">here</a> to create an account.</p>
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
    }
    return null;
  });

// when a user is created, check if the user has a request with a holderEmail that matches the user's email. if it does, assign the userId to the holderUserId field in the request
export const assignHolderIdToRequestOnUserCreate = functions.firestore.document("users/{userId}").onWrite(async (change) => {
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

export const sendVerificationEmailCallable = functions.https.onCall(async (data, context) => {
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

export const checkEmailVerificationCode = functions.https.onCall(async (data, context) => {
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
