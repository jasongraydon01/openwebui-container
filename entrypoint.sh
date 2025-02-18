#!/bin/bash

set -e  # Exit immediately if any command fails

echo "Initializing the database..."
python /app/backend/init_db.py

echo "Initializing Pinecone index..."
python /app/backend/pinecone_index.py

# Ensure required Ollama models are downloaded using the Python script
echo "Checking for required Ollama models..."
python /app/backend/check_ollama_models.py

# # Process PowerPoint files after models are downloaded
# echo "Processing PowerPoint files..."
# python /app/backend/process_pptx.py

# Start the cron service
echo "Starting cron service..."
service cron start

# Schedule a cron job to run process_pptx.py every day at 1:00 AM
echo "0 1 * * * python /app/backend/process_pptx.py" | crontab -

# Start the Flask application
echo "Starting the Flask API..."
exec python /app/backend/rag_api.py
