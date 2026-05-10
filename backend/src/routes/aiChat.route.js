const express = require("express");
const controller = require("../controllers/aiChat.controller");

const router = express.Router();

router.post("/message", controller.sendMessage);

module.exports = router;
