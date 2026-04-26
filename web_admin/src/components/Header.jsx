import { Search, Bell } from "lucide-react";

function getGreeting() {
    const hour = new Date().getHours();
    if (hour < 12) return "Buenos días";
    if (hour < 18) return "Buenas tardes";
    return "Buenas noches";
}

const storedUser = JSON.parse(localStorage.getItem("user"));
const firstName = storedUser?.names?.split(" ")[0] || "";

const USER_NAME = storedUser
    ? firstName
    : "Usuario";

export default function Header() {
    return (
        <header className="w-full bg-surfaceDark/80 backdrop-blur-md border-b border-white/5
                            px-8 py-3.5 flex items-center justify-between gap-4 sticky top-0 z-10">

            {/* Buscador */}
            <div className="flex items-center gap-3 bg-surface border border-white/6
                            rounded-xl px-4 py-2.5 w-96 group
                            focus-within:border-primary/40
                            transition-all duration-200">

                <Search size={14} className="text-muted shrink-0 group-focus-within:text-primary transition-colors duration-200" />

                <input
                    type="text"
                    placeholder="Buscar pedidos, productos, usuarios..."
                    className="bg-transparent text-sm text-white placeholder:text-muted outline-none w-full"
                />
            </div>

            {/* Derecha */}
            <div className="flex items-center gap-4">

                {/* Saludo dinámico */}
                <div className="hidden md:flex flex-col items-end">
                    <span className="text-muted text-xs">{getGreeting()},</span>
                    <span className="text-white text-sm font-semibold leading-tight">{USER_NAME} 👋</span>
                </div>

                {/* Divisor */}
                <div className="w-px h-7 bg-white/8 hidden md:block" />

                {/* Notificaciones */}
                <button className="relative w-10 h-10 flex items-center justify-center
                                    rounded-xl bg-surface border border-white/5
                                    text-muted hover:text-white hover:border-white/15
                                    transition-all duration-200 group">

                    <Bell size={15} className="group-hover:scale-110 transition-transform duration-200" />

                    <span className="absolute top-2 right-2 flex">
                        <span className="absolute inline-flex w-2 h-2 rounded-full bg-primary opacity-75 animate-ping" />
                        <span className="relative inline-flex w-2 h-2 rounded-full bg-primary" />
                    </span>
                </button>

            </div>
        </header>
    );
}