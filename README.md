# openwebui-container
## Deployment Steps for Docker Containers on AWS EC2 (g6e.12xlarge)

1. **Launch Amazon EC2 instance (g6e.12xlarge)**:
   - Start with `g6e.12xlarge`.
   - Adjust security to allow 3000, 5001, 11434, 8080.

2. **Set up standard Ubuntu protocols**:
   - Update system packages: `sudo apt update && sudo apt upgrade`
   - Install necessary dependencies: `sudo apt install curl wget build-essential`
   - Set up firewall and security rules as required.

3. **Install Docker**:
   - Install Docker from the official website.

4. **Install Docker Compose**:
   - Install Docker Compose from the official website.

5. **Install GitHub CLI**:
   - Install GitHub CLI from the official website.
   - Authenticate with GitHub.

6. **Ensure any repo changes are uploaded**:
   - Push any local changes to the GitHub repository before pulling to ensure the remote is up to date.

7. **Pull the repo into the instance**:
   - Clone the repository onto the instance using GitHub CLI:
     ```bash
     gh repo clone <username>/<repo_name>
     ```

## OneDrive Sync Setup

### **Usage Plan**
1. **We only care about syncing a specific folder indefinitely on the instance**.
   - No need for a Docker container; we will use the native OneDrive client.
   - Set up a specific sync folder using OneDrive's configuration.
   
2. **Automate OneDrive Start/Stop with Instance Lifecycle**.
   - Since the instance only runs 40-50 hours per week, we need a way to ensure OneDrive starts when the instance starts and stops when the instance shuts down.

3. **Manual authentication may be required if the instance is inactive for too long**.
   - If the instance has been shut down for an extended period, OneDrive may require re-authentication upon startup.

### **Install OneDrive Client**
Follow the installation steps provided in the [OneDrive GitHub repository](https://github.com/abraunegg/onedrive/tree/master).

### **Configure OneDrive for Syncing a Specific Folder**
1. **Create the sync list file to specify the folder to sync**:
   ```bash
   mkdir -p ~/.config/onedrive
   echo "OneDrive-Test/" > ~/.config/onedrive/sync_list
   ```

2. **Ensure OneDrive is configured correctly**:
   ```bash
   onedrive --display-config
   ```

3. **Start the OneDrive sync process in the background**:
   ```bash
   nohup onedrive --monitor > ~/onedrive.log 2>&1 & disown
   ```
   - This ensures the process **runs indefinitely**, even after logging out.
   - To check logs:
     ```bash
     tail -f ~/onedrive.log
     ```

4. **Enable automatic start on boot using `systemd`**:
   ```bash
   mkdir -p ~/.config/systemd/user
   nano ~/.config/systemd/user/onedrive.service
   ```
   Add the following content:
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

5. **Enable and start the service**:
   ```bash
   systemctl --user enable onedrive
   systemctl --user start onedrive
   ```

6. **Set up a final sync at the end of the day** (before the instance stops):
   ```bash
   crontab -e
   ```
   Add:
   ```
   55 16 * * 1-5 /usr/bin/onedrive --synchronize
   ```
   - This ensures a sync is triggered at **4:55 PM (Monday to Friday)** before the instance shuts down.

---

## Continue Docker Setup

8. **Run `docker-compose up -d`**:
    - Start the services in detached mode:
      ```bash
      docker-compose up -d
      ```

9. **Check the setup to ensure OpenWebUI is running**:
    - Make sure to update the URLs with the instance IP address.
    - Open WebUI should be accessible at `http://<instance-ip>:3000`
    - Ollama should be accessible at `http://<instance-ip>:11434`
    - RAG API should be accessible at `http://<instance-ip>:5001`

### **Additional Considerations**:
- **Verify Docker and Docker Compose**: After installation, verify Docker and Docker Compose are running correctly:
  ```bash
  docker --version
  docker-compose --version
  ```