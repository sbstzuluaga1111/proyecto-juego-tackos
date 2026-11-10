
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// ==========================================
// REGISTRO DE USUARIO
// ==========================================
exports.register = async (req, res) => {
    try {
        const { username, email, password } = req.body;

        if (!username || !email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Todos los campos son obligatorios'
            });
        }

        const cleanUsername = String(username).trim().toLowerCase();
        const cleanEmail = String(email).trim().toLowerCase();

        if (!/^[a-zA-Z0-9_]{3,30}$/.test(cleanUsername)) {
            return res.status(400).json({
                success: false,
                message: 'El usuario debe tener entre 3 y 30 caracteres y solo puede contener letras, números y guion bajo'
            });
        }

        if (
            cleanEmail.length > 150 ||
            !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(cleanEmail)
        ) {
            return res.status(400).json({
                success: false,
                message: 'El correo electrónico no es válido'
            });
        }

        if (
            typeof password !== 'string' ||
            password.length < 8 ||
            Buffer.byteLength(password, 'utf8') > 72
        ) {
            return res.status(400).json({
                success: false,
                message: 'La contraseña debe tener mínimo 8 caracteres y máximo 72 bytes'
            });
        }

        // Verificar usuario o correo existente
        const existingUser = await User.findOne({
            $or: [
                { username: cleanUsername },
                { email: cleanEmail }
            ]
        });

        if (existingUser) {
            return res.status(409).json({
                success: false,
                message: 'El usuario o correo electrónico ya está registrado'
            });
        }

        // Encriptar contraseña
        const passwordHash = await bcrypt.hash(password, 12);

        // Crear usuario
        const user = await User.create({
            username: cleanUsername,
            email: cleanEmail,
            password: passwordHash
        });

        return res.status(201).json({
            success: true,
            message: 'Cuenta creada correctamente',
            user: {
                id: user._id,
                username: user.username,
                email: user.email,
                status: user.status
            }
        });

    } catch (error) {
        if (error.code === 11000) {
            return res.status(409).json({
                success: false,
                message: 'El usuario o correo electrónico ya está registrado'
            });
        }

        console.error('Error en registro:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Error interno al registrar el usuario'
        });
    }
};


// ==========================================
// INICIO DE SESIÓN
// ==========================================
exports.login = async (req, res) => {
    try {
        const { login, password } = req.body;

        if (
            typeof login !== 'string' ||
            typeof password !== 'string' ||
            !login.trim() ||
            !password
        ) {
            return res.status(400).json({
                success: false,
                message: 'Usuario/correo y contraseña son obligatorios'
            });
        }

        const identifier = login.trim().toLowerCase();

        // Buscar usuario
        const user = await User.findOne({
            $or: [
                { username: identifier },
                { email: identifier }
            ]
        }).select('+password');

        if (!user) {
            return res.status(401).json({
                success: false,
                message: 'Credenciales incorrectas'
            });
        }

        // Verificar contraseña
        const passwordValid = await bcrypt.compare(
            password,
            user.password
        );

        if (!passwordValid) {
            return res.status(401).json({
                success: false,
                message: 'Credenciales incorrectas'
            });
        }

        // Verificar estado de cuenta
        if (user.status !== 'active') {
            return res.status(403).json({
                success: false,
                message: user.status === 'banned'
                    ? 'Esta cuenta se encuentra suspendida'
                    : 'Esta cuenta está pendiente de activación'
            });
        }

        // Actualizar último ingreso
        user.last_login = new Date();
        await user.save();

        // Generar token JWT
        if (!process.env.JWT_SECRET) {
            throw new Error('JWT_SECRET no está configurado');
        }

        const token = jwt.sign(
            {
                id: user._id.toString(),
                username: user.username
            },
            process.env.JWT_SECRET,
            {
                expiresIn: process.env.JWT_EXPIRES_IN || '7d',
                issuer: 'videojuego-api',
                audience: 'videojuego-client'
            }
        );

        return res.json({
            success: true,
            message: 'Inicio de sesión exitoso',
            token: token,
            user: {
                id: user._id,
                username: user.username,
                email: user.email,
                status: user.status
            }
        });

    } catch (error) {
        console.error('Error en login:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Error interno al iniciar sesión'
        });
    }
};


// ==========================================
// CONSULTAR USUARIO AUTENTICADO
// ==========================================
exports.me = async (req, res) => {
    try {
        const user = await User.findById(req.user.id)
            .select('-password');

        if (!user || user.status !== 'active') {
            return res.status(404).json({
                success: false,
                message: 'Usuario no encontrado o inactivo'
            });
        }

        return res.json({
            success: true,
            user: {
                id: user._id,
                username: user.username,
                email: user.email,
                status: user.status,
                created_at: user.createdAt,
                last_login: user.last_login
            }
        });

    } catch (error) {
        console.error('Error consultando usuario:', error.message);

        return res.status(500).json({
            success: false,
            message: 'Error al consultar el usuario'
        });
    }
};
