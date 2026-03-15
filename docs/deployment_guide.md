# Deployment Guide

This document details the steps taken to deploy and configure the ChatGPT clone application locally and on cloud infrastructure.

## Infrastructure as Code (Terraform)
We utilized Terraform to automate the provisioning of the cloud environment.
1. The Terraform script is located at `terraform/main.tf`.
2. It targets an AWS `ap-south-1` region and provisions a `t3.micro` EC2 instance named `main_server`.
3. A security group `ec2_sg` is defined to allow incoming SSH (port 22) and HTTP (port 80) traffic from anywhere (`0.0.0.0/0`).
4. **Provisioner Execution**: Once the instance is brought up, Terraform connects via SSH (using `likth.pem`) and automatically installs the Docker Engine using `remote-exec` with `apt-get`. It also adds the default `ubuntu` user to the docker group.

## Application Architecture
The application runs as a multi-container Docker Compose deployment.
*   **Frontend**: Next.js (Port 3000 mapped to container service)
*   **Backend**: Django / Python (Port 8000 mapped to container service)
*   **Reverse Proxy**: Nginx (Port 80 mapped to host 80)

### Dockerization
1.  **Frontend (`frontend/Dockerfile`)**: Uses `node:slim` as the base image. It copies the `package.json`, installs npm dependencies, and runs `npm run dev`. We exposed port 3000 inside the container.
2.  **Backend (`backend/dockerfile`)**: Uses `python:3.11`. Installs dependencies via `dependencies.txt`. **Crucially, the container `CMD` is configured to run database migrations automatically** before starting the Django server: `CMD sh -c "python3 manage.py migrate && python3 server.py"`.
3.  **Docker Compose (`compose.yaml`)**: The compose file bridges these services together over a custom `secure-network`. Nginx acts as the entrypoint and depends on the frontend and backend being successfully initialized.

## Deployment Steps
To deploy this application from scratch on a server with Docker installed:

1. Clone the repository and navigate into the directory.
2. Setup the `.env` variables inside `backend/.env`.
3. Run the deployment:
   ```bash
   docker compose up --build -d
   ```
4. **First-Time Setup**: Once the containers are running and the database migrations have finished, you must initialize the user roles and the primary admin account inside the backend container:
   ```bash
   docker compose exec backend python3 manage.py create_roles
   docker compose exec backend python3 manage.py create_superuser
   ```
5. You can now access the application on port 80 (e.g., `http://localhost` or `http://<server-ip>`).
