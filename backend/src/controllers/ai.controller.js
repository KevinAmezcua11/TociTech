const aiService = require("../config/ai.service");

async function chat(req, res) {
    try {
        const { message } = req.body;

        // Validar existencia
        if (!message) {
            return res.status(400).json({
                message: "Mensaje requerido"
            });
        }

        // Validar tipo
        if (typeof message !== "string") {
            return res.status(400).json({
                message: "El mensaje debe ser texto"
            });
        }

        // Limpiar espacios
        const cleanMessage = message.trim();

        // Validar vacío
        if (cleanMessage.length === 0) {
            return res.status(400).json({
                message: "Mensaje vacío"
            });
        }

        // Limitar longitud
        if (cleanMessage.length > 300) {
            return res.status(400).json({
                message: "Mensaje demasiado largo"
            });
        }

        console.log("Mensaje recibido:", message);

        const reply = await aiService.askAI(cleanMessage);

        console.log("Respuesta IA:", reply);

        return res.status(200).json({
            reply
        });

    } catch (error) {
        console.error("ERROR COMPLETO:");
        console.error(error);

        res.status(500).json({
            message: error.message || "Error con Gemini"
        });
    }
}

module.exports = {
    chat
};