
const admin = require('firebase-admin');
process.env.FIREBASE_AUTH_EMULATOR_HOST = "127.0.0.1:9099";
const serviceAccount = require ('./key.json');
const { faker } = require('@faker-js/faker');

admin.initializeApp(
    {
        credential:  admin.credential.cert(serviceAccount),
    }
);

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
        email: 'ed@doctors.com',
        password: 'boomarang',
        emailVerified: true,
    }).then((user) => {
        console.log('holder created');
    });

    const holderUser = {
        title: 'Dr',
        email: 'ed@doctors.com',
        firstName: 'Ed',
        lastName: 'Farrar',
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
            ],
            "subject_access_request":
            [
                'self',
            ],
            "other": [
                'self',
            ],
        }

        const requesterFees = {
            "private_medical_insurance": 90.0,
            "dwp_pip": 0.0,
            "disability_living_allowance": 0.0,
            "police_report": 60.0,
            "dwp_uc113": 0.0,
            "disability_student_allowance": 0.0,
            "subject_access_request": 0.0,
            "other": 120.0,
        }

        //get a random request type from the map 
        const requestType = faker.helpers.arrayElement(Object.keys(requesterOrgs));

        //get a random org from the array of orgs for the request type
        const org = faker.helpers.arrayElement(requesterOrgs[requestType]);

        //get the fee for the request type
        const fee = requesterFees[requestType];

        //feePaid is null for requests that cost 0, otherwise is a 50/50 chance of being true or false
        if (fee === 0) {
            feePaid = null;
        }
        else {
            //dont use faker here as we want a 50/50 chance
            feePaid =  Math.random() < 0.5;
        }

        const potentialPayers = [
            'requester',
            'subject',
        ]

        //for 10% of requests, set the status to rejected. for the others, set to awaiting_response
        const requestStatus = Math.random() < 0.1 ? 'rejected' : 'awaiting_response';




        
        
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
            requestStatus: requestStatus,
            requestType: requestType,
            requestDetails: null,
            requestFormRef: 'https://firebasestorage.googleapis.com/v0/b/boomarang-ac130.appspot.com/o/demo%2FRequest%20Details.pdf?alt=media&token=67700154-72bf-4e97-b5b1-10891d54b7b2',
            consentFormRef: 'https://firebasestorage.googleapis.com/v0/b/boomarang-ac130.appspot.com/o/demo%2FConsent%20Form.pdf?alt=media&token=655d6b8c-e21c-4dcf-9008-74941eebea71',
            isDemo: true,
            fee: fee,
            feePaid: feePaid,
            paymentDate: feePaid ? faker.date.recent() : null,
            payer: fee != 0 ? faker.helpers.arrayElement(potentialPayers) : null,
         }

        await requestCollection.doc(request.id).set(request);
        console.log('Request created');
    }

    //add 30 requests
    for (let i = 0; i < 90; i++) {
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



