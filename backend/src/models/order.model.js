const { collection, addDoc, getDocs, deleteDoc, updateDoc, query, where, getDoc, doc, serverTimestamp } = require("firebase/firestore");
const { db } = require('../config/firebase');

const orderCollection = collection(db, "orders");

const Product = require("./product.model");
const Service = require("./services.model");
const User = require("./user.model");

// Obtener todos los pedidos
async function getAllOrders() {
    const snapshot = await getDocs(orderCollection);

    return snapshot.docs.map(d => {
        const order = d.data();

        return {
            id: d.id,
            ...order,
            createdAt: order.createdAt?.toDate(),
            updatedAt: order.updatedAt?.toDate()
        }
    });
}

// Obtener pedidos por ID
async function getById(id) {
    const orderRef = doc(db, "orders", id);
    const orderSnap = await getDoc(orderRef);

    if(!orderSnap.exists()) return null;

    const order = orderSnap.data();

    return {
        id: orderSnap.id,
        ...order,
        createdAt: order.createdAt?.toDate(),
        updatedAt: order.updatedAt?.toDate()
    }
}

// Insertar nuevo pedido
async function createOrder({ type, customerId, items, serviceId, problem, equipment, priority, scheduledDate, notes }) {
    try {
        if (!["product", "service"].includes(type)) {
            throw new Error("Invalid order type");
        }

        const user = await User.getById(customerId);
        if (!user) throw new Error("Customer not found");

        const customer = {
            name: `${user.names} ${user.lastnames}`,
            email: user.email,
            phone: user.phone
        };

        let orderData = {
            type,
            customer,
            status: "pending",
            priority: priority || "medium",
            scheduledDate: scheduledDate || null,
            notes: notes || "",
            createdAt: serverTimestamp(),
            updatedAt: serverTimestamp()
        };

        if (type === "product") {
            if (!items || !Array.isArray(items) || items.length === 0) {
                throw new Error("Items required");
            }

            let total = 0;

            const itemsFormatted = [];

            for (const item of items) {
                if (!item.productId || !item.quantity) {
                    throw new Error("Invalid item data");
                }

                const product = await Product.getById(item.productId);

                if (!product) throw new Error("Product not found");

                if (product.stock < item.quantity) {
                    throw new Error(`Not enough stock for ${product.name}`);
                }

                const product = await Product.getById(item.productId);
                if (!product) throw new Error("Product not found");

                const price = product.price;
                const subtotal = price * item.quantity;
                total += subtotal;

                await Product.updateProduct(product.id, {
                    stock: product.stock - item.quantity
                });

                itemsFormatted.push({
                    productId: product.id,
                    name: product.name,
                    price,
                    quantity: item.quantity,
                    subtotal
                });
            }

            orderData.items = itemsFormatted;
            orderData.total = total;
        }

        if (type === "service") {
            if (!serviceId || !problem) {
                throw new Error("Service data required");
            }

            const service = await Service.getById(serviceId);
            if (!service) throw new Error("Service not found");

            orderData.service = {
                serviceId: service.id,
                name: service.name,
                basePrice: service.price || 0
            };

            orderData.problem = problem;
            orderData.equipment = equipment || "";
            orderData.diagnosis = "";
            orderData.finalPrice = null;
        }

        const docRef = await addDoc(orderCollection, orderData);

        return await getById(docRef.id);

    } catch (err) {
        console.error("Error creating order:", err);
        throw err;
    }
}

// Actualizar pedido
async function updateOrder(id, data) {
    const orderRef = doc(db, "orders", id);
    const orderSnap = await getDoc(orderRef);

    if (!orderSnap.exists()) return null;

    const allowedStatus = ["pending", "in_progress", "completed", "cancelled"];
    if (data.status && !allowedStatus.includes(data.status)) throw new Error("Invalid status");

    const allowedPriority = ["low", "medium", "high"];
    if (data.priority && !allowedPriority.includes(data.priority)) throw new Error("Invalid priority");

    if (data.finalPrice != null && data.finalPrice < 0) throw new Error("Invalid final price");

    delete data.type;
    delete data.customer;
    delete data.items;
    delete data.total;
    delete data.createdAt;
    delete data.id;

    await updateDoc(orderRef, {
        ...data,
        updatedAt: serverTimestamp()
    });

    return getById(id);
}

// Eliminar pedido
async function deleteOrder(id) {
    const orderRef = doc(db, "orders", id);
    const orderSnap = await getDoc(orderRef);

    if(!orderSnap.exists()) return null;

    await deleteDoc(orderRef);

    return { id }
}

module.exports = { getAllOrders, getById, createOrder, updateOrder, deleteOrder };