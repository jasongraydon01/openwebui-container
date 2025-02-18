# openwebui-container
## Deployment Steps for Docker Containers on AWS EC2 (G4dn)

1. **Launch Amazon EC2 instance (G4dn)**:
   - Start with `2large` (due to 8-CPU limit but scale up later as needed).
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

8. **Create `.env` file in `backend/`**:
   - Create and edit `.env` file using `nano` or `vim`.
   - Add your environment variables as required.

9. **Run `docker-compose build`**:
   - Build the Docker images defined in `docker-compose.yml`:
     ```bash
     docker-compose build
     ```

10. **Run `docker-compose up -d`**:
    - Start the services in detached mode:
      ```bash
      docker-compose up -d
      ```

11. **Check the setup to ensure openwebui is running**:
    - Make sure to update the urls with the instance ip address.
    - Open WebUI should be accessible at `http://<instance-ip>:3000`
    - Ollama should be accessible at `http://<instance-ip>:11434`
    - RAG API should be accessible at `http://<instance-ip>:5001`

### Additional Considerations:
- **Verify Docker and Docker Compose**: After installation, verify Docker and Docker Compose are running correctly:
  ```bash
  docker --version
  docker-compose --version
