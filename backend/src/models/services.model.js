const admin = require("firebase-admin");
const db = require("../config/firebase");

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

// Convierte documentos legacy (state) al formato actual (active)
function formatDoc(id, data) {
    let active = data.active;

    if (active == null && data.state != null) {
        active = data.state === true || data.state === "active";
    }

    const { state, ...rest } = data;

    return {
        id,
        ...rest,
        active: active ?? true,
        createdAt: data.createdAt?.toDate(),
        updatedAt: data.updatedAt?.toDate()
    };
}

// Obtener todos los servicios
async function getAllServices() {
    const snapshot = await db.collection("services").get();

    return snapshot.docs.map(d => formatDoc(d.id, d.data()));
}

// Obtener servicio por ID
async function getById(id) {
    const serviceRef = db.collection("services").doc(id);
    const serviceSnap = await serviceRef.get();

    if (!serviceSnap.exists) return null;

    return formatDoc(serviceSnap.id, serviceSnap.data());
}

// Buscar servicio por nombre
async function findByName(name) {
    const nameClean = name.trim().toLowerCase();

    const snapshot = await db
        .collection("services")
        .where("nameSearch", "==", nameClean)
        .get();

    if (snapshot.empty) return null;

    const docData = snapshot.docs[0];

    return formatDoc(docData.id, docData.data());
}

// Crear servicio
async function createService(rawData) {
    try {
        const input = normalizeServiceData(rawData);

        const name = validateRequiredText(input.name, "Name is required");
        const duration = validateRequiredText(input.duration, "Duration is required");
        const price = validatePrice(input.price);

        const nameClean = name.toLowerCase();

        const existing = await findByName(nameClean);
        if (existing) return null;

        const data = {
            name,
            nameSearch: nameClean,
            description: input.description || "",
            price,
            duration: duration.toLowerCase(),
            image: input.image?.trim() || "",
            active: input.active ?? true,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        };

        const docRef = await db
            .collection("services")
            .add(data);

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
async function updateService(id, rawData) {
    const existing = await getById(id);
    if (!existing) return null;

    const data = normalizeServiceData(rawData);

    if (data.name) {
        const nameClean = data.name.trim().toLowerCase();

        const existingService = await findByName(nameClean);
        if (existingService && existingService.id !== id) return null;

        data.name = data.name.trim();
        data.nameSearch = nameClean;
    }

    if (data.price != null) {
        data.price = validatePrice(data.price);
    }

    if (data.duration) {
        data.duration = validateRequiredText(data.duration, "Duration is required").toLowerCase();
    }

    delete data.createdAt;
    delete data.updatedAt;
    delete data.id;

    Object.keys(data).forEach(key => {
        if (data[key] === undefined) {
            delete data[key];
        }
    });

    if ("active" in data) {
        data.active = data.active === true || data.active === "active";
    }

    const serviceRef = db
        .collection("services")
        .doc(id);

    await serviceRef.update({
        ...data,
        // Eliminar campo legacy "state" si existía en documentos viejos
        state: admin.firestore.FieldValue.delete(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return getById(id);
}

// Eliminar servicio
async function deleteService(id) {
    const serviceRef = db.collection("services").doc(id);
    const serviceSnap = await serviceRef.get();

    if (!serviceSnap.exists) return null;

    await serviceRef.delete();

    return { id };
}

module.exports = { getAllServices, getById, findByName, createService, updateService, deleteService };
