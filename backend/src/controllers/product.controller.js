const Product = require('../models/product.model'); 

// Obtener todos los productos
async function getAll(req, res) {
    try {
        const products = await Product.getAllProducts();
        res.json(products);

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
}

// Obtener producto por ID
async function getById(req, res) {
    try {
        const product = await Product.getById(req.params.id);

        if(!product) {
            return res.status(404).json({ message: "Product not found" });
        }

        res.json(product);

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
}

// Crear producto
async function createProduct(req, res) {
    try {
        const product = await Product.createProduct(req.body);

        if(!product) {
            return res.status(400).json({ message: "Product already exists" });
        }

        res.status(201).json(product);

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
}

// Actualizar producto
async function updateProduct(req, res) {
    try {
        const updated = await Product.updateProduct(req.params.id, req.body);

        if(!updated) {
            return res.status(404).json({ message: "Product not found" });
        }

        res.json(updated);

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
}

// Eliminar producto
async function deleteProduct(req, res) {
    try {
        const deleted = await Product.deleteProduct(req.params.id);

        if(!deleted) {
            return res.status(404).json({ message: "Product not found" });
        }

        res.json({ message: "Product deleted", ...deleted });

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
}

module.exports = { getAll, getById, createProduct, updateProduct, deleteProduct }
