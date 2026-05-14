const express = require('express');
const controller = require('../controllers/auth.controller');
const { authenticate } = require('../middleware/auth.middleware');

const router = express.Router();

// Público
router.post("/register", controller.registerClient);
router.post("/login", controller.login);
router.post("/forgot-password", controller.forgotPassword);
router.post("/reset-password", controller.resetPassword);

// Protegido
router.post("/register/admin", authenticate, controller.registerAdmin);

module.exports = router;