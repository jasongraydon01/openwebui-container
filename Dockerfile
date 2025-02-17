# Use a slim Python base image
FROM python:3.10-slim

# Install cron and curl (if not already installed)
RUN apt-get update && apt-get install -y cron curl && rm -rf /var/lib/apt/lists/*

# Set working directory inside the container
WORKDIR /app/backend

# Copy the requirements.txt to the container
COPY ./backend/requirements.txt requirements.txt

# Install Python dependencies from the requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the backend code into the container
COPY ./backend /app/backend

# Copy .env file (optional, if you need to use environment variables)
COPY ./backend/.env .env

# Copy entrypoint script
COPY entrypoint.sh /app/entrypoint.sh

# Make sure the entrypoint script is executable
RUN chmod +x /app/entrypoint.sh

# Expose the port that the Flask app will run on
EXPOSE 5001