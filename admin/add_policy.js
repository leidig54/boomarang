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

//upload consent template to firebase storage

const createConsentTemplate = async () => {
    // Create a random version number for the consent template
    const version = Math.floor(Math.random() * 100) + 1; // Adjusted for a broader range

    // Get a random date in the past - assuming this part is completed in your code

    // Convert the consent text to a Blob
    const blob = new Blob([consentText], { type: 'text/plain' });

    // Define a path for the file in Firebase Storage
    const filePath = `consentTemplates/version_${version}.txt`;

    // Upload the file to Firebase Storage
    const fileRef = storage.ref().child(filePath);
    await fileRef.put(blob);

    // Get the URL of the uploaded file
    const fileURL = await fileRef.getDownloadURL();

    // Save the file URL and other metadata to Firestore (or your preferred database)
    const consentTemplateCollection = db.collection('consentTemplates');
    await consentTemplateCollection.add({
        version,
        fileURL,
        // Add other metadata as needed, e.g., creation date
    });

    console.log('Consent template uploaded and metadata saved:', fileURL);
};

createConsentTemplate().catch(console.error);