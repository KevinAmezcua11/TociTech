import { useState } from "react";
import api from "../api/api";
import { useNavigate } from "react-router-dom";

export default function Login() {
    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");
    const navigate = useNavigate();

    const handleLogin = async () => {
        try {
            const res = await api.post("/auth/login", {
                username,
                password
            });

            // Guardar token
            localStorage.setItem("token", res.data.token);

            // Guardar usuario
            localStorage.setItem("user", JSON.stringify(res.data.user));

            navigate("/dashboard");

        } catch (error) {
            alert(error.response?.data?.message || "Error login");
        }
    };

    return (
        <div style={{ padding: "20px" }}>
            <h2>Admin Login</h2>

            <div>
                <input
                    type="text"
                    placeholder="Usuario"
                    value={username}
                    onChange={(e) => setUsername(e.target.value)}
                />
            </div>

            <div>
                <input
                    type="password"
                    placeholder="Contraseña"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                />
            </div>

            <button onClick={handleLogin}>Entrar</button>
        </div>
    );
}