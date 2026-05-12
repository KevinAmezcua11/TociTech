import { useState } from "react";
import api from "../api/api";
import { useNavigate } from "react-router-dom";
import { User, Lock, Eye, EyeOff } from "lucide-react";
import logo from "../assets/Logo-img.png";
import { trackLogin } from "../utils/dataLayer";

export default function Login() {
    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");
    const [showPassword, setShowPassword] = useState(false);
    const [loading, setLoading] = useState(false);

    const navigate = useNavigate();

    const handleLogin = async () => {
        try {
            setLoading(true);

            const res = await api.post("/auth/login", {
                username,
                password
            });

            localStorage.setItem("token", res.data.token);
            localStorage.setItem("user", JSON.stringify(res.data.user));

            trackLogin("email");

            navigate("/dashboard");

        } catch (error) {
            alert(error.response?.data?.message || "Error login");
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#0f172a] to-[#020617]">

            <div className="w-full max-w-md bg-white/5 backdrop-blur-xl border border-white/10 rounded-2xl p-8 shadow-2xl">

                {/* Logo / Marca */}
                <div className="flex flex-col items-center mb-6">
                    
                    <div
                        className="w-20 h-20 rounded-full flex items-center justify-center border border-white/10"
                        style={{
                            backgroundColor: "#0F0F14",
                            boxShadow: "0 0 20px rgba(99,102,241,0.25)" // glow sutil
                        }}
                    >
                        <img src={logo} alt="TociTech" className="w-14 h-14 object-contain"/>
                    </div>

                    <h1 className="text-xl font-semibold text-white mt-3">
                        TociTech
                    </h1>

                    <p className="text-sm text-muted mt-1">
                        Panel administrativo
                    </p>
                </div>

                {/* Usuario */}
                <div className="mb-4">
                    <label className="text-xs text-muted mb-1 block">Usuario</label>
                    <div className="relative">
                        <User size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted" />
                        <input
                            type="text"
                            placeholder="Usuario"
                            value={username}
                            onChange={(e) => setUsername(e.target.value)}
                            className="w-full bg-white/5 border border-white/10 text-white text-sm p-2.5 pl-9 rounded-lg outline-none focus:border-primary/50 transition"
                        />
                    </div>
                </div>

                {/* Password */}
                <div className="mb-6">
                    <label className="text-xs text-muted mb-1 block">Contraseña</label>
                    <div className="relative">
                        <Lock size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted" />

                        <input
                            type={showPassword ? "text" : "password"}
                            placeholder="Contraseña"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            className="w-full bg-white/5 border border-white/10 text-white text-sm p-2.5 pl-9 pr-10 rounded-lg outline-none focus:border-primary/50 transition"
                        />

                        <button
                            onClick={() => setShowPassword(!showPassword)}
                            className="absolute right-3 top-1/2 -translate-y-1/2 text-muted hover:text-white"
                        >
                            {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                        </button>
                    </div>
                </div>

                {/* Botón */}
                <button
                    onClick={handleLogin}
                    disabled={loading}
                    className="w-full bg-primary text-white py-2.5 rounded-lg font-medium hover:opacity-90 transition disabled:opacity-60"
                >
                    Entrar
                </button>

                {/* Footer */}
                <p className="text-center text-xs text-muted mt-6">
                    © {new Date().getFullYear()} TociTech
                </p>
            </div>
        </div>
    );
}