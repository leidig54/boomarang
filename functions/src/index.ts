import { generate } from "@genkit-ai/ai";
import { configureGenkit } from "@genkit-ai/core";
import { firebase } from "@genkit-ai/firebase";
import { firebaseAuth } from "@genkit-ai/firebase/auth";
import { onFlow } from "@genkit-ai/firebase/functions";
import { gemini15ProPreview, vertexAI } from "@genkit-ai/vertexai";
import * as z from "zod";
import serviceAccount from "./serviceKey.json";
import admin = require("firebase-admin");


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


