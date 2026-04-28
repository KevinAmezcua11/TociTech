const Order = require('../models/order.model');

// Obtener todos los pedidos
async function getAllOrders(req, res) {
    try {
        const orders = await Order.getAllOrders();
        res.json(orders);
    
    } catch(err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
}

// Obtener pedido por ID
async function getById(req, res) {
    try {
        const order =  Order.getById(req.params.id);

        if(!order) return res.status(404).json({ message: "Order not found" });

        res.json(order);
    } catch(err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
}

// Crear pedido
async function createOrder(req, res) {
    try {
        const created = await Order.createOrder({
            ...req.body,
            customerId: req.user.id
        });

        res.status(201).json(created);

    } catch (err) {
        console.error(err);

        if (err.message.includes("Invalid") || err.message.includes("required")) {
            return res.status(400).json({ message: err.message });
        }

        res.status(500).json({ message: "Server error" });
    }
}

// Actualizar pedido
async function updateOrder(req, res) {
    try {
        const updated = await Order.updateOrder(req.params.id, req.body);

        if (!updated) return res.status(404).json({ message: "Order not found" });

        res.json(updated);

    } catch (err) {
        console.error(err);

        if (err.message.includes("Invalid")) {
            return res.status(400).json({ message: err.message });
        }

        res.status(500).json({ message: "Server error" });
    }
}

// Eliminar pedido
async function deleteOrder(req, res) {
    try {
        const deleted = await Order.deleteOrder(req.params.id);

        if (!deleted) return res.status(404).json({ message: "Order not found" });

        res.json({ message: "Order deleted", ...deleted });

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
}

module.exports = { getAllOrders, getById, createOrder, updateOrder, deleteOrder };