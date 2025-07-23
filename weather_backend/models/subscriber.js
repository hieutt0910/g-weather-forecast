const mongoose = require('mongoose');

const subscriberSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  token: String,
  isVerified: { type: Boolean, default: false },
  location: { type: String, default: 'Saigon' },
  subscribedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Subscriber', subscriberSchema);
