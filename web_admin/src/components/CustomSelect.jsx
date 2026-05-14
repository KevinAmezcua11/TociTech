import { useState, useRef, useEffect } from "react";
import { ChevronDown, Check } from "lucide-react";

export default function CustomSelect({
    value,
    onChange,
    options = [],
    placeholder = "Seleccionar...",
    icon,
    className = "",
}) {
    const [open, setOpen] = useState(false);
    const [dropdownStyle, setDropdownStyle] = useState({});
    const triggerRef = useRef(null);
    const wrapperRef = useRef(null);

    const calcPosition = () => {
        if (triggerRef.current) {
            const rect = triggerRef.current.getBoundingClientRect();
            const spaceBelow = window.innerHeight - rect.bottom;
            const spaceAbove = rect.top;
            const estimatedHeight = Math.min(options.length * 44 + 12, 256);
            const openUpward = spaceBelow < estimatedHeight && spaceAbove > spaceBelow;

            setDropdownStyle({
                position: "fixed",
                ...(openUpward
                    ? { bottom: window.innerHeight - rect.top + 6, maxHeight: Math.min(spaceAbove - 8, 256) }
                    : { top: rect.bottom + 6, maxHeight: Math.min(spaceBelow - 8, 256) }
                ),
                left: rect.left,
                width: rect.width,
                zIndex: 9999,
            });
        }
    };

    const openDropdown = () => {
        calcPosition();
        setOpen((o) => !o);
    };

    // Cerrar al hacer clic fuera
    useEffect(() => {
        const handler = (e) => {
            if (
                wrapperRef.current && !wrapperRef.current.contains(e.target) &&
                !triggerRef.current?.contains(e.target)
            ) {
                setOpen(false);
            }
        };
        document.addEventListener("mousedown", handler);
        return () => document.removeEventListener("mousedown", handler);
    }, []);

    // Recalcular al hacer scroll
    useEffect(() => {
        if (!open) return;
        const handler = () => calcPosition();
        window.addEventListener("scroll", handler, true);
        return () => window.removeEventListener("scroll", handler, true);
    }, [open]);

    const selected = options.find((o) => o.value === value);

    return (
        <div ref={wrapperRef} className={`relative ${className}`}>
            {/* Trigger */}
            <button
                ref={triggerRef}
                type="button"
                onClick={openDropdown}
                className="w-full flex items-center gap-2 bg-white/5 border border-white/10 text-sm p-2.5 rounded-lg outline-none hover:border-white/20 focus:border-primary/50 transition-colors text-left"
            >
                {icon && <span className="text-muted flex-shrink-0">{icon}</span>}

                {selected?.dot && (
                    <span className={`w-2 h-2 rounded-full flex-shrink-0 ${selected.dot}`} />
                )}

                <span className={`flex-1 truncate ${selected ? "text-white" : "text-muted"}`}>
                    {selected ? selected.label : placeholder}
                </span>

                <ChevronDown
                    size={14}
                    className={`text-muted flex-shrink-0 transition-transform duration-200 ${open ? "rotate-180" : ""}`}
                />
            </button>

            {open && (
                <div
                    style={dropdownStyle}
                    className="bg-[#1a1d2e] border border-white/15 rounded-xl shadow-2xl overflow-hidden"
                >
                    <ul className="py-1.5 overflow-y-auto" style={{ maxHeight: dropdownStyle.maxHeight ?? 256 }}>
                        {options.map((opt) => {
                            const isSelected = opt.value === value;
                            return (
                                <li key={opt.value}>
                                    <button
                                        type="button"
                                        onClick={() => {
                                            onChange(opt.value);
                                            setOpen(false);
                                        }}
                                        className={`w-full flex items-center gap-2.5 px-3 py-2.5 text-sm transition-colors text-left
                                            ${isSelected
                                                ? "bg-white/8 text-white"
                                                : "text-[#a0a8c0] hover:bg-white/5 hover:text-white"
                                            }`}
                                    >
                                        {opt.dot && (
                                            <span className={`w-2 h-2 rounded-full flex-shrink-0 ${opt.dot}`} />
                                        )}
                                        {opt.icon && (
                                            <span className="flex-shrink-0">{opt.icon}</span>
                                        )}
                                        <span className="flex-1">{opt.label}</span>
                                        {isSelected && (
                                            <Check size={13} className="text-primary flex-shrink-0" />
                                        )}
                                    </button>
                                </li>
                            );
                        })}
                    </ul>
                </div>
            )}
        </div>
    );
}