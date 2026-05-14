function getPasswordResetEmailContent({ names, code }) {
    const firstName = names?.split(' ')[0] || 'Usuario';

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
        <table width="100%" cellpadding="0" cellspacing="0" style="max-width:520px;background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">

          <!-- Header -->
          <tr>
            <td style="background:#6C63FF;padding:32px 40px;text-align:center;">
              <p style="margin:0;color:#ffffff;font-size:28px;font-weight:bold;letter-spacing:2px;">TociTech</p>
              <p style="margin:8px 0 0;color:rgba(255,255,255,0.85);font-size:14px;">Recuperación de contraseña</p>
            </td>
          </tr>

          <!-- Body -->
          <tr>
            <td style="padding:36px 40px;">
              <p style="margin:0 0 12px;color:#222;font-size:16px;font-weight:600;">Hola, ${firstName}</p>
              <p style="margin:0 0 24px;color:#555;font-size:14px;line-height:1.6;">
                Recibimos una solicitud para restablecer la contraseña de tu cuenta en TociTech.
                Usa el siguiente código de verificación:
              </p>

              <!-- Code box -->
              <table width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td align="center" style="padding:0 0 28px;">
                    <div style="display:inline-block;background:#f5f3ff;border:2px solid #6C63FF;border-radius:12px;padding:20px 40px;">
                      <p style="margin:0;color:#6C63FF;font-size:36px;font-weight:bold;letter-spacing:10px;font-family:monospace;">${code}</p>
                    </div>
                  </td>
                </tr>
              </table>

              <p style="margin:0 0 8px;color:#555;font-size:13px;line-height:1.6;">
                Este código es válido por <strong>15 minutos</strong>. Si no solicitaste este cambio, puedes ignorar este correo — tu contraseña no será modificada.
              </p>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background:#f9f9f9;padding:20px 40px;border-top:1px solid #eee;text-align:center;">
              <p style="margin:0;color:#aaa;font-size:12px;">© ${new Date().getFullYear()} TociTech. Todos los derechos reservados.</p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;

    const text = `Hola ${firstName},\n\nTu código para restablecer la contraseña de TociTech es: ${code}\n\nEste código expira en 15 minutos.\n\nSi no solicitaste este cambio, ignora este correo.\n\nTociTech`;

    return {
        subject: 'Restablece tu contraseña - TociTech',
        html,
        text
    };
}

module.exports = { getPasswordResetEmailContent };
