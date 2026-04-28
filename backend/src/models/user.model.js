const { collection, addDoc, getDocs, deleteDoc, updateDoc, query, where, getDoc, doc, serverTimestamp } = require("firebase/firestore");
const { db } = require("../config/firebase");
const bcrypt = require('bcryptjs');

const usersCollection = collection(db, "users");

// Obtener todos los usuarios
async function getAllUsers() {
    const snapshot = await getDocs(usersCollection);

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
    const userRef = doc(db, "users", id);
    const userSnap = await getDoc(userRef);

    if(!userSnap.exists()) return null;

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

    const q = query(usersCollection, where("username", "==", usernameClean));
    const snapshot = await getDocs(q);

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

        const docRef = await addDoc(usersCollection, {
            username: usernameClean,
            password: hashedPass,
            names,
            lastnames,
            email,
            phone,
            role: role || "client",
            createdAt: serverTimestamp()
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

    await updateDoc(doc(db, "users", id), {
        ...data,
        updatedAt: serverTimestamp()
    });

    return getById(id);
}

// Eliminar usuario
async function deleteUser(id) {
    const userRef = doc(db, "users", id);
    const userSnap = await getDoc(userRef);

    if(!userSnap.exists()) return null;

    await deleteDoc(userRef);

    return { id };
}

module.exports = { getAllUsers, getById, findByUsername, createUser, updateUser, deleteUser };