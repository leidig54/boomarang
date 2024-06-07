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


export const extractQuillDeltaFromFile = onFlow(
  {
    name: "extractQuillDeltaFromFile",
    inputSchema: z.object({
      fileId: z.string(),
      userId: z.string(),
    }),
    outputSchema: z.string(),
    authPolicy: firebaseAuth((user) => {
      if (user.uid === null) {
        throw new Error("Verified email required to run flow");
      }
    }),
  },
  async (subject) => {
    console.log(subject);
    const fileId = subject.fileId;
    const userId = subject.userId;

    // get file url from storage. the ref is the user id and the file id separated by a slash
    const bucket = admin.storage().bucket();
    const fileRef = bucket.file(`${userId}/${fileId}`);

    // get signed url
    const [signedUrl] = await fileRef.getSignedUrl({
      action: "read",
      expires: Date.now() + 1000 * 60 * 5,
    });

    console.log(signedUrl);

    // get file content type
    const [metadata] = await fileRef.getMetadata();
    const fileContentType = metadata.contentType;


    const result = await generate({
      model: gemini15ProPreview,
      prompt: [
        // eslint-disable-next-line max-len
        { text: "Extract the text from this pdf and give it to me in a quill delta format (json)for use in my app. Do not include ```json etc, its gets plugged straight into a jsonDecoder: No need for the ops stuff either. Always end in a newline. Add some heading formatting etc so it looks nice." },
        { media: { url: signedUrl, contentType: fileContentType } },
      ],
      config: {
        temperature: 0.5,
      },
    });

    console.log(result.text());

    return result.text();
  }
);

