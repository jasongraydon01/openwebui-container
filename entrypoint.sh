#!/bin/bash

# Initialize the database first (if it hasn't been initialized yet)
echo "Initializing the database..."
python /app/backend/init_db.py

# Initialize Pinecone index
echo "Initializing Pinecone index..."
python /app/backend/pinecone_index.py

echo "Processing PowerPoint files..."
python /app/backend/process_pptx.py

# Start the cron service for scheduled tasks
echo "Starting cron..."
service cron start

# Schedule a cron job to run process_pptx.py every day at 1:00 AM
echo "0 1 * * * python /app/backend/process_pptx.py" | crontab -

# Ensure Ollama models are downloaded (only if they aren't already present)
echo "Checking and pulling Ollama models..."

# Check for model directory in .root (or adjust the path as needed)
MODEL_DIR="/root/.ollama/models"  # Adjust path to where the models are stored in the root directory

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

# Run the Flask application (RAG API)
echo "Starting the Flask API..."
python /app/backend/rag_api.py