import api from "./api";

const API_URL = "http://localhost:3000/api";

export const getDashboardData = async () => {
    const [products, services] = await Promise.all([
        api.get("/products"),
        api.get("/services")
    ]);

    return {
        products: products.data,
        services: services.data
    };
};