// scripts/addUser.js
require("dotenv").config();
const mongoose = require("mongoose");
const User = require("../models/user");

mongoose
  .connect(process.env.MONGODB_URI)
  .then(async () => {
    await User.create({
      email: "example@gmail.com", // thay email thật
      location: "Ho Chi Minh", // địa điểm cần lấy dự báo thời tiết
    });
    console.log("User added!");
    mongoose.disconnect();
  })
  .catch((err) => console.error(err));
