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

const consentForm = {
  id: "general_consent",
  title: "General Data Consent Form",
  content:
    "## General Data Consent Form\n\n" +
    "By providing your consent, you allow us to request and share your data for the purpose outlined in the data request.\n\n" +
    "The data requested may include sensitive information such as:\n\n" +
    "- Medical records\n" +
    "- Financial details\n" +
    "- Employment history\n" +
    "- Other personal data\n\n" +
    "We assure you that your data will be handled securely and in compliance with relevant data protection laws (e.g., GDPR).\n" +
    "You have the right to withdraw your consent at any time.\n\n" +
    "By clicking **Agree**, you confirm that you understand the nature of the request and consent to the transfer of your data.\n",
};

const withUser = true;

async function createDemoEnvironment() {
  const mainUser = {
    id: "1",
    title: "Dr",
    email: "georgeleidig@icloud.com",
    firstName: "George",
    lastName: "Leidig",
    emailVerified: true,
    verificationCodeExpiresAt: null,
    isDemo: true,
    organisationId: "1",
    organisationRole: "admin",
  };

  //a list of 5 more users
  const otherUsers = [];

  //create 5 more using faker
  for (let i = 0; i < 5; i++) {
    const user = {
      id: (i + 2).toString(),
      title: faker.person.prefix(),
      email: faker.internet.email(),
      firstName: faker.person.firstName(),
      lastName: faker.person.lastName(),
      emailVerified: true,
      verificationCodeExpiresAt: null,
      isDemo: true,
      organisationId: "1",
      organisationRole: "member",
    };
    otherUsers.push(user);
  }

  const requestCollection = db.collection("requests");
  // For clearing the requests collection
  const requests = await requestCollection.get();
  await Promise.all(
    requests.docs.map((request) => requestCollection.doc(request.id).delete())
  );

  // For clearing the organisations collection
  const organisationsCollection = db.collection("organisations");
  const organisations = await organisationsCollection.get();
  await Promise.all(
    organisations.docs.map((organisation) =>
      organisationsCollection.doc(organisation.id).delete()
    )
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

    await usersCollection.doc("1").set(mainUser);

    for (let i = 0; i < otherUsers.length; i++) {
      const user = otherUsers[i];
      await auth
        .createUser({
          uid: user.id,
          email: user.email,
          password: "boomarang",
          emailVerified: user.emailVerified,
        })
        .then((user) => {
          console.log("user created");
        });

      await usersCollection.doc(user.id).set(user);
    }
    console.log("Holder document created");
  }

  const organisation = {
    id: "1",
    name: "Rosehill Vet Clinic",
    users: ["1", "2", "3", "4", "5", "6"],
  };

  await organisationsCollection.doc(organisation.id).set(organisation);

  const createRequest = async () => {
    const forms = [
      {
        id: "veterinary_insurance_claim",
        name: "Veterinary Insurance Claim",
        description: "Claim for veterinary insurance.",
        elements: [
          {
            id: "symptom_start_date",
            labelText: "Symptom Start Date",
            type: "date",
            isRequired: true,
          },
          {
            id: "consultation_date",
            labelText: "Treatment Date",
            type: "date",
            isRequired: true,
          },
          {
            id: "new_or_existing_condition",
            labelText: "New or Existing Condition",
            type: "radio",
            isRequired: true,
            options: ["New", "Existing"],
          },
          {
            id: "diagnosis",
            labelText: "Diagnosis",
            type: "text",
            isRequired: true,
          },
          {
            id: "treatment",
            labelText: "Treatment",
            minLines: 2,
            maxLines: 4,
            type: "text",
            isRequired: true,
          },
          {
            id: "cost",
            labelText: "Cost",
            type: "text",
            isRequired: true,
          },
        ],
      },
    ];

    const id = faker.string.uuid();

    const hasVerified = Math.random() < 0.5;

    const request = {
      id: id,
      subjectFirstName: faker.person.firstName(),
      subjectLastName: faker.person.lastName(),
      subjectEmail: faker.internet.email(),
      subjectEmailVerified: hasVerified,
      //over 18
      subjectDOB: faker.date.past(),
      subjectDOBVerified: hasVerified,
      senderUserId: "1",
      senderEmail: mainUser.email,
      senderOrganisationId: "1",
      recipientUserId: "1",
      recipientEmail: mainUser.email,
      recipientOrganisationId: "1",
      dateCreated: faker.date.recent({
        days: 4,
      }),
      consentVerified: hasVerified,
      consentForm: consentForm,
      isDemo: true,
      form: forms[Math.floor(Math.random() * forms.length)],
    };

    await requestCollection.doc(request.id).set(request);
  };

  //add 30 requests
  for (let i = 0; i < 10; i++) {
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
