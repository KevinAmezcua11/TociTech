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

// Obtener servicios por id
async function getById(id) {
    const serviceRef = doc(db, "services", id);
    const serviceSnap = await getDoc(serviceRef);

    if(!serviceSnap.exists()) return null;

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

    const q = query(serviceCollection, where("nameKey", "==", nameClean));
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

function normalizeServiceData(data) {
    const normalized = { ...data };

    if (normalized.duration == null && normalized.days != null) {
        normalized.duration = `${normalized.days} dias`;
    }

    if (normalized.active == null && normalized.state != null) {
        normalized.active = normalized.state === true || normalized.state === "active";
    }

    delete normalized.days;
    delete normalized.state;

    return normalized;
}

function validateRequiredText(value, message) {
    if (typeof value !== "string" || !value.trim()) {
        throw new Error(message);
    }

    return value.trim();
}

function validatePrice(value) {
    if (value === "" || value == null) {
        throw new Error("Invalid price");
    }

    const price = Number(value);

    if (price < 0 || Number.isNaN(price)) {
        throw new Error("Invalid price");
    }

    return price;
}

// Insertar nuevo servicio
async function createService(data) {
    try {
        const service = normalizeServiceData(data);
        const nameClean = validateRequiredText(service.name, "Invalid name");
        const description = validateRequiredText(service.description, "Invalid description");
        const duration = validateRequiredText(service.duration, "Invalid duration");
        const price = validatePrice(service.price);

        const nameKey = nameClean.toLowerCase();

        const existing = await findByName(nameKey);
        if(existing) throw new Error("Service already exists");

        const docRef = await addDoc(serviceCollection, {
            name: nameClean,
            nameKey,
            description,
            price,
            duration,
            active: service.active !== false,
            createdAt: serverTimestamp(),
            updatedAt: serverTimestamp()
        });

        return getById(docRef.id);
    } catch(err) {
        console.error("Error creating service:", err);
        throw err;
    }
}

// Actualizar servicio
async function updateService(id, data) {
    const existing = await getById(id);
    if (!existing) return null;

    const service = normalizeServiceData(data);

    if (service.name != null) {
        service.name = validateRequiredText(service.name, "Invalid name");
        service.nameKey = service.name.toLowerCase();

        const existingService = await findByName(service.nameKey);
        if (existingService && existingService.id !== id) {
            throw new Error("Service already exists");
        }
    }

    if (service.price != null) {
        service.price = validatePrice(service.price);
    }

    if (service.description != null) {
        service.description = validateRequiredText(service.description, "Invalid description");
    }

    if (service.duration != null) {
        service.duration = validateRequiredText(service.duration, "Invalid duration");
    }

    delete service.createdAt;
    delete service.updatedAt;
    delete service.id;

    await updateDoc(doc(db, "services", id), {
        ...service,
        updatedAt: serverTimestamp()
    });

    return getById(id);
}

// Eliminar servicio
async function deleteService(id) {
    const serviceRef = doc(db, "services", id);
    const serviceSnap = await getDoc(serviceRef);

    if(!serviceSnap.exists()) return null;

    await deleteDoc(serviceRef);

    return { id }
}

module.exports = { getAllServices, getById, findByName, createService, updateService, deleteService };

