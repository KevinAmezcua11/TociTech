import {
    X, User, Package, Wrench, Calendar, DollarSign, Tag,
    Cpu, AlertCircle, StickyNote, Clock, CreditCard,
} from "lucide-react";
import { PaymentBadge, PedidoBadge } from "./PaymentBadge";

// Convierte Firestore Timestamp serializado { _seconds, _nanoseconds } o Date a Date
const toDate = (v) => {
    if (!v) return null;
    if (v instanceof Date) return v;
    if (v._seconds != null) return new Date(v._seconds * 1000);
    return new Date(v);
};

// Normaliza status en inglés a EstadoPedido en español (compatibilidad con pedidos anteriores)
const STATUS_TO_PEDIDO = {
    pending:     "PENDIENTE",
    in_progress: "EN_PROGRESO",
    completed:   "COMPLETADO",
    cancelled:   "CANCELADO",
};

// Subcomponente de sección reutilizable (mantiene estilo existente)
const Section = ({ icon: Icon, label, children }) => (
    <div className="space-y-1.5">
        <div className="flex items-center gap-1.5 text-muted">
            <Icon size={12} />
            <p className="text-xs font-medium uppercase tracking-wider">{label}</p>
        </div>
        <div className="text-sm text-white pl-0.5">{children}</div>
    </div>
);

const Divider = () => <div className="h-px bg-white/5" />;

export default function OrderDetailsSidebar({ order, onClose }) {
    if (!order) return null;

    const total        = order.total ?? order.finalPrice ?? order.service?.basePrice;
    const estadoPedido = order.estadoPedido || STATUS_TO_PEDIDO[order.status] || "PENDIENTE";
    const paidAt       = toDate(order.paidAt);
    const hasPayment   = Boolean(order.estadoPago || order.paymentIntentId);

    return (
        <div className="fixed inset-0 z-50 flex">
            <div className="flex-1 bg-black/60 backdrop-blur-sm" onClick={onClose} />

            <div className="w-[460px] bg-surface flex flex-col border-l border-white/10 shadow-2xl">

                {/* ── Header ── */}
                <div className="flex items-center justify-between px-6 py-5 border-b border-white/10">
                    <div>
                        <h2 className="text-white font-semibold">Detalle del pedido</h2>
                        <p className="text-xs text-muted mt-0.5 font-mono">#{order.id || "—"}</p>
                    </div>
                    <button onClick={onClose}
                        className="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-white/5 text-muted hover:text-white transition">
                        <X size={16} />
                    </button>
                </div>

                {/* ── Body ── */}
                <div className="flex-1 overflow-y-auto px-6 py-5 space-y-5 text-sm">

                    {/* Información general */}
                    <div className="bg-white/[0.03] border border-white/10 rounded-xl p-4 space-y-4">
                        <Section icon={User} label="Cliente">
                            {order.customer?.name || "—"}
                        </Section>

                        <Divider />

                        <Section icon={Tag} label="Tipo">
                            <span className="inline-flex items-center gap-1.5">
                                {order.type === "product"
                                    ? <><Package size={13} className="text-primary" /> Producto</>
                                    : <><Wrench  size={13} className="text-primary" /> Servicio</>
                                }
                            </span>
                        </Section>

                        <Divider />

                        <Section icon={Calendar} label="Fecha de creación">
                            {order.createdAt ? new Date(order.createdAt).toLocaleString("es-MX") : "—"}
                        </Section>

                        <Divider />

                        <Section icon={DollarSign} label="Total">
                            <span className="text-base font-semibold text-white">
                                {total != null
                                    ? `$${Number(total).toLocaleString("es-MX", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`
                                    : "—"}
                            </span>
                        </Section>

                        <Divider />

                        <Section icon={Clock} label="Estado pedido">
                            <PedidoBadge estadoPedido={estadoPedido} />
                        </Section>
                    </div>

                    {/* ── Información de pago (solo cuando existe estadoPago o paymentIntentId) ── */}
                    {hasPayment && (
                        <div className="bg-white/[0.03] border border-white/10 rounded-xl p-4 space-y-4">
                            {/* Encabezado de sección */}
                            <div className="flex items-center gap-2">
                                <div className="p-1.5 bg-primary/10 rounded-md border border-primary/20">
                                    <CreditCard size={13} className="text-primary" />
                                </div>
                                <p className="text-xs font-semibold uppercase tracking-wider text-white">
                                    Información de pago
                                </p>
                            </div>

                            <Divider />

                            <Section icon={CreditCard} label="Estado del pago">
                                <PaymentBadge estadoPago={order.estadoPago} />
                            </Section>

                            {order.paymentIntentId && (
                                <>
                                    <Divider />
                                    <Section icon={Tag} label="Payment Intent ID">
                                        <span className="font-mono text-xs bg-white/5 border border-white/10 px-2.5 py-1.5 rounded-lg text-secondary block break-all leading-relaxed">
                                            {order.paymentIntentId}
                                        </span>
                                    </Section>
                                </>
                            )}

                            {paidAt && (
                                <>
                                    <Divider />
                                    <Section icon={Calendar} label="Fecha de pago">
                                        <span className="text-green-400">
                                            {paidAt.toLocaleString("es-MX")}
                                        </span>
                                    </Section>
                                </>
                            )}

                            {order.estadoPago === "PAGADO" && total != null && (
                                <>
                                    <Divider />
                                    <Section icon={DollarSign} label="Total pagado">
                                        <span className="text-green-400 font-semibold text-base">
                                            ${Number(total).toLocaleString("es-MX", { minimumFractionDigits: 2 })}
                                        </span>
                                    </Section>
                                </>
                            )}
                        </div>
                    )}

                    {/* ── Productos comprados ── */}
                    {order.type === "product" && (
                        <div className="space-y-3">
                            <div className="flex items-center gap-1.5 text-muted">
                                <Package size={12} />
                                <p className="text-xs font-medium uppercase tracking-wider">Productos comprados</p>
                            </div>

                            <div className="space-y-2">
                                {order.items?.map((item, i) => (
                                    <div key={i} className="bg-white/[0.03] border border-white/10 rounded-xl p-4">
                                        <div className="flex items-start justify-between gap-3">
                                            <div className="flex-1 min-w-0">
                                                <p className="text-white font-medium truncate">{item.name}</p>
                                                <div className="flex items-center gap-3 mt-1">
                                                    <span className="text-muted text-xs">x{item.quantity}</span>
                                                    <span className="text-muted text-xs">
                                                        ${Number(item.price).toLocaleString("es-MX", { minimumFractionDigits: 2 })} c/u
                                                    </span>
                                                </div>
                                            </div>
                                            <div className="text-right flex-shrink-0">
                                                <span className="text-white font-semibold text-sm">
                                                    ${Number(item.subtotal ?? item.price * item.quantity).toLocaleString("es-MX", { minimumFractionDigits: 2 })}
                                                </span>
                                                <p className="text-muted text-xs mt-0.5">subtotal</p>
                                            </div>
                                        </div>
                                    </div>
                                ))}
                            </div>

                            {/* Total de productos */}
                            {total != null && (
                                <div className="flex items-center justify-between px-4 py-3 bg-white/[0.03] border border-white/10 rounded-xl">
                                    <span className="text-sm text-secondary font-medium">Total</span>
                                    <span className="text-white font-bold text-base">
                                        ${Number(total).toLocaleString("es-MX", { minimumFractionDigits: 2 })}
                                    </span>
                                </div>
                            )}
                        </div>
                    )}

                    {/* ── Detalle de servicio ── */}
                    {order.type === "service" && (
                        <div className="bg-white/[0.03] border border-white/10 rounded-xl p-4 space-y-4">
                            <Section icon={Wrench} label="Servicio">
                                {order.service?.name || "—"}
                            </Section>

                            <Divider />

                            <Section icon={Cpu} label="Equipo">
                                {order.equipment || "—"}
                            </Section>

                            <Divider />

                            <Section icon={AlertCircle} label="Problema">
                                {order.problem || "—"}
                            </Section>

                            {order.notes && (
                                <>
                                    <Divider />
                                    <Section icon={StickyNote} label="Notas">
                                        {order.notes}
                                    </Section>
                                </>
                            )}

                            {order.scheduledDate && (
                                <>
                                    <Divider />
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
