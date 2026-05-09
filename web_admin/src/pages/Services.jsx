import { useEffect, useMemo, useState } from "react";
import Sidebar from "../components/Sidebar";
import Header from "../components/Header";
import ConfirmModal from "../components/ConfirmModal";
import {
    createService,
    deleteService,
    getServices,
    updateService,
} from "../api/serviceService";
import {
    Briefcase,
    CheckCircle2,
    DollarSign,
    Edit3,
    ImageIcon,
    Link2,
    Loader2,
    Plus,
    Search,
    Trash2,
    X,
} from "lucide-react";

const emptyForm = {
    name: "",
    description: "",
    price: "",
    duration: "",
    image: "",
    active: true,
};

export default function Services() {
    const [services, setServices] = useState([]);
    const [form, setForm] = useState(emptyForm);
    const [editingId, setEditingId] = useState(null);
    const [serviceToDelete, setServiceToDelete] = useState(null);
    const [search, setSearch] = useState("");
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [deleting, setDeleting] = useState(false);
    const [error, setError] = useState("");
    const [success, setSuccess] = useState("");

    useEffect(() => {
        fetchServices();
    }, []);

    const fetchServices = async () => {
        setLoading(true);
        setError("");

        try {
            const data = await getServices();
            setServices(data);
        } catch (err) {
            console.error(err);
            setError("No se pudieron cargar los servicios. Revisa que el backend esté corriendo.");
        } finally {
            setLoading(false);
        }
    };

    const filteredServices = useMemo(() => {
        const term = search.trim().toLowerCase();

        if (!term) return services;

        return services.filter((service) =>
            [service.name, service.description, service.duration]
                .filter(Boolean)
                .some((value) => value.toLowerCase().includes(term))
        );
    }, [services, search]);

    const showSuccess = (message) => {
        setSuccess(message);
        window.setTimeout(() => setSuccess(""), 2500);
    };

    const handleChange = (event) => {
        const { name, value, type, checked } = event.target;

        setForm((currentForm) => ({
            ...currentForm,
            [name]: type === "checkbox" ? checked : value,
        }));
    };

    const resetForm = () => {
        setForm(emptyForm);
        setEditingId(null);
        setError("");
    };

    const validateForm = () => {
        const name = form.name.trim();
        const description = form.description.trim();
        const duration = form.duration.trim();
        const price = Number(form.price);

        if (!name) return "El nombre del servicio es obligatorio.";
        if (!description) return "La descripción del servicio es obligatoria.";
        if (!form.price || Number.isNaN(price) || price < 0) {
            return "El precio debe ser un número válido mayor o igual a cero.";
        }
        if (!duration) return "La duración del servicio es obligatoria.";

        return "";
    };

    const handleSubmit = async (event) => {
        event.preventDefault();

        const validationError = validateForm();
        if (validationError) {
            setError(validationError);
            return;
        }

        const serviceData = {
            name: form.name.trim(),
            description: form.description.trim(),
            price: Number(form.price),
            duration: form.duration.trim(),
            image: form.image.trim(),
            active: form.active,
        };

        setSaving(true);
        setError("");

        try {
            if (editingId) {
                await updateService(editingId, serviceData);
                showSuccess("Servicio actualizado correctamente.");
            } else {
                await createService(serviceData);
                showSuccess("Servicio creado correctamente.");
            }

            await fetchServices();
            resetForm();
        } catch (err) {
            console.error(err);
            setError(err.response?.data?.message || "No se pudo guardar el servicio. Intenta nuevamente.");
        } finally {
            setSaving(false);
        }
    };

    const handleEdit = (service) => {
        setEditingId(service.id);
        setForm({
            name: service.name || "",
            description: service.description || "",
            price: service.price?.toString() || "",
            duration: service.duration || "",
            image: service.image || "",
            active: service.active !== false,
        });
        setError("");
        window.scrollTo({ top: 0, behavior: "smooth" });
    };

    const handleDelete = async () => {
        if (!serviceToDelete) return;

        setDeleting(true);
        setError("");

        try {
            await deleteService(serviceToDelete.id);
            showSuccess("Servicio eliminado correctamente.");

            if (editingId === serviceToDelete.id) {
                resetForm();
            }

            await fetchServices();
            setServiceToDelete(null);
        } catch (err) {
            console.error(err);
            setError(err.response?.data?.message || "No se pudo eliminar el servicio. Intenta nuevamente.");
        } finally {
            setDeleting(false);
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
                                <Briefcase size={20} className="text-primary" />
                            </div>

                            <div>
                                <h1 className="text-xl font-bold text-white leading-tight">Servicios</h1>
                                <p className="text-xs text-muted mt-0.5">
                                    Administra los servicios disponibles
                                </p>
                            </div>
                        </div>

                        <div className="relative w-full md:w-72">
                            <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted" />
                            <input
                                value={search}
                                onChange={(event) => setSearch(event.target.value)}
                                className="w-full rounded-lg bg-surface border border-white/10 py-2 pl-9 pr-3 text-sm text-white outline-none transition placeholder:text-muted focus:border-primary/60"
                                placeholder="Buscar servicio"
                            />
                        </div>
                    </div>

                    {error && (
                        <div className="rounded-lg border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-200">
                            {error}
                        </div>
                    )}

                    {success && (
                        <div className="flex items-center gap-2 rounded-lg border border-brand-green/30 bg-brand-green/10 px-4 py-3 text-sm text-green-200">
                            <CheckCircle2 size={16} />
                            {success}
                        </div>
                    )}

                    <section className="grid gap-6 xl:grid-cols-[380px_1fr]">
                        <form
                            onSubmit={handleSubmit}
                            className="bg-surface rounded-xl border border-white/10 p-5 space-y-4 h-fit"
                        >
                            <div className="flex items-center justify-between">
                                <h2 className="text-base font-semibold text-white">
                                    {editingId ? "Editar servicio" : "Nuevo servicio"}
                                </h2>

                                {editingId && (
                                    <button
                                        type="button"
                                        onClick={resetForm}
                                        className="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-white/5 text-muted transition hover:text-white"
                                        title="Cancelar edición"
                                    >
                                        <X size={16} />
                                    </button>
                                )}
                            </div>

                            <label className="block space-y-1.5">
                                <span className="text-xs font-medium uppercase text-muted">Nombre</span>
                                <input
                                    name="name"
                                    value={form.name}
                                    onChange={handleChange}
                                    className="w-full rounded-lg bg-background border border-white/10 px-3 py-2 text-sm text-white outline-none transition placeholder:text-muted focus:border-primary/60"
                                    placeholder="Ej. Mantenimiento preventivo"
                                    maxLength={80}
                                />
                            </label>

                            <label className="block space-y-1.5">
                                <span className="text-xs font-medium uppercase text-muted">Descripción</span>
                                <textarea
                                    name="description"
                                    value={form.description}
                                    onChange={handleChange}
                                    rows={4}
                                    className="w-full resize-none rounded-lg bg-background border border-white/10 px-3 py-2 text-sm text-white outline-none transition placeholder:text-muted focus:border-primary/60"
                                    placeholder="Describe el alcance del servicio"
                                    maxLength={300}
                                />
                            </label>

                            <label className="block space-y-1.5">
                                <span className="text-xs font-medium uppercase text-muted">URL de imagen</span>
                                <div className="relative">
                                    <Link2 size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted" />
                                    <input
                                        name="image"
                                        value={form.image}
                                        onChange={handleChange}
                                        className="w-full rounded-lg bg-background border border-white/10 px-3 py-2 pl-8 text-sm text-white outline-none transition placeholder:text-muted focus:border-primary/60"
                                        placeholder="https://ejemplo.com/imagen.jpg"
                                    />
                                </div>
                                {form.image.trim() && (
                                    <div className="mt-2 rounded-lg overflow-hidden border border-white/10 h-32 bg-white/5">
                                        <img
                                            src={form.image.trim()}
                                            alt="Preview"
                                            className="w-full h-full object-cover"
                                            onError={(e) => { e.currentTarget.style.display = "none"; }}
                                        />
                                    </div>
                                )}
                            </label>

                            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-1">
                                <label className="block space-y-1.5">
                                    <span className="text-xs font-medium uppercase text-muted">Precio</span>
                                    <input
                                        name="price"
                                        value={form.price}
                                        onChange={handleChange}
                                        type="number"
                                        min="0"
                                        step="0.01"
                                        className="w-full rounded-lg bg-background border border-white/10 px-3 py-2 text-sm text-white outline-none transition placeholder:text-muted focus:border-primary/60"
                                        placeholder="0.00"
                                    />
                                </label>

                                <label className="block space-y-1.5">
                                    <span className="text-xs font-medium uppercase text-muted">Duración</span>
                                    <input
                                        name="duration"
                                        value={form.duration}
                                        onChange={handleChange}
                                        className="w-full rounded-lg bg-background border border-white/10 px-3 py-2 text-sm text-white outline-none transition placeholder:text-muted focus:border-primary/60"
                                        placeholder="Ej. 2 horas"
                                        maxLength={40}
                                    />
                                </label>
                            </div>

                            <div className="space-y-1.5 mb-6">
                                <span className="text-xs font-medium uppercase text-muted">Estado</span>

                                <div className="relative flex w-full rounded-full overflow-hidden border border-white/10 bg-background">

                                    {/* Sliding indicator */}
                                    <div
                                    className="absolute inset-0 w-1/2 rounded-full transition-all duration-300 ease-in-out"
                                    style={{
                                        transform: form.active ? "translateX(0%)" : "translateX(100%)",
                                        background: form.active ? "rgba(74, 222, 128, 0.15)" : "rgba(255,255,255,0.08)",
                                        borderRight: form.active ? "1px solid rgba(74,222,128,0.2)" : "none",
                                        borderLeft: !form.active ? "1px solid rgba(255,255,255,0.1)" : "none",
                                    }}
                                    />

                                    {/* Activo */}
                                    <button
                                        type="button"
                                        onClick={() => setForm((f) => ({ ...f, active: true }))}
                                        className="relative flex-1 py-2 text-sm font-semibold transition-colors duration-300 z-10"
                                        style={{ color: form.active ? "rgb(134, 239, 172)" : "rgba(255,255,255,0.45)" }}
                                        >
                                        Activo
                                    </button>

                                    {/* Inactivo */}
                                    <button
                                        type="button"
                                        onClick={() => setForm((f) => ({ ...f, active: false }))}
                                        className="relative flex-1 py-2 text-sm font-semibold transition-colors duration-300 z-10"
                                        style={{ color: !form.active ? "#fff" : "rgba(255,255,255,0.45)" }}
                                        >
                                        Inactivo
                                    </button>
                                </div>
                            </div>

                            <button
                                type="submit"
                                disabled={saving}
                                className="inline-flex w-full items-center justify-center gap-2 rounded-lg bg-primary px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-60"
                            >
                                {saving ? <Loader2 size={16} className="animate-spin" /> : <Plus size={16} />}
                                {editingId ? "Guardar cambios" : "Crear servicio"}
                            </button>
                        </form>

                        <div className="bg-surface rounded-xl border border-white/10 overflow-hidden">
                            {loading ? (
                                <div className="flex items-center justify-center gap-3 p-12 text-muted">
                                    <div className="w-4 h-4 border-2 border-primary/40 border-t-primary rounded-full animate-spin" />
                                    <span className="text-sm">Cargando servicios...</span>
                                </div>
                            ) : filteredServices.length === 0 ? (
                                <div className="flex flex-col items-center justify-center py-14 gap-3">
                                    <div className="p-3 bg-white/5 rounded-full">
                                        <Briefcase size={24} className="text-muted" />
                                    </div>
                                    <p className="text-sm text-muted">
                                        {search ? "No hay servicios con ese criterio" : "No hay servicios registrados"}
                                    </p>
                                </div>
                            ) : (
                                <table className="w-full text-sm">
                                    <thead className="bg-white/5 border-b border-white/10">
                                        <tr>
                                            <th className="px-4 py-3 w-10 text-center"></th>
                                            
                                            <th className="px-4 py-3 text-left text-xs font-medium text-muted uppercase">
                                                Servicio
                                            </th>
                                            <th className="px-4 py-3 text-left text-xs font-medium text-muted uppercase">
                                                Precio
                                            </th>
                                            <th className="px-4 py-3 text-left text-xs font-medium text-muted uppercase">
                                                Duración
                                            </th>
                                            <th className="px-4 py-3 text-center text-xs font-medium text-muted uppercase">
                                                Estado
                                            </th>
                                            <th className="px-4 py-3 text-right text-xs font-medium text-muted uppercase">
                                                Acciones
                                            </th>
                                        </tr>
                                    </thead>

                                    <tbody className="divide-y divide-white/5">
                                        {filteredServices.map((service, index) => (
                                            <tr key={service.id} className="hover:bg-white/[0.02] transition align-middle">
                                                <td className="px-4 py-3 text-center align-middle text-muted text-xs font-medium tabular-nums">
                                                    {index + 1}
                                                </td>
                                                
                                                <td className="px-4 py-3">
                                                    <div className="flex items-center gap-3 max-w-md">
                                                        <div className="shrink-0 w-10 h-10 rounded-lg overflow-hidden bg-white/5 border border-white/10 flex items-center justify-center">
                                                            {service.image ? (
                                                                <img
                                                                    src={service.image}
                                                                    alt={service.name}
                                                                    className="w-full h-full object-cover"
                                                                    onError={(e) => {
                                                                        e.currentTarget.style.display = "none";
                                                                        e.currentTarget.nextSibling.style.display = "flex";
                                                                    }}
                                                                />
                                                            ) : null}
                                                            <span
                                                                className="text-muted"
                                                                style={{ display: service.image ? "none" : "flex" }}
                                                            >
                                                                <ImageIcon size={16} />
                                                            </span>
                                                        </div>
                                                        <div>
                                                            <p className="font-medium text-white">{service.name}</p>
                                                            <p className="mt-0.5 line-clamp-1 text-xs text-muted">
                                                                {service.description}
                                                            </p>
                                                        </div>
                                                    </div>
                                                </td>

                                                <td className="px-4 py-3">
                                                    <span className="inline-flex items-center gap-1 text-secondary">
                                                        <DollarSign size={14} className="text-muted" />
                                                        {Number(service.price || 0).toLocaleString("es-MX", {
                                                            minimumFractionDigits: 2,
                                                            maximumFractionDigits: 2,
                                                        })}
                                                    </span>
                                                </td>

                                                <td className="px-4 py-3 text-secondary">
                                                    {service.duration}
                                                </td>

                                                <td className="px-4 py-3 text-center">
                                                    <span className={`inline-flex items-center justify-center rounded-full border px-2.5 py-1 text-xs font-semibold ${
                                                        service.active !== false
                                                            ? "border-brand-green/30 bg-brand-green/10 text-green-200"
                                                            : "border-white/10 bg-white/5 text-muted"
                                                    }`}>
                                                        {service.active !== false ? "Activo" : "Inactivo"}
                                                    </span>
                                                </td>

                                                <td className="px-4 py-3">
                                                    <div className="flex justify-end gap-2">
                                                        <button
                                                            type="button"
                                                            onClick={() => handleEdit(service)}
                                                            className="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-white/5 text-secondary transition hover:text-white"
                                                            title="Editar servicio"
                                                        >
                                                            <Edit3 size={15} />
                                                        </button>

                                                        <button
                                                            type="button"
                                                            onClick={() => setServiceToDelete(service)}
                                                            className="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-red-500/10 text-red-200 transition hover:bg-red-500/20"
                                                            title="Eliminar servicio"
                                                        >
                                                            <Trash2 size={15} />
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            )}
                        </div>
                    </section>
                </main>
            </div>

            <ConfirmModal
                isOpen={Boolean(serviceToDelete)}
                onClose={() => !deleting && setServiceToDelete(null)}
                onConfirm={handleDelete}
                title="Eliminar servicio"
                message={`¿Deseas eliminar "${serviceToDelete?.name || "este servicio"}"? Esta acción no se puede deshacer.`}
                type="danger"
            />
        </div>
    );
}
