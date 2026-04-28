const User = require('../models/user.model');

// Obtener todos los usuarios
async function getAll(req, res) {
    try {
        const users = await User.getAllUsers();
        res.json(users);

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
}

// Obtener usuarios por ID
async function getById(req, res) {
    try {
        const user = await User.getById(req.params.id);

        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        res.json(user);

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
}

// Actualizar usuario
async function updateUser(req, res) {
    try {
        const updated = await User.updateUser(req.params.id, req.body);

        if (!updated) {
            return res.status(404).json({ message: "User not found or username already exists" });
        }

        res.json(updated);

    } catch (err) {
        console.error(err);

        if (err.message.includes("Invalid")) {
            return res.status(400).json({ message: err.message });
        }

        res.status(500).json({ message: "Server error" });
    }
}

// Eliminar usuario
async function deleteUser(req, res) {
    try {
        const deleted = await User.deleteUser(req.params.id);

        if (!deleted) {
            return res.status(404).json({ message: "User not found" });
        }

        res.json({ message: "User deleted", ...deleted });

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
}

module.exports = { getAll, getById, updateUser, deleteUser };