const db = require("../config/firebase");

const FEATURED_LIMIT = 3;

async function countCollection(collection, predicate = null) {
    const snapshot = await db.collection(collection).get();

    if (!predicate) {
        return snapshot.size;
    }

    return snapshot.docs.filter(doc => predicate(doc.data())).length;
}

async function getSummary(req, res) {
    try {
        const [clients, services, products] = await Promise.all([
            countCollection("users", user => user.role === "client"),
            countCollection("services", service => {
                if (service.active != null) return service.active !== false;
                if (service.state != null) return service.state === true || service.state === "active";
                return true;
            }),
            countCollection("products", product =>
                product.status !== "discontinued" &&
                product.status !== "out_of_stock" &&
                Number(product.stock ?? 0) > 0
            ),
        ]);

        res.json({
            clients,
            services,
            products,
            updatedAt: new Date().toISOString(),
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "No se pudo cargar el resumen del home." });
    }
}

async function getFeatured(req, res) {
    try {
        // Obtener todas las órdenes pagadas para calcular los más vendidos
        const ordersSnap = await db.collection('orders')
            .where('estadoPago', '==', 'PAGADO')
            .get();

        // Acumular ventas: { productId: cantidadTotal } y { serviceId: conteo }
        const productSales = {};
        const serviceSales = {};

        ordersSnap.docs.forEach(doc => {
            const order = doc.data();
            if (order.type === 'product' && Array.isArray(order.items)) {
                order.items.forEach(item => {
                    if (item.productId) {
                        productSales[item.productId] =
                            (productSales[item.productId] || 0) + (item.quantity || 1);
                    }
                });
            } else if (order.type === 'service' && order.service?.serviceId) {
                const sid = order.service.serviceId;
                serviceSales[sid] = (serviceSales[sid] || 0) + 1;
            }
        });

        // Ordenar por más vendido y tomar los primeros IDs
        const topProductIds = Object.entries(productSales)
            .sort((a, b) => b[1] - a[1])
            .slice(0, FEATURED_LIMIT)
            .map(([id]) => id);

        const topServiceIds = Object.entries(serviceSales)
            .sort((a, b) => b[1] - a[1])
            .slice(0, FEATURED_LIMIT)
            .map(([id]) => id);

        // Obtener datos completos de los productos más vendidos
        let featuredProducts = [];
        if (topProductIds.length > 0) {
            const docs = await Promise.all(
                topProductIds.map(id => db.collection('products').doc(id).get())
            );
            featuredProducts = docs
                .filter(d => d.exists &&
                    d.data().status === 'available' &&
                    Number(d.data().stock ?? 0) > 0)
                .map(d => ({ id: d.id, ...d.data() }));
        }

        // Obtener datos completos de los servicios más solicitados
        let featuredServices = [];
        if (topServiceIds.length > 0) {
            const docs = await Promise.all(
                topServiceIds.map(id => db.collection('services').doc(id).get())
            );
            featuredServices = docs
                .filter(d => d.exists && _isServiceActive(d.data()))
                .map(d => ({ id: d.id, ...d.data() }));
        }

        // Fallback productos: si no hay suficientes ventas, completar con disponibles
        if (featuredProducts.length < FEATURED_LIMIT) {
            const needed = FEATURED_LIMIT - featuredProducts.length;
            const existing = new Set(featuredProducts.map(p => p.id));
            const snap = await db.collection('products')
                .where('status', '==', 'available')
                .limit(FEATURED_LIMIT + needed + 5)
                .get();

            for (const doc of snap.docs) {
                if (featuredProducts.length >= FEATURED_LIMIT) break;
                const data = doc.data();
                if (!existing.has(doc.id) && Number(data.stock ?? 0) > 0) {
                    featuredProducts.push({ id: doc.id, ...data });
                }
            }
        }

        // Fallback servicios: si no hay suficientes ventas, completar con activos
        if (featuredServices.length < FEATURED_LIMIT) {
            const existing = new Set(featuredServices.map(s => s.id));
            const snap = await db.collection('services')
                .limit(FEATURED_LIMIT * 3)
                .get();

            for (const doc of snap.docs) {
                if (featuredServices.length >= FEATURED_LIMIT) break;
                const data = doc.data();
                if (!existing.has(doc.id) && _isServiceActive(data)) {
                    featuredServices.push({ id: doc.id, ...data });
                }
            }
        }

        res.json({
            products: featuredProducts.slice(0, FEATURED_LIMIT),
            services: featuredServices.slice(0, FEATURED_LIMIT),
        });
    } catch (err) {
        console.error('[Home] getFeatured error:', err);
        res.status(500).json({ message: 'Error al obtener destacados' });
    }
}

function _isServiceActive(data) {
    if (data.active != null) return data.active !== false;
    if (data.state != null) return data.state === true || data.state === 'active';
    return true;
}

module.exports = { getSummary, getFeatured };
