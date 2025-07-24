import nodemailer from "nodemailer";

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.GMAIL_USER,
    pass: process.env.GMAIL_PASS,
  },
});

export async function sendVerificationEmail(email, token) {
  const link = `https://yourdomain.com/verify?token=${token}`;
  await transporter.sendMail({
    from: process.env.GMAIL_USER,
    to: email,
    subject: "Confirm your weather subscription",
    html: `<p>Click <a href="${link}">here</a> to confirm your subscription.</p>`,
  });
}

export async function sendWeatherEmail(email, forecast) {
  await transporter.sendMail({
    from: process.env.GMAIL_USER,
    to: email,
    subject: "Daily Weather Forecast",
    html: `<p>Here is today’s weather:</p><p>${forecast}</p>`,
  });
}
