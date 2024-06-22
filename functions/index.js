const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch'); 

const importDynamic = (modulePath) => import(modulePath);

let gradioLoaded = false;

// importDynamic('@gradio/client').then((module) => {
//   const { client } = module;
//   gradioLoaded = true;
// }).catch(error => {
//   console.error('Failed to load module:', error);
//   gradioLoaded = false;
// });

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

function generateIdempotencyKey(userId) {
    return `createUserDocument_${userId}`;
}

exports.createUserDocument = functions.auth.user().onCreate(async (user) => {
    const userId = user.uid;
    const email = user.email;

    const displayName = user.displayName || (user.customClaims && user.customClaims.name) || '';

    const idempotencyKey = generateIdempotencyKey(userId);
    const idempotencyRef = admin.firestore().collection('idempotencyKeys').doc(idempotencyKey);
    const userRef = admin.firestore().collection('users').doc(userId);

    try {
        await admin.firestore().runTransaction(async (transaction) => {
            const idempotencyDoc = await transaction.get(idempotencyRef);
            if (!idempotencyDoc.exists){
                console.log(`Creating user document for uid: ${userId}`);
                transaction.set(userRef, {
                    name: displayName,
                    email: email,
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                });

                const cartRef = userRef.collection('cart').doc('defaultCart');
                transaction.set(cartRef, {});

                transaction.set(idempotencyRef, {
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                });
                
                console.log(`Idempotency key set for uid: ${userId}`);
            } else {
                console.log(`Idempotency key already exists for uid: ${userId}`);
            }
        });
    } catch (error){
        console.error('Error creating user document for uid:', userId, error);
        throw new functions.https.HttpsError('internal', 'Unable to create user document');
    }
});

app.get('/add', (req, res) => {
    const a = parseInt(req.query.a);
    const b = parseInt(req.query.b);

    if (isNaN(a) || isNaN(b)) {
        return res.status(400).send('Invalid input');
    }

    const c = a + b;
    res.send({ result: "gradioLoaded " + (gradioLoaded ? "Yay" : "Nay") + c});
});

app.get('/api/virtual-tryon', async (req, res) => {
    const { backgroundUrl, garmentUrl } = req.query;

    // Fetching the garment image as a blob
    const garmentResponse = await fetch(garmentUrl);
    const garmentBlob = await garmentResponse.blob();

    const backgroundResponse = await fetch(backgroundUrl);
    const backgroundBlob = await backgroundResponse.blob();

    // Initialize the Gradio client
    const { client } = await import('@gradio/client');
    const gradioApp = await client("yisol/IDM-VTON");

    // Predict using the Gradio model
    try{
        const result = await gradioApp.predict("/tryon", [
            {"background": backgroundBlob, "layers":[], "composite": null},
            garmentBlob,
            "wear", true, true, 20, 20
        ]);
        res.status(200).json({ result: result.data });
    }
    catch(e){
        res.status(500).send({ result: e });
    }
});

// Export the API to Firebase Cloud Functions
exports.api = functions.https.onRequest(app);
