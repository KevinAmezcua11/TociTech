import { useEffect, useState, useMemo } from "react";
import Sidebar from "../components/Sidebar";
import Header from "../components/Header";
import { getOrders, updateOrder } from "../api/orderService";
import OrderSidebar from "../components/orders/OrderSidebar";
import CustomSelect from "../components/CustomSelect";
import OrderDetailsSidebar from "../components/orders/OrderDetailsSidebar";
import {
    ShoppingBag,
    Clock,
    History,
    Search,
    Plus,
    User,
    Tag,
    DollarSign,
    Calendar,
    Package,
    Wrench,
    SlidersHorizontal,
    X,
    ArrowUpDown,
    ArrowUp,
    ArrowDown,
    RotateCcw,
} from "lucide-react";

const STATUS_OPTIONS = [
    { value: "pending",     label: "Pendiente",   dot: "bg-yellow-400" },
    { value: "in_progress", label: "En progreso", dot: "bg-orange-400" },
    { value: "completed",   label: "Completado",  dot: "bg-green-400"  },
    { value: "cancelled",   label: "Cancelado",   dot: "bg-red-400"    },
];

const STATUS_CONFIG = {
    pending:     { label: "Pendiente",   color: "bg-yellow-500/15 text-yellow-400 border border-yellow-500/25", dot: "bg-yellow-400" },
    in_progress: { label: "En progreso", color: "bg-orange-500/15 text-orange-400 border border-orange-500/25", dot: "bg-orange-400" },
    completed:   { label: "Completado",  color: "bg-green-500/15  text-green-400  border border-green-500/25",  dot: "bg-green-400"  },
    cancelled:   { label: "Cancelado",   color: "bg-red-500/15    text-red-400    border border-red-500/25",    dot: "bg-red-400"    },
};

const PRIORITY_CONFIG = {
    high:   { label: "Alta",  color: "bg-red-500/15 text-red-400 border border-red-500/25" },
    medium: { label: "Media", color: "bg-yellow-500/15 text-yellow-400 border border-yellow-500/25" },
    low:    { label: "Baja",  color: "bg-green-500/15 text-green-400 border border-green-500/25" },
};

const FILTER_STATUS_OPTIONS = [
    { value: "",            label: "Todos los estados" },
    { value: "pending",     label: "Pendiente",   dot: "bg-yellow-400" },
    { value: "in_progress", label: "En progreso", dot: "bg-orange-400" },
    { value: "completed",   label: "Completado",  dot: "bg-green-400"  },
    { value: "cancelled",   label: "Cancelado",   dot: "bg-red-400"    },
];

const FILTER_TYPE_OPTIONS = [
    { value: "",         label: "Todos los tipos"  },
    { value: "product",  label: "Producto"          },
    { value: "service",  label: "Servicio"          },
];

const SORT_OPTIONS = [
    { value: "date_desc", label: "Fecha: más reciente" },
    { value: "date_asc",  label: "Fecha: más antigua"  },
    { value: "total_desc",label: "Total: mayor a menor" },
    { value: "total_asc", label: "Total: menor a mayor" },
]; 

const DEFAULT_FILTERS = { status: "", type: "", dateFrom: "", dateTo: "", sort: "date_desc" };

function countActiveFilters(f) {
    return [f.status, f.type, f.dateFrom, f.dateTo, f.sort !== "date_desc" ? f.sort : ""]
        .filter(Boolean).length;
}

export default function Orders() {
    const [orders, setOrders]       = useState([]);
    const [loading, setLoading]     = useState(true);
    const [statusFilter, setStatusFilter] = useState("active"); // tabs activos/historial
    const [search, setSearch]       = useState("");
    const [showSidebar, setShowSidebar]   = useState(false);
    const [showFilters, setShowFilters]   = useState(false);
    const [filters, setFilters]     = useState(DEFAULT_FILTERS);
    const [showConfirmModal, setShowConfirmModal] = useState(false);
    const [selectedOrder, setSelectedOrder] = useState(null);
    const [pendingStatus, setPendingStatus] = useState("");
    const [showDetails, setShowDetails] = useState(false);
    const [selectedOrderDetails, setSelectedOrderDetails] = useState(null);

    const fetchOrders = async () => {
        try {
            const data = await getOrders();
            setOrders(data);
        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => { fetchOrders(); }, []);

    // Cambiar estado 
    const handleStatusChange = (id, newStatus) => {
        if (newStatus === "completed" || newStatus === "cancelled") {
            setSelectedOrder(id);
            setPendingStatus(newStatus);
            setShowConfirmModal(true);
            return;
        }

        updateOrder(id, { status: newStatus });
        setOrders(prev =>
            prev.map(o => o.id === id ? { ...o, status: newStatus } : o)
        );
    };

    const confirmStatusChange = async () => {
        try {
            await updateOrder(selectedOrder, { status: pendingStatus });

            setOrders(prev =>
                prev.map(o =>
                    o.id === selectedOrder ? { ...o, status: pendingStatus } : o
                )
            );

            setShowConfirmModal(false);
        } catch (err) {
            console.error(err);
            alert("Error al actualizar estado");
        }
    };

    // Contadores tabs 
    const counts = useMemo(() => ({
        active:  orders.filter(o => o.status === "pending" || o.status === "in_progress").length,
        history: orders.filter(o => o.status === "completed" || o.status === "cancelled").length,
    }), [orders]);

    // Pipeline de filtros + orden 
    const filteredOrders = useMemo(() => {
        let result = [...orders];

        // Tab activos / historial
        if (statusFilter === "active") {
            result = result.filter(o => o.status === "pending" || o.status === "in_progress");
        } else if (statusFilter === "history") {
            result = result.filter(o => o.status === "completed" || o.status === "cancelled");
        }

        // Búsqueda por cliente
        if (search) {
            const q = search.toLowerCase();
            result = result.filter(o => o.customer?.name?.toLowerCase().includes(q));
        }

        // Filtro estado específico
        if (filters.status) {
            result = result.filter(o => o.status === filters.status);
        }

        // Filtro tipo
        if (filters.type) {
            result = result.filter(o => o.type === filters.type);
        }

        // Filtro fecha desde
        if (filters.dateFrom) {
            const from = new Date(filters.dateFrom);
            result = result.filter(o => o.createdAt && new Date(o.createdAt) >= from);
        }

        // Filtro fecha hasta
        if (filters.dateTo) {
            const to = new Date(filters.dateTo);
            to.setHours(23, 59, 59, 999);
            result = result.filter(o => o.createdAt && new Date(o.createdAt) <= to);
        }

        // Ordenamiento
        result.sort((a, b) => {
            const priorityOrder = { high: 3, medium: 2, low: 1 };

            const pa = priorityOrder[a.priority] || 0;
            const pb = priorityOrder[b.priority] || 0;

            if (pb !== pa) return pb - pa;

            switch (filters.sort) {
                case "date_asc":
                    return new Date(a.createdAt) - new Date(b.createdAt);
                case "date_desc":
                    return new Date(b.createdAt) - new Date(a.createdAt);
                case "total_desc":
                    return (b.total ?? 0) - (a.total ?? 0);
                case "total_asc":
                    return (a.total ?? 0) - (b.total ?? 0);
                default:
                    return 0;
            }
        });

        return result;
    }, [orders, statusFilter, search, filters]);

    const activeFilterCount = countActiveFilters(filters);
    const hasFilters = activeFilterCount > 0;

    const resetFilters = () => setFilters(DEFAULT_FILTERS);

    const setFilter = (key, value) =>
        setFilters(prev => ({ ...prev, [key]: value }));

    const SortIcon = filters.sort.includes("asc") ? ArrowUp : filters.sort.includes("desc") ? ArrowDown : ArrowUpDown;

    return (
        <div className="flex min-h-screen bg-background">
            <Sidebar />

            <div className="flex-1 flex flex-col min-w-0">
                <Header />

                <main className="flex-1 p-8 space-y-6 overflow-auto">

                    {/* Header */}
                    <div className="flex justify-between items-center">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-primary/15 rounded-lg border border-primary/20">
                                <ShoppingBag size={20} className="text-primary" />
                            </div>
                            <div>
                                <h1 className="text-xl font-bold text-white leading-tight">Pedidos</h1>
                                <p className="text-xs text-muted mt-0.5">Gestiona y actualiza tus pedidos</p>
                            </div>
                        </div>

                        <button
                            onClick={() => setShowSidebar(true)}
                            className="flex items-center gap-2 bg-primary px-4 py-2 rounded-lg text-white text-sm font-medium hover:opacity-90 transition-opacity"
                        >
                            <Plus size={16} />
                            Nuevo pedido
                        </button>
                    </div>

                    {/* Stats rápidas */}
                    <div className="grid grid-cols-2 gap-3">
                        <div className="bg-surface rounded-xl border border-white/10 p-4 flex items-center gap-3">
                            <div className="p-2 bg-yellow-500/10 rounded-lg border border-yellow-500/20">
                                <Clock size={18} className="text-yellow-400" />
                            </div>
                            <div>
                                <p className="text-2xl font-bold text-white">{counts.active}</p>
                                <p className="text-xs text-muted">Activos</p>
                            </div>
                        </div>
                        <div className="bg-surface rounded-xl border border-white/10 p-4 flex items-center gap-3">
                            <div className="p-2 bg-green-500/10 rounded-lg border border-green-500/20">
                                <History size={18} className="text-green-400" />
                            </div>
                            <div>
                                <p className="text-2xl font-bold text-white">{counts.history}</p>
                                <p className="text-xs text-muted">Historial</p>
                            </div>
                        </div>
                    </div>

                    {/* Tabs + búsqueda + botón filtros */}
                    <div className="flex flex-col sm:flex-row gap-3">
                        {/* Tabs */}
                        <div className="flex gap-2 bg-surface rounded-lg border border-white/10 p-1 flex-shrink-0">
                            {[
                                { key: "active",  label: "Activos",   count: counts.active  },
                                { key: "history", label: "Historial", count: counts.history },
                            ].map(tab => (
                                <button
                                    key={tab.key}
                                    onClick={() => setStatusFilter(tab.key)}
                                    className={`flex items-center gap-2 px-4 py-2 rounded-md text-sm font-medium transition-all ${
                                        statusFilter === tab.key
                                            ? "bg-primary text-white shadow-sm"
                                            : "text-secondary hover:text-white"
                                    }`}
                                >
                                    {tab.key === "active" ? <Clock size={14} /> : <History size={14} />}
                                    {tab.label}
                                    <span className={`text-xs px-1.5 py-0.5 rounded-full font-semibold ${
                                        statusFilter === tab.key ? "bg-white/20 text-white" : "bg-white/10 text-muted"
                                    }`}>
                                        {tab.count}
                                    </span>
                                </button>
                            ))}
                        </div>

                        {/* Búsqueda */}
                        <div className="relative flex-1">
                            <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted" />
                            <input
                                type="text"
                                placeholder="Buscar por cliente..."
                                value={search}
                                onChange={(e) => setSearch(e.target.value)}
                                className="w-full bg-surface border border-white/10 rounded-lg pl-9 pr-4 py-2.5 text-sm text-white placeholder:text-muted outline-none focus:border-primary/50 transition-colors"
                            />
                        </div>

                        {/* Botón filtros */}
                        <button
                            onClick={() => setShowFilters(v => !v)}
                            className={`relative flex items-center gap-2 px-4 py-2.5 rounded-lg text-sm font-medium border transition-all flex-shrink-0 ${
                                showFilters || hasFilters
                                    ? "bg-primary/15 border-primary/40 text-primary"
                                    : "bg-surface border-white/10 text-secondary hover:text-white hover:border-white/20"
                            }`}
                        >
                            <SlidersHorizontal size={15} />
                            Filtros
                            {hasFilters && (
                                <span className="w-5 h-5 rounded-full bg-primary text-white text-xs flex items-center justify-center font-bold">
                                    {activeFilterCount}
                                </span>
                            )}
                        </button>
                    </div>

                    {/* Panel de filtros */}
                    {showFilters && (
                        <div className="bg-surface border border-white/10 rounded-xl p-4 space-y-4">
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-2">
                                    <SlidersHorizontal size={14} className="text-muted" />
                                    <span className="text-sm font-medium text-white">Filtros avanzados</span>
                                </div>
                                {hasFilters && (
                                    <button
                                        onClick={resetFilters}
                                        className="flex items-center gap-1.5 text-xs text-muted hover:text-white transition-colors"
                                    >
                                        <RotateCcw size={12} />
                                        Limpiar filtros
                                    </button>
                                )}
                            </div>

                            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">

                                {/* Filtro estado */}
                                <div className="space-y-1.5">
                                    <label className="text-xs text-muted font-medium uppercase tracking-wider flex items-center gap-1.5">
                                        <span className="w-1.5 h-1.5 rounded-full bg-yellow-400" />
                                        Estado
                                    </label>
                                    <CustomSelect
                                        value={filters.status}
                                        onChange={(v) => setFilter("status", v)}
                                        options={FILTER_STATUS_OPTIONS}
                                        placeholder="Todos los estados"
                                    />
                                </div>

                                {/* Filtro tipo */}
                                <div className="space-y-1.5">
                                    <label className="text-xs text-muted font-medium uppercase tracking-wider flex items-center gap-1.5">
                                        <Tag size={11} />
                                        Tipo
                                    </label>
                                    <CustomSelect
                                        value={filters.type}
                                        onChange={(v) => setFilter("type", v)}
                                        options={FILTER_TYPE_OPTIONS}
                                        placeholder="Todos los tipos"
                                    />
                                </div>

                                {/* Rango de fechas */}
                                <div className="space-y-1.5">
                                    <label className="text-xs text-muted font-medium uppercase tracking-wider flex items-center gap-1.5">
                                        <Calendar size={11} />
                                        Desde
                                    </label>
                                    <div className="relative">
                                        <input
                                            type="date"
                                            value={filters.dateFrom}
                                            onChange={(e) => setFilter("dateFrom", e.target.value)}
                                            className="w-full bg-white/5 border border-white/10 text-white text-sm p-2.5 rounded-lg outline-none focus:border-primary/50 transition-colors [color-scheme:dark]"
                                        />
                                        {filters.dateFrom && (
                                            <button
                                                onClick={() => setFilter("dateFrom", "")}
                                                className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted hover:text-white"
                                            >
                                                <X size={13} />
                                            </button>
                                        )}
                                    </div>
                                </div>

                                <div className="space-y-1.5">
                                    <label className="text-xs text-muted font-medium uppercase tracking-wider flex items-center gap-1.5">
                                        <Calendar size={11} />
                                        Hasta
                                    </label>
                                    <div className="relative">
                                        <input
                                            type="date"
                                            value={filters.dateTo}
                                            onChange={(e) => setFilter("dateTo", e.target.value)}
                                            className="w-full bg-white/5 border border-white/10 text-white text-sm p-2.5 rounded-lg outline-none focus:border-primary/50 transition-colors [color-scheme:dark]"
                                        />
                                        {filters.dateTo && (
                                            <button
                                                onClick={() => setFilter("dateTo", "")}
                                                className="absolute right-2.5 top-1/2 -translate-y-1/2 text-muted hover:text-white"
                                            >
                                                <X size={13} />
                                            </button>
                                        )}
                                    </div>
                                </div>
                            </div>

                            {/* Ordenamiento */}
                            <div className="pt-1 border-t border-white/8">
                                <div className="space-y-1.5">
                                    <label className="text-xs text-muted font-medium uppercase tracking-wider flex items-center gap-1.5">
                                        <ArrowUpDown size={11} />
                                        Ordenar por
                                    </label>
                                    <div className="flex flex-wrap gap-2">
                                        {SORT_OPTIONS.map(opt => (
                                            <button
                                                key={opt.value}
                                                onClick={() => setFilter("sort", opt.value)}
                                                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium border transition-all ${
                                                    filters.sort === opt.value
                                                        ? "bg-primary/15 border-primary/40 text-primary"
                                                        : "bg-white/5 border-white/10 text-secondary hover:border-white/20 hover:text-white"
                                                }`}
                                            >
                                                {opt.value.includes("asc")
                                                    ? <ArrowUp size={11} />
                                                    : <ArrowDown size={11} />
                                                }
                                                {opt.label}
                                            </button>
                                        ))}
                                    </div>
                                </div>
                            </div>
                        </div>
                    )}

                    {/* Chips de filtros activos */}
                    {hasFilters && (
                        <div className="flex flex-wrap gap-2 items-center">
                            <span className="text-xs text-muted">Filtros activos:</span>
                            {filters.status && (
                                <Chip
                                    label={FILTER_STATUS_OPTIONS.find(o => o.value === filters.status)?.label}
                                    dot={FILTER_STATUS_OPTIONS.find(o => o.value === filters.status)?.dot}
                                    onRemove={() => setFilter("status", "")}
                                />
                            )}
                            {filters.type && (
                                <Chip
                                    label={FILTER_TYPE_OPTIONS.find(o => o.value === filters.type)?.label}
                                    onRemove={() => setFilter("type", "")}
                                />
                            )}
                            {filters.dateFrom && (
                                <Chip
                                    label={`Desde ${new Date(filters.dateFrom + "T00:00:00").toLocaleDateString("es-MX", { day: "2-digit", month: "short" })}`}
                                    onRemove={() => setFilter("dateFrom", "")}
                                />
                            )}
                            {filters.dateTo && (
                                <Chip
                                    label={`Hasta ${new Date(filters.dateTo + "T00:00:00").toLocaleDateString("es-MX", { day: "2-digit", month: "short" })}`}
                                    onRemove={() => setFilter("dateTo", "")}
                                />
                            )}
                            {filters.sort !== "date_desc" && (
                                <Chip
                                    label={SORT_OPTIONS.find(o => o.value === filters.sort)?.label}
                                    onRemove={() => setFilter("sort", "date_desc")}
                                />
                            )}
                        </div>
                    )}

                    {/* Tabla */}
                    <div className="bg-surface rounded-xl border border-white/10 overflow-hidden">
                        {loading ? (
                            <div className="flex items-center justify-center gap-3 p-12 text-muted">
                                <div className="w-4 h-4 border-2 border-primary/40 border-t-primary rounded-full animate-spin" />
                                <span className="text-sm">Cargando pedidos...</span>
                            </div>
                        ) : filteredOrders.length === 0 ? (
                            <div className="flex flex-col items-center justify-center py-14 gap-3">
                                <div className="p-3 bg-white/5 rounded-full">
                                    <ShoppingBag size={24} className="text-muted" />
                                </div>
                                <p className="text-sm text-muted">No hay pedidos con estos filtros</p>
                                {hasFilters && (
                                    <button
                                        onClick={resetFilters}
                                        className="text-xs text-primary hover:underline flex items-center gap-1"
                                    >
                                        <RotateCcw size={11} /> Limpiar filtros
                                    </button>
                                )}
                            </div>
                        ) : (
                            <table className="w-full text-sm">
                                <thead className="bg-white/5 border-b border-white/10">
                                    <tr>
                                        <th className="px-4 py-3 w-10 text-center"></th>

                                        <th className="px-4 py-3 text-left">
                                            <span className="flex items-center gap-1.5 text-xs font-medium text-muted uppercase tracking-wider">
                                                <User size={12} /> Cliente
                                            </span>
                                        </th>
                                        <th className="px-4 py-3 text-left">
                                            <span className="flex items-center gap-1.5 text-xs font-medium text-muted uppercase tracking-wider">
                                                <Tag size={12} /> Tipo
                                            </span>
                                        </th>
                                        <th className="px-4 py-3 text-left">
                                            <span className="text-xs font-medium text-muted uppercase tracking-wider">
                                                Estado
                                            </span>
                                        </th>
                                        <th className="px-4 py-3 text-left">
                                            <span className="flex items-center gap-1.5 text-xs font-medium text-muted uppercase tracking-wider">
                                                <DollarSign size={12} /> Total
                                            </span>
                                        </th>
                                        <th className="px-4 py-3 text-center">
                                            <span className="text-xs font-medium text-muted uppercase tracking-wider">
                                                Prioridad
                                            </span>
                                        </th>
                                        <th className="px-4 py-3 text-center">
                                            <span className="text-xs font-medium text-muted uppercase tracking-wider">
                                                Detalle
                                            </span>
                                        </th>
                                        <th className="px-4 py-3 text-left">
                                            <span className="flex items-center gap-1.5 text-xs font-medium text-muted uppercase tracking-wider">
                                                <Calendar size={12} /> Fecha
                                            </span>
                                        </th>
                                    </tr>
                                </thead>

                                <tbody className="divide-y divide-white/5">
                                    {filteredOrders.map((order, index) => {
                                        const cfg = STATUS_CONFIG[order.status] || STATUS_CONFIG.pending;
                                        return (
                                            <tr key={order.id} className="hover:bg-white/[0.02] transition-colors">
                                                <td className="px-4 py-3 text-center align-middle text-muted text-xs font-medium tabular-nums">
                                                    {index + 1}
                                                </td>

                                                <td className="px-4 py-3">
                                                    <div className="flex items-center gap-2.5">
                                                        <div className="w-7 h-7 rounded-full bg-primary/15 border border-primary/20 flex items-center justify-center flex-shrink-0">
                                                            <User size={12} className="text-primary" />
                                                        </div>
                                                        <span className="text-white font-medium text-sm">
                                                            {order.customer?.name || "—"}
                                                        </span>
                                                    </div>
                                                </td>

                                                <td className="px-4 py-3">
                                                    <div className="flex items-center gap-1.5 text-secondary">
                                                        {order.type === "product"
                                                            ? <Package size={13} className="text-muted" />
                                                            : <Wrench size={13} className="text-muted" />
                                                        }
                                                        <span className="text-sm capitalize">{order.type}</span>
                                                    </div>
                                                </td>

                                                <td className="px-4 py-3">
                                                    {order.status === "completed" || order.status === "cancelled" ? (
                                                        <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium ${cfg.color}`}>
                                                            <span className={`w-1.5 h-1.5 rounded-full ${cfg.dot}`} />
                                                            {cfg.label}
                                                        </span>
                                                    ) : (
                                                        <CustomSelect
                                                            value={order.status}
                                                            onChange={(val) => handleStatusChange(order.id, val)}
                                                            options={STATUS_OPTIONS}
                                                            className="w-40"
                                                        />
                                                    )}
                                                </td>

                                                <td className="px-4 py-3">
                                                    <span className="text-secondary text-sm font-medium">
                                                        {(() => {
                                                            const total =
                                                                order.total ??
                                                                order.finalPrice ??
                                                                order.service?.basePrice;

                                                            return total != null
                                                                ? `$${Number(total).toLocaleString()}`
                                                                : "—";
                                                        })()}
                                                    </span>
                                                </td>
                                                <td className="px-4 py-3 text-center">
                                                    {(() => {
                                                        const p = PRIORITY_CONFIG[order.priority] || PRIORITY_CONFIG.medium;

                                                        return (
                                                            <span className={`inline-flex px-2.5 py-1 rounded-full text-xs font-medium ${p.color}`}>
                                                                {p.label}
                                                            </span>
                                                        );
                                                    })()}
                                                </td>
                                                <td className="px-4 py-3 text-center">
                                                    <button
                                                        onClick={() => {
                                                            setSelectedOrderDetails(order);
                                                            setShowDetails(true);
                                                        }}
                                                        className="px-3 py-1.5 text-xs font-medium rounded-lg bg-primary/15 text-primary border border-primary/30 hover:bg-primary/25 transition"
                                                    >
                                                        Ver
                                                    </button>
                                                </td>

                                                <td className="px-4 py-3">
                                                    <span className="text-muted text-sm">
                                                        {order.createdAt
                                                            ? new Date(order.createdAt).toLocaleDateString("es-MX", {
                                                                day: "2-digit", month: "short", year: "numeric",
                                                            })
                                                            : "—"}
                                                    </span>
                                                </td>
                                            </tr>
                                        );
                                    })}
                                </tbody>
                            </table>
                        )}
                    </div>

                    {showSidebar && (
                        <OrderSidebar
                            onClose={() => setShowSidebar(false)}
                            onCreated={fetchOrders}
                        />
                    )}

                    {showConfirmModal && (
                        <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50">

                            <div className="bg-surface p-6 rounded-xl w-full max-w-sm border border-white/10">

                                <h2 className="text-white text-lg font-semibold mb-2">
                                    {pendingStatus === "cancelled"
                                        ? "Cancelar pedido"
                                        : "Completar pedido"}
                                </h2>

                                <p className="text-secondary text-sm mb-6">
                                    {pendingStatus === "cancelled"
                                        ? "¿Seguro que deseas cancelar este pedido? Esta acción no se puede deshacer."
                                        : "¿Seguro que deseas marcar este pedido como completado?"}
                                </p>

                                <div className="flex justify-end gap-3">

                                    <button
                                        onClick={() => setShowConfirmModal(false)}
                                        className="px-4 py-2 rounded-lg bg-surfaceDark text-secondary hover:text-white"
                                    >
                                        Cancelar
                                    </button>

                                    <button
                                        onClick={confirmStatusChange}
                                        className={`px-4 py-2 rounded-lg text-white ${
                                            pendingStatus === "cancelled"
                                                ? "bg-red-500 hover:bg-red-600"
                                                : "bg-brand-green hover:bg-green-600"
                                        }`}
                                    >
                                        Confirmar
                                    </button>

                                </div>
                            </div>
                        </div>
                    )}

                    {showDetails && (
                        <OrderDetailsSidebar
                            order={selectedOrderDetails}
                            onClose={() => setShowDetails(false)}
                        />
                    )}
                </main>
            </div>
        </div>
    );
}

// Chip de filtro activo 
function Chip({ label, dot, onRemove }) {
    return (
        <span className="inline-flex items-center gap-1.5 pl-2.5 pr-1.5 py-1 bg-primary/10 border border-primary/25 text-primary text-xs rounded-full font-medium">
            {dot && <span className={`w-1.5 h-1.5 rounded-full ${dot}`} />}
            {label}
            <button
                onClick={onRemove}
                className="w-4 h-4 rounded-full hover:bg-primary/20 flex items-center justify-center transition-colors"
            >
                <X size={10} />
            </button>
        </span>
    );
}