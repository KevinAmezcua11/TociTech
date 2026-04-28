const express = require("express");
const controller = require('../controllers/user.controller');
const { authenticate } = require('../middleware/auth.middleware');
const roleAuth = require('../middleware/roleAuth');

const router = express.Router();

router.get("/", authenticate, roleAuth("admin"), controller.getAll);
router.get("/:id", authenticate, roleAuth("admin"), controller.getById);
router.put("/:id", authenticate, roleAuth("admin"), controller.updateUser);
router.delete("/:id", authenticate, roleAuth("admin"), controller.deleteUser);

module.exports = router;