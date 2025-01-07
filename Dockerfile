# User a docker image which already comes with Node.js
FROM node:carbon

# Set the working directory inside the Docker image
WORKDIR /usr/src/app

# Copy Node.js files from my project to the Docker image working directory
COPY package*.json ./

# Install Node.js dependencies on the Docker image
RUN npm install

# Copy all the other files from my project to the Docker image working directory
COPY . .

# Expose the port that the application is going to listen
EXPOSE 8080

# Start NPM inside the Docker image working directory
CMD ["npm", "start"]