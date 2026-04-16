# Use a standard Flutter environment to build
FROM ghcr.io/cirruslabs/flutter:3.32.0 AS build-env

WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --release

# Serve the static files using Nginx
FROM nginx:alpine

# The environment variable PORT is set by Cloud Run.
ENV PORT 8080

# Remove default configuration and copy our own
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy build files
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Adjust nginx to listen on the $PORT variable provided by Cloud Run
CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
