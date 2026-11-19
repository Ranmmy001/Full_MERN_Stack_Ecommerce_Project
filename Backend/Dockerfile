# Use official Node.js LTS image
FROM node:18-alpine

# Set working directory called /app inside the container and carry out all task there
WORKDIR /app

# Copy package files and install dependencies
## --only=production: Install only the dependencies and the exact libraries needed to run the app, not the devDependencies. This makes the image smaller and more secure.
COPY package*.json ./
RUN npm ci --only=production               

# Copy backend source code and all the rest of the files into the container's /app directory. This includes your index.js, routes, controllers, models, and any other files needed to run the backend.
COPY . .

# Expose backend API port
EXPOSE 5000

# Start the Express server
CMD ["node", "index.js"]

