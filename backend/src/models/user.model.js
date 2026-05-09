const admin = require("firebase-admin");
const db = require("../config/firebase");

const bcrypt = require('bcryptjs');

// Obtener todos los usuarios
async function getAllUsers() {
    const snapshot = await db
        .collection("users")
        .get();

    return snapshot.docs.map(d => {
        const { password, ...userData } = d.data();

        return {
            id: d.id,
            ...userData,
            createdAt: userData.createdAt?.toDate(),
            updatedAt: userData.updatedAt?.toDate()
        };
    });
}

// Obtener usuario por ID
async function getById(id) {
    const userRef = db.collection("users").doc(id);
    const userSnap = await userRef.get();

    if (!userSnap.exists) return null;

    const { password, ...userData } = userSnap.data();

    return {
        id: userSnap.id,
        ...userData,
        createdAt: userData.createdAt?.toDate(),
        updatedAt: userData.updatedAt?.toDate()
    };
}

// Buscar usuario por username
async function findByUsername(username) {
    const usernameClean = username.trim().toLowerCase();

    const snapshot = await db
        .collection("users")
        .where("username", "==", usernameClean)
        .get();

    if(snapshot.empty) return null;

    const docData = snapshot.docs[0];
    const data = docData.data();

    return {
        id: docData.id,
        ...data,
        createdAt: data.createdAt?.toDate(),
        updatedAt: data.updatedAt?.toDate()
    };
}

// Crear usuario
async function createUser({ username, password, names, lastnames, email, phone, role }) {
    try {
        if(!username?.trim() || !password?.trim()) throw new Error("Invalid data");

        if (!email?.trim()) throw new Error("Email required");

        if (!phone?.trim()) throw new Error("Phone required");

        if (!names?.trim() || !lastnames?.trim()) throw new Error("Names required");

        const usernameClean = username.trim().toLowerCase();

        const existing = await findByUsername(usernameClean);
        if(existing) return null;

        const hashedPass = await bcrypt.hash(password, 10);

        const docRef = await db
            .collection("users")
            .add({
                username: usernameClean,
                password: hashedPass,
                names,
                lastnames,
                email,
                phone,
                role: role || "client",
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                updatedAt: admin.firestore.FieldValue.serverTimestamp()
            });

        return { id: docRef.id, username: usernameClean, names, lastnames, email, phone, role: role || "client" };

    } catch (err) {
        console.error("Error creating user:", err);
        throw err;
    }
}

// Actualizar usuario
async function updateUser(id, data) {
    const user = await getById(id);
    if(!user) return null;

    if(data.username) {
        data.username = data.username.trim().toLowerCase();

        const existingUser = await findByUsername(data.username);
        if (existingUser && existingUser.id !== id) return null;
    }

    if(data.password) data.password = await bcrypt.hash(data.password, 10);

    delete data.createdAt;
    delete data.updatedAt;
    delete data.id;
    delete data.role;

    const userRef = db
        .collection("users")
        .doc(id);

    await userRef.update({
        ...data,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return getById(id);
}

// Eliminar usuario
async function deleteUser(id) {
    const userRef = db.collection("users").doc(id);
    const userSnap = await userRef.get();

    if (!userSnap.exists) return null;

    await userRef.delete();

    return { id };
}

module.exports = { getAllUsers, getById, findByUsername, createUser, updateUser, deleteUser };