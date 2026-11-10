
const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        minlength: 3,
        maxlength: 30,
        match: /^[a-zA-Z0-9_]+$/
    },

    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true,
        trim: true,
        maxlength: 150
    },

    password: {
        type: String,
        required: true,
        select: false
    },

    status: {
        type: String,
        enum: ['active', 'banned', 'pending'],
        default: 'active'
    },

    last_login: {
        type: Date,
        default: null
    }

}, {
    timestamps: true,
    collection: 'users'
});

module.exports = mongoose.model('User', userSchema);
