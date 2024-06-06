import { generate } from "@genkit-ai/ai";
import { configureGenkit } from "@genkit-ai/core";
import { firebase } from "@genkit-ai/firebase";
import { firebaseAuth } from "@genkit-ai/firebase/auth";
import { onFlow } from "@genkit-ai/firebase/functions";
import { geminiPro, googleAI } from "@genkit-ai/googleai";
import * as z from "zod";

configureGenkit({
  plugins: [firebase(), googleAI()],
  logLevel: "debug",
  enableTracingAndMetrics: true,
});

export const writeReportFlow = onFlow(
  {
    name: "writeReportFlow",
    inputSchema: z.string(),
    outputSchema: z.string(),
    authPolicy: firebaseAuth((user) => {
      if (!user) {
        throw new Error("User must be signed in to run flow");
      }
    }),
  },
  async (subject) => {
    const prompt = `You are an medical admin assisstant you need to write a medical report to satisfy
    the following request, given the following information: ${subject}.
     Only use what is containined in the information provided. Do not add any extra findings,
     recommendations or anything else that is not explicitly stated in the information provided.`;
    const llmResponse = await generate({
      model: geminiPro,
      prompt: prompt,
      config: {
        temperature: 1,
      },
    });

    return llmResponse.text();
  }
);

