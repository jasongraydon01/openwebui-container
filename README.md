# openwebui-container
## Deployment Steps for Docker Containers on AWS EC2 (g6e.12xlarge)

### **1. Launch Amazon EC2 Instance (Ubuntu Server 24.04, General Purpose)**
- Use **Ubuntu Server 24.04 LTS** instead of deep learning AMIs.
- This ensures better package management and avoids conflicts with pre-installed dependencies.
- Adjust security group rules to allow access on **ports 3000, 5001, 11434, and 8080**.

### **2. Install NVIDIA CUDA Toolkit & Drivers (Network `deb` method)**

```bash
# Add NVIDIA's CUDA repository and install keyring
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update

# Set Up CUDA Environment Variables:
echo 'export PATH="/usr/local/cuda-12.8/bin:$PATH"' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH="/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH"' >> ~/.bashrc
source ~/.bashrc
# Install CUDA Toolkit 12.8
sudo apt-get install -y cuda-toolkit-12-8

# Install the NVIDIA Open Kernel Module Driver (Recommended)
sudo apt-get install -y nvidia-open
```

**Verify Installation:**
```bash
nvidia-smi
nvcc --version
```
- `nvidia-smi` should show your **GPU model** and **driver version**.
- `nvcc --version` should confirm **CUDA 12.8** is installed.

### **3. Set Up Standard Ubuntu Protocols**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget build-essential
```
- Set up firewall and security rules as needed.

### **4. Install Docker**
```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

# Install Docker Engine and necessary components
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify installation
sudo docker run hello-world
```

### **5. Install Docker Compose**
```bash
sudo apt-get update
sudo apt-get install -y docker-compose-plugin

# Verify installation
sudo docker compose version
```

### **6. Install GitHub CLI**
```bash
# Install GitHub CLI
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install -y wget)) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install -y gh

# Authenticate with GitHub
gh auth login
```

### **7. Pull the Repository**
```bash
gh repo clone <username>/<repo_name>
```

## OneDrive Sync Setup

### **1. Upgrade cURL Before Syncing**
Before performing the OneDrive sync, ensure that you have the latest version of `cURL` installed:
```bash
curl --version
```
If the version is below `8.12.1`, install or upgrade it manually:
```bash
sudo apt remove --purge curl -y
sudo apt update && sudo apt install -y build-essential libssl-dev libnghttp2-dev libpsl-dev pkg-config
cd /usr/local/src
sudo wget https://curl.se/download/curl-8.12.1.tar.gz
sudo tar -xzf curl-8.12.1.tar.gz
cd curl-8.12.1
./configure --prefix=/usr/local --with-ssl --with-nghttp2
make -j$(nproc)
sudo make install
sudo ldconfig
```
Verify the updated version:
```bash
curl --version
```

### **2. Install OneDrive Client**
```bash
wget -qO - https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_24.04/Release.key | gpg --dearmor | sudo tee /usr/share/keyrings/obs-onedrive.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/obs-onedrive.gpg] https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_24.04/ ./" | sudo tee /etc/apt/sources.list.d/onedrive.list
sudo apt-get update
sudo apt install --no-install-recommends --no-install-suggests onedrive

# Initial setup
onedrive
```

### **3. Configure OneDrive for Syncing a Specific Folder**
```bash
mkdir -p ~/.config/onedrive
echo "OneDrive-Test/" > ~/.config/onedrive/sync_list

# Configure HTTP settings
echo "force_http_11 = \"true\"" > ~/.config/onedrive/config

# Verify configuration
onedrive --display-config
```

### **4. Perform One-Time Sync**
```bash
onedrive --sync
```

### **5. Enable Background Sync**
```bash
nohup onedrive --monitor > ~/onedrive.log 2>&1 & disown
```
- This ensures the process **runs indefinitely**, even after logging out.
- To check logs:
  ```bash
  tail -f ~/onedrive.log
  ```

### **6. Enable Automatic Start on Boot with `systemd`**
```bash
mkdir -p ~/.config/systemd/user
nano ~/.config/systemd/user/onedrive.service
```
Paste the following:
```ini
[Unit]
Description=OneDrive Cloud Sync Service
After=network-online.target

[Service]
ExecStart=/usr/bin/onedrive --monitor
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
```

```bash
systemctl --user enable onedrive
systemctl --user start onedrive
```

### **7. Schedule Final Sync Before Instance Stops**
```bash
crontab -e
```
Add:
```bash
55 16 * * 1-5 /usr/bin/onedrive --synchronize
```
This ensures a sync is triggered at **4:55 PM (Monday to Friday)** before the instance shuts down.

## **Continue Docker Setup**

### **8. Run `docker-compose up -d`**
```bash
docker-compose up -d
```

### **9. Verify OpenWebUI and APIs**
- **Open WebUI**: `http://<instance-ip>:3000`
- **Ollama**: `http://<instance-ip>:11434`
- **RAG API**: `http://<instance-ip>:5001`

### **10. Verify Docker Installation**
```bash
docker --version
docker-compose --version
```