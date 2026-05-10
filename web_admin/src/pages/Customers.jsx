import { useEffect, useState, useMemo } from "react";
import Sidebar from "../components/Sidebar";
import Header from "../components/Header";
import { getClients } from "../api/userService";
import { getOrders } from "../api/orderService";
import { Users, User, Mail, Phone, Clock, Calendar } from "lucide-react";

export default function Customers() {
    const [clients, setClients] = useState([]);
    const [orders, setOrders] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState("");

    const fetchData = async () => {
        try {
            const [clientsData, ordersData] = await Promise.all([
                getClients(),
                getOrders()
            ]);

            setClients(clientsData);
            setOrders(ordersData);

        } catch (err) {
            console.error(err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchData();
    }, []);

    const getActiveOrders = (clientId) => {
        return orders.filter(o =>
            (o.estadoPedido === "PENDIENTE" || o.estadoPedido === "EN_PROGRESO") &&
            o.customerId === clientId
        ).length;
    };

    const filteredClients = useMemo(() => {
        const term = search.toLowerCase().trim();

        if (!term) return clients;

        return clients.filter(client => {
            const fullName = `${client.names} ${client.lastnames}`.toLowerCase();
            const email = client.email?.toLowerCase() || "";
            const phone = client.phone?.toString() || "";

            return (
                fullName.includes(term) ||
                email.includes(term) ||
                phone.includes(term)
            );
        });
    }, [clients, search]);

    return (
        <div className="flex min-h-screen bg-background">
            <Sidebar />

            <div className="flex-1 flex flex-col min-w-0">
                <Header />

                <main className="flex-1 p-8 space-y-6 overflow-auto">

                    {/* Header */}
                    <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">

                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-primary/15 rounded-lg border border-primary/20">
                                <Users size={20} className="text-primary" />
                            </div>

                            <div>
                                <h1 className="text-xl font-bold text-white leading-tight">Clientes</h1>
                                <p className="text-xs text-muted mt-0.5">
                                    Lista de clientes registrados
                                </p>
                            </div>
                        </div>

                        {/* Buscador */}
                        <div className="relative w-full md:w-72">
                            <User size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted" />

                            <input
                                type="text"
                                placeholder="Buscar cliente"
                                value={search}
                                onChange={(e) => setSearch(e.target.value)}
                                className="w-full rounded-lg bg-surface border border-white/10 py-2 pl-9 pr-3 text-sm text-white outline-none transition placeholder:text-muted focus:border-primary/60"
                            />
                        </div>

                    </div>

                    {/* Tabla */}
                    <div className="bg-surface rounded-xl border border-white/10 overflow-hidden">

                        {loading ? (
                            <div className="flex items-center justify-center gap-3 p-12 text-muted">
                                <div className="w-4 h-4 border-2 border-primary/40 border-t-primary rounded-full animate-spin" />
                                <span className="text-sm">Cargando clientes...</span>
                            </div>
                        ) : filteredClients.length === 0 ? (
                            <div className="flex flex-col items-center justify-center py-14 gap-3">
                                <div className="p-3 bg-white/5 rounded-full">
                                    <Users size={24} className="text-muted" />
                                </div>
                                <p className="text-sm text-muted">
                                    {search ? "No se encontraron clientes" : "No hay clientes registrados"}
                                </p>
                            </div>
                        ) : (
                            <table className="w-full text-sm">

                                {/* HEADER */}
                                <thead className="bg-white/5 border-b border-white/10">
                                    <tr>
                                        <th className="px-4 py-3 w-10 text-center"></th>

                                        <th className="px-4 py-3 text-left">
                                            <span className="flex items-center gap-1.5 text-xs font-medium text-muted uppercase">
                                                <User size={12} /> Cliente
                                            </span>
                                        </th>

                                        <th className="px-4 py-3 text-left">
                                            <span className="flex items-center gap-1.5 text-xs font-medium text-muted uppercase">
                                                <Mail size={12} /> Email
                                            </span>
                                        </th>

                                        <th className="px-4 py-3 text-left">
                                            <span className="flex items-center gap-1.5 text-xs font-medium text-muted uppercase">
                                                <Phone size={12} /> Teléfono
                                            </span>
                                        </th>

                                        <th className="px-4 py-3 text-center">
                                            <span className="flex items-center justify-center gap-1.5 text-xs font-medium text-muted uppercase">
                                                <Clock size={12} /> Pedidos activos
                                            </span>
                                        </th>

                                        <th className="px-4 py-3 text-left">
                                            <span className="flex items-center gap-1.5 text-xs font-medium text-muted uppercase">
                                                <Calendar size={12} /> Registro
                                            </span>
                                        </th>

                                    </tr>
                                </thead>

                                {/* BODY */}
                                <tbody className="divide-y divide-white/5">
                                    {filteredClients.map((client, index) => {

                                        const activeOrders = getActiveOrders(client.id);

                                        return (
                                            <tr key={client.id} className="hover:bg-white/[0.02] transition align-middle">

                                                {/* Número */}
                                                <td className="py-3 text-center align-middle text-muted text-xs font-medium">
                                                    <div className="w-full flex justify-center">
                                                        {index + 1}
                                                    </div>
                                                </td>

                                                {/* Cliente */}
                                                <td className="px-4 py-3">
                                                    <div className="flex items-center gap-3">
                                                        <div className="w-8 h-8 rounded-full bg-primary/15 border border-primary/20 flex items-center justify-center">
                                                            <User size={14} className="text-primary" />
                                                        </div>
                                                        <span className="text-white font-medium leading-none">
                                                            {client.names} {client.lastnames}
                                                        </span>
                                                    </div>
                                                </td>

                                                {/* Email */}
                                                <td className="px-4 py-3">
                                                    <div className="flex items-center gap-2 text-secondary">
                                                        <Mail size={14} className="text-muted shrink-0" />
                                                        <span className="leading-none">{client.email}</span>
                                                    </div>
                                                </td>

                                                {/* Teléfono */}
                                                <td className="px-4 py-3">
                                                    <div className="flex items-center gap-2 text-secondary">
                                                        <Phone size={14} className="text-muted shrink-0" />
                                                        <span className="leading-none">{client.phone}</span>
                                                    </div>
                                                </td>

                                                {/* Pedidos activos */}
                                                <td className="px-4 py-3 text-center align-middle">
                                                    <span className={`inline-flex items-center justify-center min-w-[28px] h-7 px-2.5 rounded-full text-xs font-semibold ${
                                                        activeOrders > 0
                                                            ? "bg-primary/15 text-primary border border-primary/30"
                                                            : "bg-white/5 text-muted border border-white/10"
                                                    }`}>
                                                        {activeOrders}
                                                    </span>
                                                </td>

                                                {/* Fecha */}
                                                <td className="px-4 py-3">
                                                    <span className="text-muted text-sm leading-none">
                                                        {client.createdAt
                                                            ? new Date(client.createdAt).toLocaleDateString("es-MX", {
                                                                day: "2-digit",
                                                                month: "short",
                                                                year: "numeric",
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

                </main>
            </div>
        </div>
    );
}