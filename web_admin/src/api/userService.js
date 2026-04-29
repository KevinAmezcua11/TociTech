import api from "./api";

// Obtener todos los usuarios
export const getUsers = async () => {
    const res = await api.get("/users");
    return res.data;
};

// Obtener solo clientes
export const getClients = async () => {
    const res = await api.get("/users");
    return res.data.filter(u => u.role === "client");
};