const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

function generateIdempotencyKey(userId){
    return `createUserDocument_${userId}`;
}

exports.createUserDocument = functions.auth.user().onCreate(async (user) => {
    const userId = user.uid;
    const email = user.email;

    const idempotencyKey = generateIdempotencyKey(userId);
    const idempotencyRef = admin.firestore().collection('idempotencyKeys').doc(idempotencyKey);
    const userRef = admin.firestore().collection('users').doc(userId);
    const cartRef = userRef.collection('cart').doc();

    return admin.firestore().runTransaction(async (transaction) => {
        const idempotencyDoc = await transaction.get(idempotencyRef);

        if (!idempotencyDoc.exists) {
            transaction.set(userRef, {
                email: email,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            transaction.set(idempotencyRef, {
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        } else {
            console.log('Idempotency key already exists');
        }
    }).catch((error) => {
        console.error('Error creating user doc for uid', userId, error);
        throw new functions.https.HttpsError('internal', 'Unable to create user document');
    });
});