# Use a slim Python base image
FROM python:3.10-slim

# Install cron and curl (if not already installed)
RUN apt-get update && apt-get install -y cron curl

# Set working directory inside the container
WORKDIR /app

# Copy the requirements.txt to the container
COPY ./backend/requirements.txt /app/requirements.txt

# Install Python dependencies from the requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Install Ollama if not already installed
RUN if ! command -v ollama &>/dev/null; then \
    echo "Ollama not found, installing..."; \
    curl -fsSL https://ollama.com/install.sh | bash; \
    fi

# Set a custom location for models and ensure Ollama uses it
RUN mkdir -p /root/.ollama/models && \
    ln -s /root/.ollama/models /root/.ollama/data

# Copy the backend code into the container
COPY ./backend /app/backend

# Copy .env file (optional, if you need to use environment variables)
COPY ./backend/.env /app/.env

# Copy entrypoint script
COPY entrypoint.sh /app/entrypoint.sh

# Copy the pptx_files directory
COPY pptx_files /app/pptx_files

# Make sure the entrypoint script is executable
RUN chmod +x /app/entrypoint.sh

# Expose the port that the Flask app will run on
EXPOSE 5001

# Use the entrypoint script to initialize and start the app
ENTRYPOINT ["/app/entrypoint.sh"]