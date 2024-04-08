# Dockerfile for a basic Nginx image
# Author: Recep GUCLUER
FROM nginx:1.25.3

ARG virtual_host="app1.local"

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf.d/ /etc/nginx/conf.d
RUN sed -i "s/app1.local/${virtual_host}/g" /etc/nginx/conf.d/app1.conf
COPY data/www/ /usr/share/nginx/html
COPY data/images/ /usr/share/nginx/images

EXPOSE 80
EXPOSE 443