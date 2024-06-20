const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

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
