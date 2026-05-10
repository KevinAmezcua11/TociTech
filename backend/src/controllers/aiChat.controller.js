function buildAssistantResponse(message) {
    const text = message.toLowerCase();

    if (text.includes("horario")) {
        return "Nuestro horario es de lunes a viernes de 9:00 AM a 7:00 PM y sabados de 9:00 AM a 2:00 PM.";
    }

    if (text.includes("garantia")) {
        return "Si, los servicios y productos cuentan con garantia segun el tipo de trabajo o articulo. Podemos revisar tu caso y explicarte la cobertura antes de confirmar.";
    }

    if (text.includes("laptop") || text.includes("computadora") || text.includes("pc")) {
        return "Si realizamos diagnostico, mantenimiento y reparacion de laptops y computadoras. Cuantame la falla y te indico el siguiente paso.";
    }

    if (text.includes("producto") || text.includes("catalogo") || text.includes("disponible")) {
        return "Puedes revisar productos disponibles desde la seccion Productos. Si buscas una pieza especifica, dime marca, modelo o presupuesto.";
    }

    if (text.includes("diagnostico") || text.includes("costo") || text.includes("precio")) {
        return "El diagnostico tecnico inicia desde $150 MXN. El precio final puede variar segun el equipo y la falla detectada.";
    }

    return "Puedo ayudarte con horarios, diagnosticos, reparaciones, garantias y productos. Dame un poco mas de detalle para orientarte mejor.";
}

function sendMessage(req, res) {
    const { message } = req.body;

    if (!message || typeof message !== "string" || !message.trim()) {
        return res.status(400).json({ message: "Message is required" });
    }

    const cleanMessage = message.trim();
    if (cleanMessage.length > 500) {
        return res.status(400).json({ message: "Message is too long" });
    }

    return res.status(200).json({
        message: buildAssistantResponse(cleanMessage)
    });
}

module.exports = { sendMessage };
