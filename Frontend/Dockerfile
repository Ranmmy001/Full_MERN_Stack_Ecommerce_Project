# Stage 1: Build the React application, by compiling raw React source code into optimized static files.
FROM node:18-alpine AS build  
WORKDIR /app

COPY package*.json ./

# Configure npm timeouts (600,000millisecs) and install dependencies."clean install.” It installs the exact versions in package-lock.json, so it is reliable and repeatable.
RUN npm config set fetch-retry-maxtimeout 600000 \
    && npm config set fetch-retries 5 \
    && npm ci

# Copies the rest of your local React project files into the container's /app directory.That means your src folder, public folder, and all your React code.
COPY . .

# ARG is used to pass variables from the docker-compose.yml file to the Dockerfile. These variables are then set as ENV variables for the build process.
# REACT_APP_... is the naming style for Create React App projects and  VITE_... is the naming style for Vite projects.
ARG REACT_APP_API_URL
ARG VITE_API_URL

# Set environment variables for the build process ref the values passed by the ARG, which is used to pass variables, a place-holder for values in docker-compose.yml. The build tool (npm run build) can only read ENV values, not ARG values directly.
ENV REACT_APP_API_URL=$REACT_APP_API_URL
ENV VITE_API_URL=$VITE_API_URL


##The build tool (npm run build) can only read ENV values, not ARG values directly.
# React builds can be heavy. By default, Node’s memory limit can be too small, and the build crashes with an error like “JavaScript heap out of memory.”
#This tells Node: “you’re allowed to use up to 2048 MB (2 GB) of memory.”
ENV NODE_OPTIONS="--max-old-space-size=2048"
RUN npm run build    




# Stage 2: a very fast web server. Its job is to hand your website files to anyone who visits.its acts as a base image for the app and a link btw users and the app. It is a lightweight web server that is optimized for serving static files, such as HTML, CSS, and JavaScript. It is also very fast and efficient, making it a good choice for serving React applications.
FROM nginx:alpine
## Copies my own settings file (nginx.conf, from the project folder) into Nginx’s settings location, replacing the default or to override the default configuration
#If not used : Nginx uses its default rules, which don’t know about React routing. Typical result: the homepage works, but refreshing any other page shows “404 Not Found.”
COPY nginx.conf /etc/nginx/conf.d/default.conf  

# Copy from stage 1 (app/build) and output to Nginx default public directory./usr/share/nginx/html is the folder where Nginx looks for files to show visitors.
#If anything goes wrong, the build fails with a “not found” error, or Nginx shows the default welcome page instead of the app ui.
# Note: Change /app/build to /app/dist if using Vite
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

## Run Nginx in the foreground 
CMD ["nginx", "-g", "daemon off;"]  