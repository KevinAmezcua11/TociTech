const admin = require("firebase-admin");
const db = require("../config/firebase");

const Product = require("./product.model");
const Service = require("./services.model");
const User = require("./user.model");

const EstadoPago = {
    PENDIENTE: 'PENDIENTE',
    PAGADO: 'PAGADO',
    FALLIDO: 'FALLIDO',
    REEMBOLSADO: 'REEMBOLSADO'
};

const EstadoPedido = {
    PENDIENTE: 'PENDIENTE',
    EN_PROGRESO: 'EN_PROGRESO',
    COMPLETADO: 'COMPLETADO',
    CANCELADO: 'CANCELADO'
};

// Obtener todos los pedidos
async function getAllOrders() {
    const snapshot = await db
        .collection("orders")
        .get();

    return snapshot.docs.map(d => {
        const order = d.data();

        return {
            id: d.id,
            ...order,
            createdAt: order.createdAt?.toDate() ?? null,
            updatedAt: order.updatedAt?.toDate() ?? null,
            paidAt:    order.paidAt?.toDate()    ?? null
        }
    });
}

// Obtener pedidos por ID
async function getById(id) {
    const orderRef = db.collection("orders").doc(id);
    const orderSnap = await orderRef.get();

    if (!orderSnap.exists) return null;

    const order = orderSnap.data();

    return {
        id: orderSnap.id,
        ...order,
        createdAt: order.createdAt?.toDate() ?? null,
        updatedAt: order.updatedAt?.toDate() ?? null,
        paidAt:    order.paidAt?.toDate()    ?? null
    }
}

// Insertar nuevo pedido
async function createOrder({ type, customerId, customer: manualCustomer, items, serviceId, problem, equipment, scheduledDate, notes }) {
    try {
        if (!["product", "service"].includes(type)) {
            throw new Error("Invalid order type");
        }

        // Obtener cliente
        let customer;

        if (customerId) {
            const user = await User.getById(customerId);
            if (!user) throw new Error("Customer not found");

            customer = {
                name: `${user.names} ${user.lastnames}`,
                email: user.email,
                phone: user.phone
            };
        } else if (manualCustomer) {
            if (!manualCustomer.name || !manualCustomer.phone) {
                throw new Error("Customer data required");
            }

            customer = manualCustomer;
        } else {
            throw new Error("Customer required");
        }

        let orderData = {
            type,
            customer,
            status: "pending",
            estadoPedido: EstadoPedido.PENDIENTE,
            estadoPago: EstadoPago.PENDIENTE,
            scheduledDate: scheduledDate || null,
            notes: notes || "",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        };

        if (customerId) {
            orderData.customerId = customerId;
        }

        // PRODUCTOS
        if (type === "product") {
            if (!items || !Array.isArray(items) || items.length === 0) {
                throw new Error("Items required");
            }

            let total = 0;
            const itemsFormatted = [];
            const productsMap = [];

            // Validar productos
            for (const item of items) {
                if (!item.productId || !item.quantity) {
                    throw new Error("Invalid item data");
                }

                const product = await Product.getById(item.productId);
                if (!product) throw new Error("Product not found");

                if (product.stock < item.quantity) {
                    throw new Error(`Not enough stock for ${product.name}`);
                }

                productsMap.push({ item, product });
            }

            for (const { item, product } of productsMap) {
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

        // SERVICIOS
        if (type === "service") {
            // Validar límite de solicitudes activas por usuario
            if (customerId) {
                const snapshot = await db.collection("orders")
                    .where("customerId", "==", customerId)
                    .get();

                const activeCount = snapshot.docs.filter(doc => {
                    const d = doc.data();
                    return d.type === "service" &&
                        (d.estadoPedido === EstadoPedido.PENDIENTE ||
                         d.estadoPedido === EstadoPedido.EN_PROGRESO);
                }).length;

                if (activeCount >= 3) {
                    throw new Error(
                        "Ya tienes 3 solicitudes activas. " +
                        "Espera a que finalicen antes de crear otra."
                    );
                }
            }

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

        const docRef = await db
            .collection("orders")
            .add(orderData);

        return await getById(docRef.id);

    } catch (err) {
        console.error("Error creating order:", err);
        throw err;
    }
}

// Actualizar pedido
async function updateOrder(id, data) {
    const orderRef = db.collection("orders").doc(id);
    const orderSnap = await orderRef.get();

    if (!orderSnap.exists) return null;

    const allowedStatus = ["pending", "in_progress", "completed", "cancelled"];
    if (data.status && !allowedStatus.includes(data.status)) throw new Error("Invalid status");

    if (data.finalPrice != null && data.finalPrice < 0) throw new Error("Invalid final price");

    delete data.type;
    delete data.customer;
    delete data.items;
    delete data.total;
    delete data.createdAt;
    delete data.id;

    await orderRef.update({
        ...data,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return getById(id);
}

// Eliminar pedido
async function deleteOrder(id) {
    const orderRef = db.collection("orders").doc(id);
    const orderSnap = await orderRef.get();

    if (!orderSnap.exists) return null;

    await orderRef.delete();

    return { id }
}

// Obtener pedidos del usuario autenticado
async function getMyOrders(customerId) {
    const snapshot = await db.collection("orders")
        .where("customerId", "==", customerId)
        .get();

    const orders = snapshot.docs.map(d => {
        const order = d.data();
        return {
            id: d.id,
            ...order,
            createdAt: order.createdAt?.toDate() ?? null,
            updatedAt: order.updatedAt?.toDate() ?? null,
            paidAt:    order.paidAt?.toDate()    ?? null
        };
    });

    return orders.sort((a, b) => {
        const ta = a.createdAt ? a.createdAt.getTime() : 0;
        const tb = b.createdAt ? b.createdAt.getTime() : 0;
        return tb - ta;
    });
}

// Buscar pedido por paymentIntentId (usado por el webhook de Stripe)
async function findByPaymentIntentId(paymentIntentId) {
    const snapshot = await db.collection("orders")
        .where("paymentIntentId", "==", paymentIntentId)
        .limit(1)
        .get();

    if (snapshot.empty) return null;

    const doc = snapshot.docs[0];
    const order = doc.data();

    return {
        id: doc.id,
        ...order,
        createdAt: order.createdAt?.toDate(),
        updatedAt: order.updatedAt?.toDate()
    };
}

module.exports = {
    getAllOrders,
    getMyOrders,
    getById,
    createOrder,
    updateOrder,
    deleteOrder,
    findByPaymentIntentId,
    EstadoPago,
    EstadoPedido
};