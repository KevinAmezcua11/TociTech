const { collection, addDoc, getDocs, deleteDoc, updateDoc, query, where, getDoc, doc, serverTimestamp } = require("firebase/firestore");

const { db } = require('../config/firebase');

const serviceCollection = collection(db, "services");

// Obtener todos los servicios
async function getAllServices() {
    const snapshot = await getDocs(serviceCollection);

    return snapshot.docs.map(d => {
        const service = d.data();

        return {
            id: d.id,
            ...service,
            createdAt: service.createdAt?.toDate(),
            updatedAt: service.updatedAt?.toDate()
        };
    });
}

// Obtener servicio por ID
async function getById(id) {
    const serviceRef = doc(db, "services", id);
    const serviceSnap = await getDoc(serviceRef);

    if (!serviceSnap.exists()) return null;

    const service = serviceSnap.data();

    return {
        id: serviceSnap.id,
        ...service,
        createdAt: service.createdAt?.toDate(),
        updatedAt: service.updatedAt?.toDate()
        };
}

// Buscar servicio por nombre
async function findByName(name) {
    const nameClean = name.trim().toLowerCase();

    const q = query(serviceCollection, where("nameSearch", "==", nameClean));
    const snapshot = await getDocs(q);

    if (snapshot.empty) return null;

    const docData = snapshot.docs[0];
    const data = docData.data();

    return {
        id: docData.id,
        ...data,
        createdAt: data.createdAt?.toDate(),
        updatedAt: data.updatedAt?.toDate()
    };
}

// Crear servicio
async function createService({ name, description, price, duration, state }) {
    try {
        if (!name?.trim() || price == null || price < 0) {
            throw new Error("Invalid data");
        }

        if (!duration?.trim()) {
            throw new Error("Duration is required");
        }

        const nameClean = name.trim().toLowerCase();

        const existing = await findByName(nameClean);
        if (existing) return null;

        const data = {
            name: name.trim(),    
            nameSearch: nameClean,        
            description: description || "",
            price,
            duration: duration.trim().toLowerCase(),
            state: state ?? true,
            createdAt: serverTimestamp()
        };

        Object.keys(data).forEach(key => {
            if (data[key] === undefined) {
                delete data[key];
            }
        });

        const docRef = await addDoc(serviceCollection, data);

        return {
            id: docRef.id,
            ...data
        };

    } catch (err) {
        console.error("Error creating service:", err);
        throw err;
    }
}

// Actualizar servicio
async function updateService(id, data) {
    const existing = await getById(id);
    if (!existing) return null;

    if (data.name) {
        const nameClean = data.name.trim().toLowerCase();

        const existingService = await findByName(nameClean);
        if (existingService && existingService.id !== id) return null;

        data.name = data.name.trim();     
        data.nameSearch = nameClean;   
    }

    if (data.price != null && data.price < 0) {
        throw new Error("Invalid price");
    }

    if (data.duration) {
        data.duration = data.duration.trim().toLowerCase();
    }

    delete data.createdAt;
    delete data.updatedAt;
    delete data.id;

    Object.keys(data).forEach(key => {
        if (data[key] === undefined) {
            delete data[key];
        }
    });

    await updateDoc(doc(db, "services", id), {
        ...data,
        updatedAt: serverTimestamp()
    });

    return getById(id);
}

// Eliminar servicio
async function deleteService(id) {
    const serviceRef = doc(db, "services", id);
    const serviceSnap = await getDoc(serviceRef);

    if (!serviceSnap.exists()) return null;

    await deleteDoc(serviceRef);

    return { id };
}

module.exports = { getAllServices, getById, findByName, createService, updateService, deleteService };