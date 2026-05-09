import { collection, onSnapshot } from "firebase/firestore";
import api from "./api";
import { db, isFirebaseConfigured } from "../config/firebase";

const servicesCollectionName = "services";

const normalizeFirebaseDate = (value) => {
    if (!value) return value;
    if (typeof value.toDate === "function") return value.toDate();

    return value;
};

const normalizeServiceDoc = (documentSnapshot) => {
    const data = documentSnapshot.data();

    return {
        id: documentSnapshot.id,
        ...data,
        createdAt: normalizeFirebaseDate(data.createdAt),
        updatedAt: normalizeFirebaseDate(data.updatedAt),
    };
};

export const subscribeToServices = ({ onData, onError }) => {
    if (!isFirebaseConfigured || !db) {
        throw new Error(
            "Firebase no esta configurado en el web admin. Revisa las variables VITE_FIREBASE_*."
        );
    }

    return onSnapshot(
        collection(db, servicesCollectionName),
        (snapshot) => {
            const services = snapshot.docs
                .map(normalizeServiceDoc)
                .sort((a, b) => (a.name || "").localeCompare(b.name || "", "es-MX"));

            onData(services);
        },
        onError
    );
};

export const getServices = async () => {
    const res = await api.get("/services");
    return res.data;
};

export const getServiceById = async (id) => {
    const res = await api.get(`/services/${id}`);
    return res.data;
};

export const createService = async (data) => {
    const res = await api.post("/services", data);
    return res.data;
};

export const updateService = async (id, data) => {
    const res = await api.put(`/services/${id}`, data);
    return res.data;
};

export const deleteService = async (id) => {
    const res = await api.delete(`/services/${id}`);
    return res.data;
};
