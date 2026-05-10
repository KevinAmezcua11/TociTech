import { useState, useRef, useEffect, useCallback } from "react";
import {
    Search, Bell, Package, ShoppingBag, CreditCard,
    AlertTriangle, CheckCheck, X,
} from "lucide-react";
import { useNavigate } from "react-router-dom";
import { getProducts }      from "../api/productService";
import { getServices }      from "../api/serviceService";
import { getClients }       from "../api/userService";
import { getNotifications, markAllAsRead } from "../api/notificationService";

// ─── Helpers ─────────────────────────────────────────────────────────────────

function getGreeting() {
    const h = new Date().getHours();
    if (h < 12) return "Buenos días";
    if (h < 18) return "Buenas tardes";
    return "Buenas noches";
}

function timeAgo(date) {
    if (!date) return "";
    const diff = Math.floor((Date.now() - new Date(date)) / 1000);
    if (diff < 60)    return "Ahora";
    if (diff < 3600)  return `Hace ${Math.floor(diff / 60)} min`;
    if (diff < 86400) return `Hace ${Math.floor(diff / 3600)} h`;
    return `Hace ${Math.floor(diff / 86400)} d`;
}

// ─── Config visual por tipo de notificación ───────────────────────────────────

const NOTIF_CONFIG = {
    stock_bajo:    { Icon: AlertTriangle, color: "text-orange-400", bg: "bg-orange-400/10", dot: "bg-orange-400" },
    sin_stock:     { Icon: Package,       color: "text-red-400",    bg: "bg-red-400/10",    dot: "bg-red-400"    },
    nueva_venta:   { Icon: ShoppingBag,   color: "text-green-400",  bg: "bg-green-400/10",  dot: "bg-green-400"  },
    pago_recibido: { Icon: CreditCard,    color: "text-green-400",  bg: "bg-green-400/10",  dot: "bg-green-400"  },
};
const DEFAULT_NOTIF = { Icon: Bell, color: "text-primary", bg: "bg-primary/10", dot: "bg-primary" };

const storedUser = JSON.parse(localStorage.getItem("user") || "null");
const USER_NAME  = storedUser?.names?.split(" ")[0] || "Usuario";

// ─── Componente ───────────────────────────────────────────────────────────────

export default function Header() {
    const navigate = useNavigate();

    // Búsqueda
    const [search,      setSearch]      = useState("");
    const [results,     setResults]     = useState([]);
    const [showResults, setShowResults] = useState(false);
    const [searchData,  setSearchData]  = useState({ products: [], services: [], customers: [] });

    // Notificaciones
    const [showNotif,  setShowNotif]  = useState(false);
    const [notifs,     setNotifs]     = useState([]);
    const [stockAlerts, setStockAlerts] = useState([]);
    const [marking,    setMarking]    = useState(false);

    const searchRef = useRef(null);
    const notifRef  = useRef(null);

    // ── Cargar datos de búsqueda + alertas de stock ──────────────────────────
    useEffect(() => {
        (async () => {
            try {
                const [prods, svcs, clients] = await Promise.all([
                    getProducts(),
                    getServices(),
                    getClients(),
                ]);
                setSearchData({ products: prods, services: svcs, customers: clients });

                // Alertas de stock derivadas de productos
                const alerts = prods
                    .filter(p => p.stock === 0 || (p.minStock != null && p.stock <= p.minStock))
                    .map(p => ({
                        id:       `stock-${p.id}`,
                        type:     p.stock === 0 ? "sin_stock" : "stock_bajo",
                        title:    p.stock === 0 ? "Sin stock" : "Stock bajo",
                        message:  p.stock === 0
                            ? `"${p.name}" está agotado.`
                            : `"${p.name}" tiene ${p.stock} unidades (mín. ${p.minStock}).`,
                        leido:     false,
                        createdAt: null,
                    }));
                setStockAlerts(alerts);
            } catch (err) {
                console.error("[Header] search data:", err);
            }
        })();
    }, []);

    // ── Polling de notificaciones cada 10 s ──────────────────────────────────
    const fetchNotifs = useCallback(async () => {
        try {
            const data = await getNotifications();
            setNotifs(data);
        } catch (err) {
            console.error("[Header] notifications:", err);
        }
    }, []);

    useEffect(() => {
        fetchNotifs();
        const id = setInterval(fetchNotifs, 10_000);
        return () => clearInterval(id);
    }, [fetchNotifs]);

    // ── Cerrar al click fuera ─────────────────────────────────────────────────
    useEffect(() => {
        const handler = (e) => {
            if (searchRef.current && !searchRef.current.contains(e.target)) setShowResults(false);
            if (notifRef.current  && !notifRef.current.contains(e.target))  setShowNotif(false);
        };
        document.addEventListener("mousedown", handler);
        return () => document.removeEventListener("mousedown", handler);
    }, []);

    // ── Búsqueda ─────────────────────────────────────────────────────────────
    const handleSearch = (value) => {
        setSearch(value);
        if (!value.trim()) { setResults([]); setShowResults(false); return; }

        const q = value.toLowerCase();
        const found = [
            ...searchData.products.filter(p => p.name?.toLowerCase().includes(q))
                .map(p => ({ type: "Producto", label: p.name, id: p.id })),
            ...searchData.services.filter(s => s.name?.toLowerCase().includes(q))
                .map(s => ({ type: "Servicio", label: s.name, id: s.id })),
            ...searchData.customers
                .filter(c => `${c.names} ${c.lastnames}`.toLowerCase().includes(q))
                .map(c => ({ type: "Cliente", label: `${c.names} ${c.lastnames}`, id: c.id })),
        ];
        setResults(found.slice(0, 6));
        setShowResults(true);
    };

    const handleSelect = (item) => {
        setSearch("");
        setShowResults(false);
        if (item.type === "Producto") navigate("/products");
        if (item.type === "Servicio") navigate("/services");
        if (item.type === "Cliente")  navigate("/customers");
    };

    // ── Notificaciones: abrir / cerrar / marcar leídas ────────────────────────
    const unreadCount = notifs.filter(n => !n.leido).length + stockAlerts.length;

    const handleToggleNotif = async () => {
        const opening = !showNotif;
        setShowNotif(opening);

        if (opening && notifs.some(n => !n.leido)) {
            setMarking(true);
            try {
                await markAllAsRead();
                setNotifs(prev => prev.map(n => ({ ...n, leido: true })));
            } catch (_) { /* silent */ } finally {
                setMarking(false);
            }
        }
    };

    // Combina alertas de stock (siempre arriba) + notificaciones Firestore
    const allNotifs = [
        ...stockAlerts,
        ...notifs,
    ];

    // ── Render ────────────────────────────────────────────────────────────────
    return (
        <header className="w-full bg-surfaceDark/80 backdrop-blur-md border-b border-white/5
                           px-8 py-3.5 flex items-center justify-between gap-4 sticky top-0 z-10">

            {/* ── Búsqueda ── */}
            <div
                ref={searchRef}
                className="relative flex items-center gap-3 bg-surface border border-white/6
                           rounded-xl px-4 py-2.5 w-96 group
                           focus-within:border-primary/40 transition-all duration-200"
            >
                <Search size={14} className="text-muted shrink-0 group-focus-within:text-primary transition-colors" />

                <input
                    type="text"
                    placeholder="Buscar productos, servicios, clientes..."
                    value={search}
                    onChange={e => handleSearch(e.target.value)}
                    onFocus={() => search && setShowResults(true)}
                    className="bg-transparent text-sm text-white placeholder:text-muted outline-none w-full"
                />

                {search && (
                    <button
                        onClick={() => { setSearch(""); setResults([]); setShowResults(false); }}
                        className="text-muted hover:text-white transition-colors"
                    >
                        <X size={13} />
                    </button>
                )}

                {showResults && (
                    <div className="absolute top-full left-0 mt-2 w-full bg-surface border border-white/10 rounded-xl shadow-xl overflow-hidden z-50">
                        {results.length === 0 ? (
                            <div className="px-4 py-3 text-xs text-muted">Sin resultados para "{search}"</div>
                        ) : (
                            results.map((item, i) => (
                                <button
                                    key={i}
                                    onClick={() => handleSelect(item)}
                                    className="w-full px-4 py-2.5 text-sm text-white hover:bg-white/5 cursor-pointer flex justify-between items-center transition-colors"
                                >
                                    <span>{item.label}</span>
                                    <span className="text-[10px] text-muted uppercase tracking-wider bg-white/5 px-1.5 py-0.5 rounded">
                                        {item.type}
                                    </span>
                                </button>
                            ))
                        )}
                    </div>
                )}
            </div>

            <div className="flex items-center gap-4">

                {/* ── Saludo ── */}
                <div className="hidden md:flex flex-col items-end">
                    <span className="text-muted text-xs">{getGreeting()},</span>
                    <span className="text-white text-sm font-semibold">{USER_NAME} 👋</span>
                </div>

                <div className="w-px h-7 bg-white/8 hidden md:block" />

                {/* ── Campana de notificaciones ── */}
                <div ref={notifRef} className="relative">

                    <button
                        onClick={handleToggleNotif}
                        className="relative w-10 h-10 flex items-center justify-center
                                   rounded-xl bg-surface border border-white/5
                                   text-muted hover:text-white hover:border-white/15 transition-all"
                    >
                        <Bell size={15} />

                        {unreadCount > 0 && (
                            <span className="absolute -top-1 -right-1 flex items-center justify-center
                                             min-w-[18px] h-[18px] px-1 rounded-full bg-primary text-white
                                             text-[10px] font-bold leading-none">
                                {unreadCount > 99 ? "99+" : unreadCount}
                            </span>
                        )}
                    </button>

                    {/* ── Panel de notificaciones ── */}
                    {showNotif && (
                        <div className="absolute right-0 top-full mt-2 w-[360px] bg-surface border border-white/10 rounded-xl shadow-2xl z-50 overflow-hidden">

                            {/* Cabecera del panel */}
                            <div className="flex items-center justify-between px-4 py-3 border-b border-white/8">
                                <div className="flex items-center gap-2">
                                    <p className="text-white text-sm font-semibold">Notificaciones</p>
                                    {unreadCount > 0 && (
                                        <span className="px-1.5 py-0.5 rounded-full bg-primary/20 text-primary text-[10px] font-bold">
                                            {unreadCount}
                                        </span>
                                    )}
                                </div>
                                {marking && (
                                    <span className="text-xs text-muted flex items-center gap-1">
                                        <CheckCheck size={12} /> Marcando...
                                    </span>
                                )}
                            </div>

                            {/* Lista */}
                            <div className="max-h-[420px] overflow-y-auto">
                                {allNotifs.length === 0 ? (
                                    <div className="flex flex-col items-center py-10 gap-2 text-muted">
                                        <Bell size={28} className="opacity-30" />
                                        <p className="text-xs">Sin notificaciones</p>
                                    </div>
                                ) : (
                                    <div className="p-2 space-y-1">
                                        {allNotifs.map((n) => {
                                            const cfg = NOTIF_CONFIG[n.type] ?? DEFAULT_NOTIF;
                                            const { Icon } = cfg;
                                            const isUnread = !n.leido;
                                            return (
                                                <div
                                                    key={n.id}
                                                    className={`flex gap-3 p-3 rounded-xl transition-colors
                                                        ${isUnread ? "bg-white/[0.05]" : "hover:bg-white/[0.03]"}`}
                                                >
                                                    {/* Icono */}
                                                    <div className={`flex-shrink-0 w-8 h-8 rounded-lg flex items-center justify-center ${cfg.bg}`}>
                                                        <Icon size={15} className={cfg.color} />
                                                    </div>

                                                    {/* Contenido */}
                                                    <div className="flex-1 min-w-0">
                                                        <div className="flex items-start justify-between gap-2">
                                                            <p className="text-white text-xs font-semibold leading-snug">
                                                                {n.title}
                                                            </p>
                                                            {isUnread && (
                                                                <span className={`flex-shrink-0 w-1.5 h-1.5 rounded-full mt-1 ${cfg.dot}`} />
                                                            )}
                                                        </div>
                                                        <p className="text-muted text-xs mt-0.5 leading-relaxed line-clamp-2">
                                                            {n.message}
                                                        </p>
                                                        {n.createdAt && (
                                                            <p className="text-white/25 text-[10px] mt-1">
                                                                {timeAgo(n.createdAt)}
                                                            </p>
                                                        )}
                                                    </div>
                                                </div>
                                            );
                                        })}
                                    </div>
                                )}
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </header>
    );
}
