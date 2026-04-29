function roleAuth(requiredRoles) {
    return function (req, res, next) {

        if (!req.user || !req.user.role) {
            return res.status(401).json({ message: 'Unauthorized' });
        }

        const roles = Array.isArray(requiredRoles)
            ? requiredRoles
            : [requiredRoles];

        if (!roles.includes(req.user.role)) {
            return res.status(403).json({ message: 'Forbidden: insufficient role' });
        }

        next();
    };
}

module.exports = roleAuth;