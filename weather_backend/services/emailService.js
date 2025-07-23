// services/emailService.js
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.GMAIL_USER,
    pass: process.env.GMAIL_PASS,
  },
});

async function sendWeatherEmail(to, subject, body) {
  await transporter.sendMail({
    from: `"Weather Bot 🌤️" <${process.env.GMAIL_USER}>`,
    to,
    subject,
    html: body,
  });
}

module.exports = { sendWeatherEmail };
