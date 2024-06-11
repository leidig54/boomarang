const admin = require('firebase-admin');
const { faker } = require('@faker-js/faker');

admin.initializeApp();

const db = admin.firestore();
db.settings({
    host: "localhost:8080",
    ssl: false
})

const requestCollection = db.collection('requests');

const createRequest = async () => {
    const request = {
        id: faker.datatype.uuid(),
        authoriserFirstName: faker.name.firstName(),
        authoriserLastName: faker.name.lastName(),
        authoriserEmail: faker.internet.email(),
        authoriserPhoneNumber: faker.phone.number(),
        requesterUserId: faker.datatype.uuid(),
        holderUserId: faker.datatype.uuid(),
        dateCreated: faker.date.recent(),
        dateUpdated: faker.date.recent(),
        consentStatus: faker.helpers.arrayElement(['granted', 'denied']),
        paymentStatus: faker.helpers.arrayElement(['paid', 'unpaid']),
        requestStatus: faker.helpers.arrayElement(['pending', 'completed'])
    }
    await requestCollection.doc(request.id).set(request);
}



//add 50 requests
for (let i = 0; i < 50; i++) {
    createRequest();
}




//request models (in Dart) 
    // String id;
    // String authoriserFirstName;
    // String authoriserLastName;
    // String authoriserEmail;
    // String authoriserPhoneNumber;
    // String requesterUserId;
    // String holderUserId;
    // DateTime dateCreated;
    // DateTime dateUpdated;
    // String consentStatus;
    // String paymentStatus;
    // String requestStatus;