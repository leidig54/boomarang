
const admin = require('firebase-admin');
process.env.FIREBASE_AUTH_EMULATOR_HOST = "127.0.0.1:9099";

const { faker } = require('@faker-js/faker');

admin.initializeApp();

const db = admin.firestore();
db.settings({
    host: "localhost:8080",
    ssl: false
})

async function createDemoEnvironment()   {

    const auth = admin.auth();
    //clear all users from firebase auth
    // For clearing all users from Firebase Auth
const listUsers = await auth.listUsers();
await Promise.all(listUsers.users.map(user => auth.deleteUser(user.uid)));

// For clearing the users collection
const usersCollection = db.collection('users');
const users = await usersCollection.get();
await Promise.all(users.docs.map(user => usersCollection.doc(user.id).delete()));

// For clearing the requests collection
const requestCollection = db.collection('requests');
const requests = await requestCollection.get();
await Promise.all(requests.docs.map(request => requestCollection.doc(request.id).delete()));

    const requesterId = "1";
    await auth.createUser({
        uid: requesterId,
        email: 'ian@insurance.com',
        password: 'boomarang',
        emailVerified: true,
    }).then((user) => {
        console.log('requester created');
    });
    
    const holderId = "2";
     await auth.createUser({
        uid: holderId,
        email: 'dave@doctors.com',
        password: 'boomarang',
        emailVerified: true,
    }).then((user) => {
        console.log('holder created');
    });

    const holderUser = {
        title: 'Dr',
        email: 'dave@doctors.com',
        firstName: 'Dave',
        lastName: 'Smith',
        userType: 'holder',
        emailVerified: true,
        verificationCodeExpiresAt: null,
        isDemo: true,
    }

    const requesterUser = {
        title: 'Dr',
        email: 'ian@insurance.com',
        firstName: 'Ian',
        lastName: 'Jones',
        userType: 'requester',
        emailVerified: true,
        verificationCodeExpiresAt: null,
        isDemo: true,
    }

    await usersCollection.doc(requesterId).set(requesterUser);
    console.log('Requester document created');
    await usersCollection.doc(holderId).set(holderUser);
    console.log('Holder document created');

    const createRequest = async () => {

        console.log('Creating request');
        const id = faker.string.uuid();

        const requesterOrgs = {
            "private_medical_insurance": [
                'Vitality',
                'BUPA',
                'Aviva',
                'AXA'
            ],
            "dwp_pip": [
                'DWP'
            ],
            "disability_living_allowance": [
                'DWP'
            ],
            "police_report": [
                'Metropolitan Police',
                'City of London Police',
                'British Transport Police'
            ],
            "dwp_uc113": [
                'DWP'
            ],
            "disability_student_allowance": [
                'Student Finance England',
            ]
        }

        //get a random request type from the map 
        const requestType = faker.helpers.arrayElement(Object.keys(requesterOrgs));

        //get a random org from the array of orgs for the request type
        const org = faker.helpers.arrayElement(requesterOrgs[requestType]);

        
        
        const request = {
            id: id,
            subjectFirstName: faker.person.firstName(),
            subjectLastName: faker.person.lastName(),
            subjectEmail: faker.internet.email(),
            subjectEmailVerified: true,
            subjectDOB: faker.date.past(),
            subjectDOBVerified: true,
            requesterUserId: requesterId,
            requesterEmail: requesterUser.email,
            requesterOrgName: org,
            holderUserId: holderId,
            dateCreated: faker.date.recent(
               {
                days: 4,
               }

            ),
            consentVerified: true,
            requestStatus: faker.helpers.arrayElement(['awaiting_response']),
            requestType: requestType,
            requestDetails: null,
            requestFormRef: 'https://firebasestorage.googleapis.com/v0/b/boomarang-ac130.appspot.com/o/demo%2FRequest%20Details.pdf?alt=media&token=67700154-72bf-4e97-b5b1-10891d54b7b2',
            consentFormRef: 'https://firebasestorage.googleapis.com/v0/b/boomarang-ac130.appspot.com/o/demo%2FConsent%20Form.pdf?alt=media&token=655d6b8c-e21c-4dcf-9008-74941eebea71',
            isDemo: true,
         }

        await requestCollection.doc(request.id).set(request);
        console.log('Request created');
    }

    //add 30 requests
    for (let i = 0; i < 30; i++) {
        await createRequest();
    }
     
}

createDemoEnvironment().then(() => {
    console.log('Demo environment created');
    process.exit(0);
}).catch((error) => {
    console.error('Error creating demo environment', error);
    process.exit(1);
});



