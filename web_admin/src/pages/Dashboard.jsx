import { useEffect, useState } from "react";
import {
    AreaChart, Area, BarChart, Bar, XAxis, YAxis,
    Tooltip, ResponsiveContainer, CartesianGrid
} from "recharts";
import {
    ArrowUpRight, TrendingUp, ShoppingCart,
    Users, Package, Layers, DollarSign
} from "lucide-react";
import Sidebar from "../components/Sidebar";
import Header from "../components/Header";
import { getDashboardData } from "../api/dashboardService";
import { trackPageView } from "../utils/dataLayer";

const tickStyle = { fill: "rgba(255,255,255,0.35)", fontSize: 11 };

function CustomTooltip({ active, payload, label }) {
    if (!active || !payload?.length) return null;
    return (
        <div className="bg-surface border border-white/10 rounded-xl px-4 py-3 shadow-2xl">
            <p className="text-muted text-xs mb-1">{label}</p>
            {payload.map((p, i) => (
                <p key={i} className="text-white text-sm font-bold">
                    {p.name === "ventas" ? "$" : ""}
                    {typeof p.value === "number" ? p.value.toLocaleString() : p.value}
                </p>
            ))}
        </div>
    );
}

const ACCENTS = {
    purple: { orb: "bg-primary",     badge: "bg-primary/15 text-primary",        icon: "bg-primary" },
    blue:   { orb: "bg-blue",        badge: "bg-blue/15 text-blue",              icon: "bg-blue" },
    green:  { orb: "bg-brand-green", badge: "bg-brand-green/15 text-brand-green", icon: "bg-brand-green/80" },
    pink:   { orb: "bg-purple-500",  badge: "bg-purple-500/15 text-purple-400",  icon: "bg-purple-500/80" },
};

function StatCard({ icon: Icon, label, value, color = "purple", trend }) {
    const a = ACCENTS[color];
    return (
        <div className="relative bg-surface border border-white/5 rounded-2xl p-5 flex flex-col gap-3 overflow-hidden">
            <div className={`absolute -top-5 -right-5 w-28 h-28 rounded-full blur-2xl opacity-20 ${a.orb}`} />
            <div className="flex items-start justify-between relative">
                <div className={`w-11 h-11 rounded-xl flex items-center justify-center ${a.icon}`}>
                    <Icon size={20} className="text-white" />
                </div>
                {trend != null && (
                    <span className={`flex items-center gap-0.5 text-xs font-semibold px-2 py-1 rounded-full ${a.badge}`}>
                        <ArrowUpRight size={11} />
                        {trend}%
                    </span>
                )}
            </div>
            <div className="relative">
                <p className="text-muted text-xs uppercase tracking-wider">{label}</p>
                <p className="text-white text-2xl font-bold mt-0.5">{value}</p>
            </div>
        </div>
    );
}

function SectionTitle({ children, sub }) {
    return (
        <div>
            <p className="text-muted text-xs uppercase tracking-wider">{sub}</p>
            <p className="text-white text-xl font-bold mt-0.5">{children}</p>
        </div>
    );
}

export default function Dashboard() {
    const [products, setProducts] = useState([]);
    const [services, setServices] = useState([]);
    const [areaData, setAreaData] = useState([]);
    const [barData, setBarData] = useState([]);
    const [totalSales, setTotalSales] = useState(0);

    useEffect(() => { 
        trackPageView("Dashboard"); 
        loadData(); 
    }, []);

    const loadData = async () => {
        try {
            const data = await getDashboardData();
            const productsData = data.products || [];
            const servicesData = data.services || [];
            setProducts(productsData);
            setServices(servicesData);

            const total = productsData.reduce((acc, p) => acc + (p.price || 0), 0);
            setTotalSales(total);

            const salesByMonth = {};
            servicesData.forEach((s) => {
                const date = s.createdAt ? new Date(s.createdAt) : new Date();
                const month = date.toLocaleString("es-MX", { month: "short" });
                salesByMonth[month] = (salesByMonth[month] || 0) + (s.price || 0);
            });
            setAreaData(Object.keys(salesByMonth).map((mes) => ({ mes, ventas: salesByMonth[mes] })));

            const daysCount = { Lun: 0, Mar: 0, Mié: 0, Jue: 0, Vie: 0, Sáb: 0, Dom: 0 };
            servicesData.forEach(() => {
                const days = Object.keys(daysCount);
                daysCount[days[Math.floor(Math.random() * days.length)]]++;
            });
            setBarData(Object.keys(daysCount).map((d) => ({ name: d, value: daysCount[d] })));
        } catch (error) {
            console.error("ERROR DASHBOARD:", error.response?.data || error.message);
        }
    };

    const totalStock    = products.reduce((acc, p) => acc + (p.stock || 0), 0);
    const inventoryValue = products.reduce((acc, p) => acc + ((p.price || 0) * (p.stock || 0)), 0);

    return (
        <div className="flex min-h-screen bg-background">
            <Sidebar />
            <div className="flex-1 flex flex-col min-w-0">
                <Header />
                <main className="flex-1 p-8 space-y-6 overflow-auto">

                    {/* Stat cards */}
                    <div className="grid grid-cols-2 xl:grid-cols-4 gap-4">
                        <StatCard icon={TrendingUp}   label="Ventas totales" value={`$${totalSales.toLocaleString()}`} color="purple" trend={12} />
                        <StatCard icon={Users}         label="Servicios"     value={services.length}                   color="blue"   trend={5}  />
                        <StatCard icon={ShoppingCart}  label="Productos"     value={products.length}                   color="green"  trend={8}  />
                        <StatCard icon={Package}       label="Inventario"    value={`${totalStock} u`}                 color="pink"             />
                    </div>

                    {/* Charts */}
                    <div className="grid grid-cols-1 xl:grid-cols-5 gap-4">

                        <div className="xl:col-span-3 bg-surface border border-white/5 rounded-2xl p-6">
                            <div className="flex items-start justify-between mb-6">
                                <SectionTitle sub="Ventas por mes">
                                    ${totalSales.toLocaleString()}
                                </SectionTitle>
                                <span className="flex items-center gap-1 text-brand-green text-xs font-semibold bg-brand-green/10 px-2.5 py-1 rounded-full">
                                    <ArrowUpRight size={11} />
                                    {services.length} servicios
                                </span>
                            </div>
                            <ResponsiveContainer width="100%" height={190}>
                                <AreaChart data={areaData} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
                                    <defs>
                                        <linearGradient id="gradPurple" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="5%"  stopColor="#6C63FF" stopOpacity={0.35} />
                                            <stop offset="95%" stopColor="#6C63FF" stopOpacity={0}    />
                                        </linearGradient>
                                    </defs>
                                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" />
                                    <XAxis dataKey="mes" tick={tickStyle} axisLine={false} tickLine={false} />
                                    <YAxis tick={tickStyle} axisLine={false} tickLine={false} />
                                    <Tooltip content={<CustomTooltip />} />
                                    <Area type="monotone" dataKey="ventas" stroke="#6C63FF" strokeWidth={2} fill="url(#gradPurple)" />
                                </AreaChart>
                            </ResponsiveContainer>
                        </div>

                        <div className="xl:col-span-2 bg-surface border border-white/5 rounded-2xl p-6">
                            <div className="mb-6">
                                <SectionTitle sub="Actividad semanal">
                                    {services.length} servicios
                                </SectionTitle>
                            </div>
                            <ResponsiveContainer width="100%" height={190}>
                                <BarChart data={barData} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
                                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" />
                                    <XAxis dataKey="name" tick={tickStyle} axisLine={false} tickLine={false} />
                                    <YAxis tick={tickStyle} axisLine={false} tickLine={false} />
                                    <Tooltip content={<CustomTooltip />} />
                                    <Bar dataKey="value" fill="#6C63FF" radius={[4, 4, 0, 0]} />
                                </BarChart>
                            </ResponsiveContainer>
                        </div>

                    </div>

                    {/* Bottom cards */}
                    <div className="grid grid-cols-1 xl:grid-cols-3 gap-4">

                        {/* Products */}
                        <div className="bg-surface border border-white/5 rounded-2xl p-6">
                            <div className="flex items-center justify-between mb-5">
                                <h2 className="text-white font-semibold">Productos recientes</h2>
                                <a href="/Products"><span className="text-primary text-xs font-medium cursor-pointer hover:underline">Ver todos →</span></a>
                            </div>
                            {products.length === 0 ? (
                                <div className="flex flex-col items-center justify-center py-8 gap-2">
                                    <Package size={32} className="text-muted opacity-40" />
                                    <p className="text-muted text-sm">No hay productos</p>
                                </div>
                            ) : (
                                <div className="space-y-1">
                                    {products.slice(0, 5).map((p, i) => (
                                        <div key={p.id ?? i} className="flex items-center gap-3 hover:bg-white/5 transition-colors px-3 py-3 rounded-xl">
                                            <div className="w-7 h-7 rounded-full bg-white/5 border border-white/8 flex items-center justify-center flex-shrink-0">
                                                <span className="text-muted text-xs font-bold">{i + 1}</span>
                                            </div>
                                            <div className="flex-1 min-w-0">
                                                <p className="text-white text-sm font-medium truncate">{p.name}</p>
                                                <div className="flex items-center gap-2 mt-1">
                                                    <div className="flex-1 h-1 bg-white/10 rounded-full overflow-hidden">
                                                        <div
                                                            className={`h-full rounded-full ${(p.stock || 0) > 5 ? "bg-brand-green" : "bg-yellow-400"}`}
                                                            style={{ width: `${Math.min(((p.stock || 0) / 20) * 100, 100)}%` }}
                                                        />
                                                    </div>
                                                    <span className="text-muted text-xs flex-shrink-0">{p.stock || 0}u</span>
                                                </div>
                                            </div>
                                            <span className="text-brand-green text-sm font-bold flex-shrink-0">
                                                ${(p.price || 0).toLocaleString()}
                                            </span>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>

                        {/* Services */}
                        <div className="bg-surface border border-white/5 rounded-2xl p-6">
                            <div className="flex items-center justify-between mb-5">
                                <h2 className="text-white font-semibold">Servicios</h2>
                                <a href="/Services"><span className="text-primary text-xs font-medium cursor-pointer hover:underline">Ver todos →</span></a>
                            </div>
                            {services.length === 0 ? (
                                <div className="flex flex-col items-center justify-center py-8 gap-2">
                                    <Users size={32} className="text-muted opacity-40" />
                                    <p className="text-muted text-sm">No hay servicios</p>
                                </div>
                            ) : (
                                <div className="space-y-1">
                                    {services.slice(0, 5).map((s, i) => (
                                        <div key={s.id ?? i} className="flex items-center gap-3 hover:bg-white/5 transition-colors px-3 py-3 rounded-xl">
                                            <div className="w-8 h-8 rounded-full bg-blue/20 flex items-center justify-center flex-shrink-0">
                                                <span className="text-blue text-xs font-bold">{(s.name?.[0] || "S").toUpperCase()}</span>
                                            </div>
                                            <div className="flex-1 min-w-0">
                                                <div className="flex items-center gap-1.5">
                                                    <p className="text-white text-sm font-medium truncate">{s.name}</p>
                                                    {s.duration && (
                                                        <span className="text-xs bg-white/10 text-muted px-1.5 py-0.5 rounded-md flex-shrink-0">{s.duration}</span>
                                                    )}
                                                </div>
                                                <p className="text-muted text-xs mt-0.5">Servicio activo</p>
                                            </div>
                                            <span className="text-blue text-sm font-bold flex-shrink-0">
                                                ${(s.price || 0).toLocaleString()}
                                            </span>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>

                        {/* Resumen */}
                        <div className="bg-surface border border-white/5 rounded-2xl p-6">
                            <h2 className="text-white font-semibold mb-5">Resumen</h2>
                            <div className="grid grid-cols-2 gap-3">
                                {[
                                    { icon: ShoppingCart, label: "Productos",   value: products.length,                       color: "text-brand-green", bg: "bg-brand-green/10", border: "border-brand-green/20" },
                                    { icon: Users,        label: "Servicios",   value: services.length,                       color: "text-blue",        bg: "bg-blue/10",        border: "border-blue/20"        },
                                    { icon: Layers,       label: "Inventario",  value: `${totalStock}u`,                      color: "text-purple-400",  bg: "bg-purple-500/10",  border: "border-purple-500/20"  },
                                    { icon: DollarSign,   label: "Valor total", value: `$${inventoryValue.toLocaleString()}`, color: "text-brand-green", bg: "bg-brand-green/10", border: "border-brand-green/20" },
                                ].map(({ icon: Icon, label, value, color, bg, border }) => (
                                    <div key={label} className={`${bg} border ${border} rounded-xl p-4 flex flex-col gap-1`}>
                                        <Icon size={15} className={`${color} mb-1`} />
                                        <p className={`text-lg font-bold ${color}`}>{value}</p>
                                        <p className="text-muted text-xs">{label}</p>
                                    </div>
                                ))}
                            </div>
                        </div>

                    </div>

                </main>
            </div>
        </div>
    );
}
