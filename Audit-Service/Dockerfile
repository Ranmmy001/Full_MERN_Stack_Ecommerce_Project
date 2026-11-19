FROM node:20-alpine

## woking directory for the application inside the container
WORKDIR /app

## Copy package.json and package-lock.json to the working directory
COPY package*.json ./    

## Install dependencies using npm ci, which is optimized for CI/CD environments and ensures a clean install of dependencies based on the package-lock.json file. The --omit=dev flag is used to exclude devDependencies from the installation, which is useful for production builds where only runtime dependencies are needed.
RUN npm ci --omit=dev

## Copy the rest of the application code to the working directory inside the container
COPY src/ ./src/

EXPOSE 5001


## Set the default command to run the application using npm start, which will start the Audit Service when the container is run.
CMD ["npm", "start"]



# this Dockerfile packages your Audit Service into its own container.
