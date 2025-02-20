# openwebui-container
## Deployment Steps for Docker Containers on AWS EC2 (g6e.12xlarge)

### **1. Launch Amazon EC2 Instance (g6e.12xlarge)**
- Start with `g6e.12xlarge`.
- Adjust security group rules to allow access on **ports 3000, 5001, 11434, and 8080**.

### **2. Set Up Standard Ubuntu Protocols**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget build-essential
```
- Set up firewall and security rules as needed.

### **3. Install Docker**
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

### **4. Install Docker Compose**
```bash
sudo apt-get update
sudo apt-get install -y docker-compose-plugin

# Verify installation
sudo docker compose version
```

### **5. Install GitHub CLI**
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

### **6. Pull the Repository**
```bash
gh repo clone <username>/<repo_name>
```

## OneDrive Sync Setup

### **1. Install OneDrive Client**
```bash
wget -qO - https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_22.04/Release.key | gpg --dearmor | sudo tee /usr/share/keyrings/obs-onedrive.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/obs-onedrive.gpg] https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/xUbuntu_22.04/ ./" | sudo tee /etc/apt/sources.list.d/onedrive.list
sudo apt-get update
sudo apt install --no-install-recommends --no-install-suggests onedrive

# Initial setup
onedrive
```

### **2. Configure OneDrive for Syncing a Specific Folder**
```bash
mkdir -p ~/.config/onedrive
echo "OneDrive-Test/" > ~/.config/onedrive/sync_list

# Configure HTTP settings
echo "force_http_11 = \"true\"" > ~/.config/onedrive/config

# Verify configuration
onedrive --display-config
```

### **3. Perform One-Time Sync**
```bash
onedrive --sync
```

### **4. Enable Background Sync**
```bash
nohup onedrive --monitor > ~/onedrive.log 2>&1 & disown
```
- This ensures the process **runs indefinitely**, even after logging out.
- To check logs:
  ```bash
  tail -f ~/onedrive.log
  ```

### **5. Enable Automatic Start on Boot with `systemd`**
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

### **6. Schedule Final Sync Before Instance Stops**
```bash
crontab -e
```
Add:
```bash
55 16 * * 1-5 /usr/bin/onedrive --synchronize
```
This ensures a sync is triggered at **4:55 PM (Monday to Friday)** before the instance shuts down.

## **Continue Docker Setup**

### **7. Run `docker-compose up -d`**
```bash
docker-compose up -d
```

### **8. Verify OpenWebUI and APIs**
- **Open WebUI**: `http://<instance-ip>:3000`
- **Ollama**: `http://<instance-ip>:11434`
- **RAG API**: `http://<instance-ip>:5001`

### **9. Verify Docker Installation**
```bash
docker --version
docker-compose --version
```

### **Final Notes**
- If OneDrive authentication expires, manually re-authenticate with:
  ```bash
  onedrive
  ```
- If needed, restart OneDrive monitoring:
  ```bash
  systemctl --user restart onedrive
  ```