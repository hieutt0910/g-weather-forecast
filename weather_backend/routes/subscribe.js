const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const Subscriber = require('../models/subscriber');
const { sendVerificationEmail } = require('../utils/sendEmail');

// Đăng ký
router.post('/subscribe', async (req, res) => {
  const { email } = req.body;
  const token = uuidv4();

  let user = await Subscriber.findOne({ email });
  if (!user) {
    user = await Subscriber.create({ email, token });
  } else {
    user.token = token;
    user.isVerified = false;
    await user.save();
  }

  await sendVerificationEmail(email, token);
  res.json({ message: 'Verification email sent' });
});

// Xác minh
router.get('/verify', async (req, res) => {
  const { token } = req.query;
  const user = await Subscriber.findOne({ token });
  if (!user) return res.status(400).send('Invalid token');

  user.isVerified = true;
  user.token = null;
  await user.save();
  res.send('✅ Email verified successfully!');
});

// Hủy đăng ký
router.post('/unsubscribe', async (req, res) => {
  const { email } = req.body;
  await Subscriber.findOneAndDelete({ email });
  res.json({ message: 'Unsubscribed successfully' });
});

module.exports = router;
