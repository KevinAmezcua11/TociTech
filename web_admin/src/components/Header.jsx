import { useState, useRef, useEffect } from "react";
import { Search, Bell } from "lucide-react";
import { useNavigate } from "react-router-dom";

function getGreeting() {
    const hour = new Date().getHours();
    if (hour < 12) return "Buenos días";
    if (hour < 18) return "Buenas tardes";
    return "Buenas noches";
}

const storedUser = JSON.parse(localStorage.getItem("user"));
const firstName = storedUser?.names?.split(" ")[0] || "";

const USER_NAME = storedUser ? firstName : "Usuario";

export default function Header({ products = [], services = [], customers = [] }) {

    const navigate = useNavigate();

    const [search, setSearch] = useState("");
    const [results, setResults] = useState([]);
    const [showResults, setShowResults] = useState(false);

    const [showNotifications, setShowNotifications] = useState(false);

    const [notifications, setNotifications] = useState([]);

    const searchRef = useRef();
    const notifRef = useRef();

    useEffect(() => {
        const handler = (e) => {
            if (searchRef.current && !searchRef.current.contains(e.target)) {
                setShowResults(false);
            }
            if (notifRef.current && !notifRef.current.contains(e.target)) {
                setShowNotifications(false);
            }
        };

        document.addEventListener("mousedown", handler);
        return () => document.removeEventListener("mousedown", handler);
    }, []);

    const handleSearch = (value) => {
        setSearch(value);

        if (!value.trim()) {
            setResults([]);
            return;
        }

        const query = value.toLowerCase();

        const filtered = [
            ...products
                .filter(p => p.name?.toLowerCase().includes(query))
                .map(p => ({
                    type: "Producto",
                    label: p.name,
                    id: p.id
                })),

            ...services
                .filter(s => s.name?.toLowerCase().includes(query))
                .map(s => ({
                    type: "Servicio",
                    label: s.name,
                    id: s.id
                })),

            ...customers
                .filter(c =>
                    `${c.names} ${c.lastnames}`.toLowerCase().includes(query)
                )
                .map(c => ({
                    type: "Cliente",
                    label: `${c.names} ${c.lastnames}`,
                    id: c.id
                }))
        ];

        setResults(filtered.slice(0, 6));
        setShowResults(true);
    };

    const handleSelect = (item) => {
        setSearch("");
        setShowResults(false);

        if (item.type === "Producto") navigate("/products");
        if (item.type === "Servicio") navigate("/services");
        if (item.type === "Cliente") navigate("/customers");
    };

    return (
        <header className="w-full bg-surfaceDark/80 backdrop-blur-md border-b border-white/5
                            px-8 py-3.5 flex items-center justify-between gap-4 sticky top-0 z-10">

            <div
                ref={searchRef}
                className="relative flex items-center gap-3 bg-surface border border-white/6
                            rounded-xl px-4 py-2.5 w-96 group
                            focus-within:border-primary/40 transition-all duration-200"
            >
                <Search size={14} className="text-muted shrink-0 group-focus-within:text-primary" />

                <input
                    type="text"
                    placeholder="Buscar..."
                    value={search}
                    onChange={(e) => handleSearch(e.target.value)}
                    onFocus={() => setShowResults(true)}
                    className="bg-transparent text-sm text-white placeholder:text-muted outline-none w-full"
                />

                {showResults && search && (
                    <div className="absolute top-full left-0 mt-2 w-full bg-surface border border-white/10 rounded-xl shadow-xl overflow-hidden z-50">

                        {results.length === 0 ? (
                            <div className="p-3 text-xs text-muted">
                                Sin resultados
                            </div>
                        ) : (
                            results.map((item, i) => (
                                <div
                                    key={i}
                                    onClick={() => handleSelect(item)}
                                    className="px-4 py-2.5 text-sm text-white hover:bg-white/5 cursor-pointer flex justify-between"
                                >
                                    <span>{item.label}</span>

                                    <span className="text-[10px] text-muted uppercase">
                                        {item.type}
                                    </span>
                                </div>
                            ))
                        )}
                    </div>
                )}
            </div>

            <div className="flex items-center gap-4">

                <div className="hidden md:flex flex-col items-end">
                    <span className="text-muted text-xs">{getGreeting()},</span>
                    <span className="text-white text-sm font-semibold">
                        {USER_NAME} 👋
                    </span>
                </div>

                <div className="w-px h-7 bg-white/8 hidden md:block" />

                <div ref={notifRef} className="relative">

                    <button
                        onClick={() => setShowNotifications(!showNotifications)}
                        className="relative w-10 h-10 flex items-center justify-center
                                    rounded-xl bg-surface border border-white/5
                                    text-muted hover:text-white hover:border-white/15"
                    >
                        <Bell size={15} />

                        {notifications.length > 0 && (
                            <span className="absolute top-2 right-2 flex">
                                <span className="absolute inline-flex w-2 h-2 rounded-full bg-primary opacity-75 animate-ping" />
                                <span className="relative inline-flex w-2 h-2 rounded-full bg-primary" />
                            </span>
                        )}
                    </button>

                    {showNotifications && (
                        <div className="absolute right-0 top-full mt-2 w-72 bg-surface border border-white/10 rounded-xl shadow-xl p-3 z-50">

                            <p className="text-white text-sm font-semibold mb-2">
                                Notificaciones
                            </p>

                            {notifications.length === 0 ? (
                                <div className="text-center text-xs text-muted py-6">
                                    No tienes notificaciones
                                </div>
                            ) : (
                                <div className="space-y-2 max-h-60 overflow-y-auto">
                                    {notifications.map((n, i) => (
                                        <div
                                            key={i}
                                            className="p-3 rounded-xl bg-white/5 border border-white/5 hover:bg-white/8 transition-all"
                                        >
                                            <p className="text-sm text-white">{n.title}</p>
                                            <p className="text-xs text-muted mt-0.5">{n.message}</p>
                                        </div>
                                    ))}
                                </div>
                            )}

                        </div>
                    )}
                </div>
            </div>
        </header>
    );
}