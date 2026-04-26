import { BrowserRouter, Routes, Route } from "react-router-dom";
import Login from "../pages/Login";
import Dashboard from "../pages/Dashboard";
import Products from "../pages/Products";
import Services from "../pages/Services";
import Orders from "../pages/Orders";
import Customers from "../pages/Customers";
import Profile from "../pages/Profile";
import Settings from "../pages/Settings";
import PrivateRoute from "./PrivateRoute";

export default function Router() {
    return (
        <BrowserRouter>
        <Routes>

            {/* Público */}
            <Route path="/" element={<Login />}/>

            {/* Privadas */}
            <Route path="/dashboard"
            element={
                <PrivateRoute>
                <Dashboard />
                </PrivateRoute>
            }/>

            <Route path="/products"
            element={
                <PrivateRoute>
                <Products />
                </PrivateRoute>
            }/>

            <Route path="/services"
            element={
                <PrivateRoute>
                <Services />
                </PrivateRoute>
            }/>

            <Route path="/orders"
            element={
                <PrivateRoute>
                <Orders />
                </PrivateRoute>
            }/>

            <Route path="/customers"
            element={
                <PrivateRoute>
                <Orders />
                </PrivateRoute>
            }/>

            <Route path="/profile"
            element={
                <PrivateRoute>
                <Orders />
                </PrivateRoute>
            }/>

            <Route path="/settings"
            element={
                <PrivateRoute>
                <Orders />
                </PrivateRoute>
            }/>

        </Routes>
        </BrowserRouter>
    );
}