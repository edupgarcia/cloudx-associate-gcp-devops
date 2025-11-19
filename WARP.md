# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This repository contains training materials for the CloudX Associate GCP DevOps program. It's structured around practical GCP infrastructure tasks with corresponding solutions. Each task demonstrates specific GCP services and architectural patterns.

## Repository Structure

- `tasks/` - Task descriptions and starter code for each exercise
  - `basic-network.md` - VPC networking with bastion host and NAT configuration
  - `dynamic-serverless-website.md` - Serverless architecture with Cloud Functions, Cloud SQL, and Cloud Storage
  - `bulk-processing.md` - Event-driven data pipeline using Pub/Sub and managed instance groups
  - `nextcloud-gce.md` - High-availability Nextcloud deployment with Filestore, Cloud SQL, Memorystore
- `solutions/` - Implementation scripts organized by task name
  - Each solution typically contains numbered shell scripts executed in sequence
  - `test/` subdirectories contain validation scripts

## Environment Setup

All solutions use environment variables defined in `1-setup.sh` files:
- `PROJECT_ID` - GCP project identifier
- `REGION` - Default GCP region (typically `us-central1`)
- `ZONE` - Default GCP zone (typically `us-central1-a`)
- `NETWORK_NAME` - VPC network name
- `EXTERNAL_IP` - Your current IP for firewall rules (obtain with `curl ifconfig.me`)

Before running any solution scripts:
1. Source the setup file: `source solutions/<task-name>/1-setup.sh`
2. Modify environment variables as needed for your GCP project
3. Ensure you have an SSH key: `ssh-keygen -t rsa -f ~/.ssh/id_rsa -C "your_email"`

## Common Development Workflow

### Executing Solutions

Solution scripts are numbered to indicate execution order:
```bash
cd solutions/<task-name>
source 1-setup.sh
./2-vpc.sh
./3-nat.sh
# ... continue with remaining scripts
```

### Testing Solutions

Use test scripts in `solutions/<task-name>/test/` subdirectories to verify deployments:
```bash
cd solutions/<task-name>/test
./1-bastion-ssh.sh
./2-workstation-ssh.sh
```

### Cleanup

Each solution includes a cleanup script (typically `99-project-cleanup.sh`):
```bash
./99-project-cleanup.sh
```

## GCP Service APIs

Most tasks require enabling specific GCP APIs. Common APIs across tasks:
- `compute.googleapis.com` - Compute Engine (VMs, networks, firewalls)
- `cloudresourcemanager.googleapis.com` - Project management
- `servicenetworking.googleapis.com` - Private Google Access
- `dns.googleapis.com` - Cloud DNS
- `oslogin.googleapis.com` - SSH key management

## Python Scripts

Python scripts in this repository follow these patterns:

### Environment Variable Configuration
Scripts use a common pattern for environment variables:
```python
def getEnvVar(var_name, def_value):
    result = def_value
    if var_name in os.environ and os.environ[var_name]:
        result = os.environ[var_name]
    return result
```

### Required Environment Variables
- `PROJECT_ID` - GCP project identifier (required)
- `SUBSCRIPTION` - Pub/Sub subscription name
- `TOPIC` - Pub/Sub topic name
- `BUCKET` - Cloud Storage bucket name

### Python Dependencies
Install dependencies from task-specific `requirements.txt` files:
```bash
pip3 install -r tasks/<task-name>/requirements.txt
```

## Task-Specific Notes

### Basic Network
- Implements VPC with private subnet, Cloud NAT, bastion host, and firewall rules
- Scripts execute GCP CLI commands directly (no Terraform)
- Firewall rules restrict bastion access to specific IP addresses

### Dynamic Serverless Website
- Cloud Function backend (`tasks/dynamic-serverless-website/main.py`)
- Credentials stored in Secret Manager with `DB_CREDS` environment variable
- Load balancer routing: `/*` → Cloud Storage, `/api/*` → Cloud Function

### Bulk Processing
- Three-stage pipeline: ingest → unpack → transform
- Uses Pub/Sub for event-driven processing
- Managed instance groups with autoscaling based on unprocessed message count
- Data generator creates 100 sensor readings per batch
- Use `parallel` command for load testing: `parallel -j 50 bash -c "./ingest.sh gs://bucket-name" -- $(seq 1 1000 | xargs echo)`

### Nextcloud GCE
- Complex multi-service deployment with high availability
- Startup script in task description handles complete Nextcloud installation
- Integrates: Filestore (NFS), Cloud SQL (MySQL), Memorystore (Redis), Cloud Scheduler, Cloud Armor
- Secrets format includes nextcloud, mysql, redis, and nfs configuration sections

## Acceptance Criteria Testing

Each task includes specific acceptance criteria. Common validation approaches:
- SSH access testing from allowed/restricted IPs
- Network connectivity verification: `sudo apt-get update`, `traceroute storage.googleapis.com`
- Service availability checks via browser or curl
- VPN connection for testing IP-based restrictions
- Traffic analysis with `tcpdump` for encryption verification

## Working with gcloud CLI

All infrastructure provisioning uses `gcloud` commands rather than Terraform or other IaC tools. When suggesting commands:
- Use `--no-pager` flag to avoid pagination issues
- Include full resource paths when deleting resources
- Set region/zone explicitly or rely on configured defaults
- Use tags for firewall targeting (`bastion`, `internal`)
