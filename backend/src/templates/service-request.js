function getServiceEmailContent(order) {
    const { customer, service, problem, equipment } = order;
    const customerName = customer?.name || 'Cliente';
    const serviceName = service?.name || 'Servicio solicitado';

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

          <!-- BANNER SOLICITUD RECIBIDA -->
          <tr>
            <td style="background:#1d4ed8;padding:18px 30px;text-align:center;">
              <p style="margin:0;color:#ffffff;font-size:16px;font-weight:bold;">✓ &nbsp;Solicitud de servicio recibida</p>
            </td>
          </tr>

          <!-- BODY -->
          <tr>
            <td style="padding:36px 30px;">

              <p style="color:#1a1a2e;font-size:20px;font-weight:bold;margin:0 0 8px;">Hola, ${customerName}</p>
              <p style="color:#555;font-size:14px;line-height:1.7;margin:0 0 28px;">
                Hemos recibido tu solicitud de servicio correctamente. A continuación encontrarás el resumen de lo que nos informaste.
              </p>

              <!-- DETALLE DEL SERVICIO -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:24px;">
                <tr>
                  <td style="padding-bottom:10px;">
                    <p style="margin:0;font-size:13px;color:#888;text-transform:uppercase;letter-spacing:0.5px;">Detalle de la solicitud</p>
                  </td>
                </tr>
                <tr>
                  <td style="background:#f8f9fc;border-radius:6px;padding:20px;">
                    <table width="100%" cellpadding="0" cellspacing="0">
                      <tr>
                        <td style="padding:6px 0;font-size:13px;color:#888;width:40%;">Servicio</td>
                        <td style="padding:6px 0;font-size:14px;color:#1a1a2e;font-weight:bold;">${serviceName}</td>
                      </tr>
                      <tr>
                        <td style="padding:6px 0;font-size:13px;color:#888;vertical-align:top;">Descripción del problema</td>
                        <td style="padding:6px 0;font-size:14px;color:#444;line-height:1.6;">${problem || 'No especificado'}</td>
                      </tr>
                      ${equipment ? `
                      <tr>
                        <td style="padding:6px 0;font-size:13px;color:#888;">Equipo</td>
                        <td style="padding:6px 0;font-size:14px;color:#444;">${equipment}</td>
                      </tr>` : ''}
                    </table>
                  </td>
                </tr>
              </table>

              <!-- AVISO SEGUIMIENTO -->
              <table width="100%" cellpadding="0" cellspacing="0" style="margin-bottom:28px;">
                <tr>
                  <td style="background:#eef4ff;border-left:4px solid #1d4ed8;border-radius:4px;padding:16px 20px;">
                    <p style="margin:0;font-size:14px;color:#1a1a2e;line-height:1.6;">
                      <strong>Próximos pasos:</strong><br>
                      TociTech se pondrá en contacto contigo por WhatsApp o correo para continuar con el proceso de tu servicio.
                    </p>
                  </td>
                </tr>
              </table>

              <p style="color:#555;font-size:14px;line-height:1.7;margin:0;">
                Gracias por confiar en nosotros. Atenderemos tu solicitud a la brevedad posible.
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
        'TociTech - Solicitud de servicio recibida',
        '='.repeat(40),
        '',
        `Hola, ${customerName}`,
        '',
        'Hemos recibido tu solicitud de servicio correctamente.',
        '',
        'DETALLE DE LA SOLICITUD:',
        `  Servicio:  ${serviceName}`,
        `  Problema:  ${problem || 'No especificado'}`,
        ...(equipment ? [`  Equipo:    ${equipment}`] : []),
        '',
        'TociTech se pondrá en contacto contigo por WhatsApp o correo para continuar con el proceso de tu servicio.',
        '',
        'Gracias por confiar en nosotros.',
        '',
        'TociTech | Tepic, Nayarit'
    ].join('\n');

    return {
        subject: 'Solicitud de servicio recibida - TociTech',
        html,
        text
    };
}

module.exports = { getServiceEmailContent };
