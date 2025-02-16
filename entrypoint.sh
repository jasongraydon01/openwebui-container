#!/bin/bash

# Initialize the database first (if it hasn't been initialized yet)
echo "Initializing the database..."
python /app/backend/init_db.py

# Initialize Pinecone index
echo "Initializing Pinecone index..."
python /app/backend/pinecone_index.py

# Ensure Ollama is installed
echo "Checking if Ollama is installed..."
if ! command -v ollama &>/dev/null; then
    echo "Ollama not found, installing..."
    curl -fsSL https://ollama.com/install.sh | bash
else
    echo "Ollama is already installed."
fi

# Check for model directory in .root (or adjust the path as needed)
MODEL_DIR="/root/.ollama/models"  # Adjust path to where the models are stored in the root directory

# Ensure models are downloaded (before processing PowerPoint files)
echo "Checking for required Ollama models..."

# Check for model mistral:7b
if [ ! -d "$MODEL_DIR/mistral:7b" ]; then
    echo "Model mistral:7b not found. Downloading..."
    ollama pull mistral:7b
else
    echo "Model mistral:7b already downloaded."
fi

# Check for model nomic-embed-text
if [ ! -d "$MODEL_DIR/nomic-embed-text" ]; then
    echo "Model nomic-embed-text not found. Downloading..."
    ollama pull nomic-embed-text
else
    echo "Model nomic-embed-text already downloaded."
fi

# Check for model deepseek-r1:7b
if [ ! -d "$MODEL_DIR/deepseek-r1:7b" ]; then
    echo "Model deepseek-r1:7b not found. Downloading..."
    ollama pull deepseek-r1:7b
else
    echo "Model deepseek-r1:7b already downloaded."
fi

# Process PowerPoint files after models are downloaded
echo "Processing PowerPoint files..."
python /app/backend/process_pptx.py

# Start the cron service for scheduled tasks
echo "Starting cron..."
service cron start

# Schedule a cron job to run process_pptx.py every day at 1:00 AM
echo "0 1 * * * python /app/backend/process_pptx.py" | crontab -

# Run the Flask application (RAG API)
echo "Starting the Flask API..."
python /app/backend/rag_api.py