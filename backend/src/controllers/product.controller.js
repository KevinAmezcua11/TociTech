const Product = require('../models/product.model'); 

// Obtener todos los productos
async function getAll(req, res) {
    try {
        const products = await Product.getAllProducts();
        res.json(products);

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Error al obtener productos" });
    }
}

// Obtener producto por ID
async function getById(req, res) {
    try {
        const product = await Product.getById(req.params.id);

        if (!product) {
            return res.status(404).json({ message: "Producto no encontrado" });
        }

        res.json(product);

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Error al obtener producto" });
    }
}

// Crear producto
async function createProduct(req, res) {
    try {
        const data = req.body;

        if (!data.name || data.price == null) {
            return res.status(400).json({
                message: "Nombre y precio son obligatorios"
            });
        }

        const product = await Product.createProduct(data);

        if (!product) {
            return res.status(400).json({
                message: "El producto ya existe (nombre duplicado)"
            });
        }

        res.status(201).json({
            message: "Producto creado correctamente",
            data: product
        });

    } catch (err) {
        console.error(err);

        res.status(400).json({
            message: err.message || "Error al crear producto"
        });
    }
}

// Actualizar producto
async function updateProduct(req, res) {
    try {
        const id = req.params.id;
        const data = req.body;

        const updated = await Product.updateProduct(id, data);

        if (!updated) {
            return res.status(404).json({
                message: "Producto no encontrado"
            });
        }

        res.json({
            message: "Producto actualizado correctamente",
            data: updated
        });

    } catch (err) {
        console.error(err);

        res.status(400).json({
            message: err.message || "Error al actualizar producto"
        });
    }
}

// Eliminar producto
async function deleteProduct(req, res) {
    try {
        const deleted = await Product.deleteProduct(req.params.id);

        if (!deleted) {
            return res.status(404).json({
                message: "Producto no encontrado"
            });
        }

        res.json({
            message: "Producto eliminado correctamente",
            id: deleted.id
        });

    } catch (err) {
        console.error(err);
        res.status(500).json({
            message: "Error al eliminar producto"
        });
    }
}

module.exports = { getAll, getById, createProduct, updateProduct, deleteProduct };