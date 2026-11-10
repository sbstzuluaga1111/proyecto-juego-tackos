
const mongoose = require('mongoose');
require('dotenv').config();

const connectDatabase = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI, {
            serverSelectionTimeoutMS: 10000
        });

        console.log('================================');
        console.log(' MONGODB CONECTADO');
        console.log('================================');
        console.log('Base de datos:', mongoose.connection.name);
        console.log('Host:', mongoose.connection.host);

    } catch (error) {
        console.error('Error conectando MongoDB:', error.message);
        throw error;
    }
};

module.exports = connectDatabase;
