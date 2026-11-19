const mongoose = require("mongoose");
const Product = require("../models/productModel");
const Color = require("../models/colorModel");

const colorNames = ["Black", "White", "Red", "Blue", "Green"];

const products = [
  {
    title: "Classic White Sneakers",
    slug: "classic-white-sneakers",
    description:
      "Comfortable everyday sneakers with a clean white design, suitable for casual outfits.",
    price: 25000,
    category: "Shoes",
    brand: "Urban Style",
    quantity: 25,
    images: [
      {
        public_id: "",
        url: "https://placehold.co/600x600?text=White+Sneakers",
      },
    ],
    tags: "sneakers casual footwear",
  },
  {
    title: "Premium Blue Denim Jeans",
    slug: "premium-blue-denim-jeans",
    description:
      "Classic blue denim jeans designed for everyday comfort and versatile styling.",
    price: 32000,
    category: "Clothing",
    brand: "Denim House",
    quantity: 18,
    images: [
      {
        public_id: "",
        url: "https://placehold.co/600x600?text=Blue+Denim+Jeans",
      },
    ],
    tags: "jeans denim casual",
  },
  {
    title: "Black Leather Handbag",
    slug: "black-leather-handbag",
    description:
      "A stylish black handbag suitable for work, shopping, and everyday use.",
    price: 28000,
    category: "Bags",
    brand: "Elegance",
    quantity: 12,
    images: [
      {
        public_id: "",
        url: "https://placehold.co/600x600?text=Black+Handbag",
      },
    ],
    tags: "handbag fashion accessories",
  },
  {
    title: "Minimalist Wristwatch",
    slug: "minimalist-wristwatch",
    description:
      "A minimalist wristwatch with a versatile design for everyday wear.",
    price: 45000,
    category: "Accessories",
    brand: "TimeCraft",
    quantity: 10,
    images: [
      {
        public_id: "",
        url: "https://placehold.co/600x600?text=Wristwatch",
      },
    ],
    tags: "watch accessories",
  },
  {
    title: "Casual Striped T-Shirt",
    slug: "casual-striped-t-shirt",
    description:
      "A casual striped T-shirt suitable for relaxed weekends and everyday outfits.",
    price: 12000,
    category: "Clothing",
    brand: "Urban Style",
    quantity: 30,
    images: [
      {
        public_id: "",
        url: "https://placehold.co/600x600?text=Striped+T-Shirt",
      },
    ],
    tags: "tshirt striped casual clothing",
  },
];

async function main() {
  await mongoose.connect(process.env.MONGODB_URL);

  // Retrieve the five default colours.
  const savedColors = await Color.find({
    title: { $in: colorNames },
  });

  if (savedColors.length !== colorNames.length) {
    throw new Error(
      "The five default colours must be initialized before product seeding."
    );
  }

  // Maintain a consistent colour order.
  const colorIds = colorNames.map((name) => {
    const color = savedColors.find((item) => item.title === name);
    return color._id;
  });

  // Find products that already exist.
  const existingSlugs = await Product.find({
    slug: { $in: products.map((product) => product.slug) },
  }).distinct("slug");

  const existing = new Set(existingSlugs);

  const newProducts = products
    .filter((product) => !existing.has(product.slug))
    .map((product) => ({
      ...product,
      color: colorIds,
    }));

  if (newProducts.length > 0) {
    await Product.insertMany(newProducts);
  }

  console.log(`Colours retrieved: ${savedColors.length}`);
  console.log(`Products already present: ${existing.size}`);
  console.log(`New products inserted: ${newProducts.length}`);
  console.log(
    `Total products in database: ${await Product.countDocuments()}`
  );

  await mongoose.disconnect();
}

main().catch(async (error) => {
  console.error("Failed to insert sample products:", error);

  await mongoose.disconnect();

  process.exitCode = 1;
});