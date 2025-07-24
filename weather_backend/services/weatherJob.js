const axios = require('axios');
const User = require('../models/user');
const { sendWeatherEmail } = require('./emailService');

async function fetchWeather(location) {
  const res = await axios.get('http://api.weatherapi.com/v1/forecast.json', {
    params: {
      key: process.env.WEATHER_API_KEY,
      q: location,
      days: 1,
    },
  });
  return res.data;
}

async function runWeatherJob() {
  const users = await User.find({});
  for (const user of users) {
    const weather = await fetchWeather(user.location);

    const body = `
      <h2>🌤️ Weather Forecast for ${user.location}</h2>
      <p><b>Condition:</b> ${weather.current.condition.text}</p>
      <p><b>Temperature:</b> ${weather.current.temp_c}°C</p>
      <p><b>Humidity:</b> ${weather.current.humidity}%</p>
    `;

    await sendWeatherEmail(user.email, `🌦️ Weather Today in ${user.location}`, body);
    console.log(`📧 Email sent to ${user.email}`);
  }
}

module.exports = { runWeatherJob };
