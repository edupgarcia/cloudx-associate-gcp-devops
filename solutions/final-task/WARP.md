# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Solution Overview

This is the final-task solution directory for the CloudX Associate GCP DevOps program. It follows the same deployment pattern as other solutions in this repository:

- Numbered deployment scripts (01-setup.sh, 02-*.sh, etc.) that must be run in sequence
- A cleanup script (99-project-cleanup.sh)
- A test/ directory for validation
- A README.md with detailed documentation

## Deployment Pattern

All scripts in this solution follow the standard CloudX pattern:

### Setup Script (01-setup.sh)

The setup script must be sourced (not executed) to export environment variables:

```bash
source 01-setup.sh
```

**Key behaviors:**
- Exports environment variables for all subsequent scripts
- Enables required GCP APIs (can take 1-2 minutes)
- Generates random passwords/secrets using `openssl rand -base64 18`
- Creates a `.env` file with timestamped configuration
- Displays organized configuration output grouped by category

**Environment Variables Pattern:**
- `PROJECT_ID` - GCP project (from $GOOGLE_CLOUD_PROJECT)
- `REGION` - Default: us-central1
- `ZONE` or `ZONE_A/B/C` - Availability zones
- Component-specific variables (network names, instance names, etc.)

### Sequential Deployment Scripts (02-XX-*.sh)

Scripts are numbered and must run in order:
- 02-*.sh - First infrastructure component
- 03-*.sh - Second component (may depend on 02)
- etc.

Common components across solutions:
- VPC networking (vpc.sh)
- Cloud SQL (sql.sh, cloudsql.sh) - Takes ~10 minutes
- Storage buckets (storage.sh, bucket.sh)
- Pub/Sub (pubsub.sh)
- Instance templates and MIGs (mig.sh, instance-group.sh) - Takes 3-5 minutes
- Load balancers (load-balancer.sh)

### Cleanup Script (99-project-cleanup.sh)

Deletes all resources created by deployment scripts:

```bash
source 01-setup.sh  # Restore environment variables
./99-project-cleanup.sh
```

## Environment Management

### Initial Deployment

```bash
# First time - creates .env file
source 01-setup.sh
./02-*.sh
./03-*.sh
# ... continue with remaining scripts
```

### Restoring Environment

```bash
# Restore variables from existing .env file
source .env

# Or re-run setup (WARNING: regenerates passwords/secrets)
source 01-setup.sh
```

**Important:** Re-running `01-setup.sh` regenerates random passwords, which breaks existing deployments. Use `source .env` to restore existing configuration.

## Testing Structure

Create a `test/` directory with:
- Acceptance criteria test scripts matching solution requirements
- `run-all-tests.sh` for running complete test suite (if multiple tests)
- Python unit tests using `unittest` framework
- README.md documenting test procedures

**Unit Test Pattern:**
```python
import unittest
from unittest.mock import patch

class TestComponent(unittest.TestCase):
    @patch('subprocess.run')
    def test_configuration(self, mock_run):
        # Mock gcloud command response
        mock_run.return_value.stdout = '{"key": "value"}'
        # Test logic
```

Run tests: `python3 test_*.py -v`

## Common Commands

### Deployment

```bash
# Setup environment
source 01-setup.sh

# Deploy in sequence (adjust numbers based on actual scripts)
./02-*.sh
./03-*.sh
# ... continue through all scripts

# Cleanup
./99-project-cleanup.sh
```

### Monitoring

```bash
# View GCP resources by type
gcloud compute instances list
gcloud compute instance-groups list
gcloud sql instances list
gcloud storage buckets list
gcloud pubsub topics list
gcloud pubsub subscriptions list

# Check resource status
gcloud compute instances describe <instance-name> --zone=$ZONE
gcloud sql instances describe <instance-name>
```

### Debugging

```bash
# View instance logs (for Compute Engine)
gcloud compute instances get-serial-port-output <instance-name> --zone=$ZONE

# SSH to instance
gcloud compute ssh <instance-name> --zone=$ZONE

# Check startup script logs
sudo journalctl -u google-startup-scripts.service

# View Cloud Function logs (if applicable)
gcloud functions logs read <function-name>
```

## GCP-Specific Considerations

- **API Enablement:** First-time setup enables GCP APIs (1-2 minutes)
- **Long-Running Operations:**
  - Cloud SQL creation: ~10 minutes
  - Filestore creation: ~5 minutes
  - Memorystore Redis creation: ~5 minutes
  - MIG creation: 3-5 minutes
- **Default Region/Zone:** Solutions default to `us-central1`/`us-central1-a`
- **Project ID:** Set via `GOOGLE_CLOUD_PROJECT` environment variable (automatic in Cloud Shell)
- **IP Restrictions:** Some solutions require `EXTERNAL_IP` for firewall rules:
  ```bash
  export EXTERNAL_IP="$(curl -s ifconfig.me)/32"
  ```

## Script Development Guidelines

When creating deployment scripts, follow these patterns:

### Variable Usage
- Use `${VARIABLE}` syntax for environment variables
- Validate required variables at script start
- Use `gcloud` commands with `--format` for consistent output

### Error Handling
```bash
set -e  # Exit on error
set -u  # Exit on undefined variable
```

### Idempotency
- Check if resources exist before creating
- Use `gcloud` return codes to handle existing resources
- Delete before recreate for resources that don't support updates

### Resource Naming
- Use descriptive prefixes (e.g., `nextcloud-`, `bulk-processing-`)
- Export names as environment variables in 01-setup.sh
- Use consistent naming across related resources

## Repository Context

This solution is part of the CloudX Associate GCP DevOps program. Related solutions:
- `../basic-network/` - VPC networking with bastion host
- `../dynamic-serverless-website/` - Cloud Functions with Cloud SQL
- `../bulk-processing/` - Event-driven pipeline with Pub/Sub
- `../nextcloud-gce/` - Nextcloud on GCE with monitoring

All solutions share the same deployment script pattern and follow GCP best practices.
