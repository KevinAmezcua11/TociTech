const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const User = require('../models/user.model');

if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET not defined");
}
const JWT_SECRET = process.env.JWT_SECRET;
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || JWT_SECRET;

function createAccessToken(user) {
    return jwt.sign(
        {id: user.id, username: user.username, role: user.role},
        JWT_SECRET,
        {expiresIn: '1h'}
    );
}

function createRefreshToken(user) {
    return jwt.sign(
        {id: user.id, username: user.username, role: user.role, type: 'refresh'},
        JWT_REFRESH_SECRET,
        {expiresIn: '7d'}
    );
}

function isValidEmail(email) {
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return regex.test(email);
}

async function registerClient(req, res) {
    const { username, password, names, lastnames, email, phone } = req.body;

    if (!username?.trim() || !password?.trim()) {
        return res.status(400).json({ message: "Username and password are required" });
    }

    if (!email || !isValidEmail(email)) {
        return res.status(400).json({ message: "Invalid email format" });
    }

    const usernameClean = username.trim().toLowerCase();

    try {
        const created = await User.createUser({
            username: usernameClean,
            password,
            names,
            lastnames,
            email,
            phone,
            role: "client"
        });

        if (!created) {
            return res.status(400).json({ message: "Username already exists" });
        }

        res.status(201).json(created);

    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: "Server error" });
    }
}

async function registerAdmin(req, res) {
    const { username, password, names, lastnames, email, phone, role } = req.body;

    if (req.user?.role !== "admin") {
        return res.status(403).json({ message: "Forbidden" });
    }

    if (!username?.trim() || !password?.trim()) {
        return res.status(400).json({ message: "Username and password are required" });
    }

    if (!email || !isValidEmail(email)) {
        return res.status(400).json({ message: "Invalid email format" });
    }

    const allowedRoles = ["admin", "client"];

    if (role && !allowedRoles.includes(role)) {
        return res.status(400).json({ message: "Invalid role" });
    }

    const usernameClean = username.trim().toLowerCase();

    try {
        const created = await User.createUser({
            username: usernameClean,
            password,
            names,
            lastnames,
            email,
            phone,
            role
        });

        if (!created) {
            return res.status(400).json({ message: "Username already exists" });
        }

        res.status(201).json(created);

    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: "Server error" });
    }
}

async function login(req, res) {
    const {username, password} = req.body;
    if(!username?.trim() || !password?.trim()) {
        return res.status(400).json({message: "Username and password are required"});
    }

    const usernameClean = username.trim().toLowerCase();

    try {
        const user = await User.findByUsername(usernameClean);
        
        if(!user) {
            return res.status(401).json({message: "Invalid credentials"});
        };

        const match = await bcrypt.compare(password, user.password)
        if(!match) {
            return res.status(401).json({message: "Invalid credentials"});
        };

        const token = createAccessToken(user);
        const refreshToken = createRefreshToken(user);

        res.status(200).json({
            token,
            refreshToken,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                phone: user.phone,
                role: user.role,
                names: user.names,
                lastnames: user.lastnames
            }
        });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: "Server error" });
    }   
}

async function refresh(req, res) {
    const { refreshToken } = req.body;

    if (!refreshToken?.trim()) {
        return res.status(400).json({ message: "Refresh token is required" });
    }

    try {
        const decoded = jwt.verify(refreshToken, JWT_REFRESH_SECRET);

        if (decoded.type !== 'refresh') {
            return res.status(401).json({ message: "Invalid refresh token" });
        }

        const user = await User.getById(decoded.id);
        if (!user) {
            return res.status(401).json({ message: "Invalid refresh token" });
        }

        const token = createAccessToken(user);
        const newRefreshToken = createRefreshToken(user);

        return res.status(200).json({
            token,
            refreshToken: newRefreshToken
        });
    } catch (err) {
        return res.status(401).json({ message: "Invalid refresh token" });
    }
}

module.exports = { registerClient, registerAdmin, login, refresh };
