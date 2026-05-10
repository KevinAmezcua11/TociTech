import { useState } from "react";
import {
    X, User, Package, Wrench, Calendar, DollarSign, Tag,
    Cpu, AlertCircle, Clock, CreditCard, Phone, Mail,
    Zap, Lock, ChevronDown, Loader2,
} from "lucide-react";
import { PaymentBadge, PedidoBadge, PAGO_CONFIG } from "./PaymentBadge";
import { updateOrder } from "../../api/orderService";

// Convierte Firestore Timestamp serializado { _seconds, _nanoseconds } o Date a Date
const toDate = (v) => {
    if (!v) return null;
    if (v instanceof Date) return v;
    if (v._seconds != null) return new Date(v._seconds * 1000);
    return new Date(v);
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

export default function OrderDetailsSidebar({ order, onClose, onUpdated }) {
    const [localEstadoPago, setLocalEstadoPago] = useState(
        order?.estadoPago || "PENDIENTE"
    );
    const [savingPago, setSavingPago]     = useState(false);
    const [pagoError,  setPagoError]      = useState(null);

    if (!order) return null;

    const isProduct    = order.type === "product";
    const isService    = order.type === "service";
    const total        = order.total ?? order.finalPrice ?? order.service?.basePrice;
    const estadoPedido = order.estadoPedido || "PENDIENTE";
    const paidAt       = toDate(order.paidAt);
    // Productos: mostrar sección solo si tiene datos de Stripe
    // Servicios: mostrar siempre para permitir gestión manual
    const showPaymentCard = isService || Boolean(order.estadoPago || order.paymentIntentId);

    const handlePagoChange = async (nuevoEstado) => {
        if (!isService || savingPago || nuevoEstado === localEstadoPago) return;
        setSavingPago(true);
        setPagoError(null);
        try {
            await updateOrder(order.id, { estadoPago: nuevoEstado });
            setLocalEstadoPago(nuevoEstado);
            onUpdated?.();
        } catch (err) {
            console.error(err);
            setPagoError("No se pudo actualizar el estado de pago.");
        } finally {
            setSavingPago(false);
        }
    };

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
                            <div className="space-y-1.5">
                                <span>{order.customer?.name || "—"}</span>
                                {order.customer?.email && (
                                    <div className="flex items-center gap-1.5">
                                        <Mail size={12} className="text-muted flex-shrink-0" />
                                        <span className="text-secondary text-xs">{order.customer.email}</span>
                                    </div>
                                )}
                                {order.customer?.phone && (
                                    <div className="flex items-center gap-1.5">
                                        <Phone size={12} className="text-muted flex-shrink-0" />
                                        <span className="text-secondary text-xs">{order.customer.phone}</span>
                                    </div>
                                )}
                            </div>
                        </Section>

                        <Divider />

                        <Section icon={Tag} label="Tipo">
                            <span className="inline-flex items-center gap-1.5">
                                {isProduct
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

                    {/* ── Información de pago ── */}
                    {showPaymentCard && (
                        <div className="bg-white/[0.03] border border-white/10 rounded-xl p-4 space-y-4">

                            {/* Encabezado de sección */}
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-2">
                                    <div className="p-1.5 bg-primary/10 rounded-md border border-primary/20">
                                        <CreditCard size={13} className="text-primary" />
                                    </div>
                                    <p className="text-xs font-semibold uppercase tracking-wider text-white">
                                        Información de pago
                                    </p>
                                </div>
                                {/* Badge que indica el origen del pago */}
                                {isProduct && (
                                    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-[#635bff]/10 border border-[#635bff]/20 text-[10px] font-medium text-[#a09bff]">
                                        <Zap size={9} /> Stripe
                                    </span>
                                )}
                                {isService && (
                                    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full bg-white/5 border border-white/10 text-[10px] font-medium text-muted">
                                        Pago presencial
                                    </span>
                                )}
                            </div>

                            <Divider />

                            {/* ── PRODUCTO: solo lectura, Stripe controla ── */}
                            {isProduct && (
                                <>
                                    <Section icon={CreditCard} label="Estado del pago">
                                        <PaymentBadge estadoPago={order.estadoPago} />
                                    </Section>

                                    <div className="flex items-center gap-2.5 px-3 py-2.5 bg-[#635bff]/[0.06] border border-[#635bff]/15 rounded-lg mt-1">
                                        <Lock size={12} className="text-[#a09bff] flex-shrink-0" />
                                        <p className="text-xs text-[#c0bbff] leading-relaxed">
                                            Gestionado automáticamente por Stripe.
                                            El admin no puede modificar este estado.
                                        </p>
                                    </div>
                                </>
                            )}

                            {/* ── SERVICIO: editable por el admin ── */}
                            {isService && (
                                <Section icon={CreditCard} label="Estado del pago">
                                    <div className="space-y-2">
                                        <div className="relative">
                                            <select
                                                value={localEstadoPago}
                                                onChange={(e) => handlePagoChange(e.target.value)}
                                                disabled={savingPago}
                                                className="w-full bg-white/5 border border-white/10 text-white text-xs p-2.5 pl-3 pr-8 rounded-lg outline-none focus:border-primary/50 transition-colors appearance-none cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
                                            >
                                                {Object.entries(PAGO_CONFIG).map(([key, cfg]) => (
                                                    <option key={key} value={key} className="bg-[#1A1A22] text-white">
                                                        {cfg.label}
                                                    </option>
                                                ))}
                                            </select>
                                            <div className="absolute right-2.5 top-1/2 -translate-y-1/2 pointer-events-none text-muted">
                                                {savingPago
                                                    ? <Loader2 size={13} className="animate-spin" />
                                                    : <ChevronDown size={13} />
                                                }
                                            </div>
                                        </div>

                                        {pagoError && (
                                            <p className="text-xs text-red-400">{pagoError}</p>
                                        )}

                                        {/* Preview del badge seleccionado */}
                                        <div className="flex items-center gap-2 text-xs text-muted">
                                            <span>Vista previa:</span>
                                            <PaymentBadge estadoPago={localEstadoPago} />
                                        </div>
                                    </div>
                                </Section>
                            )}

                            {/* ── Datos de Stripe (solo productos con paymentIntentId) ── */}
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

                            {(order.estadoPago === "PAGADO" || localEstadoPago === "PAGADO") && total != null && (
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
                    {isProduct && (
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
                    {isService && (
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
