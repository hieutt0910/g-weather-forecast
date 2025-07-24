import dotenv from 'dotenv';
import mongoose from 'mongoose';
import axios from 'axios';
import Subscriber from '../models/subscriber.js';
import { sendWeatherEmail } from '../utils/sendEmail.js';

dotenv.config();

async function getWeatherForecast(location) {
  const res = await axios.get(
    `http://api.weatherapi.com/v1/forecast.json?key=${process.env.WEATHER_API_KEY}&q=${location}&days=1`
  );
  const forecast = res.data.forecast.forecastday[0].day;
  return `🌤️ ${res.data.location.name}: ${forecast.avgtemp_c}°C, ${forecast.condition.text}`;
}

async function run() {
  await mongoose.connect(process.env.MONGODB_URI);

  console.log('⏰ Sending daily weather emails...');
  const subscribers = await Subscriber.find({ isVerified: true });

  for (const user of subscribers) {
    const forecast = await getWeatherForecast(user.location);
    await sendWeatherEmail(user.email, forecast);
  }

  await mongoose.disconnect();
}

run();
