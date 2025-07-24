require("dotenv").config();
const mongoose = require("mongoose");
const User = require("../models/user");

mongoose
  .connect(process.env.MONGODB_URI)
  .then(async () => {
    await User.create({
      email: "example@gmail.com", 
      location: "Ho Chi Minh", 
    });
    console.log("User added!");
    mongoose.disconnect();
  })
  .catch((err) => console.error(err));
