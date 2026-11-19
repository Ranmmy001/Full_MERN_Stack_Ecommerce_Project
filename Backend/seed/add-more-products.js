const mongoose = require("mongoose");
const Product = require("../models/productModel");
const Color = require("../models/colorModel");

const colorNames = ["Black", "White", "Red", "Blue", "Green"];

const products = [
  {
    title: "Brown Leather Loafers",
    slug: "brown-leather-loafers",
    description: "Classic brown loafers designed for smart casual outfits, work, and special occasions.",
    price: 35000,
    category: "Shoes",
    brand: "Classic Walk",
    quantity: 20,
    images: [{ public_id: "", url: "https://images.unsplash.com/photo-1531310197839-ccf54634509e?auto=format&fit=crop&w=600&q=80" }],
    tags: "loafers shoes brown formal",
  },
  {
    title: "Womens Floral Summer Dress",
    slug: "womens-floral-summer-dress",
    description: "A lightweight floral summer dress suitable for casual outings and warm weather.",
    price: 28000,
    category: "Clothing",
    brand: "Elegance Wear",
    quantity: 15,
    images: [{ public_id: "", url: "https://images.unsplash.com/photo-1496747611176-843222e1e57c?auto=format&fit=crop&w=600&q=80" }],
    tags: "dress floral summer women",
  },
  {
    title: "Casual Black Backpack",
    slug: "casual-black-backpack",
    description: "A versatile everyday backpack with a simple design for school, work, and travel.",
    price: 22000,
    category: "Bags",
    brand: "Urban Carry",
    quantity: 18,
    images: [{ public_id: "", url: "https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=600&q=80" }],
    tags: "backpack black bags travel",
  },
  {
    title: "Gold Tone Necklace",
    slug: "gold-tone-necklace",
    description: "A simple gold-tone necklace designed to complement everyday and occasion outfits.",
    price: 15000,
    category: "Accessories",
    brand: "Luxe Collection",
    quantity: 25,
    images: [{ public_id: "", url: "https://images.unsplash.com/photo-1611652022419-a9419f74343d?auto=format&fit=crop&w=600&q=80" }],
    tags: "necklace gold jewelry accessories",
  },
  {
    title: "Grey Running Sneakers",
    slug: "grey-running-sneakers",
    description: "Lightweight athletic sneakers for daily walks, exercise, and casual wear.",
    price: 38000,
    category: "Shoes",
    brand: "ActiveStep",
    quantity: 16,
    images: [{ public_id: "", url: "https://images.unsplash.com/photo-1460353581641-37baddab0fa2?auto=format&fit=crop&w=600&q=80" }],
    tags: "running sneakers grey sports",
  },
  {
    title: "Mens Casual Polo Shirt",
    slug: "mens-casual-polo-shirt",
    description: "A versatile casual polo shirt for everyday outfits and relaxed occasions.",
    price: 18000,
    category: "Clothing",
    brand: "Urban Style",
    quantity: 30,
    images: [{ public_id: "", url: "https://images.unsplash.com/photo-1625910513413-5fc9d7c1b8a9?auto=format&fit=crop&w=600&q=80" }],
    tags: "polo shirt men casual clothing",
  },
  {
    title: "Womens Shoulder Bag",
    slug: "womens-shoulder-bag",
    description: "A stylish shoulder bag for everyday essentials, shopping, and social occasions.",
    price: 26000,
    category: "Bags",
    brand: "Bella Fashion",
    quantity: 14,
    images: [{ public_id: "", url: "https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=600&q=80" }],
    tags: "shoulder bag women fashion",
  },
  {
    title: "Silver Stainless Steel Watch",
    slug: "silver-stainless-steel-watch",
    description: "A silver-tone wristwatch with a timeless design for everyday use.",
    price: 42000,
    category: "Accessories",
    brand: "TimeCraft",
    quantity: 12,
    images: [{ public_id: "", url: "https://images.unsplash.com/photo-1524805444758-089113d48a6d?auto=format&fit=crop&w=600&q=80" }],
    tags: "watch silver accessories",
  },
  {
    title: "Slim Fit Black Jeans",
    slug: "slim-fit-black-jeans",
    description: "Slim-fit black denim jeans that pair easily with casual shirts, polos, and sneakers.",
    price: 30000,
    category: "Clothing",
    brand: "Denim House",
    quantity: 22,
    images: [{ public_id: "", url: "https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=600&q=80" }],
    tags: "black jeans denim slim fit",
  },
  {
    title: "Brown Leather Belt",
    slug: "brown-leather-belt",
    description: "A classic brown belt suitable for smart casual and formal outfits.",
    price: 9000,
    category: "Accessories",
    brand: "Classic Walk",
    quantity: 28,
    images: [{ public_id: "", url: "https://images.unsplash.com/photo-1624222247344-550fb8f2b6b5?auto=format&fit=crop&w=600&q=80" }],
    tags: "brown leather belt accessories",
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

  const slugs = products.map((product) => product.slug);

  const existingSlugs = new Set(
    await Product.find({ slug: { $in: slugs } }).distinct("slug")
  );

  const newProducts = products
    .filter((product) => !existingSlugs.has(product.slug))
    .map((product) => ({
      ...product,
      color: colorIds,
    }));

  if (newProducts.length) {
    await Product.insertMany(newProducts);
  }

  console.log(`Colours retrieved: ${savedColors.length}`);
  console.log(`Already present: ${existingSlugs.size}`);
  console.log(`New products inserted: ${newProducts.length}`);
  console.log(`Total products in database: ${await Product.countDocuments()}`);

  await mongoose.disconnect();
}

main().catch(async (error) => {
  console.error("Failed to insert products:", error);
  await mongoose.disconnect();
  process.exitCode = 1;
});