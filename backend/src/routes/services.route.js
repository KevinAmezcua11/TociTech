const express = require("express");
const controller = require('../controllers/services.controller');
const { authenticate } = require('../middleware/auth.middleware');
const roleAuth = require('../middleware/roleAuth');

const router = express.Router();

router.get("/", authenticate, controller.getAll);
router.get("/:id", authenticate, controller.getById);

router.post("/", authenticate, roleAuth("admin"), controller.createService);
router.put("/:id", authenticate, roleAuth("admin"), controller.updateService);
router.delete("/:id", authenticate, roleAuth("admin"), controller.deleteService);

module.exports = router;