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

async function createDemoEnvironment() {
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

  // For clearing the requests collection
  const requestCollection = db.collection("requests");
  const requests = await requestCollection.get();
  await Promise.all(
    requests.docs.map((request) => requestCollection.doc(request.id).delete())
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

  const createRequest = async () => {
    const id = faker.string.uuid();

    const requesterOrgs = {
      "private_medical_insurance": ["Vitality", "BUPA", "Aviva", "AXA"],
      "dwp_pip": ["DWP"],
      "disability_living_allowance": ["DWP"],
      "police_report": [
        "Metropolitan Police",
        "City of London Police",
        "British Transport Police",
      ],
      "dwp_uc113": ["DWP"],
      "disability_student_allowance": ["Student Finance England"],
      "subject_access_request": ["self"],
      "other": ["self"],
    };

    //get a random request type from the map
    const requestType = faker.helpers.arrayElement(Object.keys(requesterOrgs));

    //for 10% of requests, set the status to rejected. for the others, set to awaiting_response
    const requestStatus =
      Math.random() < 0.1 ? "rejected" : "awaiting_response";

    let requestDetails = faker.lorem.sentences(
      Math.floor(Math.random() * 4) + 4
    );

    const request = {
      id: id,
      subjectFirstName: faker.person.firstName(),
      subjectLastName: faker.person.lastName(),
      subjectEmail: faker.internet.email(),
      subjectEmailVerified: true,
      subjectDOB: faker.date.past(),
      subjectDOBVerified: true,
      senderUserId: "1",
      senderEmail: user.email,
      recipientUserId: "1",
      recipientEmail: user.email,
      dateCreated: faker.date.recent({
        days: 4,
      }),
      consentVerified: Math.random() < 0.5,
      requestStatus: requestStatus,
      requestType: requestType,
      requestDetails: requestDetails,
      isDemo: true,
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
