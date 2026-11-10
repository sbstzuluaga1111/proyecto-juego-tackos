
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const connectDatabase = require('./config/database');
const authRoutes = require('./routes/auth.routes');

const app = express();

app.use(helmet());

app.use(cors({
    origin: process.env.CORS_ORIGIN || 'http://localhost'
}));

app.use(express.json({ limit: '10kb' }));

app.use('/api/', rateLimit({
    windowMs: 15 * 60 * 1000,
    limit: 100,
    standardHeaders: 'draft-8',
    legacyHeaders: false
}));

// RUTAS DE AUTENTICACIÓN
app.use('/api/auth', authRoutes);

// VERIFICAR CONEXIÓN
app.get('/api/health', (req, res) => {
    res.json({
        success: true,
        message: 'Servidor y MongoDB funcionando',
        database: 'connected'
    });
});

// RUTA NO ENCONTRADA
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: 'Ruta no encontrada'
    });
});

// INICIAR SERVIDOR
const startServer = async () => {
    try {
        await connectDatabase();

        const PORT = process.env.PORT || 3000;

        app.listen(PORT, () => {
            console.log('================================');
            console.log(' VIDEOJUEGO - BACKEND');
            console.log('================================');
            console.log(`Servidor: http://localhost:${PORT}`);
            console.log('Autenticación: /api/auth');
            console.log('================================');
        });

    } catch (error) {
        console.error('No se pudo iniciar el servidor.');
        process.exit(1);
    }
};

startServer();
