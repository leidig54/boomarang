
const admin = require('firebase-admin');
process.env.FIREBASE_AUTH_EMULATOR_HOST = "127.0.0.1:9099";

const { faker } = require('@faker-js/faker');

admin.initializeApp();

const db = admin.firestore();
db.settings({
    host: "localhost:8080",
    ssl: false
})

// create 2 users, a holder and a requester, in firebase auth 
//email holder = ian@insurance.com, password = boomarang
//email requester = dave@doctors.com, password = boomarang

async function createDemoEnvironment()   {

    const auth = admin.auth();
    //clear all users
    const listUsers = await auth.listUsers();
    listUsers.users.forEach(async (user) => {
        await auth.deleteUser(user.uid);
    });

    //clear the users collection
    const usersCollection = db.collection('users');
    const users = await usersCollection.get();
    users.forEach(async (user) => {
        await usersCollection.doc(user.id).delete();
    });

    //clear the requests collection
    const requestCollection = db.collection('requests');
    const requests = await requestCollection.get();
    requests.forEach(async (request) => {
        await requestCollection.doc(request.id).delete();
    });

    const requesterId = faker.string.uuid();
    const requester = await auth.createUser({
        uid: requesterId,
        email: 'ian@insurance.com',
        password: 'boomarang'
    }).then((user) => {
        console.log('holder created');
    });
    
    const holderId = faker.string.uuid();
    const holder = await auth.createUser({
        uid: holderId,
        email: 'dave@doctors.com',
        password: 'boomarang'
    }).then((user) => {
        console.log('requester created');
    });

    const holderUser = {
        title: 'Dr',
        email: 'ian@insurance.com',
        firstName: 'Ian',
        lastName: 'Smith',
        userType: 'holder',
        emailVerified: true,
        verificationCodeExpiresAt: null,
    }

    const requesterUser = {
        title: 'Dr',
        email: 'dave@doctors.com',
        firstName: 'Dave',
        lastName: 'Jones',
        userType: 'requester',
        emailVerified: true,
        verificationCodeExpiresAt: null,
    }

    await usersCollection.doc(requesterId).set(requesterUser);
    await usersCollection.doc(holderId).set(holderUser);

    const createRequest = async () => {

        const id = faker.string.uuid();
        const request = {
            id: id,
            subjectFirstName: faker.person.firstName(),
            subjectLastName: faker.person.lastName(),
            subjectEmail: faker.internet.email(),
            subjectEmailVerified: true,
            subjectDOB: faker.date.past(),
            subjectDOBVerified: true,
            requesterUserId: requesterId,
            holderUserId: holderId,
            dateCreated: faker.date.recent(),
            consentVerified: false,
            requestStatus: faker.helpers.arrayElement(['awaiting_response']),
            requestType: faker.helpers.arrayElement(['Private Medical Insurance']),
            requestDetails: null,
            requestFormRef: 'https://firebasestorage.googleapis.com/v0/b/boomarang-ac130.appspot.com/o/demo%2FRequest%20Details.pdf?alt=media&token=67700154-72bf-4e97-b5b1-10891d54b7b2',
            consentFormRef: 'https://firebasestorage.googleapis.com/v0/b/boomarang-ac130.appspot.com/o/demo%2FConsent%20Form.pdf?alt=media&token=655d6b8c-e21c-4dcf-9008-74941eebea71',
         }
        await requestCollection.doc(request.id).set(request);
    }

    //add 50 requests
    for (let i = 0; i < 50; i++) {
        createRequest();
    }   
}

createDemoEnvironment().then(() => {
    console.log('Demo environment created');
    process.exit(0);
}).catch((error) => {
    console.error('Error creating demo environment', error);
    process.exit(1);
});



