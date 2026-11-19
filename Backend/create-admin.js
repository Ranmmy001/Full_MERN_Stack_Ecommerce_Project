const mongoose = require("mongoose");
const readline = require("readline");
const User = require("./models/userModel");

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: true,
});

const ask = (question) =>
  new Promise((resolve) => rl.question(question, resolve));

(async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URL);

    const email = "olaranmmyola@gmail.com";
    const existingUser = await User.findOne({ email });

    if (existingUser) {
      console.log("This email already exists. No changes made.");
      return;
    }

    const password = await ask("Enter your new admin password: ");

    if (password.length < 12) {
      throw new Error("Use a password with at least 12 characters.");
    }

    const firstname = await ask("First name: ");
    const lastname = await ask("Last name: ");
    const mobile = await ask("Mobile number: ");

    const user = new User({
      firstname,
      lastname,
      email,
      mobile,
      password,
      role: "admin",
    });

    await user.save();

    console.log("\nAdmin account created successfully!");
    console.log("Email:", email);
    console.log("Role:", user.role);
  } catch (error) {
    console.error("Admin creation failed:", error.message);
    process.exitCode = 1;
  } finally {
    rl.close();
    await mongoose.disconnect().catch(() => {});
  }
})();