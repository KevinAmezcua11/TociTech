const admin = require('firebase-admin');
const stripe = require('../config/stripe');
const db = require('../config/firebase');
const Product = require('../models/product.model');
const User = require('../models/user.model');
const { EstadoPago, EstadoPedido } = require('../models/order.model');

async function createPaymentIntent(req, res) {
    try {
        const { items } = req.body;
        const userId = req.user.id;

        // Validar estructura básica
        if (!items || !Array.isArray(items) || items.length === 0) {
            return res.status(400).json({ error: 'Se requiere al menos un producto (items)' });
        }

        for (const item of items) {
            if (!item.productId || !item.quantity || item.quantity <= 0 || !Number.isInteger(item.quantity)) {
                return res.status(400).json({ error: 'Datos de producto inválidos: se requiere productId y quantity entero positivo' });
            }
        }

        // Obtener usuario autenticado
        const user = await User.getById(userId);
        if (!user) {
            return res.status(404).json({ error: 'Usuario no encontrado' });
        }

        // Validar productos y calcular total
        let total = 0;
        const itemsValidados = [];

        for (const item of items) {
            const producto = await Product.getById(item.productId);

            if (!producto) {
                return res.status(404).json({ error: `Producto no encontrado: ${item.productId}` });
            }

            if (producto.status === false || producto.status === 'inactive') {
                return res.status(400).json({ error: `Producto no disponible: ${producto.name}` });
            }

            if (producto.stock < item.quantity) {
                return res.status(400).json({
                    error: `Stock insuficiente para "${producto.name}". Disponible: ${producto.stock}, solicitado: ${item.quantity}`
                });
            }

            const subtotal = producto.price * item.quantity;
            total += subtotal;

            itemsValidados.push({
                productId: producto.id,
                name: producto.name,
                price: producto.price,
                quantity: item.quantity,
                subtotal
            });
        }

        // Crear PaymentIntent en Stripe (monto en centavos)
        const paymentIntent = await stripe.paymentIntents.create({
            amount: Math.round(total * 100),
            currency: 'mxn',
            metadata: {
                userId,
                username: user.username
            }
        });

        console.log(`[Stripe] PaymentIntent creado: ${paymentIntent.id} | Total: $${total} MXN`);

        // Guardar pedido en Firestore con estado PENDIENTE (sin descontar stock)
        const pedidoData = {
            type: 'product',
            customerId: userId,
            customer: {
                name: `${user.names} ${user.lastnames}`,
                email: user.email,
                phone: user.phone || ''
            },
            items: itemsValidados,
            total,
            estadoPedido: EstadoPedido.PENDIENTE,
            estadoPago: EstadoPago.PENDIENTE,
            paymentIntentId: paymentIntent.id,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        };

        const docRef = await db.collection('orders').add(pedidoData);

        console.log(`[Pedido] Creado: ${docRef.id} vinculado a PaymentIntent ${paymentIntent.id}`);

        return res.status(200).json({
            clientSecret: paymentIntent.client_secret,
            paymentIntentId: paymentIntent.id
        });

    } catch (err) {
        console.error('[createPaymentIntent] Error:', err);
        return res.status(500).json({ error: err.message || 'Error interno del servidor' });
    }
}

async function webhook(req, res) {
    const sig = req.headers['stripe-signature'];
    const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

    if (!webhookSecret) {
        console.error('[Webhook] STRIPE_WEBHOOK_SECRET no configurado');
        return res.status(500).json({ error: 'Webhook secret no configurado' });
    }

    let evento;

    try {
        evento = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
    } catch (err) {
        console.error('[Webhook] Firma inválida:', err.message);
        return res.status(400).json({ error: `Webhook error: ${err.message}` });
    }

    console.log(`[Webhook] Evento recibido: ${evento.type}`);

    const paymentIntent = evento.data.object;

    try {
        switch (evento.type) {
            case 'payment_intent.succeeded':
                await manejarPagoExitoso(paymentIntent);
                break;

            case 'payment_intent.payment_failed':
                await manejarPagoFallido(paymentIntent);
                break;

            default:
                console.log(`[Webhook] Evento no manejado: ${evento.type}`);
        }

        return res.status(200).json({ received: true });

    } catch (err) {
        console.error('[Webhook] Error en handler:', err);
        return res.status(500).json({ error: 'Error procesando webhook' });
    }
}

// Handler: pago exitoso 
async function manejarPagoExitoso(paymentIntent) {
    // Buscar pedido por paymentIntentId
    const snapshot = await db.collection('orders')
        .where('paymentIntentId', '==', paymentIntent.id)
        .limit(1)
        .get();

    if (snapshot.empty) {
        console.error(`[Webhook] Pedido no encontrado para PaymentIntent: ${paymentIntent.id}`);
        return;
    }

    const pedidoDoc = snapshot.docs[0];
    const pedido = pedidoDoc.data();

    // Descontar stock de cada producto
    for (const item of pedido.items || []) {
        const productoRef = db.collection('products').doc(item.productId);
        const productoSnap = await productoRef.get();

        if (!productoSnap.exists) {
            console.warn(`[Stock] Producto no encontrado: ${item.productId}`);
            continue;
        }

        const productoData = productoSnap.data();
        const stockNuevo = (productoData.stock || 0) - item.quantity;

        await productoRef.update({
            stock: admin.firestore.FieldValue.increment(-item.quantity),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });

        console.log(`[Stock] "${item.name}" | stock anterior: ${productoData.stock} → nuevo: ${stockNuevo}`);

        // Notificación de stock bajo
        const minStock = productoData.minStock || 5;
        if (stockNuevo <= minStock) {
            await crearNotificacion({
                type: 'stock_bajo',
                title: 'Stock bajo',
                message: `El producto "${item.name}" tiene stock bajo (${stockNuevo} unidades restantes)`,
                productId: item.productId,
                productName: item.name,
                stockActual: stockNuevo
            });
        }
    }

    // Actualizar estado del pedido
    await pedidoDoc.ref.update({
        estadoPago: EstadoPago.PAGADO,
        estadoPedido: EstadoPedido.EN_PROGRESO,
        paidAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    console.log(`[Pedido] ${pedidoDoc.id} → PAGADO / EN_PROGRESO`);

    // Notificación: pago recibido (para el cliente)
    await crearNotificacion({
        type: 'pago_recibido',
        title: 'Pago recibido',
        message: `Pago de $${pedido.total?.toFixed(2)} MXN recibido. Tu pedido está en progreso.`,
        orderId: pedidoDoc.id,
        customerId: pedido.customerId || null,
        amount: pedido.total
    });

    // Notificación: nueva venta (para el admin)
    await crearNotificacion({
        type: 'nueva_venta',
        title: 'Nueva venta confirmada',
        message: `Venta por $${pedido.total?.toFixed(2)} MXN confirmada. Pedido: ${pedidoDoc.id}`,
        orderId: pedidoDoc.id,
        amount: pedido.total
    });
}

// Handler: pago fallido 
async function manejarPagoFallido(paymentIntent) {
    const snapshot = await db.collection('orders')
        .where('paymentIntentId', '==', paymentIntent.id)
        .limit(1)
        .get();

    if (snapshot.empty) {
        console.error(`[Webhook] Pedido no encontrado para PaymentIntent: ${paymentIntent.id}`);
        return;
    }

    const pedidoDoc = snapshot.docs[0];

    await pedidoDoc.ref.update({
        estadoPago: EstadoPago.FALLIDO,
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    console.log(`[Pedido] ${pedidoDoc.id} → FALLIDO`);
}

// Crear notificación en Firestore 
async function crearNotificacion(data) {
    try {
        await db.collection('notifications').add({
            ...data,
            leido: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp()
        });
    } catch (err) {
        console.error('[Notificación] Error al crear:', err.message);
    }
}

module.exports = { createPaymentIntent, webhook };
