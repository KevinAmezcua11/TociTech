function roleAuth(requiredRoles) {
    return function (req, res, next) {

        if (!req.userRole) {
            return res.status(401).json({ message: 'Unauthorized' });
        }

        const roles = Array.isArray(requiredRoles)
            ? requiredRoles
            : [requiredRoles];

        if (!roles.includes(req.userRole)) {
            return res.status(403).json({ message: 'Forbidden: insufficient role' });
        }

        next();
    };
};

module.exports = roleAuth;