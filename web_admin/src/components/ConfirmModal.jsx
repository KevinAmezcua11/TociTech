export default function ConfirmModal({
    isOpen,
    onClose,
    onConfirm,
    title,
    message,
    type = "default" // success | danger
    }) {
    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50">

        <div className="bg-surface rounded-2xl p-6 w-full max-w-md border border-white/5">

            <h2 className="text-white text-xl font-semibold mb-2">
            {title}
            </h2>

            <p className="text-secondary mb-6">
            {message}
            </p>

            <div className="flex justify-end gap-3">

            <button
                onClick={onClose}
                className="px-4 py-2 rounded-xl bg-surfaceDark text-secondary hover:text-white transition"
            >
                Cancelar
            </button>

            <button
                onClick={onConfirm}
                className={`px-4 py-2 rounded-xl text-white font-medium transition
                ${type === "danger"
                    ? "bg-red-500 hover:bg-red-600"
                    : "bg-brand-green hover:bg-green-600"}
                `}
            >
                Confirmar
            </button>

            </div>
        </div>
        </div>
    );
}