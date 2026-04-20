import { useState } from "react";
import {
    AreaChart, Area, BarChart, Bar, XAxis, YAxis,
    Tooltip, ResponsiveContainer, CartesianGrid
} from "recharts";
import {
    ArrowUpRight, TrendingUp, ShoppingCart,
    Users, Package, ArrowDownUp, MoreHorizontal
} from "lucide-react";
import Sidebar from "../components/Sidebar";
import Header from "../components/Header";

// ── Datos de ejemplo ──────────────────────────────────────────────────────────
const areaData = [
    { mes: "Ene", ventas: 32000, pedidos: 140 },
    { mes: "Feb", ventas: 41000, pedidos: 180 },
    { mes: "Mar", ventas: 38000, pedidos: 160 },
    { mes: "Abr", ventas: 55000, pedidos: 210 },
    { mes: "May", ventas: 49000, pedidos: 195 },
    { mes: "Jun", ventas: 63000, pedidos: 240 },
    { mes: "Jul", ventas: 58000, pedidos: 220 },
    { mes: "Ago", ventas: 72000, pedidos: 264 },
    { mes: "Sep", ventas: 68000, pedidos: 255 },
];

const barData = [
    { name: "Lun", value: 42 },
    { name: "Mar", value: 78 },
    { name: "Mié", value: 55 },
    { name: "Jue", value: 91 },
    { name: "Vie", value: 63 },
    { name: "Sáb", value: 38 },
    { name: "Dom", value: 29 },
];

const orders = [
    { id: "#324561324", assignee: "Edgar Humbert",  from: "🇬🇧 London, UK",  to: "🇪🇪 Tallinn, EE", date: "12 Sep, 2024", status: "Recogido",   statusColor: "text-brand-green" },
    { id: "#183896772", assignee: "Craig Howard",   from: "🇮🇹 Rome, IT",    to: "🇩🇪 Berlin, DE",  date: "14 Sep, 2024", status: "En tránsito", statusColor: "text-blue"        },
    { id: "#267189302", assignee: "Timothy Hines",  from: "🇦🇪 Dubai, UAE",  to: "🇳🇴 Oslo, NO",    date: "15 Sep, 2024", status: "Recogido",   statusColor: "text-brand-green" },
    { id: "#942625346", assignee: "Lisa Collins",   from: "🇫🇷 Lyon, FR",    to: "🇮🇹 Milan, IT",   date: "18 Sep, 2024", status: "En tránsito", statusColor: "text-blue"        },
    { id: "#512748901", assignee: "María Torres",   from: "🇲🇽 CDMX, MX",   to: "🇺🇸 Dallas, US",  date: "20 Sep, 2024", status: "Pendiente",  statusColor: "text-yellow-400"  },
];

const TABS = ["Pendientes 70", "Respondidos 85", "Asignados 53", "Completados 56"];

// ── Tooltip personalizado ─────────────────────────────────────────────────────
function CustomTooltip({ active, payload, label }) {
    if (!active || !payload?.length) return null;
    return (
        <div className="bg-surface border border-white/10 rounded-xl px-4 py-3 shadow-xl">
            <p className="text-muted text-xs mb-1">{label}</p>
            {payload.map((p, i) => (
                <p key={i} className="text-white text-sm font-semibold">
                    {p.name === "ventas" ? "$" : ""}{p.value.toLocaleString()}
                    <span className="text-muted font-normal ml-1 text-xs">{p.name}</span>
                </p>
            ))}
        </div>
    );
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
function StatCard({ icon: Icon, label, value, change, accent }) {
    return (
        <div className="bg-surface border border-white/5 rounded-2xl p-5 flex flex-col gap-4">
            <div className="flex items-center justify-between">
                <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${accent}`}>
                    <Icon size={18} className="text-white" />
                </div>
                <span className="flex items-center gap-1 text-brand-green text-xs font-semibold
                                 bg-brand-green/10 px-2.5 py-1 rounded-full">
                    <ArrowUpRight size={11} />
                    {change}
                </span>
            </div>
            <div>
                <p className="text-muted text-xs mb-1">{label}</p>
                <p className="text-white text-2xl font-bold tracking-tight">{value}</p>
            </div>
        </div>
    );
}

// ── Dashboard ─────────────────────────────────────────────────────────────────
export default function Dashboard() {
    const [activeTab, setActiveTab] = useState(2);

    return (
        <div className="flex min-h-screen bg-background">
            <Sidebar />

            <div className="flex-1 flex flex-col min-w-0">
                <Header />

                <main className="flex-1 p-8 space-y-6 overflow-auto">

                    {/* ── Stat Cards ───────────────────────────────────── */}
                    <div className="grid grid-cols-2 xl:grid-cols-4 gap-4">
                        <StatCard icon={TrendingUp}   label="Ventas totales" value="$440,925" change="32.2%"  accent="bg-primary" />
                        <StatCard icon={Users}         label="Usuarios"       value="1,248"    change="12.5%"  accent="bg-blue" />
                        <StatCard icon={ShoppingCart}  label="Pedidos"        value="264"      change="8.1%"   accent="bg-brand-green/80" />
                        <StatCard icon={Package}       label="Productos"      value="53"       change="4.3%"   accent="bg-purple-500/80" />
                    </div>

                    {/* ── Gráficas ─────────────────────────────────────── */}
                    <div className="grid grid-cols-1 xl:grid-cols-5 gap-4">

                        {/* Área — ventas */}
                        <div className="xl:col-span-3 bg-surface border border-white/5 rounded-2xl p-6">
                            <div className="flex items-center justify-between mb-6">
                                <div>
                                    <p className="text-muted text-xs mb-0.5">Rendimiento de ventas</p>
                                    <p className="text-white text-2xl font-bold">$440,925</p>
                                </div>
                                <span className="flex items-center gap-1 text-brand-green text-xs font-semibold
                                                 bg-brand-green/10 px-2.5 py-1 rounded-full">
                                    <ArrowUpRight size={11} /> 32.2%
                                </span>
                            </div>
                            <ResponsiveContainer width="100%" height={180}>
                                <AreaChart data={areaData} margin={{ top: 0, right: 0, left: -20, bottom: 0 }}>
                                    <defs>
                                        <linearGradient id="gradVentas" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="5%"  stopColor="#6C63FF" stopOpacity={0.3} />
                                            <stop offset="95%" stopColor="#6C63FF" stopOpacity={0} />
                                        </linearGradient>
                                    </defs>
                                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" />
                                    <XAxis dataKey="mes" tick={{ fill: "rgba(255,255,255,0.35)", fontSize: 11 }} axisLine={false} tickLine={false} />
                                    <YAxis tick={{ fill: "rgba(255,255,255,0.35)", fontSize: 11 }} axisLine={false} tickLine={false} tickFormatter={v => `$${v/1000}k`} />
                                    <Tooltip content={<CustomTooltip />} />
                                    <Area type="monotone" dataKey="ventas" name="ventas" stroke="#6C63FF" strokeWidth={2} fill="url(#gradVentas)" dot={false} />
                                </AreaChart>
                            </ResponsiveContainer>
                        </div>

                        {/* Barras — pedidos semanales */}
                        <div className="xl:col-span-2 bg-surface border border-white/5 rounded-2xl p-6">
                            <div className="mb-6">
                                <p className="text-muted text-xs mb-0.5">Pedidos esta semana</p>
                                <p className="text-white text-2xl font-bold">264</p>
                            </div>
                            <ResponsiveContainer width="100%" height={180}>
                                <BarChart data={barData} margin={{ top: 0, right: 0, left: -20, bottom: 0 }} barSize={14}>
                                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.04)" vertical={false} />
                                    <XAxis dataKey="name" tick={{ fill: "rgba(255,255,255,0.35)", fontSize: 11 }} axisLine={false} tickLine={false} />
                                    <YAxis tick={{ fill: "rgba(255,255,255,0.35)", fontSize: 11 }} axisLine={false} tickLine={false} />
                                    <Tooltip content={<CustomTooltip />} />
                                    <Bar dataKey="value" name="pedidos" fill="#6C63FF" radius={[6, 6, 0, 0]} />
                                </BarChart>
                            </ResponsiveContainer>
                        </div>

                    </div>

                    {/* ── Tabla de Pedidos ──────────────────────────────── */}
                    <div className="bg-surface border border-white/5 rounded-2xl p-6">

                        {/* Cabecera tabla */}
                        <div className="flex items-center justify-between mb-5">
                            <div className="flex items-center gap-3">
                                <h2 className="text-white font-semibold text-base">Pedidos</h2>
                                <span className="text-xs text-muted bg-white/5 border border-white/8
                                                 px-2.5 py-0.5 rounded-full font-medium">264</span>
                            </div>
                            <button className="text-muted hover:text-white transition-colors">
                                <ArrowDownUp size={16} />
                            </button>
                        </div>

                        {/* Tabs de estado */}
                        <div className="flex items-center gap-2 mb-5 flex-wrap">
                            {TABS.map((tab, i) => (
                                <button
                                    key={i}
                                    onClick={() => setActiveTab(i)}
                                    className={`px-4 py-2 rounded-xl text-xs font-semibold transition-all duration-200
                                                ${activeTab === i
                                            ? "bg-primary text-white shadow-md shadow-primary/20"
                                            : "text-muted hover:text-white bg-white/4 hover:bg-white/8"}`}
                                >
                                    {tab}
                                </button>
                            ))}
                        </div>

                        {/* Encabezados */}
                        <div className="grid grid-cols-[1.2fr_1.4fr_1.4fr_1.4fr_1fr_1fr_auto]
                                        gap-4 px-3 mb-3 text-muted text-xs font-medium">
                            <span>Order ID</span>
                            <span>Asignado a</span>
                            <span>Origen</span>
                            <span>Destino</span>
                            <span>Est. entrega</span>
                            <span>Estado</span>
                            <span />
                        </div>

                        {/* Filas */}
                        <div className="space-y-1">
                            {orders.map((order) => (
                                <div
                                    key={order.id}
                                    className="grid grid-cols-[1.2fr_1.4fr_1.4fr_1.4fr_1fr_1fr_auto]
                                               gap-4 items-center px-3 py-3.5 rounded-xl
                                               hover:bg-white/4 transition-colors duration-150 group"
                                >
                                    <span className="text-secondary text-sm font-mono">{order.id}</span>
                                    <span className="text-white text-sm font-medium">{order.assignee}</span>
                                    <span className="text-secondary text-sm">{order.from}</span>
                                    <span className="text-secondary text-sm">{order.to}</span>
                                    <span className="text-muted text-sm">{order.date}</span>
                                    <span className={`text-sm font-medium flex items-center gap-1.5 ${order.statusColor}`}>
                                        <span className={`w-1.5 h-1.5 rounded-full ${order.statusColor.replace("text-", "bg-")}`} />
                                        {order.status}
                                    </span>
                                    <div className="flex items-center gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                        <button className="px-3 py-1.5 rounded-lg bg-white/6 border border-white/8
                                                           text-secondary text-xs hover:text-white hover:bg-white/10
                                                           transition-all duration-150">
                                            Ver más
                                        </button>
                                        <button className="w-7 h-7 flex items-center justify-center rounded-lg
                                                           bg-white/6 border border-white/8 text-muted
                                                           hover:text-white transition-colors">
                                            <MoreHorizontal size={14} />
                                        </button>
                                    </div>
                                </div>
                            ))}
                        </div>

                    </div>

                </main>
            </div>
        </div>
    );
}