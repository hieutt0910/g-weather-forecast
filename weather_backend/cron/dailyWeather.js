const cron = require("node-cron");
const axios = require("axios");
const Subscriber = require("../models/subscriber");
const { sendWeatherEmail } = require("../utils/sendEmail");

async function getWeatherForecast(location) {
  const res = await axios.get(
    `http://api.weatherapi.com/v1/forecast.json?key=${process.env.WEATHER_API_KEY}&q=${location}&days=1`
  );
  const forecast = res.data.forecast.forecastday[0].day;
  return `🌤️ ${res.data.location.name}: ${forecast.avgtemp_c}°C, ${forecast.condition.text}`;
}

cron.schedule("0 8 * * *", async () => {
  console.log("⏰ Sending daily weather emails...");
  const subscribers = await Subscriber.find({ isVerified: true });

  for (const user of subscribers) {
    const forecast = await getWeatherForecast(user.location);
    await sendWeatherEmail(user.email, forecast);
  }
});
