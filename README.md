# OpenWebUI Container Deployment Guide

## **1. Launch an EC2 Instance (Ubuntu Server 24.04, General Purpose)**
- Select **Ubuntu Server 24.04 LTS** for better package management and fewer conflicts.
- Configure **security group rules** to allow traffic on **ports 3000, 5001, 11434, and 8080**.

## **2. Install NVIDIA CUDA Toolkit & Drivers (Network `deb` method)**

```bash
# Add NVIDIA's CUDA repository and install keyring
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update

# Install CUDA Toolkit 12.8
sudo apt-get install -y cuda-toolkit-12-8

# Install NVIDIA Open Kernel Module Driver (Recommended)
sudo apt-get install -y nvidia-open

# Set Up CUDA Environment Variables
echo 'export PATH="/usr/local/cuda-12.8/bin:$PATH"' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH="/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Verify Installation:**
```bash
nvidia-smi
nvcc --version
```

## **3. Set Up Standard Ubuntu Protocols**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget build-essential
```

## **4. Install Docker**
```bash
# Add Docker repository and install necessary packages
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify installation
sudo docker run hello-world
```

## **5. Install Docker Compose**
```bash
sudo apt-get update
sudo apt-get install -y docker-compose-plugin
sudo docker compose version
```

## **6. Install GitHub CLI**
```bash
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install -y wget)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install -y gh

gh auth login
```

## **7. Clone Repository**
```bash
gh repo clone <username>/<repo_name>
```

## **OneDrive Sync Setup**

### **Upgrade cURL Before Syncing**
Ensure `cURL` is at least version 8.12.1:
```bash
curl --version
```
If below 8.12.1, upgrade:
```bash
sudo apt update && sudo apt install -y build-essential libssl-dev libnghttp2-dev libpsl-dev
cd ~
wget https://curl.se/download/curl-8.12.1.tar.gz
tar -xzf curl-8.12.1.tar.gz
cd curl-8.12.1
./configure --with-ssl --with-nghttp2 --prefix=/usr --libdir=/usr/lib/x86_64-linux-gnu
make -j$(nproc)
sudo make install
sudo ldconfig
```
Verify:
```bash
/usr/bin/curl --version
```

### **Install OneDrive Client**
```bash
wget -qO - https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_24.04/Release.key | gpg --dearmor | sudo tee /usr/share/keyrings/obs-onedrive.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/obs-onedrive.gpg] https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_24.04/ ./" | sudo tee /etc/apt/sources.list.d/onedrive.list
sudo apt-get update
sudo apt install --no-install-recommends --no-install-suggests onedrive
onedrive
```

### **Configure OneDrive for Syncing a Specific Folder**
```bash
mkdir -p ~/.config/onedrive
echo "OneDrive-Test/" > ~/.config/onedrive/sync_list
echo "force_http_11 = \"true\"" > ~/.config/onedrive/config  # Shouldn't be necessary if using latest curl
onedrive --display-config
```

### **Perform One-Time Sync**
```bash
onedrive --sync #if this doesn't work try onedrive --sync --resync
```

### **Enable Background Sync**
```bash
nohup onedrive --monitor > ~/onedrive.log 2>&1 & disown
tail -f ~/onedrive.log
```

## **Continue Docker Setup**

### **Run `docker-compose up -d`**
```bash
docker-compose up -d
```

### **Verify OpenWebUI and APIs**
- **Open WebUI**: `http://<instance-ip>:3100`
- **Ollama**: `http://<instance-ip>:11434`
- **RAG API**: `http://<instance-ip>:5001`

### **Verify Docker Installation**
```bash
docker --version
docker-compose --version
```