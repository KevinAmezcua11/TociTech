export const PAGO_CONFIG = {
    PENDIENTE:   { label: "Pend. pago",  color: "bg-yellow-500/15 text-yellow-400 border border-yellow-500/25", dot: "bg-yellow-400" },
    PAGADO:      { label: "Pagado",      color: "bg-green-500/15  text-green-400  border border-green-500/25",  dot: "bg-green-400"  },
    FALLIDO:     { label: "Fallido",     color: "bg-red-500/15    text-red-400    border border-red-500/25",    dot: "bg-red-400"    },
    REEMBOLSADO: { label: "Reembolsado", color: "bg-blue-500/15   text-blue-400   border border-blue-500/25",   dot: "bg-blue-400"   },
};

export const PEDIDO_CONFIG = {
    PENDIENTE:   { label: "Pendiente",   color: "bg-yellow-500/15 text-yellow-400 border border-yellow-500/25", dot: "bg-yellow-400" },
    EN_PROGRESO: { label: "En progreso", color: "bg-orange-500/15 text-orange-400 border border-orange-500/25", dot: "bg-orange-400" },
    COMPLETADO:  { label: "Completado",  color: "bg-green-500/15  text-green-400  border border-green-500/25",  dot: "bg-green-400"  },
    CANCELADO:   { label: "Cancelado",   color: "bg-red-500/15    text-red-400    border border-red-500/25",    dot: "bg-red-400"    },
};

export function PaymentBadge({ estadoPago }) {
    if (!estadoPago) return <span className="text-muted text-xs">—</span>;
    const cfg = PAGO_CONFIG[estadoPago];
    if (!cfg) return <span className="text-muted text-xs">{estadoPago}</span>;
    return (
        <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium ${cfg.color}`}>
            <span className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${cfg.dot}`} />
            {cfg.label}
        </span>
    );
}

export function PedidoBadge({ estadoPedido }) {
    if (!estadoPedido) return <span className="text-muted text-xs">—</span>;
    const cfg = PEDIDO_CONFIG[estadoPedido];
    if (!cfg) return <span className="text-muted text-xs">{estadoPedido}</span>;
    return (
        <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium ${cfg.color}`}>
            <span className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${cfg.dot}`} />
            {cfg.label}
        </span>
    );
}
