export default function StatCard({ title, value, color }) {
    return (
        <div className="bg-surface p-5 rounded-xl shadow">
        <p className="text-secondary text-sm">{title}</p>
        <h2 className={`text-3xl font-bold ${color}`}>{value}</h2>
        </div>
    );
}