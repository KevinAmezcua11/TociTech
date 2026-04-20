import { useState } from "react";
import { login } from "../services/authService";
import { useNavigate } from "react-router-dom";

export default function Login() {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const navigate = useNavigate();

    const handleLogin = async () => {
        try {
        await login(email, password);
        navigate("/dashboard");
        } catch (error) {
        alert(error.message);
        }
    };

    return (
        <div style={{ padding: "20px" }}>
        <h2>Admin Login</h2>

        <div>
            <input
            type="email"
            placeholder="Correo"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
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