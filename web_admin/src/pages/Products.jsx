import { useEffect, useState, useMemo } from "react";
import {
    Plus, Search, Pencil, Trash2, Package,
    ChevronUp, ChevronDown, ArrowUpDown,
    X, Save, ImagePlus, AlertCircle, CheckCircle,
    Tag, DollarSign, Layers, Hash, RotateCcw
} from "lucide-react";
import Sidebar from "../components/Sidebar";
import Header from "../components/Header";
import CustomSelect from "../components/CustomSelect";
import ConfirmModal from "../components/ConfirmModal";
import {
    getProducts, createProduct, updateProduct, deleteProduct
} from "../api/productService";
import {
    trackPageView,
    trackCreateProduct,
    trackUpdateProduct,
    trackDeleteProduct
} from "../utils/dataLayer";

/* ─── Opciones ─────────────────────────────────────── */
const CATEGORY_OPTIONS = [
    { value: "Hardware",       label: "Hardware"       },
    { value: "Software",       label: "Software"       },
    { value: "Periféricos",    label: "Periféricos"    },
    { value: "Redes",          label: "Redes"          },
    { value: "Almacenamiento", label: "Almacenamiento" },
    { value: "Otro",           label: "Otro"           },
];

const STATUS_OPTIONS = [
    { value: "available",     label: "Disponible",    dot: "bg-green-400"  },
    { value: "out_of_stock",  label: "Sin stock",     dot: "bg-red-400"    },
    { value: "discontinued",  label: "Descontinuado", dot: "bg-gray-400"   },
];

const FILTER_STATUS_OPTIONS = [
    { value: "", label: "Todos los estados" },
    ...STATUS_OPTIONS,
];

const FILTER_CAT_OPTIONS = [
    { value: "", label: "Todas las categorías" },
    ...CATEGORY_OPTIONS,
];

const STATUS_CONFIG = {
    available:    { label: "Disponible",    cls: "bg-green-500/15 text-green-400 border border-green-500/25",  dot: "bg-green-400"  },
    out_of_stock: { label: "Sin stock",     cls: "bg-red-500/15   text-red-400   border border-red-500/25",    dot: "bg-red-400"    },
    discontinued: { label: "Descontinuado", cls: "bg-white/5      text-muted     border border-white/10",      dot: "bg-gray-500"   },
};

const EMPTY_FORM = {
    name: "", description: "", price: "", cost: "",
    category: "", brand: "", model: "", sku: "",
    warranty: "", status: "available",
    stock: "", minStock: "",
    images: [""],           // array de URLs
    specs: [{ key: "", value: "" }],
};

/* ─── helpers ────────────────────────────────────────── */
const fmt = (n) =>
    Number(n).toLocaleString("es-MX", { style: "currency", currency: "MXN" });

function stockBadge(stock, minStock) {
    const s = Number(stock), m = Number(minStock);
    if (s === 0) return { label: "Agotado",    cls: "bg-red-500/15 text-red-400 border border-red-500/25"       };
    if (s <= m)  return { label: "Stock bajo", cls: "bg-yellow-500/15 text-yellow-400 border border-yellow-500/25" };
    return               { label: "En stock",  cls: "bg-green-500/15 text-green-400 border border-green-500/25"  };
}

const normalizeStatus = (status, stock) => {
    if (typeof status === "string") return status;

    if (status === true) return "available";
    if (status === false) return "discontinued";

    if (Number(stock) === 0) return "out_of_stock";

    return "available";
};

/* ═══════════════════════════════════════════════════════ */
export default function Products() {
    const [products, setProducts]   = useState([]);
    const [loading, setLoading]     = useState(true);
    const [feedback, setFeedback]   = useState(null); // { type, message }

    /* filtros */
    const [search,    setSearch]    = useState("");
    const [filterCat, setFilterCat] = useState("");
    const [filterSt,  setFilterSt]  = useState("");
    const [sort,      setSort]      = useState({ key: "name", dir: "asc" });

    /* modal form */
    const [modalMode, setModalMode]   = useState(null); // "create" | "edit" | null
    const [selected,  setSelected]    = useState(null);
    const [form,      setForm]        = useState(EMPTY_FORM);
    const [saving,    setSaving]      = useState(false);

    /* modal confirmar borrar */
    const [confirmDelete, setConfirmDelete] = useState(false);
    const [toDelete,      setToDelete]      = useState(null);

    /* ── fetch ── */
    const fetchProducts = async () => {
        try {
            setLoading(true);
            const data = await getProducts();

            const normalized = data.map(p => ({
                ...p,
                status: normalizeStatus(p.status, p.stock)
            }));

            setProducts(normalized);
        } catch {
            showFeedback("error", "No se pudieron cargar los productos.");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => { 
        trackPageView("Products");
        fetchProducts(); 
    }, []);

    /* ── feedback ── */
    useEffect(() => {
        if (!feedback) return;
        const t = setTimeout(() => setFeedback(null), 4000);
        return () => clearTimeout(t);
    }, [feedback]);

    const showFeedback = (type, message) => setFeedback({ type, message });

    /* ── abrir modales ── */
    const openCreate = () => {
        setForm({
            ...EMPTY_FORM,
            images: [""],
            specs: [{ key: "", value: "" }]
        });
        setSelected(null);
        setModalMode("create");
    };

    const openEdit = (p) => {
        setForm({
            name:        p.name        || "",
            description: p.description || "",
            price:       p.price       ?? "",
            cost:        p.cost        ?? "",
            category:    p.category    || "",
            brand:       p.brand       || "",
            model:       p.model       || "",
            sku:         p.sku         || "",
            warranty:    p.warranty    || "",
            status:      p.status      || "available",
            stock:       p.stock       ?? "",
            minStock:    p.minStock    ?? "",
            images:      p.images?.length ? p.images : [""],
            specs: p.specs
                ? Object.entries(p.specs).map(([k, v]) => ({ key: k, value: v }))
                : [{ key: "", value: "" }],
        });
        setSelected(p);
        setModalMode("edit");
    };

    const openDelete = (p) => { setToDelete(p); setConfirmDelete(true); };

    const closeModal = () => { setModalMode(null); setSelected(null); };

    /* ── CRUD ── */
    const handleSave = async () => {
        if (!form.name.trim()) { showFeedback("error", "El nombre es obligatorio."); return; }
        if (form.price === "" || Number(form.price) < 0) { showFeedback("error", "El precio es inválido."); return; }

        const specs = {};
        form.specs
            .filter(s => s.key && s.value)
            .forEach(s => {
                specs[s.key.toLowerCase()] = s.value;
            });

        const images = form.images.map(u => u.trim()).filter(Boolean);

        const autoStatus = (status, stock) => {
            if (status === "discontinued") return "discontinued";
            if (Number(stock) === 0) return "out_of_stock";
            return "available";
        };

        const payload = {
            name:        form.name.trim(),
            description: form.description.trim(),
            price:       Number(form.price),
            cost:        form.cost !== "" ? Number(form.cost) : 0,
            category: form.category.trim(),
            brand:       form.brand.trim(),
            model:       form.model.trim(),
            sku:         form.sku.trim(),
            warranty:    form.warranty.trim(),
            status: autoStatus(form.status, form.stock),
            stock:       form.stock !== "" ? Number(form.stock) : 0,
            minStock:    form.minStock !== "" ? Number(form.minStock) : 0,
            images,
            specs,
        };

        try {
            setSaving(true);
            if (modalMode === "create") {
                const created = await createProduct(payload);

                trackCreateProduct({
                    id: created?.id || payload.sku || payload.name,
                    name: payload.name
                });

                showFeedback("success", "Producto creado correctamente.");
            } else {
                await updateProduct(selected.id, payload);

                trackUpdateProduct({
                    id: selected.id,
                    name: payload.name
                });

                showFeedback("success", "Producto actualizado correctamente.");
            }
            closeModal();
            fetchProducts();
        } catch (err) {
            showFeedback("error", err.response?.data?.message || "Error al guardar el producto.");
        } finally {
            setSaving(false);
        }
    };

    const handleDelete = async () => {
        try {
            setSaving(true);
            await deleteProduct(toDelete.id);
            trackDeleteProduct(toDelete.id);
            showFeedback("success", `"${toDelete.name}" eliminado.`);
            setConfirmDelete(false);
            setToDelete(null);
            fetchProducts();
        } catch {
            showFeedback("error", "Error al eliminar el producto.");
        } finally {
            setSaving(false);
        }
    };

    /* ── filtrado & ordenado ── */
    const visible = useMemo(() => {
        const q = search.toLowerCase();
        return products
            .filter(p => {
                const matchSearch = !q || p.name?.toLowerCase().includes(q)
                    || p.brand?.toLowerCase().includes(q)
                    || p.sku?.toLowerCase().includes(q)
                    || p.description?.toLowerCase().includes(q);
                const matchCat = !filterCat || p.category === filterCat;
                const matchSt  = !filterSt  || p.status   === filterSt;
                return matchSearch && matchCat && matchSt;
            })
            .sort((a, b) => {
                let av = a[sort.key], bv = b[sort.key];
                if (sort.key === "price" || sort.key === "stock") { av = Number(av); bv = Number(bv); }
                else { av = String(av ?? "").toLowerCase(); bv = String(bv ?? "").toLowerCase(); }
                if (av < bv) return sort.dir === "asc" ? -1 : 1;
                if (av > bv) return sort.dir === "asc" ? 1 : -1;
                return 0;
            });
    }, [products, search, filterCat, filterSt, sort]);

    const toggleSort = (key) =>
        setSort(prev => prev.key === key
            ? { key, dir: prev.dir === "asc" ? "desc" : "asc" }
            : { key, dir: "asc" });

    const SortIcon = ({ k }) => {
        if (sort.key !== k) return <ArrowUpDown size={12} className="text-muted/50" />;
        return sort.dir === "asc" ? <ChevronUp size={12} className="text-primary" /> : <ChevronDown size={12} className="text-primary" />;
    };

    const hasFilters = search || filterCat || filterSt;
    const resetFilters = () => { setSearch(""); setFilterCat(""); setFilterSt(""); };

    /* stats */
    const stats = [
        { label: "Total",        value: products.length,                                            color: "text-white"       },
        { label: "Disponibles",  value: products.filter(p => p.status === "available").length,      color: "text-green-400"   },
        { label: "Sin stock",    value: products.filter(p => p.status === "out_of_stock").length,   color: "text-red-400"     },
        { label: "Descontinuados", value: products.filter(p => p.status === "discontinued").length, color: "text-muted"       },
    ];

    /* ═══════════════════ RENDER ═══════════════════ */
    return (
        <div className="flex min-h-screen bg-background">
            <Sidebar />

            <div className="flex-1 flex flex-col min-w-0">
                <Header />

                <main className="flex-1 p-8 space-y-6 overflow-auto">

                    {/* Cabecera */}
                    <div className="flex items-center justify-between gap-4">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-primary/15 rounded-lg border border-primary/20">
                                <Package size={20} className="text-primary" />
                            </div>
                            <div>
                                <h1 className="text-xl font-bold text-white leading-tight">Productos</h1>
                                <p className="text-xs text-muted mt-0.5">Gestiona el catálogo de la tienda</p>
                            </div>
                        </div>
                        <button onClick={openCreate}
                            className="flex items-center gap-2 px-4 py-2 rounded-xl bg-primary
                                       text-white text-sm font-medium hover:bg-primary/85
                                       transition-all duration-200 shrink-0">
                            <Plus size={15} />
                            Nuevo producto
                        </button>
                    </div>

                    {/* Feedback */}
                    {feedback && (
                        <div className={`flex items-center gap-3 px-4 py-3 rounded-xl border text-sm
                            ${feedback.type === "success"
                                ? "bg-green-500/10 border-green-500/20 text-green-400"
                                : "bg-red-500/10 border-red-500/20 text-red-400"}`}>
                            {feedback.type === "success"
                                ? <CheckCircle size={15} />
                                : <AlertCircle size={15} />}
                            {feedback.message}
                        </div>
                    )}

                    {/* Stats */}
                    <div className="grid grid-cols-2 xl:grid-cols-4 gap-4">
                        {stats.map(s => (
                            <div key={s.label} className="bg-surface border border-white/5 rounded-2xl p-5">
                                <p className="text-muted text-xs mb-1">{s.label}</p>
                                <p className={`text-3xl font-bold ${s.color}`}>{s.value}</p>
                            </div>
                        ))}
                    </div>

                    {/* Filtros */}
                    <div className="flex flex-wrap items-center gap-3">
                        <div className="flex items-center gap-2 bg-surface border border-white/6
                                        rounded-xl px-3.5 py-2.5 w-64 focus-within:border-primary/40 transition-all">
                            <Search size={14} className="text-muted shrink-0" />
                            <input value={search} onChange={e => setSearch(e.target.value)}
                                placeholder="Buscar por nombre, SKU..."
                                className="bg-transparent text-sm text-white placeholder:text-muted outline-none w-full" />
                        </div>

                        <div className="w-52">
                            <CustomSelect value={filterCat} onChange={setFilterCat}
                                options={FILTER_CAT_OPTIONS} placeholder="Todas las categorías"
                                icon={<Tag size={13} />} />
                        </div>

                        <div className="w-52">
                            <CustomSelect value={filterSt} onChange={setFilterSt}
                                options={FILTER_STATUS_OPTIONS} placeholder="Todos los estados" />
                        </div>

                        {hasFilters && (
                            <button onClick={resetFilters}
                                className="flex items-center gap-1.5 px-3 py-2.5 rounded-xl text-xs
                                           text-muted border border-white/6 hover:text-white hover:border-white/15
                                           bg-surface transition-all">
                                <RotateCcw size={12} /> Limpiar
                            </button>
                        )}

                        <span className="ml-auto text-muted text-xs">
                            {visible.length} {visible.length === 1 ? "producto" : "productos"}
                        </span>
                    </div>

                    {/* Tabla */}
                    <div className="bg-surface border border-white/5 rounded-2xl overflow-hidden">
                        {loading ? (
                            <div className="py-20 text-center text-muted text-sm animate-pulse">
                                Cargando productos...
                            </div>
                        ) : visible.length === 0 ? (
                            <EmptyState hasFilters={!!hasFilters} onAdd={openCreate} onReset={resetFilters} />
                        ) : (
                            <div className="overflow-x-auto">
                                <table className="w-full text-sm">
                                    <thead>
                                        <tr className="border-b border-white/5 text-muted text-xs">
                                            <Th label="Producto"   k="name"     sort={sort} onSort={toggleSort} SortIcon={SortIcon} />
                                            <Th label="SKU"        k="sku"      sort={sort} onSort={toggleSort} SortIcon={SortIcon} />
                                            <Th label="Categoría"  k="category" sort={sort} onSort={toggleSort} SortIcon={SortIcon} />
                                            <Th label="Precio"     k="price"    sort={sort} onSort={toggleSort} SortIcon={SortIcon} align="right" />
                                            <Th label="Costo"      k="cost"     sort={sort} onSort={toggleSort} SortIcon={SortIcon} align="right" />
                                            <Th label="Stock"      k="stock"    sort={sort} onSort={toggleSort} SortIcon={SortIcon} align="center" />
                                            <th className="px-5 py-3 font-medium text-left">Estado</th>
                                            <th className="px-5 py-3 font-medium text-right">Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {visible.map((p, i) => {
                                            const sb  = stockBadge(p.stock, p.minStock);
                                            const stc = STATUS_CONFIG[p.status] || STATUS_CONFIG.discontinued;
                                            const isLast = i === visible.length - 1;
                                            return (
                                                <tr key={p.id}
                                                    className={`hover:bg-white/2 transition-colors
                                                                ${!isLast ? "border-b border-white/4" : ""}`}>

                                                    {/* Producto */}
                                                    <td className="px-5 py-3.5">
                                                        <div className="flex items-center gap-3">
                                                            <ProductThumb images={p.images} name={p.name} />
                                                            <div className="min-w-0">
                                                                <p className="text-white font-medium truncate max-w-[180px]">{p.name}</p>
                                                                {(p.brand || p.model) && (
                                                                    <p className="text-muted text-xs truncate max-w-[180px]">
                                                                        {[p.brand, p.model].filter(Boolean).join(" · ")}
                                                                    </p>
                                                                )}
                                                            </div>
                                                        </div>
                                                    </td>

                                                    {/* SKU */}
                                                    <td className="px-5 py-3.5">
                                                        <span className="text-muted text-xs font-mono">
                                                            {p.sku || "—"}
                                                        </span>
                                                    </td>

                                                    {/* Categoría */}
                                                    <td className="px-5 py-3.5">
                                                        <span className="text-white/70 text-xs bg-white/5 border border-white/8 px-2.5 py-1 rounded-lg">
                                                            {p.category || "—"}
                                                        </span>
                                                    </td>

                                                    {/* Precio */}
                                                    <td className="px-5 py-3.5 text-right">
                                                        <span className="text-white font-semibold">
                                                            {p.price != null ? fmt(p.price) : "—"}
                                                        </span>
                                                    </td>

                                                    {/* Costo */}
                                                    <td className="px-5 py-3.5 text-right">
                                                        <span className="text-muted text-xs">
                                                            {p.cost != null ? fmt(p.cost) : "—"}
                                                        </span>
                                                    </td>

                                                    {/* Stock */}
                                                    <td className="px-5 py-3.5 text-center">
                                                        <div className="flex flex-col items-center gap-1">
                                                            <span className="text-white font-medium">{p.stock ?? "—"}</span>
                                                            <span className={`text-xs px-2 py-0.5 rounded-full ${sb.cls}`}>
                                                                {sb.label}
                                                            </span>
                                                        </div>
                                                    </td>

                                                    {/* Estado */}
                                                    <td className="px-5 py-3.5">
                                                        <span className={`inline-flex items-center gap-1.5 text-xs px-2.5 py-1 rounded-full ${stc.cls}`}>
                                                            <span className={`w-1.5 h-1.5 rounded-full ${stc.dot}`} />
                                                            {stc.label}
                                                        </span>
                                                    </td>

                                                    {/* Acciones */}
                                                    <td className="px-5 py-3.5">
                                                        <div className="flex items-center justify-end gap-2">
                                                            <ActionBtn
                                                                icon={<Pencil size={13} />} label="Editar"
                                                                cls="text-primary hover:bg-primary/10 border-primary/20"
                                                                onClick={() => openEdit(p)} />
                                                            <ActionBtn
                                                                icon={<Trash2 size={13} />} label="Eliminar"
                                                                cls="text-red-400 hover:bg-red-500/10 border-red-500/20"
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
            {modalMode && (
                <ProductModal
                    mode={modalMode}
                    form={form}
                    setForm={setForm}
                    onClose={closeModal}
                    onSave={handleSave}
                    saving={saving}
                />
            )}

            {/* ── Modal confirmar borrar ── */}
            <ConfirmModal
                isOpen={confirmDelete}
                onClose={() => { setConfirmDelete(false); setToDelete(null); }}
                onConfirm={handleDelete}
                type="danger"
                title="Eliminar producto"
                message={`¿Seguro que deseas eliminar "${toDelete?.name}"? Esta acción no se puede deshacer.`}
            />
        </div>
    );
}

/* ══════════════════════════════════════════════════════════
   Modal de crear / editar
══════════════════════════════════════════════════════════ */
function ProductModal({ mode, form, setForm, onClose, onSave, saving }) {
    const set = (key, val) => setForm(f => ({ ...f, [key]: val }));

    /* imágenes dinámicas */
    const addImage    = ()      => setForm(f => ({ ...f, images: [...f.images, ""] }));
    const removeImage = (i)     => setForm(f => ({ ...f, images: f.images.filter((_, idx) => idx !== i) }));
    const setImage    = (i, v)  => setForm(f => {
        const imgs = [...f.images]; imgs[i] = v; return { ...f, images: imgs };
    });

    useEffect(() => {
        const handler = e => { if (e.key === "Escape") onClose(); };
        window.addEventListener("keydown", handler);
        return () => window.removeEventListener("keydown", handler);
    }, [onClose]);

    useEffect(() => {
        if (Number(form.stock) === 0 && form.status !== "out_of_stock") {
            setForm(f => ({ ...f, status: "out_of_stock" }));
        }
    }, [form.stock]);

    return (
        <div className="fixed inset-0 z-50 flex items-start justify-center p-4 overflow-y-auto"
            onClick={e => { if (e.target === e.currentTarget) onClose(); }}>
            <div className="fixed inset-0 bg-black/60 backdrop-blur-sm" />

            <div className="relative bg-surface border border-white/8 rounded-2xl shadow-2xl
                            w-full max-w-2xl my-10">
                {/* Header */}
                <div className="flex items-center justify-between px-6 py-4 border-b border-white/5">
                    <h2 className="text-white font-semibold text-base">
                        {mode === "create" ? "Nuevo producto" : "Editar producto"}
                    </h2>
                    <button onClick={onClose}
                        className="w-8 h-8 flex items-center justify-center rounded-lg
                                   text-muted hover:text-white hover:bg-white/8 transition-all">
                        <X size={15} />
                    </button>
                </div>

                <div className="p-6 space-y-6">

                    {/* Sección: Info básica */}
                    <Section title="Información básica">
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <FormField label="Nombre *" value={form.name}
                                onChange={v => set("name", v)} placeholder="Ej. Laptop ASUS ROG" />
                            <FormField label="SKU" value={form.sku}
                                onChange={v => set("sku", v)} placeholder="TT-001"
                                icon={<Hash size={13} />} />
                        </div>
                        <FormField label="Descripción" value={form.description}
                            onChange={v => set("description", v)}
                            placeholder="Descripción breve del producto" textarea />
                    </Section>

                    {/* Sección: Marca y modelo */}
                    <Section title="Marca y modelo">
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <FormField label="Marca" value={form.brand}
                                onChange={v => set("brand", v)} placeholder="Ej. ASUS" />
                            <FormField label="Modelo" value={form.model}
                                onChange={v => set("model", v)} placeholder="Ej. ROG Strix G16" />
                        </div>
                        <FormField label="Garantía" value={form.warranty}
                            onChange={v => set("warranty", v)} placeholder="Ej. 1 año de garantía" />
                    </Section>

                    {/* Sección: Precios y stock */}
                    <Section title="Precios e inventario">
                        <div className="grid grid-cols-2 gap-4">
                            <FormField label="Precio (MXN) *" type="number" value={form.price}
                                onChange={v => set("price", v)} placeholder="0.00"
                                icon={<DollarSign size={13} />} />
                            <FormField label="Costo (MXN)" type="number" value={form.cost}
                                onChange={v => set("cost", v)} placeholder="0.00"
                                icon={<DollarSign size={13} />} />
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                            <FormField label="Stock" type="number" value={form.stock}
                                onChange={v => set("stock", v)} placeholder="0"
                                icon={<Layers size={13} />} />
                            <FormField label="Stock mínimo" type="number" value={form.minStock}
                                onChange={v => set("minStock", v)} placeholder="0" />
                        </div>
                    </Section>

                    {/* Sección: Categoría y estado */}
                    <Section title="Clasificación">
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <div className="space-y-1.5">
                                <label className="text-muted text-xs font-medium">Categoría</label>
                                <CustomSelect value={form.category} onChange={v => set("category", v)}
                                    options={CATEGORY_OPTIONS} placeholder="Seleccionar..."
                                    icon={<Tag size={13} />} />
                            </div>
                            <div className="space-y-1.5">
                                <label className="text-muted text-xs font-medium">Estado</label>
                                <CustomSelect value={form.status} onChange={v => set("status", v)}
                                    options={STATUS_OPTIONS} disabled={Number(form.stock) === 0} />
                            </div>
                        </div>
                    </Section>

                    {/* Sección: Imágenes */}
                    <Section title="Imágenes (URLs)">
                        <div className="space-y-2">
                            {form.images.map((url, i) => (
                                <div key={i} className="flex items-center gap-2">
                                    <div className="flex-1">
                                        <FormField value={url} onChange={v => setImage(i, v)}
                                            placeholder={`URL imagen ${i + 1}`}
                                            icon={<ImagePlus size={13} />} />
                                    </div>
                                    {form.images.length > 1 && (
                                        <button onClick={() => removeImage(i)}
                                            className="w-9 h-9 flex items-center justify-center rounded-lg
                                                       text-muted hover:text-red-400 hover:bg-red-500/10
                                                       border border-white/8 transition-all mt-0.5 shrink-0">
                                            <X size={13} />
                                        </button>
                                    )}
                                </div>
                            ))}
                            <button onClick={addImage}
                                className="flex items-center gap-2 text-xs text-primary hover:text-primary/80
                                           px-3 py-2 rounded-lg border border-primary/20 hover:bg-primary/8
                                           transition-all">
                                <Plus size={12} /> Agregar imagen
                            </button>
                        </div>

                        {/* Preview de imágenes */}
                        {form.images.some(u => u.trim()) && (
                            <div className="flex gap-2 mt-3 flex-wrap">
                                {form.images.filter(u => u.trim()).map((url, i) => (
                                    <img key={i} src={url} alt={`preview-${i}`}
                                        className="w-16 h-16 rounded-lg object-cover border border-white/10 bg-white/5"
                                        onError={e => { e.target.style.opacity = "0.2"; }} />
                                ))}
                            </div>
                        )}
                    </Section>

                    {/* Sección: Specs */}
                    <Section title="Especificaciones">
                        {form.specs.every(s => !s.key && !s.value) && (
                            <p className="text-xs text-muted">Agrega especificaciones</p>
                        )}

                        {form.specs.map((spec, i) => (
                            <div key={i} className="flex gap-2">
                                <input
                                    value={spec.key}
                                    onChange={e => {
                                        const newSpecs = [...form.specs];
                                        newSpecs[i].key = e.target.value;
                                        setForm(f => ({ ...f, specs: newSpecs }));
                                    }}
                                    placeholder="Ej. RAM"
                                    className="flex-1 bg-white/5 border border-white/10 rounded-xl px-3 py-2 text-sm text-white placeholder:text-muted outline-none focus:border-primary/40 transition-all"
                                />

                                <input
                                    value={spec.value}
                                    onChange={e => {
                                        const newSpecs = [...form.specs];
                                        newSpecs[i].value = e.target.value;
                                        setForm(f => ({ ...f, specs: newSpecs }));
                                    }}
                                    placeholder="Ej. 8GB"
                                    className="flex-1 bg-white/5 border border-white/10 rounded-xl px-3 py-2 text-sm text-white placeholder:text-muted outline-none focus:border-primary/40 transition-all"
                                />

                                <button
                                    onClick={() => {
                                        if (form.specs.length === 1) return;

                                        const newSpecs = form.specs.filter((_, idx) => idx !== i);

                                        setForm(f => ({
                                            ...f,
                                            specs: newSpecs
                                        }));
                                    }}
                                    className="px-2 text-red-400"
                                >
                                    <Trash2 size={14}/>
                                </button>
                            </div>
                        ))}

                        <button
                            onClick={() => {
                                setForm(f => ({
                                    ...f,
                                    specs: [...f.specs, { key: "", value: "" }]
                                }));
                            }}
                            className="text-primary text-xs mt-2"
                        >
                            + Agregar especificación
                        </button>
                    </Section>
                </div>

                {/* Footer */}
                <div className="flex justify-end gap-3 px-6 py-4 border-t border-white/5">
                    <button onClick={onClose}
                        className="px-4 py-2 rounded-xl bg-surfaceDark text-secondary
                                   hover:text-white transition text-sm">
                        Cancelar
                    </button>
                    <button onClick={onSave} disabled={saving}
                        className="flex items-center gap-2 px-5 py-2 rounded-xl bg-primary
                                   text-white text-sm font-medium hover:bg-primary/85
                                   disabled:opacity-50 transition-all">
                        <Save size={14} />
                        {saving ? "Guardando..." : mode === "create" ? "Crear producto" : "Guardar cambios"}
                    </button>
                </div>
            </div>
        </div>
    );
}

/* ─── Sub-componentes ─────────────────────────────── */

function Section({ title, children }) {
    return (
        <div className="space-y-3">
            <p className="text-muted text-xs font-semibold uppercase tracking-wider">{title}</p>
            <div className="space-y-3">{children}</div>
        </div>
    );
}

function FormField({ label, value, onChange, placeholder, type = "text", textarea, icon, rows = 3, mono }) {
    const base = `w-full bg-white/5 border border-white/10 rounded-xl text-sm text-white
                  placeholder:text-muted outline-none focus:border-primary/40 transition-all
                  ${mono ? "font-mono" : ""}`;
    return (
        <div className={label ? "space-y-1.5" : ""}>
            {label && <label className="text-muted text-xs font-medium">{label}</label>}
            {textarea ? (
                <textarea value={value} onChange={e => onChange(e.target.value)}
                    placeholder={placeholder} rows={rows}
                    className={`${base} px-3.5 py-2.5 resize-none`} />
            ) : (
                <div className="flex items-center gap-2 bg-white/5 border border-white/10
                                rounded-xl px-3.5 focus-within:border-primary/40 transition-all">
                    {icon && <span className="text-muted shrink-0">{icon}</span>}
                    <input type={type} value={value} onChange={e => onChange(e.target.value)}
                        placeholder={placeholder}
                        className="bg-transparent py-2.5 text-sm text-white placeholder:text-muted outline-none w-full" />
                </div>
            )}
        </div>
    );
}

function Th({ label, k, sort, onSort, SortIcon, align = "left" }) {
    return (
        <th onClick={() => onSort(k)}
            className={`px-5 py-3 font-medium cursor-pointer select-none
                        hover:text-white/70 transition-colors text-${align}`}>
            <div className={`flex items-center gap-1 ${align === "right" ? "justify-end" : align === "center" ? "justify-center" : ""}`}>
                <span className={sort.key === k ? "text-white" : ""}>{label}</span>
                <SortIcon k={k} />
            </div>
        </th>
    );
}

function ActionBtn({ icon, label, cls, onClick }) {
    return (
        <button onClick={onClick} title={label}
            className={`w-8 h-8 flex items-center justify-center rounded-lg border
                        transition-all duration-200 ${cls}`}>
            {icon}
        </button>
    );
}

function ProductThumb({ images, name }) {
    const [err, setErr] = useState(false);
    const src = images?.[0];
    if (!src || err) {
        return (
            <div className="w-9 h-9 rounded-lg bg-white/5 border border-white/8
                            flex items-center justify-center text-muted shrink-0">
                <Package size={14} />
            </div>
        );
    }
    return (
        <img src={src} alt={name} onError={() => setErr(true)}
            className="w-9 h-9 rounded-lg object-cover border border-white/8 shrink-0 bg-white/5" />
    );
}

function EmptyState({ hasFilters, onAdd, onReset }) {
    return (
        <div className="py-20 flex flex-col items-center gap-4 text-center px-6">
            <div className="w-14 h-14 rounded-2xl bg-white/4 border border-white/6
                            flex items-center justify-center text-muted">
                <Package size={22} />
            </div>
            <div>
                <p className="text-white font-semibold">
                    {hasFilters ? "Sin resultados" : "Sin productos aún"}
                </p>
                <p className="text-muted text-sm mt-1">
                    {hasFilters
                        ? "Prueba con otro término o cambia los filtros."
                        : "Agrega tu primer producto para comenzar."}
                </p>
            </div>
            {hasFilters ? (
                <button onClick={onReset}
                    className="flex items-center gap-2 px-4 py-2 rounded-xl bg-white/5
                               border border-white/10 text-muted text-sm hover:text-white transition-all">
                    <RotateCcw size={13} /> Limpiar filtros
                </button>
            ) : (
                <button onClick={onAdd}
                    className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-primary
                               text-white text-sm font-medium hover:bg-primary/85 transition-all">
                    <Plus size={15} /> Agregar producto
                </button>
            )}
        </div>
    );
}