# Monitoring and Maintenance Guide

## Basic Monitoring Setup
To monitor the health of the containerized environment, the following theoretical stack should be established on the host server:

1. **Prometheus**: To pull metrics actively from Docker and the Host Server (via Node Exporter).
2. **Grafana**: Serves dashboard visualizations connected to the local Prometheus instance.

**Key Metrics to Alert On:**
- Host CPU usage consistently exceeding 85%.
- Memory Limits: If either the Django backend or Next.js frontend begins consuming above threshold limits, warning alerts should trigger (especially on `t3.micro` instances where resources are heavily constrained).
- 5xx HTTP Error rates through Nginx.

## Routine Maintenance

### Container Pruning
Once a month, dangling and untagged Docker images generated during consecutive CI/CD pipeline runs (`docker compose build`) should be cleared using:
```bash
docker system prune -a -f
```
This avoids unnecessary storage exhaustions on the EC2 instance partition.
