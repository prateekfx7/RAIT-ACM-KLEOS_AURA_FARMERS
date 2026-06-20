# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS build

WORKDIR /app
COPY sheshield_mesh/ .

RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

# Configure Nginx to listen on PORT (Railway provides this)
RUN echo 'server { listen ${PORT}; location / { root /usr/share/nginx/html; try_files $uri $uri/ /index.html; } }' > /etc/nginx/templates/default.conf.template

EXPOSE 8080
