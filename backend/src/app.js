require("dotenv").config();

const express = require("express");
const cors = require("cors");

const authRoutes = require("./routes/auth.routes");
const productRoutes = require("./routes/product.routes");
const servicesRoutes = require("./routes/services.route");
const ordersRoutes = require("./routes/order.route");
const usersRoutes = require("./routes/user.route");
const aiRoute = require("./routes/ai.routes");
const paymentRoutes = require("./routes/payment.routes");
const notificationRoutes = require("./routes/notification.route");

const app = express();

app.use(cors({
    origin: [
        "http://localhost:5173",
        "http://10.0.2.2:3000",  // Android emulator
        "http://localhost:3000",  // iOS simulator
        "https://toci-tech.vercel.app"
    ],
    credentials: true
}));

app.use('/api/payments/webhook', express.raw({ type: 'application/json' }));

app.use(express.json());

app.get("/", (req, res) => {
    res.status(200).json({status: "ok"})
});

// Rutas públicas
app.use("/api/auth", authRoutes);

// Rutas protegidas
app.use("/api/products", productRoutes);
app.use("/api/services", servicesRoutes);
app.use("/api/orders", ordersRoutes);
app.use("/api/users", usersRoutes);
app.use("/api/chat", aiRoute);
app.use("/api/payments", paymentRoutes);
app.use("/api/notifications", notificationRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
