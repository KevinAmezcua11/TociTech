function getProductEmailContent(order) {
    const { id, customer, items = [], total } = order;
    const customerName = customer?.name || 'Cliente';
    const totalFormatted = Number(total || 0).toFixed(2);

    const itemsRows = items.map(item => `
        <tr>
            <td style="padding:10px 0;border-bottom:1px solid #f0f0f0;color:#444;font-size:14px;">
                ${item.name}
            </td>
            <td style="padding:10px 0;border-bottom:1px solid #f0f0f0;color:#444;font-size:14px;text-align:center;">
                ${item.quantity}
            </td>
            <td style="padding:10px 0;border-bottom:1px solid #f0f0f0;color:#444;font-size:14px;text-align:right;">
                $${Number(item.subtotal || 0).toFixed(2)} MXN
            </td>
        </tr>
    `).join('');

    const html = `
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
</head>
<body style="margin:0;padding:0;background:#f2f4f8;font-family:Arial,Helvetica,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f2f4f8;">
    <tr>
      <td align="center" style="padding:40px 16px;">

        <table width="600" cellpadding="0" cellspacing="0" style="max-width:600px;width:100%;background:#ffffff;border-radius:10px;overflow:hidden;box-shadow:0 2px 12px rgba(0,0,0,0.08);">

          <!-- HEADER -->
          <tr>
            <td style="background:#1a1a2e;padding:32px 30px;text-align:center;">
              <h1 style="margin:0;color:#ffffff;font-size:26px;letter-spacing:1px;">TociTech</h1>
              <p style="margin:6px 0 0;color:#8888aa;font-size:13px;">Tecnología y Servicios · Tepic, Nayarit</p>
            </td>
          </tr>

          <!-- BANNER PAGO EXITOSO -->
          <tr>
            <td style="background:#16a34a;padding:18px 30px;text-align:center;">
              <p style="margin:0;color:#ffffff;font-size:16px;font-weight:bold;">✓ &nbsp;Pago confirmado exitosamente</p>
            </td>
          </tr>

          <!-- BODY -->
          <tr>
            <td style="padding:36px 30px;">

              <p style="color:#1a1a2e;font-size:20px;font-weight:bold;margin:0 0 8px;">Hola, ${customerName}</p>
              <p style="color:#555;font-size:14px;line-height:1.7;margin:0 0 28px;">
                Tu pago ha sido procesado exitosamente. A continuación encontrarás el resumen de tu pedido.
              </p>

              <!-- RESUMEN PEDIDO -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:24px;">
                <tr>
                  <td style="padding-bottom:10px;">
                    <p style="margin:0;font-size:13px;color:#888;text-transform:uppercase;letter-spacing:0.5px;">Resumen del pedido</p>
                  </td>
                </tr>
                <tr>
                  <td>
                    <table width="100%" cellpadding="0" cellspacing="0">
                      <!-- ENCABEZADO TABLA -->
                      <tr style="background:#f8f9fc;">
                        <td style="padding:10px 0;font-size:12px;color:#888;text-transform:uppercase;font-weight:bold;">Producto</td>
                        <td style="padding:10px 0;font-size:12px;color:#888;text-transform:uppercase;font-weight:bold;text-align:center;">Cant.</td>
                        <td style="padding:10px 0;font-size:12px;color:#888;text-transform:uppercase;font-weight:bold;text-align:right;">Subtotal</td>
                      </tr>
                      ${itemsRows}
                      <!-- TOTAL -->
                      <tr>
                        <td colspan="2" style="padding:14px 0 0;font-size:15px;font-weight:bold;color:#1a1a2e;">Total pagado</td>
                        <td style="padding:14px 0 0;font-size:15px;font-weight:bold;color:#16a34a;text-align:right;">$${totalFormatted} MXN</td>
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>

              <!-- AVISO ENTREGA -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:28px;">
                <tr>
                  <td style="background:#eef4ff;border-left:4px solid #1a1a2e;border-radius:4px;padding:16px 20px;">
                    <p style="margin:0;font-size:14px;color:#1a1a2e;line-height:1.6;">
                      <strong>Próximos pasos:</strong><br>
                      TociTech se pondrá en contacto contigo por WhatsApp o correo para coordinar la entrega de tu pedido.
                    </p>
                  </td>
                </tr>
              </table>

              <p style="color:#555;font-size:14px;line-height:1.7;margin:0;">
                ¡Gracias por tu compra! Si tienes alguna duda no dudes en contactarnos.
              </p>

            </td>
          </tr>

          <!-- FOOTER -->
          <tr>
            <td style="background:#f8f9fc;padding:20px 30px;text-align:center;border-top:1px solid #eee;">
              <p style="margin:0;font-size:12px;color:#aaa;">
                Este correo fue generado automáticamente · TociTech &copy; ${new Date().getFullYear()}
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;

    const text = [
        'TociTech - Confirmación de compra',
        '='.repeat(40),
        '',
        `Hola, ${customerName}`,
        '',
        'Tu pago ha sido procesado exitosamente.',
        '',
        'RESUMEN DEL PEDIDO:',
        ...items.map(i => `  - ${i.name} x${i.quantity}  →  $${Number(i.subtotal || 0).toFixed(2)} MXN`),
        '',
        `Total pagado: $${totalFormatted} MXN`,
        '',
        'TociTech se pondrá en contacto contigo por WhatsApp o correo para coordinar la entrega de tu pedido.',
        '',
        '¡Gracias por tu compra!',
        '',
        'TociTech | Tepic, Nayarit'
    ].join('\n');

    return {
        subject: '✓ Confirmación de compra - TociTech',
        html,
        text
    };
}

module.exports = { getProductEmailContent };
