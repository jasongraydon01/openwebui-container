#!/bin/bash

# Install NVIDIA Container Toolkit (if not already installed)
echo "Installing NVIDIA Container Toolkit..."

# Add NVIDIA container repository
if ! dpkg -l | grep -q nvidia-container-toolkit; then
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
        | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
        | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
        | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

    # Update apt and install NVIDIA container toolkit
    sudo apt-get update
    sudo apt-get install -y nvidia-container-toolkit

    # Ensure Docker is set to use GPUs
    echo "Configuring Docker to use GPUs..."
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
else
    echo "NVIDIA Container Toolkit is already installed."
fi

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