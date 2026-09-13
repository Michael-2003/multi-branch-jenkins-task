# Use an official lightweight Node.js image
FROM node:20-alpine

# Set the working directory
WORKDIR /app

# Copy dependency files and install dependencies
COPY package*.json ./
RUN npm install --omit=dev

# Copy the application code
COPY . .

# Expose Express default port
EXPOSE 3000

# Run the app
CMD ["node", "index.js"]
