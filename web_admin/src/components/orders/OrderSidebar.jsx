import { useEffect, useState } from "react";
import { createOrder } from "../../api/orderService";
import { getUsers } from "../../api/userService";
import { getProducts } from "../../api/productService";
import { getServices } from "../../api/serviceService";
import CustomSelect from "../CustomSelect";
import {
    X, ShoppingBag, User, Users, UserPlus, Package, Wrench,
    Plus, Trash2, Phone, Mail, Hash, Loader2,
    Laptop, AlertCircle, FileText, Calendar,
} from "lucide-react";

const DEFAULT_SERVICE_FORM = {
    serviceId:     "",
    equipment:     "",
    problem:       "",
    notes:         "",
    scheduledDate: "",
};

export default function OrderSidebar({ onClose, onCreated }) {
    const [type, setType]               = useState("product");
    const [customers, setCustomers]     = useState([]);
    const [products, setProducts]       = useState([]);
    const [services, setServices]       = useState([]);
    const [customerId, setCustomerId]   = useState("");
    const [customerMode, setCustomerMode] = useState("existing");
    const [manualCustomer, setManualCustomer] = useState({
        name: "",
        phone: "",
        email: ""
    });
    const [items, setItems]             = useState([{ productId: "", quantity: 1 }]);
    const [serviceForm, setServiceForm] = useState(DEFAULT_SERVICE_FORM);
    const [loading, setLoading]         = useState(false);

    useEffect(() => {
        const loadData = async () => {
            try {
                const [users, prods, svcs] = await Promise.all([
                    getUsers(),
                    getProducts(),
                    getServices(),
                ]);
                setCustomers(users.filter(u => u.role === "client"));
                setProducts(prods);
                setServices(svcs);
            } catch (err) {
                console.error(err);
            }
        };
        loadData();
    }, []);

    const addItem    = () => setItems([...items, { productId: "", quantity: 1 }]);
    const removeItem = (i) => setItems(items.filter((_, idx) => idx !== i));
    const updateItem = (i, field, value) => {
        const n = [...items];
        n[i][field] = value;
        setItems(n);
    };

    const setSF = (key, value) => setServiceForm(prev => ({ ...prev, [key]: value }));

    const handleSubmit = async () => {
        try {
            setLoading(true);
            const payload = { type };

            if (customerMode === "existing") {
                if (!customerId) {
                    return;
                }
                payload.customerId = customerId;
            } else {
                if (!manualCustomer.name) {
                    alert("Ingresa el nombre del cliente");
                    return;
                }

                payload.customer = {
                    name: manualCustomer.name,
                    phone: manualCustomer.phone,
                    email: manualCustomer.email
                };
            }

            if (type === "product") {
                payload.items = items;
            } else {
                payload.serviceId     = serviceForm.serviceId;
                payload.equipment     = serviceForm.equipment;
                payload.problem       = serviceForm.problem;
                payload.notes         = serviceForm.notes;
                payload.scheduledDate = serviceForm.scheduledDate || null;
            }

            await createOrder(payload);

            // limpiar
            setCustomerId("");
            setCustomerMode("existing");
            setManualCustomer({ name: "", phone: "", email: "" });
            setItems([{ productId: "", quantity: 1 }]);
            setServiceForm(DEFAULT_SERVICE_FORM);

            onClose();
            onCreated();

        } catch (err) {
            console.error(err);
            alert("Error al crear pedido");
        } finally {
            setLoading(false);
        }
    };

    // UI 
    return (
        <div className="fixed inset-0 z-50 flex">
            <div className="flex-1 bg-black/60 backdrop-blur-sm" onClick={onClose} />

            <div className="w-[440px] bg-surface flex flex-col overflow-hidden border-l border-white/10 shadow-2xl">

                {/* Header */}
                <div className="flex items-center justify-between px-6 py-5 border-b border-white/10 bg-white/[0.02]">
                    <div className="flex items-center gap-3">
                        <div className="p-2 bg-primary/15 rounded-lg border border-primary/20">
                            <ShoppingBag size={18} className="text-primary" />
                        </div>
                        <div>
                            <h2 className="text-white font-semibold text-base">Nuevo pedido</h2>
                            <p className="text-xs text-muted">Completa los datos del pedido</p>
                        </div>
                    </div>
                    <button onClick={onClose} className="p-1.5 rounded-lg hover:bg-white/10 text-muted hover:text-white transition-colors">
                        <X size={18} />
                    </button>
                </div>

                {/* Body */}
                <div className="flex-1 overflow-y-auto px-6 py-5 space-y-5">

                    {/* Tipo */}
                    <div className="space-y-2">
                        <label className="text-xs font-medium text-muted uppercase tracking-wider">Tipo de pedido</label>
                        <div className="grid grid-cols-2 gap-2">
                            {[
                                { val: "product", label: "Producto", Icon: Package },
                                { val: "service", label: "Servicio", Icon: Wrench  },
                            ].map(({ val, label, Icon }) => (
                                <button
                                    key={val}
                                    onClick={() => setType(val)}
                                    className={`flex items-center justify-center gap-2 p-3 rounded-lg border text-sm font-medium transition-all ${
                                        type === val
                                            ? "bg-primary/15 border-primary/40 text-primary"
                                            : "bg-white/5 border-white/10 text-secondary hover:border-white/20"
                                    }`}
                                >
                                    <Icon size={15} />
                                    {label}
                                </button>
                            ))}
                        </div>
                    </div>

                    <div className="border-t border-white/10" />

                    {/* Cliente */}
                    <div className="space-y-3">
                        <label className="text-xs font-medium text-muted uppercase tracking-wider">Cliente</label>
                        <div className="grid grid-cols-2 gap-2">
                            {[
                                { mode: "existing", label: "Existente", Icon: Users    },
                                { mode: "manual",   label: "Nuevo",     Icon: UserPlus },
                            ].map(({ mode, label, Icon }) => (
                                <button
                                    key={mode}
                                    onClick={() => {
                                        setCustomerMode(mode);
                                        setCustomerId("");
                                        setManualCustomer({ name: "", phone: "", email: "" });
                                    }}
                                    className={`flex items-center justify-center gap-2 p-2.5 rounded-lg border text-sm font-medium transition-all ${
                                        customerMode === mode
                                            ? "bg-primary/15 border-primary/40 text-primary"
                                            : "bg-white/5 border-white/10 text-secondary hover:border-white/20"
                                    }`}
                                >
                                    <Icon size={14} />
                                    {label}
                                </button>
                            ))}
                        </div>

                        {customerMode === "existing" ? (
                            <CustomSelect
                                value={customerId}
                                onChange={setCustomerId}
                                options={customers.map(c => ({ value: c.id, label: `${c.names} ${c.lastnames}` }))}
                                placeholder="Seleccionar cliente"
                                icon={<User size={14} />}
                            />
                        ) : (
                            <div className="space-y-2">
                                {[
                                    { key: "name",  placeholder: "Nombre completo",    Icon: User  },
                                    { key: "phone", placeholder: "Teléfono",           Icon: Phone },
                                    { key: "email", placeholder: "Correo electrónico", Icon: Mail  },
                                ].map(({ key, placeholder, Icon }) => (
                                    <div key={key} className="relative">
                                        <Icon size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted" />
                                        <input
                                            placeholder={placeholder}
                                            value={manualCustomer[key]}
                                            onChange={(e) => setManualCustomer({ ...manualCustomer, [key]: e.target.value })}
                                            className="w-full bg-white/5 border border-white/10 text-white text-sm p-2.5 pl-9 rounded-lg outline-none placeholder:text-muted focus:border-primary/50 transition-colors"
                                        />
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>

                    <div className="border-t border-white/10" />

                    {/* Sección Productos */}
                    {type === "product" && (
                        <div className="space-y-3">
                            <label className="text-xs font-medium text-muted uppercase tracking-wider">Productos</label>
                            <div className="space-y-2">
                                {items.map((item, i) => (
                                    <div key={i} className="flex gap-2 items-center">
                                        <CustomSelect
                                            value={item.productId}
                                            onChange={(val) => updateItem(i, "productId", val)}
                                            options={products.map(p => ({ value: p.id, label: p.name }))}
                                            placeholder="Seleccionar producto"
                                            icon={<Package size={13} />}
                                            className="flex-1"
                                        />
                                        <div className="relative w-20">
                                            <Hash size={12} className="absolute left-2.5 top-1/2 -translate-y-1/2 text-muted" />
                                            <input
                                                type="number" min="1"
                                                value={item.quantity}
                                                onChange={(e) => updateItem(i, "quantity", e.target.value)}
                                                className="w-full bg-white/5 border border-white/10 text-white text-sm p-2.5 pl-7 rounded-lg outline-none focus:border-primary/50 transition-colors text-center"
                                            />
                                        </div>
                                        {items.length > 1 && (
                                            <button
                                                onClick={() => removeItem(i)}
                                                className="p-2 rounded-lg hover:bg-red-500/10 text-muted hover:text-red-400 border border-transparent hover:border-red-500/20 transition-all flex-shrink-0"
                                            >
                                                <Trash2 size={14} />
                                            </button>
                                        )}
                                    </div>
                                ))}
                            </div>
                            <button onClick={addItem} className="flex items-center gap-2 text-sm text-primary hover:text-primary/80 font-medium transition-colors">
                                <Plus size={14} /> Agregar producto
                            </button>
                        </div>
                    )}

                    {/* Sección Servicio */}
                    {type === "service" && (
                        <div className="space-y-4">
                            <label className="text-xs font-medium text-muted uppercase tracking-wider">Detalle del servicio</label>

                            {/* Servicio */}
                            <div className="space-y-1.5">
                                <span className="text-xs text-muted flex items-center gap-1.5">
                                    <Wrench size={11} /> Tipo de servicio
                                </span>
                                <CustomSelect
                                    value={serviceForm.serviceId}
                                    onChange={(v) => setSF("serviceId", v)}
                                    options={services.map(s => ({ value: s.id, label: s.name }))}
                                    placeholder="Seleccionar servicio"
                                    icon={<Wrench size={14} />}
                                />
                            </div>

                            {/* Equipo */}
                            <div className="space-y-1.5">
                                <span className="text-xs text-muted flex items-center gap-1.5">
                                    <Laptop size={11} /> Equipo
                                </span>
                                <div className="relative">
                                    <Laptop size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted" />
                                    <input
                                        placeholder="Ej. Laptop HP, iPhone 13..."
                                        value={serviceForm.equipment}
                                        onChange={(e) => setSF("equipment", e.target.value)}
                                        className="w-full bg-white/5 border border-white/10 text-white text-sm p-2.5 pl-9 rounded-lg outline-none placeholder:text-muted focus:border-primary/50 transition-colors"
                                    />
                                </div>
                            </div>

                            {/* Problema */}
                            <div className="space-y-1.5">
                                <span className="text-xs text-muted flex items-center gap-1.5">
                                    <AlertCircle size={11} /> Problema reportado
                                </span>
                                <div className="relative">
                                    <AlertCircle size={14} className="absolute left-3 top-3 text-muted" />
                                    <textarea
                                        rows={3}
                                        placeholder="Describe el problema del equipo..."
                                        value={serviceForm.problem}
                                        onChange={(e) => setSF("problem", e.target.value)}
                                        className="w-full bg-white/5 border border-white/10 text-white text-sm p-2.5 pl-9 rounded-lg outline-none placeholder:text-muted focus:border-primary/50 transition-colors resize-none"
                                    />
                                </div>
                            </div>

                            {/* Fecha programada */}
                            <div className="space-y-1.5">
                                <span className="text-xs text-muted flex items-center gap-1.5">
                                    <Calendar size={11} /> Fecha programada
                                </span>
                                <input
                                    type="date"
                                    value={serviceForm.scheduledDate}
                                    onChange={(e) => setSF("scheduledDate", e.target.value)}
                                    className="w-full bg-white/5 border border-white/10 text-white text-sm p-2.5 rounded-lg outline-none focus:border-primary/50 transition-colors [color-scheme:dark]"
                                />
                            </div>

                            {/* Notas */}
                            <div className="space-y-1.5">
                                <span className="text-xs text-muted flex items-center gap-1.5">
                                    <FileText size={11} /> Notas adicionales
                                    <span className="text-white/20 font-normal normal-case tracking-normal">(opcional)</span>
                                </span>
                                <div className="relative">
                                    <FileText size={14} className="absolute left-3 top-3 text-muted" />
                                    <textarea
                                        rows={2}
                                        placeholder="Observaciones, instrucciones especiales..."
                                        value={serviceForm.notes}
                                        onChange={(e) => setSF("notes", e.target.value)}
                                        className="w-full bg-white/5 border border-white/10 text-white text-sm p-2.5 pl-9 rounded-lg outline-none placeholder:text-muted focus:border-primary/50 transition-colors resize-none"
                                    />
                                </div>
                            </div>
                        </div>
                    )}
                </div>

                {/* Footer */}
                <div className="px-6 py-4 border-t border-white/10 bg-white/[0.02]">
                    <div className="flex gap-2">
                        <button
                            onClick={onClose}
                            className="flex-1 bg-white/5 border border-white/10 text-secondary hover:text-white hover:bg-white/10 text-sm font-medium p-2.5 rounded-lg transition-all"
                        >
                            Cancelar
                        </button>
                        <button
                            onClick={handleSubmit}
                            disabled={
                                loading ||
                                (customerMode === "existing"
                                    ? !customerId
                                    : !manualCustomer.name
                                ) ||
                                (type === "product" && items.some(i => !i.productId)) ||
                                (type === "service" && !serviceForm.serviceId)
                            }
                            className="flex-1 flex items-center justify-center gap-2 bg-primary text-white text-sm font-medium p-2.5 rounded-lg hover:opacity-90 disabled:opacity-60 transition-all"
                        >
                            {loading ? (
                                <><Loader2 size={15} className="animate-spin" /> Guardando...</>
                            ) : (
                                <><ShoppingBag size={15} /> Crear pedido</>
                            )}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}