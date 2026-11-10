
const jwt = require('jsonwebtoken');

exports.authenticate = (req, res, next) => {
    try {
        const authorization = req.headers.authorization;

        if (!authorization || !authorization.startsWith('Bearer ')) {
            return res.status(401).json({
                success: false,
                message: 'No estás autenticado'
            });
        }

        const token = authorization.substring(7).trim();

        if (!token) {
            return res.status(401).json({
                success: false,
                message: 'Token no proporcionado'
            });
        }

        const decoded = jwt.verify(
            token,
            process.env.JWT_SECRET,
            {
                issuer: 'videojuego-api',
                audience: 'videojuego-client'
            }
        );

        req.user = decoded;

        next();

    } catch (error) {
        return res.status(401).json({
            success: false,
            message: 'Sesión inválida o expirada'
        });
    }
};
