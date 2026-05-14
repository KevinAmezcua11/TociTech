const admin = require("firebase-admin");
const db = require("../config/firebase");
const bcrypt = require("bcryptjs");
const crypto = require("crypto");

const COLLECTION = "password_resets";
const EXPIRY_MINUTES = 15;

async function createResetToken(userId) {
    // Elimina cualquier token previo del usuario
    await deleteByUserId(userId);

    const code = String(Math.floor(100000 + Math.random() * 900000));
    const hashedCode = await bcrypt.hash(code, 10);
    const expiresAt = new Date(Date.now() + EXPIRY_MINUTES * 60 * 1000);

    await db.collection(COLLECTION).add({
        userId,
        hashedCode,
        expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
        createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return code;
}

async function findByUserId(userId) {
    const snapshot = await db
        .collection(COLLECTION)
        .where("userId", "==", userId)
        .limit(1)
        .get();

    if (snapshot.empty) return null;

    const doc = snapshot.docs[0];
    const data = doc.data();

    return {
        id: doc.id,
        userId: data.userId,
        hashedCode: data.hashedCode,
        expiresAt: data.expiresAt?.toDate()
    };
}

async function verifyCode(userId, code) {
    const record = await findByUserId(userId);
    if (!record) return false;

    if (record.expiresAt < new Date()) return false;

    return bcrypt.compare(code, record.hashedCode);
}

async function deleteByUserId(userId) {
    const snapshot = await db
        .collection(COLLECTION)
        .where("userId", "==", userId)
        .get();

    const batch = db.batch();
    snapshot.docs.forEach(doc => batch.delete(doc.ref));
    await batch.commit();
}

module.exports = { createResetToken, verifyCode, deleteByUserId };
