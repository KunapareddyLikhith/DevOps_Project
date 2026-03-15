# CI/CD Pipeline Documentation

The repository utilizes GitHub Actions to automatically deploy the application to our provisioned AWS EC2 infrastructure.

## Configuration File
The pipeline definition is situated at `.github/workflows/cicd.yaml`. 

```yaml
name: Deploy Docker Compose Application

on:
  push:
    branches:
      - main
```
The workflow triggers automatically on any direct push to the `main` branch.

## Pipeline Flow

1. **Deploy to Server Step**: The job utilizes the standard `appleboy/ssh-action@v1.0.3` which spins up a temporary Ubuntu runner to SSH into the remote deployment server authenticated via GitHub Secrets.
2. **Access Required**:
    * `SERVER_IP`: The public IP address of the provisioned AWS EC2 instance.
    * `SERVER_SSH_KEY`: The private key contents of the `.pem` file associated with the target server.
3. The runner executes a deployment bash script directly on the server host:
   ```bash
   cd /home/ubuntu/project
   git pull origin main
   docker compose down
   docker compose build
   docker compose up -d
   ```
4. This ensures that the code repository is entirely refreshed to match `main`, the old containers are stopped, new containers are explicitly rebuilt to ingest updated dependencies (via `docker-compose build`), and then spun up in detached mode.
