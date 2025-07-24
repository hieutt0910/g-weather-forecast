import cron from "node-cron";
import axios from "axios";
import Subscriber from "../models/subscriber.js";
import { sendWeatherEmail } from "../utils/sendEmail.js";

async function getWeatherForecast(location) {
  const res = await axios.get(
    `http://api.weatherapi.com/v1/forecast.json?key=${process.env.WEATHER_API_KEY}&q=${location}&days=1`
  );
  const forecast = res.data.forecast.forecastday[0].day;
  return `🌤️ ${res.data.location.name}: ${forecast.avgtemp_c}°C, ${forecast.condition.text}`;
}

function dailyWeather() {
  cron.schedule("0 12 * * *", async () => {
    console.log("⏰ Sending daily weather emails...");
    const subscribers = await Subscriber.find({ isVerified: true });

    for (const user of subscribers) {
      try {
        const forecast = await getWeatherForecast(user.location);
        await sendWeatherEmail(user.email, forecast);
      } catch (err) {
        console.error(`❌ Failed to send to ${user.email}:`, err.message);
      }
    }
  });
}

export default dailyWeather;
