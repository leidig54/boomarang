const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();
db.settings({
    host: "localhost:8080",
    ssl: false
})



const consentText = `
**Consent to Data Processing and Sharing**

By using the Boomerang platform, you acknowledge and consent to the collection, storage, processing, and sharing of your medical data. This includes sensitive and personally identifiable information ("Personal Data") that is essential for the services we provide.

**Collection and Use of Data:** We retrieve your medical data directly from healthcare providers with your prior consent and use this data to facilitate services tailored to your specific needs.

**Storage and Security:** Your data is securely stored on our servers and is protected using industry-standard security measures to prevent unauthorized access, disclosure, or misuse.

**Processing:** We utilize advanced processing techniques, including Google AI, to analyze your data. This processing is crucial for delivering personalized insights and recommendations based on your medical information.

**Data Sharing:** As part of our processing, your data is shared with Google AI. We ensure that all data shared is handled in strict accordance with our privacy policy and relevant data protection legislation, maintaining the highest levels of confidentiality and integrity.

**Your Rights:** You have the right to access, correct, or delete your Personal Data at any time. Please contact our support team should you wish to exercise these rights.

**Consent Withdrawal:** You may withdraw your consent at any time by contacting us. Upon withdrawal, we will cease processing your data and will delete it unless required to retain it by law.

By clicking "I Agree," you confirm that you have read, understood, and agreed to these terms. You also affirm that you are consenting freely and without any duress or undue influence.
`;

//upload consent template to firestore

const consentTemplateCollection = db.collection('consentTemplates');

const createConsentTemplate = async () => {

    //create a random version number for the consent template
    const version = Math.floor(Math.random() * 10) + 1;

    //get a random date in the past
    const date = new Date();
    date.setDate(date.getDate() - Math.floor(Math.random() * 365));


    const consentTemplate = {
        version: version,
        text: consentText,
        createdAt: date,
    }

    await consentTemplateCollection.doc(version.toString()).set(consentTemplate);
}

//add 10 consent templates
for (let i = 0; i < 10; i++) {
    createConsentTemplate();
}

//