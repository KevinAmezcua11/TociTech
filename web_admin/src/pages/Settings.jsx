import { useEffect, useState } from "react";
import Sidebar from "../components/Sidebar";
import Header from "../components/Header";
import {
    Bell,
    CheckCircle2,
    AlertCircle,
    Info,
    Loader2,
    Moon,
    Palette,
    Save,
    Settings as SettingsIcon,
    Sun,
} from "lucide-react";
import { applyTheme, loadSettings, saveSettings } from "../utils/settingsPreferences";

function SettingsSection({ icon, title, description, children }) {
    const SectionIcon = icon;

    return (
        <section className="bg-surface rounded-xl border border-white/10 p-5 space-y-4">
            <div className="flex items-start gap-3">
                <div className="p-2 bg-primary/15 rounded-lg border border-primary/20">
                    <SectionIcon size={18} className="text-primary" />
                </div>

                <div>
                    <h2 className="text-base font-semibold text-white leading-tight">{title}</h2>
                    <p className="text-xs text-muted mt-1">{description}</p>
                </div>
            </div>

            {children}
        </section>
    );
}

function SegmentedControl({ label, value, options, onChange }) {
    return (
        <div className="space-y-2">
            <p className="text-xs font-medium uppercase text-muted">{label}</p>
            <div className="grid grid-cols-2 gap-2 rounded-lg bg-background border border-white/10 p-1">
                {options.map((option) => {
                    const Icon = option.icon;
                    const active = value === option.value;

                    return (
                        <button
                            key={option.value}
                            type="button"
                            onClick={() => onChange(option.value)}
                            className={`inline-flex items-center justify-center gap-2 rounded-md px-3 py-2 text-sm font-medium transition ${
                                active
                                    ? "bg-primary text-white shadow-sm"
                                    : "text-secondary hover:bg-white/5 hover:text-white"
                            }`}
                        >
                            {Icon && <Icon size={15} />}
                            {option.label}
                        </button>
                    );
                })}
            </div>
        </div>
    );
}

function TogglePreference({ checked, onChange, label, description }) {
    return (
        <label className="flex items-center justify-between gap-4 rounded-lg bg-background border border-white/10 px-4 py-3">
            <span>
                <span className="block text-sm font-medium text-white">{label}</span>
                <span className="block text-xs text-muted mt-0.5">{description}</span>
            </span>

            <input
                type="checkbox"
                checked={checked}
                onChange={(event) => onChange(event.target.checked)}
                className="h-4 w-4 accent-primary"
            />
        </label>
    );
}

function InfoRow({ label, value }) {
    return (
        <div className="flex items-center justify-between gap-4 border-b border-white/5 py-3 last:border-b-0">
            <span className="text-sm text-muted">{label}</span>
            <span className="text-sm font-medium text-white text-right">{value}</span>
        </div>
    );
}

export default function Settings() {
    const [settings, setSettings] = useState(loadSettings);
    const [saving, setSaving] = useState(false);
    const [success, setSuccess] = useState("");
    const [error, setError] = useState("");

    useEffect(() => {
        try {
            applyTheme(settings.theme);
            saveSettings(settings);
        } catch (err) {
            console.error(err);
            setError("No se pudieron guardar los ajustes en este navegador.");
        }
    }, [settings]);

    const updatePreference = (key, value) => {
        setError("");
        setSettings((currentSettings) => ({
            ...currentSettings,
            [key]: value,
        }));
        setSuccess("Cambio aplicado.");
        window.setTimeout(() => setSuccess(""), 1800);
    };

    const handleSave = async () => {
        setSaving(true);
        setSuccess("");
        setError("");

        try {
            saveSettings(settings);
            setSuccess("Ajustes guardados correctamente.");
            window.setTimeout(() => setSuccess(""), 2500);
        } catch (err) {
            console.error(err);
            setError("No se pudieron guardar los ajustes. Revisa permisos de almacenamiento del navegador.");
        } finally {
            setSaving(false);
        }
    };

    return (
        <div className="flex min-h-screen bg-background">
            <Sidebar />

            <div className="flex-1 flex flex-col min-w-0">
                <Header />

                <main className="flex-1 p-8 space-y-6 overflow-auto">
                    <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-primary/15 rounded-lg border border-primary/20">
                                <SettingsIcon size={20} className="text-primary" />
                            </div>

                            <div>
                                <h1 className="text-xl font-bold text-white leading-tight">Configuracion</h1>
                                <p className="text-xs text-muted mt-0.5">
                                    Preferencias generales del panel web admin
                                </p>
                            </div>
                        </div>

                        <button
                            type="button"
                            onClick={handleSave}
                            disabled={saving}
                            className="inline-flex items-center justify-center gap-2 rounded-lg bg-primary px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-60"
                        >
                            {saving ? <Loader2 size={16} className="animate-spin" /> : <Save size={16} />}
                            Guardar ajustes
                        </button>
                    </div>

                    {success && (
                        <div className="flex items-center gap-2 rounded-lg border border-brand-green/30 bg-brand-green/10 px-4 py-3 text-sm text-green-200">
                            <CheckCircle2 size={16} />
                            {success}
                        </div>
                    )}

                    {error && (
                        <div className="flex items-center gap-2 rounded-lg border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-200">
                            <AlertCircle size={16} />
                            {error}
                        </div>
                    )}

                    <div className="grid gap-6 xl:grid-cols-2">
                        <SettingsSection
                            icon={Palette}
                            title="Tema de color"
                            description="Cambia la preferencia visual principal del panel."
                        >
                            <SegmentedControl
                                label="Tema"
                                value={settings.theme}
                                onChange={(value) => updatePreference("theme", value)}
                                options={[
                                    { value: "dark", label: "Oscuro", icon: Moon },
                                    { value: "light", label: "Claro", icon: Sun },
                                ]}
                            />
                        </SettingsSection>

                        <SettingsSection
                            icon={Bell}
                            title="Notificaciones"
                            description="Activa o desactiva avisos administrativos basicos."
                        >
                            <TogglePreference
                                checked={settings.notifications}
                                onChange={(value) => updatePreference("notifications", value)}
                                label="Recibir notificaciones"
                                description="Permite mostrar avisos del panel cuando esten disponibles."
                            />
                        </SettingsSection>

                        <SettingsSection
                            icon={Info}
                            title="Informacion de la aplicacion"
                            description="Datos generales del sistema administrativo."
                        >
                            <div className="rounded-lg bg-background border border-white/10 px-4">
                                <InfoRow label="Aplicacion" value="TociTech Admin" />
                                <InfoRow label="Version" value={import.meta.env.VITE_APP_VERSION || "0.0.0"} />
                                <InfoRow label="Tema actual" value={settings.theme === "light" ? "Claro" : "Oscuro"} />
                                <InfoRow label="Creditos" value="TociTech" />
                            </div>
                        </SettingsSection>
                    </div>
                </main>
            </div>
        </div>
    );
}