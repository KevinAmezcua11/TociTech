import { X, User, Package, Wrench, Calendar, DollarSign, Tag, Cpu, AlertCircle, StickyNote, Clock } from "lucide-react";

export default function OrderDetailsSidebar({ order, onClose }) {
    if (!order) return null;

    const total =
        order.total ??
        order.finalPrice ??
        order.service?.basePrice;

    const Section = ({ icon: Icon, label, children }) => (
        <div className="space-y-1.5">
            <div className="flex items-center gap-1.5 text-muted">
                <Icon size={12} />
                <p className="text-xs font-medium uppercase tracking-wider">{label}</p>
            </div>
            <div className="text-sm text-white pl-0.5">{children}</div>
        </div>
    );

    return (
        <div className="fixed inset-0 z-50 flex">
            <div className="flex-1 bg-black/60 backdrop-blur-sm" onClick={onClose} />

            <div className="w-[420px] bg-surface flex flex-col border-l border-white/10 shadow-2xl">

                {/* Header */}
                <div className="flex items-center justify-between px-6 py-5 border-b border-white/10">
                    <div>
                        <h2 className="text-white font-semibold">Detalle del pedido</h2>
                        <p className="text-xs text-muted mt-0.5">#{order.id || "—"}</p>
                    </div>

                    <button
                        onClick={onClose}
                        className="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-white/5 text-muted hover:text-white transition"
                    >
                        <X size={16} />
                    </button>
                </div>

                {/* Body */}
                <div className="flex-1 overflow-y-auto px-6 py-5 space-y-5 text-sm">

                    {/* Info general */}
                    <div className="bg-white/[0.03] border border-white/10 rounded-xl p-4 space-y-4">
                        <Section icon={User} label="Cliente">
                            {order.customer?.name || "—"}
                        </Section>

                        <div className="h-px bg-white/5" />

                        <Section icon={Tag} label="Tipo">
                            <span className="inline-flex items-center gap-1.5">
                                {order.type === "product"
                                    ? <><Package size={13} className="text-primary" /> Producto</>
                                    : <><Wrench size={13} className="text-primary" /> Servicio</>
                                }
                            </span>
                        </Section>

                        <div className="h-px bg-white/5" />

                        <Section icon={Calendar} label="Fecha">
                            {order.createdAt
                                ? new Date(order.createdAt).toLocaleString("es-MX")
                                : "—"}
                        </Section>

                        <div className="h-px bg-white/5" />

                        <Section icon={DollarSign} label="Total">
                            <span className="text-base font-semibold text-white">
                                {total != null
                                    ? `$${Number(total).toLocaleString("es-MX", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
                                    : "—"}
                            </span>
                        </Section>
                    </div>

                    {/* PRODUCTOS */}
                    {order.type === "product" && (
                        <div className="space-y-3">
                            <div className="flex items-center gap-1.5 text-muted">
                                <Package size={12} />
                                <p className="text-xs font-medium uppercase tracking-wider">Productos</p>
                            </div>

                            <div className="space-y-2">
                                {order.items?.map((item, i) => (
                                    <div key={i} className="bg-white/[0.03] border border-white/10 rounded-xl p-4 flex items-center justify-between gap-3">
                                        <div>
                                            <p className="text-white font-medium">{item.name}</p>
                                            <p className="text-muted text-xs mt-0.5">Cantidad: {item.quantity}</p>
                                        </div>
                                        <span className="text-white font-semibold whitespace-nowrap">
                                            ${Number(item.price).toLocaleString("es-MX", { minimumFractionDigits: 2 })}
                                        </span>
                                    </div>
                                ))}
                            </div>
                        </div>
                    )}

                    {/* SERVICIO */}
                    {order.type === "service" && (
                        <div className="bg-white/[0.03] border border-white/10 rounded-xl p-4 space-y-4">
                            <Section icon={Wrench} label="Servicio">
                                {order.service?.name || "—"}
                            </Section>

                            <div className="h-px bg-white/5" />

                            <Section icon={Cpu} label="Equipo">
                                {order.equipment || "—"}
                            </Section>

                            <div className="h-px bg-white/5" />

                            <Section icon={AlertCircle} label="Problema">
                                {order.problem || "—"}
                            </Section>

                            {order.notes && (
                                <>
                                    <div className="h-px bg-white/5" />
                                    <Section icon={StickyNote} label="Notas">
                                        {order.notes}
                                    </Section>
                                </>
                            )}

                            {order.scheduledDate && (
                                <>
                                    <div className="h-px bg-white/5" />
                                    <Section icon={Clock} label="Fecha programada">
                                        {new Date(order.scheduledDate).toLocaleDateString("es-MX")}
                                    </Section>
                                </>
                            )}
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}