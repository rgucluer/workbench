# Author: Recep GUCLUER 
FROM node:22.12-bookworm AS build1

ENV NODE_ENV=production
ENV CHOKIDAR_USEPOLLING=1
ENV GATSBY_WEBPACK_PUBLICPATH=/

ARG virtual_host="app.local"

# # Install apt packages
# RUN apt-get update && apt-get install -y \
#   less \
#   nano \
#   iputils-ping \
#   htop \
#   && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /home/node/app

COPY . .

RUN npm install 
RUN npm install --global gatsby-cli
# RUN npm run build

FROM nginx:1.27.3-bookworm
WORKDIR /usr/share/nginx/html
# Remove default nginx static assets
RUN rm -rf ./*

COPY nginx/ /etc/nginx
RUN sed -i "s/app.local/${virtual_host}/g" /etc/nginx/conf.d/app.conf

# Copy static assets from builder stage
COPY --from=build1 /home/node/app/public .

# Make port available to the world outside this container
EXPOSE 80
EXPOSE 443

# Containers run nginx with global directives and daemon off
ENTRYPOINT ["nginx", "-g", "daemon off;"]
