const { GoogleGenerativeAI } = require("@google/generative-ai");

const Product = require("../models/product.model");
const Service = require("../models/services.model");

const cache = new Map();

const genAI = new GoogleGenerativeAI(
    process.env.GEMINI_API_KEY
);

const model = genAI.getGenerativeModel({
    model: "gemini-2.0-flash",
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
    const cacheKey = message.toLowerCase().trim();

    if (cache.has(cacheKey)) {
        console.log("✅ Respuesta desde caché");
        return cache.get(cacheKey);
    }

    const lower = message.toLowerCase();

    const loadProducts = needsProducts(message);
    const loadServices = needsServices(message);

    const products = loadProducts ? await Product.getAllProducts() : [];
    const services = loadServices ? await Service.getAllServices() : [];

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

    const filteredServices = services.filter(service => {
        const text = `
            ${service.name}
            ${service.description}
        `.toLowerCase();

        return lower
            .split(" ")
            .some(word => word.length > 2 && text.includes(word));
    }).slice(0, 3);

    const productsContext = filteredProducts.length > 0
        ? filteredProducts.map(p =>
            `• ${p.name} (${p.brand}) - $${p.price} - Stock: ${p.stock}`
        ).join("\n")
        : loadProducts ? "Sin productos relacionados." : "";

    const servicesContext = filteredServices.length > 0
        ? filteredServices.map(s =>
            `• ${s.name} - $${s.price} - ${s.duration}`
        ).join("\n")
        : loadServices ? "Sin servicios relacionados." : "";

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
        const reply = result.response.text();

        // Guardar en caché
        cache.set(cacheKey, reply);
        console.log("💾 Respuesta guardada en caché");

        return reply;

    } catch (error) {

        const isRateLimit = error.status === 429;
        const canRetry = retries > 0;

        if (isRateLimit && canRetry) {
            const delay = getRetryDelay(error);
            if (delay <= 8000) {
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