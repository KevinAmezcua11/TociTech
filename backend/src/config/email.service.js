const sgMail = require('@sendgrid/mail');
const { getProductEmailContent } = require('../templates/product-payment-success');
const { getServiceEmailContent } = require('../templates/service-request');
const { getPasswordResetEmailContent } = require('../templates/password-reset');

sgMail.setApiKey(process.env.SENDGRID_API_KEY);

async function sendEmail({ to, subject, html, text }) {
    const msg = {
        to,
        from: {
            email: process.env.SENDGRID_FROM_EMAIL,
            name: 'TociTech'
        },
        subject,
        text,
        html
    };
    await sgMail.send(msg);
}

async function sendProductPurchaseEmail(order) {
    try {
        if (!order?.customer?.email) {
            console.warn('[Email] Correo de compra omitido: sin email de cliente');
            return;
        }
        const { subject, html, text } = getProductEmailContent(order);
        await sendEmail({ to: order.customer.email, subject, html, text });
        console.log(`[Email] Confirmación de compra enviada a ${order.customer.email} | Pedido: ${order.id}`);
    } catch (err) {
        console.error('[Email] Error al enviar correo de compra:', err.message);
    }
}

async function sendServiceRequestEmail(order) {
    try {
        if (!order?.customer?.email) {
            console.warn('[Email] Correo de servicio omitido: sin email de cliente');
            return;
        }
        const { subject, html, text } = getServiceEmailContent(order);
        await sendEmail({ to: order.customer.email, subject, html, text });
        console.log(`[Email] Confirmación de servicio enviada a ${order.customer.email} | Pedido: ${order.id}`);
    } catch (err) {
        console.error('[Email] Error al enviar correo de servicio:', err.message);
    }
}

async function sendPasswordResetEmail({ to, names, code }) {
    try {
        const { subject, html, text } = getPasswordResetEmailContent({ names, code });
        await sendEmail({ to, subject, html, text });
        console.log(`[Email] Código de recuperación enviado a ${to}`);
    } catch (err) {
        console.error('[Email] Error al enviar correo de recuperación:', err.message);
        throw err;
    }
}

module.exports = { sendProductPurchaseEmail, sendServiceRequestEmail, sendPasswordResetEmail };
