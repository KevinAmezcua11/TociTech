import Sidebar from "../components/Sidebar";
import Header from "../components/Header";

export default function Settings() {
    return (
        <div className="flex min-h-screen bg-background">
            <Sidebar />

            <div className="flex-1 flex flex-col min-w-0">
                <Header />

                <main className="flex-1 p-8 space-y-6 overflow-auto">
                    
                </main>
            </div>
        </div>
    );
}