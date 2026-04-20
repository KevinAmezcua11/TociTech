import { useState, useRef, useEffect } from "react";
import { LayoutGrid, Package, Wrench, ShoppingCart, Users, Settings, ChevronDown, User, LogOut } from "lucide-react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { signOut } from "firebase/auth";
import { auth } from "../firebase/config";

// Logo TociTech
function TociTechLogo({ size = 34 }) {
    return (
        <svg width={size} height={size} viewBox="0 0 34 34" fill="none" xmlns="http://www.w3.org/2000/svg">
            <rect width="34" height="34" rx="9" fill="#6C63FF" />
            <text
                x="50%" y="54%" dominantBaseline="middle" textAnchor="middle"
                fill="white" fontSize="13" fontWeight="800" fontFamily="monospace" letterSpacing="-1"
            >
                TT
            </text>
        </svg>
    );
}

// Usuario loggeado
const USER = {
    name: "Said Encarnación",
    role: "Admin",
    avatar: null,
};

function Avatar({ name }) {
    const initials = name.split(" ").map((n) => n[0]).join("").slice(0, 2).toUpperCase();
    return (
        <div className="w-10 h-10 rounded-full bg-primary flex items-center justify-center
                        text-white font-bold text-sm shrink-0 border-2 border-white/10">
            {initials}
        </div>
    );
}

// Dropdown del usuario
function UserDropdown() {
    const [open, setOpen] = useState(false);
    const ref = useRef(null);
    const navigate = useNavigate();

    const handleLogout = async () => {
        setOpen(false);
        await signOut(auth);
        navigate("/");
    };

    // Cierra al hacer click fuera
    useEffect(() => {
        const handler = (e) => {
            if (ref.current && !ref.current.contains(e.target)) setOpen(false);
        };
        document.addEventListener("mousedown", handler);
        return () => document.removeEventListener("mousedown", handler);
    }, []);

    return (
        <div className="relative" ref={ref}>

            {/* Trigger */}
            <button
                onClick={() => setOpen((v) => !v)}
                className={`flex items-center justify-center w-8 h-8 rounded-lg
                            transition-all duration-200
                            ${open
                        ? "bg-white/10 text-white"
                        : "text-muted hover:text-white hover:bg-white/8"}`}
            >
                <ChevronDown
                    size={15}
                    className={`transition-transform duration-200 ${open ? "rotate-180" : ""}`}
                />
            </button>

            {/* Dropdown */}
            {open && (
                <div className="absolute right-0 top-full mt-2 w-44 bg-surface border border-white/8
                                rounded-2xl shadow-2xl shadow-black/40 overflow-hidden z-50
                                animate-in fade-in slide-in-from-top-2 duration-150">

                    <div className="p-1.5 space-y-0.5">

                        <Link
                            to="/profile"
                            onClick={() => setOpen(false)}
                            className="flex items-center gap-3 px-3 py-2.5 rounded-xl
                                       text-secondary text-sm hover:bg-white/6 hover:text-white
                                       transition-colors duration-150"
                        >
                            <User size={15} strokeWidth={1.8} />
                            Perfil
                        </Link>

                        <Link
                            to="/settings"
                            onClick={() => setOpen(false)}
                            className="flex items-center gap-3 px-3 py-2.5 rounded-xl
                                       text-secondary text-sm hover:bg-white/6 hover:text-white
                                       transition-colors duration-150"
                        >
                            <Settings size={15} strokeWidth={1.8} />
                            Configuración
                        </Link>

                    </div>

                    {/* Divisor */}
                    <div className="border-t border-white/6 mx-1.5" />

                    <div className="p-1.5">
                        <button
                            onClick={handleLogout}
                            className="flex items-center gap-3 px-3 py-2.5 rounded-xl w-full
                                       text-red-400 text-sm hover:bg-red-500/10
                                       transition-colors duration-150"
                        >
                            <LogOut size={15} strokeWidth={1.8} />
                            Cerrar sesión
                        </button>
                    </div>

                </div>
            )}
        </div>
    );
}

// Cuadro grande: Dashboard
function BigNavItem({ to, icon: Icon, label, active }) {
    return (
        <Link
            to={to}
            className={`flex flex-col items-center justify-center gap-3 w-full py-9 rounded-2xl
                        font-semibold text-base transition-all duration-200
                        ${active
                    ? "bg-primary/20 text-white shadow-lg shadow-black/30 border border-primary/40 ring-1 ring-primary/20"
                    : "bg-surface/50 text-secondary border border-white/5 hover:bg-surface hover:text-white hover:border-white/15 hover:shadow-md hover:shadow-black/20"}`}
        >
            <Icon size={28} strokeWidth={active ? 2.2 : 1.8} />
            {label}
        </Link>
    );
}

// Cuadro card pequeño
function GridNavItem({ to, icon: Icon, label, active }) {
    return (
        <Link
            to={to}
            className={`flex flex-col items-center justify-center gap-3 p-5 rounded-2xl
                        font-medium text-sm transition-all duration-200
                        ${active
                    ? "bg-primary/20 text-white border border-primary/40 ring-1 ring-primary/20 shadow-md shadow-black/20"
                    : "bg-surface/50 text-secondary border border-white/5 hover:bg-surface hover:text-white hover:border-white/15 hover:shadow-md hover:shadow-black/20"}`}
        >
            <Icon size={22} strokeWidth={1.8} />
            {label}
        </Link>
    );
}

// Configuración
function SettingsItem({ to, icon: Icon, label, active }) {
    return (
        <Link
            to={to}
            className={`flex items-center gap-3 px-2 py-2 rounded-xl
                        font-medium text-sm transition-all duration-200
                        ${active ? "text-white" : "text-secondary hover:text-white"}`}
        >
            <Icon size={17} strokeWidth={1.8} />
            {label}
        </Link>
    );
}

// Sidebar
export default function Sidebar() {
    const location = useLocation();
    const p = location.pathname;

    return (
        <aside className="w-72 min-h-screen bg-surfaceDark flex flex-col p-5
                          border-r border-white/5 box-border">

            {/* Logo + nombre */}
            <div className="flex items-center gap-3 mb-5">
                <TociTechLogo size={34} />
                <span className="text-white font-extrabold text-lg tracking-tight">
                    TociTech
                </span>
            </div>

            {/* Card usuario */}
            <div className="flex items-center justify-between bg-surface
                            rounded-2xl px-4 py-3 mb-6 border border-white/5">
                <div className="flex items-center gap-3">
                    {USER.avatar
                        ? <img src={USER.avatar} alt={USER.name}
                            className="w-10 h-10 rounded-full object-cover" />
                        : <Avatar name={USER.name} />}
                    <div>
                        <p className="text-white font-semibold text-sm leading-tight">
                            {USER.name}
                        </p>
                        <p className="text-muted text-xs">{USER.role}</p>
                    </div>
                </div>

                {/* Dropdown */}
                <UserDropdown />
            </div>

            {/* Dashboard */}
            <BigNavItem to="/dashboard" icon={LayoutGrid} label="Dashboard" active={p === "/dashboard"} />

            {/* Label PRINCIPAL */}
            <p className="text-muted text-[10px] font-bold tracking-[0.12em] uppercase mt-6 mb-3 px-1">
                Principal
            </p>

            <div className="grid grid-cols-2 gap-3">
                <GridNavItem to="/products" icon={Package}      label="Productos" active={p === "/products"} />
                <GridNavItem to="/services" icon={Wrench}       label="Servicios" active={p === "/services"} />
                <GridNavItem to="/orders"   icon={ShoppingCart} label="Pedidos"   active={p === "/orders"} />
            </div>

            {/* Label GESTIÓN */}
            <p className="text-muted text-[10px] font-bold tracking-[0.12em] uppercase mt-6 mb-3 px-1">
                Gestión
            </p>

            <div className="grid grid-cols-2 gap-3">
                <GridNavItem to="/customers" icon={Users} label="Clientes" active={p === "/customers"} />
            </div>

            {/* Espaciador */}
            <div className="flex-1" />

            {/* Configuración */}
            <div className="mt-10 pt-4 border-t border-white/8">
                <SettingsItem to="/settings" icon={Settings} label="Configuración" active={p === "/settings"} />
            </div>

        </aside>
    );
}