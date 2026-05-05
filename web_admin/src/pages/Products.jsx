import { useState, useEffect, useRef } from "react";
import {
    Plus, Search, Pencil, Trash2, X, Save, AlertCircle,
    CheckCircle, Package, ChevronUp, ChevronDown, Image as ImageIcon
} from "lucide-react";
import Sidebar from "../components/Sidebar";
import Header from "../components/Header";
import api from "../api/api";

/* ─────────── constantes ─────────── */
const CATEGORIES = ["Hardware", "Software", "Periféricos", "Redes", "Almacenamiento", "Otro"];
const STATES     = ["activo", "inactivo", "agotado"];

const EMPTY_FORM = {
    name: "", description: "", price: "", category: "",
    image: "", state: "activo", stock: "", minStock: ""
};

/* ─────────── helpers ─────────── */
function fmt(n) {
    return Number(n).toLocaleString("es-MX", { style: "currency", currency: "MXN" });
}

function stockBadge(stock, minStock) {
    const s = Number(stock), m = Number(minStock);
    if (s === 0)   return { label: "Agotado",   cls: "bg-red-500/15 text-red-400 border-red-500/20" };
    if (s <= m)    return { label: "Stock bajo", cls: "bg-yellow-500/15 text-yellow-400 border-yellow-500/20" };
    return          { label: "En stock",         cls: "bg-green-500/15 text-green-400 border-green-500/20" };
}

function stateBadge(state) {
    if (state === "activo")   return "bg-green-500/15 text-green-400 border-green-500/20";
    if (state === "inactivo") return "bg-white/5 text-muted border-white/10";
    return "bg-red-500/15 text-red-400 border-red-500/20";
}

/* ═══════════════════════════════════════════════════════════ */
export default function Products() {
    const [products, setProducts]   = useState([]);
    const [loading, setLoading]     = useState(true);
    const [search, setSearch]       = useState("");
    const [catFilter, setCatFilter] = useState("Todas");
    const [sort, setSort]           = useState({ key: "name", dir: "asc" });

    const [modal, setModal]         = useState(null); // null | "create" | "edit" | "delete"
    const [selected, setSelected]   = useState(null);
    const [form, setForm]           = useState(EMPTY_FORM);
    const [saving, setSaving]       = useState(false);
    const [feedback, setFeedback]   = useState(null);

    /* ── fetch ── */
    const fetchProducts = async () => {
        try {
            setLoading(true);
            const res = await api.get("/products");
            setProducts(res.data);
        } catch {
            showFeedback("error", "No se pudieron cargar los productos.");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => { fetchProducts(); }, []);

    /* ── feedback auto-dismiss ── */
    useEffect(() => {
        if (!feedback) return;
        const t = setTimeout(() => setFeedback(null), 4000);
        return () => clearTimeout(t);
    }, [feedback]);

    function showFeedback(type, message) { setFeedback({ type, message }); }

    /* ── modales ── */
    function openCreate() {
        setForm(EMPTY_FORM);
        setSelected(null);
        setModal("create");
    }

    function openEdit(p) {
        setForm({
            name: p.name || "", description: p.description || "",
            price: p.price ?? "", category: p.category || "",
            image: p.image || "", state: p.state || "activo",
            stock: p.stock ?? "", minStock: p.minStock ?? ""
        });
        setSelected(p);
        setModal("edit");
    }

    function openDelete(p) { setSelected(p); setModal("delete"); }
    function closeModal()  { setModal(null); setSelected(null); }

    /* ── CRUD ── */
    async function handleSave() {
        if (!form.name.trim()) { showFeedback("error", "El nombre es obligatorio."); return; }
        if (form.price === "" || Number(form.price) < 0) { showFeedback("error", "Precio inválido."); return; }

        const payload = {
            name: form.name.trim(),
            description: form.description.trim(),
            price: Number(form.price),
            category: form.category,
            image: form.image.trim(),
            state: form.state,
            stock: form.stock !== "" ? Number(form.stock) : 0,
            minStock: form.minStock !== "" ? Number(form.minStock) : 0,
        };

        try {
            setSaving(true);
            if (modal === "create") {
                await api.post("/products", payload);
                showFeedback("success", "Producto creado correctamente.");
            } else {
                await api.put(`/products/${selected.id}`, payload);
                showFeedback("success", "Producto actualizado correctamente.");
            }
            closeModal();
            fetchProducts();
        } catch (err) {
            showFeedback("error", err.response?.data?.message || "Error al guardar el producto.");
        } finally {
            setSaving(false);
        }
    }

    async function handleDelete() {
        try {
            setSaving(true);
            await api.delete(`/products/${selected.id}`);
            showFeedback("success", "Producto eliminado.");
            closeModal();
            fetchProducts();
        } catch {
            showFeedback("error", "Error al eliminar el producto.");
        } finally {
            setSaving(false);
        }
    }

    /* ── filtrado & ordenado ── */
    const categories = ["Todas", ...new Set(products.map(p => p.category).filter(Boolean))];

    const visible = products
        .filter(p => {
            const q = search.toLowerCase();
            const matchSearch = !q || p.name?.includes(q) || p.description?.includes(q) || p.category?.includes(q);
            const matchCat = catFilter === "Todas" || p.category === catFilter;
            return matchSearch && matchCat;
        })
        .sort((a, b) => {
            let av = a[sort.key], bv = b[sort.key];
            if (sort.key === "price" || sort.key === "stock") { av = Number(av); bv = Number(bv); }
            else { av = String(av ?? "").toLowerCase(); bv = String(bv ?? "").toLowerCase(); }
            if (av < bv) return sort.dir === "asc" ? -1 : 1;
            if (av > bv) return sort.dir === "asc" ? 1 : -1;
            return 0;
        });

    function toggleSort(key) {
        setSort(prev => prev.key === key
            ? { key, dir: prev.dir === "asc" ? "desc" : "asc" }
            : { key, dir: "asc" });
    }

    /* ═══════════════════ RENDER ═══════════════════ */
    return (
        <div className="flex min-h-screen bg-background">
            <Sidebar />

            <div className="flex-1 flex flex-col min-w-0">
                <Header />

                <main className="flex-1 p-8 space-y-6 overflow-auto">

                    {/* Título + botón */}
                    <div className="flex items-center justify-between gap-4">
                        <div>
                            <h1 className="text-2xl font-bold text-white">Productos</h1>
                            <p className="text-muted text-sm mt-0.5">Gestiona el catálogo de productos de la tienda.</p>
                        </div>
                        <button onClick={openCreate}
                            className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-primary
                                       text-white text-sm font-medium hover:bg-primary/85
                                       transition-all duration-200 shrink-0">
                            <Plus size={16} />
                            Nuevo producto
                        </button>
                    </div>

                    {/* Feedback */}
                    {feedback && (
                        <div className={`flex items-center gap-3 px-4 py-3 rounded-xl border text-sm
                            ${feedback.type === "success"
                                ? "bg-green-500/10 border-green-500/20 text-green-400"
                                : "bg-red-500/10 border-red-500/20 text-red-400"}`}>
                            {feedback.type === "success" ? <CheckCircle size={15} /> : <AlertCircle size={15} />}
                            {feedback.message}
                        </div>
                    )}

                    {/* Filtros */}
                    <div className="flex flex-wrap items-center gap-3">
                        {/* Búsqueda */}
                        <div className="flex items-center gap-2.5 bg-surface border border-white/6
                                        rounded-xl px-3.5 py-2.5 w-72 focus-within:border-primary/40 transition-all">
                            <Search size={14} className="text-muted shrink-0" />
                            <input
                                type="text" value={search} onChange={e => setSearch(e.target.value)}
                                placeholder="Buscar productos..."
                                className="bg-transparent text-sm text-white placeholder:text-muted outline-none w-full" />
                        </div>

                        {/* Categorías */}
                        <div className="flex items-center gap-2 flex-wrap">
                            {categories.map(c => (
                                <button key={c} onClick={() => setCatFilter(c)}
                                    className={`px-3 py-1.5 rounded-lg text-xs font-medium border transition-all
                                        ${catFilter === c
                                            ? "bg-primary/15 border-primary/30 text-primary"
                                            : "bg-surface border-white/6 text-muted hover:text-white hover:border-white/15"}`}>
                                    {c}
                                </button>
                            ))}
                        </div>
                    </div>

                    {/* Stats rápidos */}
                    <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
                        {[
                            { label: "Total productos", value: products.length },
                            { label: "Activos",  value: products.filter(p => p.state === "activo").length },
                            { label: "Stock bajo", value: products.filter(p => Number(p.stock) <= Number(p.minStock) && Number(p.stock) > 0).length },
                            { label: "Agotados", value: products.filter(p => Number(p.stock) === 0).length },
                        ].map(s => (
                            <div key={s.label} className="bg-surface border border-white/6 rounded-xl px-5 py-4">
                                <p className="text-muted text-xs mb-1">{s.label}</p>
                                <p className="text-white text-2xl font-bold">{s.value}</p>
                            </div>
                        ))}
                    </div>

                    {/* Tabla */}
                    <div className="bg-surface border border-white/6 rounded-2xl overflow-hidden">

                        {/* Header tabla */}
                        <div className="px-5 py-4 border-b border-white/5 flex items-center justify-between">
                            <span className="text-white text-sm font-semibold">
                                {visible.length} {visible.length === 1 ? "producto" : "productos"}
                            </span>
                        </div>

                        {loading ? (
                            <div className="py-20 text-center text-muted text-sm animate-pulse">Cargando productos...</div>
                        ) : visible.length === 0 ? (
                            <EmptyState onAdd={openCreate} filtered={search || catFilter !== "Todas"} />
                        ) : (
                            <div className="overflow-x-auto">
                                <table className="w-full text-sm">
                                    <thead>
                                        <tr className="border-b border-white/5 text-muted text-xs">
                                            <Th label="Producto" sortKey="name" sort={sort} onSort={toggleSort} />
                                            <Th label="Categoría" sortKey="category" sort={sort} onSort={toggleSort} />
                                            <Th label="Precio" sortKey="price" sort={sort} onSort={toggleSort} className="text-right" />
                                            <Th label="Stock" sortKey="stock" sort={sort} onSort={toggleSort} className="text-center" />
                                            <th className="px-5 py-3 font-medium text-left">Estado</th>
                                            <th className="px-5 py-3 font-medium text-right">Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {visible.map((p, i) => {
                                            const sb = stockBadge(p.stock, p.minStock);
                                            return (
                                                <tr key={p.id}
                                                    className={`border-b border-white/4 hover:bg-white/2 transition-colors
                                                                ${i === visible.length - 1 ? "border-b-0" : ""}`}>

                                                    {/* Producto */}
                                                    <td className="px-5 py-3.5">
                                                        <div className="flex items-center gap-3">
                                                            <ProductThumb src={p.image} name={p.name} />
                                                            <div className="min-w-0">
                                                                <p className="text-white font-medium capitalize truncate max-w-[200px]">{p.name}</p>
                                                                {p.description && (
                                                                    <p className="text-muted text-xs truncate max-w-[200px]">{p.description}</p>
                                                                )}
                                                            </div>
                                                        </div>
                                                    </td>

                                                    {/* Categoría */}
                                                    <td className="px-5 py-3.5">
                                                        <span className="text-white/70 text-xs bg-white/5 border border-white/8 px-2.5 py-1 rounded-lg">
                                                            {p.category || "—"}
                                                        </span>
                                                    </td>

                                                    {/* Precio */}
                                                    <td className="px-5 py-3.5 text-right text-white font-semibold">
                                                        {p.price != null ? fmt(p.price) : "—"}
                                                    </td>

                                                    {/* Stock */}
                                                    <td className="px-5 py-3.5 text-center">
                                                        <div className="flex flex-col items-center gap-1">
                                                            <span className="text-white font-medium">{p.stock ?? "—"}</span>
                                                            <span className={`text-xs px-2 py-0.5 rounded-full border ${sb.cls}`}>
                                                                {sb.label}
                                                            </span>
                                                        </div>
                                                    </td>

                                                    {/* Estado */}
                                                    <td className="px-5 py-3.5">
                                                        <span className={`text-xs px-2.5 py-1 rounded-full border capitalize ${stateBadge(p.state)}`}>
                                                            {p.state || "—"}
                                                        </span>
                                                    </td>

                                                    {/* Acciones */}
                                                    <td className="px-5 py-3.5">
                                                        <div className="flex items-center justify-end gap-2">
                                                            <ActionBtn icon={<Pencil size={13} />} label="Editar"
                                                                className="text-primary hover:bg-primary/10 border-primary/20"
                                                                onClick={() => openEdit(p)} />
                                                            <ActionBtn icon={<Trash2 size={13} />} label="Eliminar"
                                                                className="text-red-400 hover:bg-red-500/10 border-red-500/20"
                                                                onClick={() => openDelete(p)} />
                                                        </div>
                                                    </td>
                                                </tr>
                                            );
                                        })}
                                    </tbody>
                                </table>
                            </div>
                        )}
                    </div>
                </main>
            </div>

            {/* ── Modal crear / editar ── */}
            {(modal === "create" || modal === "edit") && (
                <Modal title={modal === "create" ? "Nuevo producto" : "Editar producto"} onClose={closeModal}>
                    <div className="space-y-4">
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <FormField label="Nombre *" value={form.name}
                                onChange={v => setForm(f => ({ ...f, name: v }))}
                                placeholder="Ej. Laptop Asus ROG" />
                            <FormField label="Precio (MXN) *" type="number" value={form.price}
                                onChange={v => setForm(f => ({ ...f, price: v }))}
                                placeholder="0.00" />
                        </div>

                        <FormField label="Descripción" value={form.description}
                            onChange={v => setForm(f => ({ ...f, description: v }))}
                            placeholder="Descripción breve del producto" textarea />

                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <FormSelect label="Categoría" value={form.category}
                                onChange={v => setForm(f => ({ ...f, category: v }))}
                                options={CATEGORIES} placeholder="Selecciona..." />
                            <FormSelect label="Estado" value={form.state}
                                onChange={v => setForm(f => ({ ...f, state: v }))}
                                options={STATES} />
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                            <FormField label="Stock" type="number" value={form.stock}
                                onChange={v => setForm(f => ({ ...f, stock: v }))}
                                placeholder="0" />
                            <FormField label="Stock mínimo" type="number" value={form.minStock}
                                onChange={v => setForm(f => ({ ...f, minStock: v }))}
                                placeholder="0" />
                        </div>

                        <FormField label="URL de imagen" value={form.image}
                            onChange={v => setForm(f => ({ ...f, image: v }))}
                            placeholder="https://..." />

                        {/* Preview imagen */}
                        {form.image && (
                            <div className="rounded-xl overflow-hidden border border-white/6 bg-white/3 h-32 flex items-center justify-center">
                                <img src={form.image} alt="preview"
                                    className="h-full object-contain"
                                    onError={e => { e.target.style.display = "none"; }} />
                            </div>
                        )}
                    </div>

                    <div className="flex justify-end gap-3 mt-6">
                        <button onClick={closeModal}
                            className="px-4 py-2 rounded-xl bg-white/5 border border-white/10
                                       text-muted text-sm hover:text-white hover:bg-white/10 transition-all">
                            Cancelar
                        </button>
                        <button onClick={handleSave} disabled={saving}
                            className="flex items-center gap-2 px-5 py-2 rounded-xl bg-primary
                                       text-white text-sm font-medium hover:bg-primary/85
                                       disabled:opacity-50 transition-all">
                            <Save size={14} />
                            {saving ? "Guardando..." : modal === "create" ? "Crear producto" : "Guardar cambios"}
                        </button>
                    </div>
                </Modal>
            )}

            {/* ── Modal eliminar ── */}
            {modal === "delete" && selected && (
                <Modal title="Eliminar producto" onClose={closeModal} size="sm">
                    <div className="flex flex-col items-center text-center gap-4 py-2">
                        <div className="w-14 h-14 rounded-full bg-red-500/10 border border-red-500/20
                                        flex items-center justify-center text-red-400">
                            <Trash2 size={22} />
                        </div>
                        <div>
                            <p className="text-white font-semibold text-base">¿Eliminar este producto?</p>
                            <p className="text-muted text-sm mt-1">
                                Se eliminará <span className="text-white capitalize">"{selected.name}"</span> de forma permanente.
                            </p>
                        </div>
                    </div>
                    <div className="flex justify-center gap-3 mt-6">
                        <button onClick={closeModal}
                            className="px-5 py-2 rounded-xl bg-white/5 border border-white/10
                                       text-muted text-sm hover:text-white hover:bg-white/10 transition-all">
                            Cancelar
                        </button>
                        <button onClick={handleDelete} disabled={saving}
                            className="flex items-center gap-2 px-5 py-2 rounded-xl bg-red-500/80
                                       text-white text-sm font-medium hover:bg-red-500
                                       disabled:opacity-50 transition-all">
                            <Trash2 size={14} />
                            {saving ? "Eliminando..." : "Sí, eliminar"}
                        </button>
                    </div>
                </Modal>
            )}
        </div>
    );
}

/* ─────────── sub-componentes ─────────── */

function Modal({ title, onClose, children, size = "md" }) {
    // cerrar con Escape
    useEffect(() => {
        const handler = e => { if (e.key === "Escape") onClose(); };
        window.addEventListener("keydown", handler);
        return () => window.removeEventListener("keydown", handler);
    }, [onClose]);

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4"
            onClick={e => { if (e.target === e.currentTarget) onClose(); }}>
            {/* Backdrop */}
            <div className="absolute inset-0 bg-black/60 backdrop-blur-sm" />

            {/* Panel */}
            <div className={`relative bg-surface border border-white/8 rounded-2xl shadow-2xl w-full
                             ${size === "sm" ? "max-w-sm" : "max-w-xl"}
                             max-h-[90vh] overflow-y-auto`}>
                {/* Header */}
                <div className="flex items-center justify-between px-6 py-4 border-b border-white/5">
                    <h2 className="text-white font-semibold text-base">{title}</h2>
                    <button onClick={onClose}
                        className="w-8 h-8 flex items-center justify-center rounded-lg
                                   text-muted hover:text-white hover:bg-white/8 transition-all">
                        <X size={15} />
                    </button>
                </div>
                <div className="p-6">{children}</div>
            </div>
        </div>
    );
}

function FormField({ label, value, onChange, placeholder, type = "text", textarea }) {
    const base = `w-full bg-white/5 border border-white/10 rounded-xl px-3.5 py-2.5 text-sm
                  text-white placeholder:text-muted outline-none
                  focus:border-primary/40 transition-all`;
    return (
        <div className="space-y-1.5">
            <label className="text-muted text-xs font-medium">{label}</label>
            {textarea
                ? <textarea value={value} onChange={e => onChange(e.target.value)}
                    placeholder={placeholder} rows={3}
                    className={`${base} resize-none`} />
                : <input type={type} value={value} onChange={e => onChange(e.target.value)}
                    placeholder={placeholder} className={base} />}
        </div>
    );
}

function FormSelect({ label, value, onChange, options, placeholder }) {
    return (
        <div className="space-y-1.5">
            <label className="text-muted text-xs font-medium">{label}</label>
            <select value={value} onChange={e => onChange(e.target.value)}
                className="w-full bg-white/5 border border-white/10 rounded-xl px-3.5 py-2.5 text-sm
                           text-white outline-none focus:border-primary/40 transition-all
                           appearance-none cursor-pointer">
                {placeholder && <option value="" className="bg-surface">{placeholder}</option>}
                {options.map(o => (
                    <option key={o} value={o} className="bg-surface capitalize">{o}</option>
                ))}
            </select>
        </div>
    );
}

function Th({ label, sortKey, sort, onSort, className = "" }) {
    const active = sort.key === sortKey;
    return (
        <th onClick={() => onSort(sortKey)}
            className={`px-5 py-3 font-medium text-left cursor-pointer select-none
                        hover:text-white/70 transition-colors group ${className}`}>
            <div className="flex items-center gap-1">
                <span className={active ? "text-white" : ""}>{label}</span>
                <span className={`transition-opacity ${active ? "opacity-100" : "opacity-0 group-hover:opacity-40"}`}>
                    {active && sort.dir === "asc" ? <ChevronUp size={12} /> : <ChevronDown size={12} />}
                </span>
            </div>
        </th>
    );
}

function ActionBtn({ icon, label, onClick, className }) {
    return (
        <button onClick={onClick} title={label}
            className={`w-8 h-8 flex items-center justify-center rounded-lg border
                        transition-all duration-200 ${className}`}>
            {icon}
        </button>
    );
}

function ProductThumb({ src, name }) {
    const [err, setErr] = useState(false);
    if (!src || err) {
        return (
            <div className="w-9 h-9 rounded-lg bg-white/5 border border-white/8 flex items-center
                            justify-center text-muted shrink-0">
                <Package size={14} />
            </div>
        );
    }
    return (
        <img src={src} alt={name} onError={() => setErr(true)}
            className="w-9 h-9 rounded-lg object-cover border border-white/8 shrink-0 bg-white/5" />
    );
}

function EmptyState({ onAdd, filtered }) {
    return (
        <div className="py-20 flex flex-col items-center gap-4 text-center px-6">
            <div className="w-14 h-14 rounded-2xl bg-white/4 border border-white/6 flex items-center justify-center text-muted">
                <Package size={22} />
            </div>
            <div>
                <p className="text-white font-semibold">
                    {filtered ? "Sin resultados" : "Sin productos aún"}
                </p>
                <p className="text-muted text-sm mt-1">
                    {filtered
                        ? "Prueba con otro término o categoría."
                        : "Agrega tu primer producto para comenzar."}
                </p>
            </div>
            {!filtered && (
                <button onClick={onAdd}
                    className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-primary
                               text-white text-sm font-medium hover:bg-primary/85 transition-all">
                    <Plus size={15} /> Agregar producto
                </button>
            )}
        </div>
    );
}