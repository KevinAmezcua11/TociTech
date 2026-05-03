import { useState, useEffect } from "react";
import { User, Mail, Phone, Lock, Save, AlertCircle, CheckCircle, Pencil, X } from "lucide-react";
import Sidebar from "../components/Sidebar";
import Header from "../components/Header";
import api from "../api/api";

export default function Profile() {
    const storedUser = JSON.parse(localStorage.getItem("user") || "{}");

    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [editMode, setEditMode] = useState(false);
    const [feedback, setFeedback] = useState(null); // { type: "success" | "error", message }

    const [form, setForm] = useState({
        names: "",
        lastnames: "",
        username: "",
        email: "",
        phone: "",
        password: "",
        confirmPassword: "",
    });

    // Cargar datos del usuario logueado desde el backend
    useEffect(() => {
        const fetchUser = async () => {
            try {
                const res = await api.get(`/users/${storedUser.id}`);
                setUser(res.data);
                setForm({
                    names: res.data.names || "",
                    lastnames: res.data.lastnames || "",
                    username: res.data.username || "",
                    email: res.data.email || "",
                    phone: res.data.phone || "",
                    password: "",
                    confirmPassword: "",
                });
            } catch (err) {
                setFeedback({ type: "error", message: "No se pudieron cargar los datos del perfil." });
            } finally {
                setLoading(false);
            }
        };
        if (storedUser?.id) fetchUser();
        else setLoading(false);
    }, []);

    const handleChange = (e) => {
        setForm(prev => ({ ...prev, [e.target.name]: e.target.value }));
    };

    const handleCancel = () => {
        setForm({
            names: user.names || "",
            lastnames: user.lastnames || "",
            username: user.username || "",
            email: user.email || "",
            phone: user.phone || "",
            password: "",
            confirmPassword: "",
        });
        setEditMode(false);
        setFeedback(null);
    };

    const handleSave = async () => {
        setFeedback(null);

        if (form.password && form.password !== form.confirmPassword) {
            setFeedback({ type: "error", message: "Las contraseñas no coinciden." });
            return;
        }

        const payload = {
            names: form.names.trim(),
            lastnames: form.lastnames.trim(),
            username: form.username.trim(),
            email: form.email.trim(),
            phone: form.phone.trim(),
        };
        if (form.password) payload.password = form.password;

        try {
            setSaving(true);
            const res = await api.put(`/users/${user.id}`, payload);

            // Actualizar localStorage con los nuevos datos
            const updatedUser = { ...storedUser, ...res.data };
            localStorage.setItem("user", JSON.stringify(updatedUser));

            setUser(res.data);
            setEditMode(false);
            setFeedback({ type: "success", message: "Perfil actualizado correctamente." });
            setForm(prev => ({ ...prev, password: "", confirmPassword: "" }));
        } catch (err) {
            const msg = err.response?.data?.message || "Error al actualizar el perfil.";
            setFeedback({ type: "error", message: msg });
        } finally {
            setSaving(false);
        }
    };

    const initials = user
        ? `${user.names?.charAt(0) || ""}${user.lastnames?.charAt(0) || ""}`.toUpperCase()
        : "?";

    return (
        <div className="flex min-h-screen bg-background">
            <Sidebar />

            <div className="flex-1 flex flex-col min-w-0">
                <Header />

                <main className="flex-1 p-8 overflow-auto">
                    <div className="max-w-2xl mx-auto space-y-6">

                        {/* Título */}
                        <div>
                            <h1 className="text-2xl font-bold text-white">Mi Perfil</h1>
                            <p className="text-muted text-sm mt-1">Visualiza y actualiza tu información personal.</p>
                        </div>

                        {/* Feedback */}
                        {feedback && (
                            <div className={`flex items-center gap-3 px-4 py-3 rounded-xl border text-sm
                                ${feedback.type === "success"
                                    ? "bg-green-500/10 border-green-500/20 text-green-400"
                                    : "bg-red-500/10 border-red-500/20 text-red-400"}`}>
                                {feedback.type === "success"
                                    ? <CheckCircle size={16} />
                                    : <AlertCircle size={16} />}
                                {feedback.message}
                            </div>
                        )}

                        {/* Tarjeta principal */}
                        {loading ? (
                            <div className="bg-surface border border-white/6 rounded-2xl p-8 flex items-center justify-center">
                                <span className="text-muted text-sm animate-pulse">Cargando datos...</span>
                            </div>
                        ) : !user ? (
                            <div className="bg-surface border border-white/6 rounded-2xl p-8 text-center text-muted text-sm">
                                No se encontró información del usuario.
                            </div>
                        ) : (
                            <div className="bg-surface border border-white/6 rounded-2xl overflow-hidden">

                                {/* Header de tarjeta */}
                                <div className="bg-surfaceDark/60 px-6 py-5 flex items-center gap-4 border-b border-white/5">
                                    {/* Avatar con iniciales */}
                                    <div className="w-14 h-14 rounded-xl bg-primary/15 border border-primary/20
                                                    flex items-center justify-center text-primary font-bold text-xl select-none">
                                        {initials}
                                    </div>

                                    <div className="flex-1 min-w-0">
                                        <p className="text-white font-semibold text-lg leading-tight truncate">
                                            {user.names} {user.lastnames}
                                        </p>
                                        <span className="inline-flex items-center mt-1 px-2.5 py-0.5 rounded-full
                                                         bg-primary/15 border border-primary/20
                                                         text-primary text-xs font-medium capitalize">
                                            {user.role}
                                        </span>
                                    </div>

                                    {/* Botón editar / cancelar */}
                                    {!editMode ? (
                                        <button
                                            onClick={() => { setEditMode(true); setFeedback(null); }}
                                            className="flex items-center gap-2 px-4 py-2 rounded-xl
                                                       bg-primary/10 border border-primary/20 text-primary
                                                       text-sm font-medium hover:bg-primary/20 transition-all duration-200">
                                            <Pencil size={14} />
                                            Editar
                                        </button>
                                    ) : (
                                        <button
                                            onClick={handleCancel}
                                            className="flex items-center gap-2 px-4 py-2 rounded-xl
                                                       bg-white/5 border border-white/10 text-muted
                                                       text-sm font-medium hover:text-white hover:bg-white/10 transition-all duration-200">
                                            <X size={14} />
                                            Cancelar
                                        </button>
                                    )}
                                </div>

                                {/* Campos del formulario */}
                                <div className="p-6 space-y-5">

                                    {/* Nombres y Apellidos */}
                                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                                        <Field
                                            label="Nombre(s)"
                                            icon={<User size={14} />}
                                            name="names"
                                            value={form.names}
                                            onChange={handleChange}
                                            disabled={!editMode}
                                        />
                                        <Field
                                            label="Apellidos"
                                            icon={<User size={14} />}
                                            name="lastnames"
                                            value={form.lastnames}
                                            onChange={handleChange}
                                            disabled={!editMode}
                                        />
                                    </div>

                                    {/* Username */}
                                    <Field
                                        label="Nombre de usuario"
                                        icon={<User size={14} />}
                                        name="username"
                                        value={form.username}
                                        onChange={handleChange}
                                        disabled={!editMode}
                                    />

                                    {/* Email y Teléfono */}
                                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                                        <Field
                                            label="Correo electrónico"
                                            icon={<Mail size={14} />}
                                            name="email"
                                            type="email"
                                            value={form.email}
                                            onChange={handleChange}
                                            disabled={!editMode}
                                        />
                                        <Field
                                            label="Teléfono"
                                            icon={<Phone size={14} />}
                                            name="phone"
                                            value={form.phone}
                                            onChange={handleChange}
                                            disabled={!editMode}
                                        />
                                    </div>

                                    {/* Contraseña (solo en modo edición) */}
                                    {editMode && (
                                        <div className="pt-2 border-t border-white/5 space-y-4">
                                            <p className="text-muted text-xs">
                                                Deja los campos de contraseña en blanco si no deseas cambiarla.
                                            </p>
                                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                                                <Field
                                                    label="Nueva contraseña"
                                                    icon={<Lock size={14} />}
                                                    name="password"
                                                    type="password"
                                                    value={form.password}
                                                    onChange={handleChange}
                                                    placeholder="••••••••"
                                                />
                                                <Field
                                                    label="Confirmar contraseña"
                                                    icon={<Lock size={14} />}
                                                    name="confirmPassword"
                                                    type="password"
                                                    value={form.confirmPassword}
                                                    onChange={handleChange}
                                                    placeholder="••••••••"
                                                />
                                            </div>
                                        </div>
                                    )}

                                    {/* Info de solo lectura: fechas */}
                                    {!editMode && (
                                        <div className="pt-3 border-t border-white/5 grid grid-cols-1 sm:grid-cols-2 gap-3">
                                            <InfoRow label="Miembro desde" value={
                                                user.createdAt
                                                    ? new Date(user.createdAt).toLocaleDateString("es-MX", { year: "numeric", month: "long", day: "numeric" })
                                                    : "—"
                                            } />
                                            <InfoRow label="Última actualización" value={
                                                user.updatedAt
                                                    ? new Date(user.updatedAt).toLocaleDateString("es-MX", { year: "numeric", month: "long", day: "numeric" })
                                                    : "—"
                                            } />
                                        </div>
                                    )}

                                    {/* Botón guardar */}
                                    {editMode && (
                                        <div className="flex justify-end pt-2">
                                            <button
                                                onClick={handleSave}
                                                disabled={saving}
                                                className="flex items-center gap-2 px-6 py-2.5 rounded-xl
                                                           bg-primary text-white font-medium text-sm
                                                           hover:bg-primary/90 disabled:opacity-50
                                                           transition-all duration-200">
                                                <Save size={15} />
                                                {saving ? "Guardando..." : "Guardar cambios"}
                                            </button>
                                        </div>
                                    )}
                                </div>
                            </div>
                        )}
                    </div>
                </main>
            </div>
        </div>
    );
}

/* ---- Componentes auxiliares ---- */

function Field({ label, icon, name, value, onChange, disabled, type = "text", placeholder }) {
    return (
        <div className="space-y-1.5">
            <label className="text-muted text-xs font-medium">{label}</label>
            <div className={`flex items-center gap-2.5 px-3.5 py-2.5 rounded-xl border
                            transition-all duration-200
                            ${disabled
                                ? "bg-white/3 border-white/5 text-white/50 cursor-default"
                                : "bg-white/5 border-white/10 text-white focus-within:border-primary/40"}`}>
                <span className={disabled ? "text-white/25" : "text-muted"}>{icon}</span>
                <input
                    type={type}
                    name={name}
                    value={value}
                    onChange={onChange}
                    disabled={disabled}
                    placeholder={placeholder || ""}
                    className="bg-transparent text-sm outline-none w-full placeholder:text-white/20
                               disabled:cursor-default"
                />
            </div>
        </div>
    );
}

function InfoRow({ label, value }) {
    return (
        <div className="space-y-0.5">
            <span className="text-muted text-xs">{label}</span>
            <p className="text-white/70 text-sm">{value}</p>
        </div>
    );
}
