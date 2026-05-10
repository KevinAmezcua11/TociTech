import api from "./api";

// Obtener todos los pedidos
export const getOrders = async () => {
    const res = await api.get("/orders");
    return res.data;
};

// Obtener pedido por ID
export const getOrderById = async (id) => {
    const res = await api.get(`/orders/${id}`);
    return res.data;
};

// Crear pedido
export const createOrder = async (data) => {
    const res = await api.post("/orders", data);
    return res.data;
};

// Actualizar pedido
export const updateOrder = async (id, data) => {
    const res = await api.put(`/orders/${id}`, data);
    return res.data;
};

// Cancelar pedido
export const cancelOrder = async (id) => {
    const res = await api.put(`/orders/${id}`, {
        estadoPedido: "CANCELADO"
    });
    return res.data;
};