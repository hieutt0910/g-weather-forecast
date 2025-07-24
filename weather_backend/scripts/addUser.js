import dotenv from "dotenv";
import mongoose from "mongoose";
import Subscriber from "../models/subscriber.js";

dotenv.config();

mongoose
  .connect(process.env.MONGODB_URI)
  .then(async () => {
    await Subscriber.create({
      email: "example@gmail.com",
      location: "Ho Chi Minh",
      isVerified: true,
    });

    console.log("Subscriber added!");
    await mongoose.disconnect();
  })
  .catch((err) => console.error("MongoDB connection error:", err));
