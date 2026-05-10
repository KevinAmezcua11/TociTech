require("dotenv").config();

const express = require("express");
const cors = require("cors");

const authRoutes = require("./routes/auth.routes");
const aiChatRoutes = require("./routes/aiChat.route");
const productRoutes = require("./routes/product.routes");
const servicesRoutes = require("./routes/services.route");
const ordersRoutes = require("./routes/order.route");
const usersRoutes = require("./routes/user.route");

const app  = express();

app.use(cors({
    origin: "http://localhost:5173",
    credentials: true
}));

app.use(express.json());

app.get("/", (req, res) => {
    res.status(200).json({status: "ok"})
});

// Rutas públicas
app.use("/api/auth", authRoutes);
app.use("/api/ai-chat", aiChatRoutes);

// Rutas protegidas
app.use("/api/products", productRoutes);
app.use("/api/services", servicesRoutes);
app.use("/api/orders", ordersRoutes);
app.use("/api/users", usersRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
