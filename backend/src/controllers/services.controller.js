const Service = require('../models/services.model'); 

// Obtener todos los servicios
async function getAll(req, res) {
    try {
        const services = await Service.getAllServices();
        res.json(services);

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
}

// Obtener servicio por ID
async function getById(req, res) {
    try {
        const service = await Service.getById(req.params.id);

        if(!service) {
            return res.status(404).json({ message: "Service not found" });
        }

        res.json(service);

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
}

// Crear servicio
async function createService(req, res) {
    try {
        const service = await Service.createService(req.body);

        if(!service) {
            return res.status(400).json({ message: "Service already exists" });
        }

        res.status(201).json(service);

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
}

// Actualizar servicio
async function updateService(req, res) {
    try {
        const updated = await Service.updateService(req.params.id, req.body);

        if(!updated) {
            return res.status(404).json({ message: "Service not found" });
        }

        res.json(updated);

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
}

// Eliminar servicio
async function deleteService(req, res) {
    try {
        const deleted = await Service.deleteService(req.params.id);

        if(!deleted) {
            return res.status(404).json({ message: "Service not found" });
        }

        res.json({ message: "Service deleted", ...deleted });

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: "Server error" });
    }
}

module.exports = { getAll, getById, createService, updateService, deleteService }
