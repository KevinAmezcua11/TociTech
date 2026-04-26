const express = require("express");
const controller = require('../controllers/product.controller');
const { authenticate } = require('../middleware/auth.middleware');
const roleAuth = require('../middleware/roleAuth'); // ✅

const router = express.Router();

router.get("/", authenticate, controller.getAll);
router.get("/:id", authenticate, controller.getById);

router.post("/", authenticate, roleAuth("admin"), controller.createProduct);
router.put("/:id", authenticate, roleAuth("admin"), controller.updateProduct);
router.delete("/:id", authenticate, roleAuth("admin"), controller.deleteProduct);

module.exports = router;