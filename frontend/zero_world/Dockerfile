# Stage 1: Use a community-managed Flutter image to build the web app
FROM instrumentisto/flutter:latest AS build

# Copy the app files
COPY . /app

# Set working directory
WORKDIR /app

# Get dependencies
RUN flutter pub get

# Build the web app
RUN flutter build web

# Stage 2: Serve the web app with a lightweight web server
FROM nginx:latest

# Copy the built web app from the build stage
COPY --from=build /app/build/web /usr/share/nginx/html
