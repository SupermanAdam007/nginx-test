# Start from the official nginx alpine image
FROM nginx:1.27.1-alpine

# Copy the custom index.html to the default nginx HTML location
COPY nginx/index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
