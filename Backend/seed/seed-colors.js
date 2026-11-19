const mongoose = require("mongoose");
require("dotenv").config();

const Color = require("../models/colorModel");
const Product = require("../models/productModel");

const colors = [
  "Black",
  "White",
  "Red",
  "Blue",
  "Green",
];

const seedColors = async () => {
  try {
    console.log("Starting colour initialization...");

    // Create each colour only if it does not already exist.
    for (const title of colors) {
      await Color.updateOne(
        { title },
        {
          $setOnInsert: { title },
        },
        { upsert: true }
      );
    }

    // Retrieve the five colour documents.
    const savedColors = await Color.find({
      title: { $in: colors },
    });

    if (savedColors.length !== colors.length) {
      throw new Error(
        `Expected ${colors.length} colours but found ${savedColors.length}.`
      );
    }

    const colorIds = savedColors.map((color) => color._id);

    console.log("Five colours created or already exist.");

    // Add the colour IDs to all existing products.
    // $addToSet prevents duplicate IDs.
    const result = await Product.updateMany(
      {},
      {
        $addToSet: {
          color: {
            $each: colorIds,
          },
        },
      }
    );

    console.log("Colour IDs attached to existing products.");
    console.log("Products matched:", result.matchedCount);
    console.log("Products modified:", result.modifiedCount);

    console.log("Colour initialization completed successfully.");
  } catch (error) {
    console.error("Colour initialization failed:", error);
    throw error;
  }
};

const start = async () => {
  try {
    if (!process.env.MONGODB_URL) {
      throw new Error("MONGODB_URL is missing.");
    }

    await mongoose.connect(process.env.MONGODB_URL);

    console.log("Connected to MongoDB.");

    await seedColors();

  } catch (error) {
    console.error(error);
    process.exitCode = 1;

  } finally {
    await mongoose.disconnect();
  }
};

start();