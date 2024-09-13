const admin = require("firebase-admin");
process.env.FIREBASE_AUTH_EMULATOR_HOST = "127.0.0.1:9099";
const serviceAccount = require("./key.json");
const { faker } = require("@faker-js/faker");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
db.settings({
  host: "localhost:8080",
  ssl: false,
});

const b2bForms = [
  // 1. Employee Background Check Details
  {
    id: "employee_background_check_request",
    name: "Employee Background Check Details",
    description: "Details regarding the background check of the employee.",
    elements: [
      {
        id: "criminal_record_check",
        labelText: "Has the employee passed the criminal record check?",
        type: "radio",
        options: ["Yes", "No"],
        isRequired: true,
      },
      {
        id: "employment_history",
        labelText: "Was the employee's employment history verified?",
        type: "radio",
        options: ["Yes", "No"],
        isRequired: true,
      },
      {
        id: "employment_history_details",
        labelText: "If yes, provide employment history details",
        helperText: "Include company names, positions, and dates of employment",
        type: "text",
        isRequired: false,
      },
      {
        id: "additional_comments",
        labelText: "Additional Comments",
        helperText: "Provide any additional details or comments",
        type: "text",
        isRequired: false,
      },
    ],
  },

  // 2. Medical Records for Insurance Claim
  {
    id: "medical_records_insurance_claim_request",
    name: "Medical Records for Insurance Claim",
    description:
      "Request for medical records related to the treatment of the patient for the purpose of an insurance claim.",
    elements: [
      {
        id: "diagnosis_details",
        labelText: "Diagnosis Details",
        helperText:
          "Please provide the diagnosis and relevant medical history.",
        type: "text",
        isRequired: true,
      },
      {
        id: "treatment_administered",
        labelText: "Treatment Administered",
        helperText: "Describe the treatment given during the consultation.",
        type: "text",
        isRequired: true,
      },
      {
        id: "follow_up_required",
        labelText: "Is follow-up treatment required?",
        type: "radio",
        options: ["Yes", "No"],
        isRequired: true,
      },
      {
        id: "additional_medical_information",
        labelText: "Additional Medical Information",
        helperText:
          "Provide any other relevant medical information or details.",
        type: "text",
        isRequired: false,
      },
    ],
  },

  // 3. Academic Transcript
  {
    id: "academic_transcript_request",
    name: "Academic Transcript",
    description: "Request for academic transcript details for the student.",
    elements: [
      {
        id: "degree_awarded",
        labelText: "Was the student awarded a degree?",
        type: "radio",
        options: ["Yes", "No"],
        isRequired: true,
      },
      {
        id: "degree_details",
        labelText: "If yes, provide the degree details",
        helperText: "Include the degree name, major, and graduation date.",
        type: "text",
        isRequired: false,
      },
      {
        id: "academic_performance",
        labelText: "Provide academic performance details",
        helperText:
          "Include GPA, honors, or any other relevant academic performance metrics.",
        type: "text",
        isRequired: true,
      },
      {
        id: "additional_academic_info",
        labelText: "Additional Academic Information",
        helperText:
          "Provide any additional information about the student's academic history.",
        type: "text",
        isRequired: false,
      },
    ],
  },

  // 4. Rental Payment History
  {
    id: "rental_payment_history_request",
    name: "Rental Payment History",
    description:
      "Request for rental payment history for the tenant during their tenancy with the previous landlord.",
    elements: [
      {
        id: "rent_paid_on_time",
        labelText: "Did the tenant consistently pay rent on time?",
        type: "radio",
        options: ["Yes", "No"],
        isRequired: true,
      },
      {
        id: "late_payment_count",
        labelText: "If no, how many times was rent paid late?",
        type: "text",
        isRequired: false,
      },
      {
        id: "damage_to_property",
        labelText: "Was there any damage to the property caused by the tenant?",
        type: "radio",
        options: ["Yes", "No"],
        isRequired: true,
      },
      {
        id: "deposit_withheld",
        labelText: "Was any part of the deposit withheld?",
        type: "radio",
        options: ["Yes", "No"],
        isRequired: true,
      },
      {
        id: "deposit_withheld_reason",
        labelText: "If yes, provide the reason for withholding the deposit",
        type: "text",
        isRequired: false,
      },
    ],
  },

  // 5. Client Financial Records
  {
    id: "client_financial_records_request",
    name: "Client Financial Records",
    description: "Request for financial records necessary for securing a loan.",
    elements: [
      {
        id: "balance_sheet",
        labelText: "Please provide the client's most recent balance sheet",
        helperText:
          "Attach or describe the latest balance sheet including assets and liabilities.",
        type: "text",
        isRequired: true,
      },
      {
        id: "profit_loss_statement",
        labelText:
          "Please provide the client's most recent profit and loss statement",
        helperText: "Attach or describe the profit and loss statement.",
        type: "text",
        isRequired: true,
      },
      {
        id: "cash_flow_statement",
        labelText:
          "Please provide the client's most recent cash flow statement",
        helperText: "Attach or describe the cash flow statement.",
        type: "text",
        isRequired: true,
      },
      {
        id: "additional_financial_info",
        labelText: "Additional Financial Information",
        helperText:
          "Provide any other relevant financial information regarding the client.",
        type: "text",
        isRequired: false,
      },
    ],
  },
];

const withUser = true;

async function createDemoEnvironment() {
  const user = {
    title: "Dr",
    email: "georgeleidig@icloud.com",
    firstName: "George",
    lastName: "Leidig",
    emailVerified: true,
    verificationCodeExpiresAt: null,
    isDemo: true,
  };

  const requestCollection = db.collection("requests");
  // For clearing the requests collection
  const requests = await requestCollection.get();
  await Promise.all(
    requests.docs.map((request) => requestCollection.doc(request.id).delete())
  );

  if (withUser) {
    const auth = admin.auth();
    //clear all users from firebase auth
    // For clearing all users from Firebase Auth
    const listUsers = await auth.listUsers();
    await Promise.all(listUsers.users.map((user) => auth.deleteUser(user.uid)));

    // For clearing the users collection
    const usersCollection = db.collection("users");
    const users = await usersCollection.get();
    await Promise.all(
      users.docs.map((user) => usersCollection.doc(user.id).delete())
    );

    await auth
      .createUser({
        uid: "1",
        email: "georgeleidig@icloud.com",
        password: "boomarang",
        emailVerified: true,
      })
      .then((user) => {
        console.log("requester created");
      });

    const user = {
      title: "Dr",
      email: "georgeleidig@icloud.com",
      firstName: "George",
      lastName: "Leidig",
      emailVerified: true,
      verificationCodeExpiresAt: null,
      isDemo: true,
    };

    await usersCollection.doc("1").set(user);
    console.log("Holder document created");
  }

  const createRequest = async () => {
    const id = faker.string.uuid();

    const request = {
      id: id,
      subjectFirstName: faker.person.firstName(),
      subjectLastName: faker.person.lastName(),
      subjectEmail: faker.internet.email(),
      subjectEmailVerified: true,
      subjectDOB: faker.date.past().getTime(),
      subjectDOBVerified: true,
      senderUserId: "1",
      senderEmail: user.email,
      recipientUserId: "1",
      recipientEmail: user.email,
      dateCreated: faker.date
        .recent({
          days: 4,
        })
        .getTime(),
      consentVerified: Math.random() < 0.5,
      isDemo: true,
      form: b2bForms[Math.floor(Math.random() * b2bForms.length)],
    };

    await requestCollection.doc(request.id).set(request);
  };

  //add 30 requests
  for (let i = 0; i < 90; i++) {
    await createRequest();
  }
}

createDemoEnvironment()
  .then(() => {
    console.log("Demo environment created");
    process.exit(0);
  })
  .catch((error) => {
    console.error("Error creating demo environment", error);
    process.exit(1);
  });
