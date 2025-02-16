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

# Ensure the model directory exists
MODEL_DIR="/root/.ollama/models"  # Adjust path to where the models are stored in the root directory
if [ ! -d "$MODEL_DIR" ]; then
    echo "Model directory not found, creating $MODEL_DIR..."
    mkdir -p "$MODEL_DIR"
fi

# Ensure models are downloaded (before processing PowerPoint files)
echo "Checking for required Ollama models..."

# List of models to check/download
models=("mistral:7b" "nomic-embed-text" "deepseek-r1:7b")

for model in "${models[@]}"; do
    if [ ! -d "$MODEL_DIR/$model" ]; then
        echo "Model $model not found. Downloading..."
        ollama pull "$model"
    else
        echo "Model $model already downloaded."
    fi
done

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