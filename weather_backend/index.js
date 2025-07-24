require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('./cron/dailyWeather');

const app = express();
app.use(cors());
app.use(express.json());

app.use('/api', require('./routes/subscribe'));

mongoose.connect(process.env.MONGODB_URI)
  .then(() => app.listen(process.env.PORT, () => {
    console.log(`Server running on port ${process.env.PORT}`);
  }))
  .catch(console.error);
