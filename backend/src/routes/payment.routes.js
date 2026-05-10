const express = require('express');
const router = express.Router();

const { createPaymentIntent, webhook } = require('../controllers/payment.controller');
const { authenticate } = require('../middleware/auth.middleware');

router.post('/webhook', webhook);

router.post('/create-payment-intent', authenticate, createPaymentIntent);

module.exports = router;
