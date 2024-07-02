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
        id: faker.string.uuid(),
        creatorId: faker.string.uuid(),
        subjectFirstName: faker.person.firstName(),
        subjectLastName: faker.person.lastName(),
        subjectEmail: faker.internet.email(),
        requesterUserId: faker.string.uuid(),
        requesterOrgName: faker.company.name(),
        holderUserId: faker.string.uuid(),
        holderOrgId: faker.string.uuid(),
        dateCreated: faker.date.past(),
        dateUpdated: faker.date.recent(),
        dateSubmitted: faker.date.recent(),
        consentStatus: faker.helpers.arrayElement(['granted', 'denied', 'pending']),
        paymentStatus: faker.helpers.arrayElement(['paid', 'unpaid']),
        requestStatus: faker.helpers.arrayElement(['completed', 'pending', 'cancelled']),
        requestType: faker.helpers.arrayElement(['consent', 'payment', 'other']),
        requestDetails: faker.lorem.sentence(),
        requestFormRef: faker.string.uuid(),
        consentTemplateId: faker.string.uuid(),
        consentFormRef: faker.string.uuid(),
        isSubmitted: faker.helpers.boolean(),
        knowsHolder: faker.helpers.arrayElement(['yes', 'no', 'self']),
        hasConsent: faker.helpers.boolean(),
        
        

    }
    await requestCollection.doc(request.id).set(request);
}



//add 50 requests
for (let i = 0; i < 50; i++) {
    createRequest();
}


 