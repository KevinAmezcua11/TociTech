const db = require("../config/firebase");

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

module.exports = { getSummary };
