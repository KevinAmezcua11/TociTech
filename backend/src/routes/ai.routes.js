const express = require("express");
const controller = require("../controllers/ai.controller");
const { authenticate } = require('../middleware/auth.middleware');

const router = express.Router();

router.post("/", authenticate, controller.chat);

module.exports = router;