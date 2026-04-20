import { BrowserRouter, Routes, Route } from "react-router-dom";
import Login from "../pages/Login";
import Dashboard from "../pages/Dashboard";
import Products from "../pages/Products";
import Services from "../pages/Services";
import Orders from "../pages/Orders";
import Customers from "../pages/Customers";
import Settings from "../pages/Settings";
import Profile from "../pages/Profile";

export default function AppRouter() {
    return (
        <BrowserRouter>
            <Routes>
                <Route path="/" element={<Login />} />
                <Route path="/dashboard" element={<Dashboard />} />
                <Route path="/products" element={<Products />} />
                <Route path="/services" element={<Services />} />
                <Route path="/orders" element={<Orders />} />
                <Route path="/customers" element={<Customers />} />
                <Route path="/settings" element={<Settings />} />
                <Route path="/profile" element={<Profile />} />
            </Routes>
        </BrowserRouter>
    );
    }