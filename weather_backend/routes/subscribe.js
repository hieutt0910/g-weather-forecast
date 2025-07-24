import express from 'express';
import { v4 as uuidv4 } from 'uuid';
import Subscriber from '../models/subscriber.js';
import { sendVerificationEmail } from '../utils/sendEmail.js';

const router = express.Router();

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
  res.send('Email verified successfully!');
});

router.post('/unsubscribe', async (req, res) => {
  const { email } = req.body;
  await Subscriber.findOneAndDelete({ email });
  res.json({ message: 'Unsubscribed successfully' });
});

export default router;
