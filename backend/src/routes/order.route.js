const express = require("express");
const controller = require('../controllers/order.controller');
const { authenticate } = require('../middleware/auth.middleware');
const roleAuth = require('../middleware/roleAuth');

const router = express.Router();

router.get("/my", authenticate, controller.getMyOrders);
router.post("/", authenticate, controller.createOrder);

router.get("/", authenticate, roleAuth("admin"), controller.getAllOrders);
router.get("/:id", authenticate, roleAuth("admin"), controller.getById);
router.put("/:id", authenticate, roleAuth("admin"), controller.updateOrder);
router.delete("/:id", authenticate, roleAuth("admin"), controller.deleteOrder);

module.exports = router;
