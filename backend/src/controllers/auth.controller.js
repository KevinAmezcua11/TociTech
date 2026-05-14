const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const User = require('../models/user.model');
const PasswordReset = require('../models/password-reset.model');
const { sendPasswordResetEmail } = require('../config/email.service');

if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET not defined");
}
const JWT_SECRET = process.env.JWT_SECRET;

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

    if (req.userRole !== "admin") {
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

        const token = jwt.sign({id: user.id, username: user.username, role: user.role}, JWT_SECRET, {expiresIn: '1h'});

        res.status(200).json({
            token,
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

async function forgotPassword(req, res) {
    const { email } = req.body;

    if (!email || !isValidEmail(email)) {
        return res.status(400).json({ message: "Invalid email format" });
    }

    try {
        const user = await User.findByEmail(email.trim().toLowerCase());

        // Respuesta genérica siempre para no revelar si el email existe
        if (!user) {
            return res.status(200).json({ message: "If that email is registered, you will receive a reset code" });
        }

        const code = await PasswordReset.createResetToken(user.id);

        await sendPasswordResetEmail({
            to: user.email,
            names: user.names,
            code
        });

        return res.status(200).json({ message: "If that email is registered, you will receive a reset code" });

    } catch (err) {
        console.error('[forgotPassword]', err);
        return res.status(500).json({ message: "Server error" });
    }
}

async function resetPassword(req, res) {
    const { email, code, newPassword } = req.body;

    if (!email || !isValidEmail(email)) {
        return res.status(400).json({ message: "Invalid email" });
    }

    if (!code || String(code).length !== 6) {
        return res.status(400).json({ message: "Invalid code" });
    }

    if (!newPassword || newPassword.length < 8) {
        return res.status(400).json({ message: "Password must be at least 8 characters" });
    }

    try {
        const user = await User.findByEmail(email.trim().toLowerCase());

        if (!user) {
            return res.status(400).json({ message: "Invalid or expired code" });
        }

        const valid = await PasswordReset.verifyCode(user.id, String(code));

        if (!valid) {
            return res.status(400).json({ message: "Invalid or expired code" });
        }

        await User.resetPasswordDirect(user.id, newPassword);
        await PasswordReset.deleteByUserId(user.id);

        return res.status(200).json({ message: "Password updated successfully" });

    } catch (err) {
        console.error('[resetPassword]', err);
        return res.status(500).json({ message: "Server error" });
    }
}

module.exports = { registerClient, registerAdmin, login, forgotPassword, resetPassword };