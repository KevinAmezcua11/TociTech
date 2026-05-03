import { useEffect, useState } from "react";
import {
    AreaChart, Area, BarChart, Bar, XAxis, YAxis,
    Tooltip, ResponsiveContainer, CartesianGrid
} from "recharts";
import {
    ArrowUpRight, TrendingUp, ShoppingCart,
    Users, Package
} from "lucide-react";
import Sidebar from "../components/Sidebar";
import Header from "../components/Header";
import { getDashboardData } from "../api/dashboardService";

function CustomTooltip({ active, payload, label }) {
    if (!active || !payload?.length) return null;
    return (
        <div className="bg-surface border border-white/10 rounded-xl px-4 py-3">
            <p className="text-muted text-xs">{label}</p>
            {payload.map((p, i) => (
                <p key={i} className="text-white text-sm font-semibold">
                    {p.name === "ventas" ? "$" : ""}{p.value}
                </p>
            ))}
        </div>
    );
}

function StatCard({ icon: Icon, label, value, accent }) {
    return (
        <div className="bg-surface border border-white/5 rounded-2xl p-5 flex flex-col gap-4">
            <div className="flex items-center justify-between">
                <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${accent}`}>
                    <Icon size={18} className="text-white" />
                </div>
                <span className="flex items-center gap-1 text-brand-green text-xs font-semibold bg-brand-green/10 px-2 py-1 rounded-full">
                    <ArrowUpRight size={11} />
                </span>
            </div>
            <div>
                <p className="text-muted text-xs">{label}</p>
                <p className="text-white text-2xl font-bold">{value}</p>
            </div>
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

                if (!salesByMonth[month]) {
                    salesByMonth[month] = 0;
                }

                salesByMonth[month] += s.price || 0;
            });

            const formattedArea = Object.keys(salesByMonth).map((mes) => ({
                mes,
                ventas: salesByMonth[mes]
            }));

            setAreaData(formattedArea);

            const daysCount = {
                Lun: 0, Mar: 0, Mié: 0, Jue: 0, Vie: 0, Sáb: 0, Dom: 0
            };

            servicesData.forEach(() => {
                const days = Object.keys(daysCount);
                const randomDay = days[Math.floor(Math.random() * days.length)];
                daysCount[randomDay]++;
            });

            setBarData(
                Object.keys(daysCount).map((d) => ({
                    name: d,
                    value: daysCount[d]
                }))
            );

        } catch (error) {
            console.error("ERROR DASHBOARD:", error.response?.data || error.message);
        }
    };

    return (
        <div className="flex min-h-screen bg-background">
            <Sidebar />

            <div className="flex-1 flex flex-col min-w-0">
                <Header />

                <main className="flex-1 p-8 space-y-6 overflow-auto">

                    <div className="grid grid-cols-2 xl:grid-cols-4 gap-4">
                        <StatCard icon={TrendingUp} label="Ventas totales" value={`$${totalSales}`} accent="bg-primary" />
                        <StatCard icon={Users} label="Servicios" value={services.length} accent="bg-blue" />
                        <StatCard icon={ShoppingCart} label="Productos" value={products.length} accent="bg-brand-green/80" />
                        <StatCard icon={Package} label="Inventario" value={products.reduce((acc, p) => acc + (p.stock || 0), 0)} accent="bg-purple-500/80" />
                    </div>

                    <div className="grid grid-cols-1 xl:grid-cols-5 gap-4">

                        <div className="xl:col-span-3 bg-surface border border-white/5 rounded-2xl p-6">

                            <div className="flex items-center justify-between mb-6">
                                <div>
                                    <p className="text-muted text-xs">Ventas por mes</p>
                                    <p className="text-white text-2xl font-bold">
                                        ${totalSales}
                                    </p>
                                </div>

                                <span className="flex items-center gap-1 text-brand-green text-xs font-semibold bg-brand-green/10 px-2.5 py-1 rounded-full">
                                    <ArrowUpRight size={11} />
                                    {services.length} servicios
                                </span>
                            </div>

                            <ResponsiveContainer width="100%" height={180}>
                                <AreaChart data={areaData}>
                                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" />
                                    <XAxis dataKey="mes" />
                                    <YAxis />
                                    <Tooltip content={<CustomTooltip />} />
                                    <Area type="monotone" dataKey="ventas" stroke="#6C63FF" fill="#6C63FF33" />
                                </AreaChart>
                            </ResponsiveContainer>
                        </div>

                        <div className="xl:col-span-2 bg-surface border border-white/5 rounded-2xl p-6">

                            <div className="mb-6">
                                <p className="text-muted text-xs">Actividad semanal</p>
                                <p className="text-white text-2xl font-bold">
                                    {services.length}
                                </p>
                            </div>

                            <ResponsiveContainer width="100%" height={180}>
                                <BarChart data={barData}>
                                    <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" />
                                    <XAxis dataKey="name" />
                                    <YAxis />
                                    <Tooltip />
                                    <Bar dataKey="value" fill="#6C63FF" />
                                </BarChart>
                            </ResponsiveContainer>
                        </div>

                    </div>

                    <div className="grid grid-cols-1 xl:grid-cols-3 gap-4">

                        <div className="bg-surface border border-white/5 rounded-2xl p-6">
                            <h2 className="text-white font-semibold mb-4">Productos recientes</h2>

                            {products.length === 0 ? (
                                <p className="text-muted text-sm">No hay productos</p>
                            ) : (
                                <div className="space-y-3">
                                    {products.slice(0, 5).map((p) => (
                                        <div key={p.id} className="flex justify-between bg-white/5 px-4 py-3 rounded-xl">
                                            <div>
                                                <p className="text-white text-sm">{p.name}</p>
                                                <p className="text-muted text-xs">${p.price}</p>
                                            </div>
                                            <span className="text-xs text-brand-green">
                                                Stock {p.stock || 0}
                                            </span>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>

                        <div className="bg-surface border border-white/5 rounded-2xl p-6">
                            <h2 className="text-white font-semibold mb-4">Servicios</h2>

                            {services.length === 0 ? (
                                <p className="text-muted text-sm">No hay servicios</p>
                            ) : (
                                <div className="space-y-3">
                                    {services.slice(0, 5).map((s) => (
                                        <div key={s.id} className="flex justify-between bg-white/5 px-4 py-3 rounded-xl">
                                            <div>
                                                <p className="text-white text-sm">{s.name}</p>
                                                <p className="text-muted text-xs">{s.duration}</p>
                                            </div>
                                            <span className="text-xs text-blue">
                                                ${s.price}
                                            </span>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>

                        <div className="bg-surface border border-white/5 rounded-2xl p-6">
                            <h2 className="text-white font-semibold mb-4">Resumen</h2>

                            <div className="space-y-3 text-sm">
                                <div className="flex justify-between">
                                    <span className="text-muted">Productos</span>
                                    <span className="text-white">{products.length}</span>
                                </div>
                                <div className="flex justify-between">
                                    <span className="text-muted">Servicios</span>
                                    <span className="text-white">{services.length}</span>
                                </div>
                                <div className="flex justify-between">
                                    <span className="text-muted">Inventario</span>
                                    <span className="text-white">
                                        {products.reduce((acc, p) => acc + (p.stock || 0), 0)}
                                    </span>
                                </div>
                                <div className="flex justify-between">
                                    <span className="text-muted">Valor</span>
                                    <span className="text-brand-green">
                                        ${products.reduce((acc, p) => acc + ((p.price || 0) * (p.stock || 0)), 0)}
                                    </span>
                                </div>
                            </div>
                        </div>

                    </div>

                </main>
            </div>
        </div>
    );
}