#!/bin/bash

set -e  # Exit immediately if any command fails

echo "Initializing the database..."
python /app/backend/init_db.py

echo "Initializing Pinecone index..."
python /app/backend/pinecone_index.py

# Ensure required Ollama models are downloaded
echo "Checking for required Ollama models..."
models=("mistral:7b" "nomic-embed-text" "deepseek-r1:7b")

for model in "${models[@]}"; do
    if ! ollama list | grep -q "$model"; then
        echo "Downloading model: $model..."
        ollama pull "$model"
    else
        echo "Model $model already exists."
    fi
done

# Process PowerPoint files after models are downloaded
echo "Processing PowerPoint files..."
python /app/backend/process_pptx.py

# Start the cron service
echo "Starting cron service..."
service cron start

# Ensure cron job exists
echo "Setting up scheduled tasks..."
crontab /app/backend/cronjobs

# Start the Flask application
echo "Starting the Flask API..."
exec python /app/backend/rag_api.py
