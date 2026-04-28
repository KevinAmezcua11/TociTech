const express = require("express");
const controller = require('../controllers/order.controller');
const { authenticate } = require('../middleware/auth.middleware');

const router = express.Router();

router.get("/", authenticate, controller.getAllOrders);
router.get("/:id", authenticate, controller.getById);
router.post("/", authenticate, controller.createOrder);
router.put("/:id", authenticate, controller.updateOrder);
router.delete("/:id", authenticate, controller.deleteOrder);

module.exports = router;