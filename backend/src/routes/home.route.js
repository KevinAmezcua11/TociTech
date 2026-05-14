const express = require("express");
const controller = require("../controllers/home.controller");

const router = express.Router();

router.get("/summary", controller.getSummary);
router.get("/featured", controller.getFeatured);

module.exports = router;
