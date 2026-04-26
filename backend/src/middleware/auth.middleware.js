const jwt = require('jsonwebtoken');

if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET not defined");
}
const JWT_SECRET = process.env.JWT_SECRET;

function authenticate(req, res, next) {
    const auth = req.headers.authorization;

    if (!auth || !auth.startsWith('Bearer ')) {
        return res.status(401).json({ message: "Unauthorized" });
    }

    const token = auth.split(" ")[1];

    try {
        const payload = jwt.verify(token, JWT_SECRET);

        req.userId = payload.id;
        req.userRole = payload.role;

        next();

    } catch (err) {
        if (err.name === "TokenExpiredError") {
            return res.status(401).json({ message: "Token expired" });
        }

        return res.status(401).json({ message: "Invalid token" });
    }
}

module.exports = { authenticate };