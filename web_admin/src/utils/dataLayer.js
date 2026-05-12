// Inicializar Data Layer
window.dataLayer = window.dataLayer || [];

// Función principal
export const pushEvent = (eventData) => {
    window.dataLayer.push({
        ...eventData,
        timestamp: new Date().toISOString()
    });

    console.log('[DataLayer Event]', eventData);
};

// =========================
// EVENTOS ADMIN
// =========================

// Vista de página
export const trackPageView = (pageName) => {
    pushEvent({
        event: 'page_view',
        page_name: pageName,
        page_location: window.location.href
    });
};

// Inicio de sesión
export const trackLogin = (method = 'email') => {
    pushEvent({
        event: 'login',
        method
    });
};

// Cerrar sesión
export const trackLogout = () => {
    pushEvent({
        event: 'logout'
    });
};

// Buscar
export const trackSearch = (searchTerm) => {
    pushEvent({
        event: 'search',
        search_term: searchTerm
    });
};

// Crear producto
export const trackCreateProduct = (product) => {
    pushEvent({
        event: 'create_product',
        product_id: product.id,
        product_name: product.name
    });
};

// Actualizar producto
export const trackUpdateProduct = (product) => {
    pushEvent({
        event: 'update_product',
        product_id: product.id,
        product_name: product.name
    });
};

// Eliminar producto
export const trackDeleteProduct = (productId) => {
    pushEvent({
        event: 'delete_product',
        product_id: productId
    });
};

// Crear servicio
export const trackCreateService = (service) => {
    pushEvent({
        event: 'create_service',
        service_id: service.id,
        service_name: service.name
    });
};

// Actualizar servicio
export const trackUpdateService = (service) => {
    pushEvent({
        event: 'update_service',
        service_id: service.id,
        service_name: service.name
    });
};

// Eliminar servicio
export const trackDeleteService = (serviceId) => {
    pushEvent({
        event: 'delete_service',
        service_id: serviceId
    });
};

// Actualizar estado de orden
export const trackUpdateOrderStatus = (orderId, status) => {
    pushEvent({
        event: 'update_order_status',
        order_id: orderId,
        status
    });
};