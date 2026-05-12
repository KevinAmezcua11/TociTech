const { GoogleGenerativeAI } = require("@google/generative-ai");

const Product = require("../models/product.model");
const Service = require("../models/services.model");

const genAI = new GoogleGenerativeAI(
    process.env.GEMINI_API_KEY
);

const model = genAI.getGenerativeModel({
    model: "gemini-2.5-flash",
    generationConfig: {
        temperature: 0.5,
        maxOutputTokens: 300,
    }
});

// =========================
// HELPERS
// =========================

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function getRetryDelay(error) {
    try {
        const retryInfo = error.errorDetails?.find(d =>
            d["@type"]?.includes("RetryInfo")
        );
        if (retryInfo?.retryDelay) {
            const seconds = parseFloat(retryInfo.retryDelay.replace("s", ""));
            return seconds * 1000;
        }
    } catch (_) {}
    return 6000;
}

function needsProducts(message) {
    return /product|laptop|celular|precio|stock|compu|tablet|teclado|mouse|monitor|impres|bocin|audif|camara|cable|carg|bateria|memoria|disco|procesador|pantalla|pc|desktop/i.test(message);
}

function needsServices(message) {
    return /servicio|repar|diagnos|manten|instala|format|virus|limpieza|actualiz|configur|recover|datos/i.test(message);
}

// =========================
// MAIN FUNCTION
// =========================

async function askAI(message, retries = 3) {

    const lower = message.toLowerCase();

    // Solo cargar datos si la pregunta los necesita
    const loadProducts = needsProducts(message);
    const loadServices = needsServices(message);

    const products = loadProducts ? await Product.getAllProducts() : [];
    const services = loadServices ? await Service.getAllServices() : [];

    // Filtrar productos relevantes
    const filteredProducts = products.filter(product => {

        const text = `
            ${product.name}
            ${product.category}
            ${product.brand}
            ${product.description}
        `.toLowerCase();

        return lower
            .split(" ")
            .some(word => word.length > 2 && text.includes(word));

    }).slice(0, 3);

    // Filtrar servicios relevantes
    const filteredServices = services.filter(service => {

        const text = `
            ${service.name}
            ${service.description}
        `.toLowerCase();

        return lower
            .split(" ")
            .some(word => word.length > 2 && text.includes(word));

    }).slice(0, 3);

    // Contexto compacto productos
    const productsContext = filteredProducts.length > 0
        ? filteredProducts.map(p =>
            `• ${p.name} (${p.brand}) - $${p.price} - Stock: ${p.stock}`
        ).join("\n")
        : loadProducts ? "Sin productos relacionados." : "";

    // Contexto compacto servicios
    const servicesContext = filteredServices.length > 0
        ? filteredServices.map(s =>
            `• ${s.name} - $${s.price} - ${s.duration}`
        ).join("\n")
        : loadServices ? "Sin servicios relacionados." : "";

    // Prompt minimalista
    const prompt = `Eres el asistente de TociTech, tienda de tecnología en Tepic, Nayarit.
Horario: lunes a viernes 9:00am-7:00pm, sábado 9:00am-2:00pm, domingo cerrado.
Responde breve y profesional.
Solo habla de: productos, servicios, precios, horarios y ubicación.
No inventes información que no esté aquí.
${productsContext ? `\nProductos:\n${productsContext}` : ""}
${servicesContext ? `\nServicios:\n${servicesContext}` : ""}

Cliente: ${message}
Respuesta:`;

    console.log(`📦 Productos cargados: ${products.length} | Filtrados: ${filteredProducts.length}`);
    console.log(`🔧 Servicios cargados: ${services.length} | Filtrados: ${filteredServices.length}`);
    console.log(`📝 Tokens aprox: ${Math.round(prompt.length / 4)}`);

    try {

        const result = await model.generateContent(prompt);
        return result.response.text();

    } catch (error) {

        const isRateLimit = error.status === 429;
        const canRetry = retries > 0;

        if (isRateLimit && canRetry) {
            const delay = getRetryDelay(error);
            // Solo reintentar si la espera es corta (<=15s), si no, fallar rápido
            if (delay <= 15000) {
                console.log(`⏳ Rate limit. Reintentando en ${delay / 1000}s... (intentos restantes: ${retries - 1})`);
                await sleep(delay);
                return askAI(message, retries - 1);
            }
            console.log(`⏳ Rate limit con espera larga (${delay / 1000}s). Fallando rápido.`);
        }

        if (isRateLimit) {
            throw new Error("El asistente está ocupado en este momento. Intenta de nuevo en unos segundos.");
        }

        throw error;
    }
}

module.exports = {
    askAI
};