# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This is a learning repository for CloudX Associate GCP DevOps program containing three main infrastructure solutions deployed on Google Cloud Platform:

1. **Basic Network**: VPC networking with bastion host, Cloud NAT, and Private Google Access
2. **Dynamic Serverless Website**: Serverless architecture with Cloud Functions, Cloud SQL, and Load Balancer
3. **Bulk Processing**: Event-driven data pipeline with Pub/Sub, Cloud Storage, and autoscaling Managed Instance Groups

Each solution is structured with:
- Numbered deployment scripts (01-setup.sh, 02-*.sh, etc.) that must be run in sequence
- A cleanup script (99-project-cleanup.sh)
- A test/ directory for validation
- A README.md with detailed documentation

## Environment Setup

All solutions require environment setup before execution:

```bash
# Always source the setup script first (sets environment variables and enables APIs)
source 01-setup.sh

# For solutions with IP restrictions (basic-network, dynamic-serverless-website):
export EXTERNAL_IP="$(curl -s ifconfig.me)/32"
```

**Important**: The setup script exports environment variables that are used by all subsequent scripts. Always run `source 01-setup.sh` (not `./01-setup.sh`) to ensure variables persist in the current shell.

**Environment Persistence**: The setup script automatically generates a `.env` file containing all configuration variables with a timestamp. This file:
- Persists all environment variables for future reference
- Can be sourced to restore the environment: `source .env`
- Contains sensitive data (passwords, credentials) and should NOT be committed to version control
- Is automatically added to `.gitignore` to prevent accidental commits

## Common Commands

### Bulk Processing Solution

```bash
# Deploy (from solutions/bulk-processing/)
source 01-setup.sh
./02-storage.sh
./03-pubsub.sh
./04-bucket-notifications.sh
./05-unpack-worker.sh
./06-transform-worker.sh
./07-unpack-mig.sh  # Takes several minutes
./08-transform-mig.sh  # Takes several minutes

# Test
cd test
./run-all-tests.sh  # Run all acceptance criteria tests
./01-test-pipeline.sh  # Test end-to-end pipeline
./02-test-autoscaling.sh  # Verify autoscaling configuration
./03-test-mig-configuration.sh  # Verify MIG settings
python3 test_mig_validation.py -v  # Run unit tests

# Monitor pipeline
gcloud storage ls gs://$INGEST_BUCKET/
gcloud storage ls gs://$UNPACK_BUCKET/**/*.json
gcloud storage ls gs://$TRANSFORM_BUCKET/**/*.csv

# Check autoscaling
gcloud compute instance-groups managed list-instances $UNPACK_MIG --zone=$ZONE
gcloud compute instance-groups managed list-instances $TRANSFORM_MIG --zone=$ZONE

# Check Pub/Sub queue depth
gcloud pubsub subscriptions describe $INGEST_SUBSCRIPTION --format="value(numUnacknowledgedMessages)"
gcloud pubsub subscriptions describe $UNPACK_SUBSCRIPTION --format="value(numUnacknowledgedMessages)"

# Cleanup
source 01-setup.sh
./99-project-cleanup.sh
```

### Dynamic Serverless Website Solution

```bash
# Deploy (from solutions/dynamic-serverless-website/)
source 01-setup.sh
export EXTERNAL_IP="$(curl -s ifconfig.me)/32"
./02-vpc.sh
./03-vpc-connector.sh
./04-cloudsql.sh  # Takes ~10 minutes
./05-secret-manager.sh
./06-storage-bucket.sh
./07-cloud-function.sh
./08-load-balancer.sh
./09-cloud-armor.sh

# Test
LB_IP=$(gcloud compute addresses describe $IP_NAME --global --format="value(address)")
curl http://$LB_IP/
curl http://$LB_IP/api/
```

### Basic Network Solution

```bash
# Deploy (from solutions/basic-network/)
source 01-setup.sh
export EXTERNAL_IP="$(curl -s ifconfig.me)/32"
./02-vpc.sh
./03-nat.sh
./04-fw.sh
./05-bastion-host.sh
./06-workstation.sh

# Test
cd test
./01-bastion-ssh.sh
./02-workstation-ssh.sh
```

## Architecture Patterns

### Bulk Processing Pipeline

The bulk processing solution implements a three-stage event-driven pipeline:

**Data Flow**:
1. Ingest: ZIP files → Cloud Storage (ingest bucket) → Pub/Sub notification (ingest topic)
2. Unpack: Workers pull from ingest subscription → Extract ZIP to JSON files → Upload to unpack bucket → Publish to unpack topic
3. Transform: Workers pull from unpack subscription → Convert JSON to CSV by metric type (temperature/humidity/pressure) → Upload to transform bucket → Publish to transform topic

**Autoscaling**: Both worker Managed Instance Groups scale based on Pub/Sub subscription queue depth (target: 5 unacked messages per instance, min: 1, max: 10)

**Worker Implementation**: Python workers use:
- `google.cloud.storage` for bucket operations
- `google.cloud.pubsub` for message handling
- Environment variables: `PROJECT_ID`, `SUBSCRIPTION`, `TOPIC`, `BUCKET`

**Key Files**:
- `tasks/bulk-processing/unpack.py` - Unpack worker implementation
- `tasks/bulk-processing/transform.py` - Transform worker implementation
- `07-unpack-mig.sh` and `08-transform-mig.sh` - Create instance templates and MIGs with autoscaling policies

### Deployment Script Pattern

All solutions follow this pattern:
1. **01-setup.sh**: Sets environment variables, enables APIs, displays configuration, and generates `.env` file
2. **02-0X-*.sh**: Sequential deployment scripts for infrastructure components
3. **99-project-cleanup.sh**: Deletes all created resources

Scripts use numbered prefixes to indicate execution order. Always run in sequence.

**Setup Script Behavior**:
- Exports all configuration variables to the current shell session
- Creates a timestamped `.env` file with all variables for persistence
- Displays organized configuration output grouped by category
- Enables all required GCP APIs
- For solutions with sensitive data (passwords, credentials), displays security warnings

### Testing Structure

Each solution has a `test/` directory with:
- Automated test scripts matching acceptance criteria
- `run-all-tests.sh` for running complete test suite
- README.md documenting test procedures

Tests assume deployment scripts have been run and environment variables are loaded.

### Environment Variable Management

**Initial Setup**:
```bash
# First time setup - creates .env file
source 01-setup.sh
```

**Restoring Environment**:
```bash
# Restore variables from previously generated .env file
source .env

# Or re-run setup (will regenerate random passwords/secrets)
source 01-setup.sh
```

**Important Considerations**:
- The `.env` file is created automatically by `01-setup.sh` in each solution directory
- Re-running `01-setup.sh` will regenerate random passwords/secrets (if applicable), which may break existing deployments
- To preserve existing configuration, use `source .env` instead of re-running the setup script
- The `.env` file contains the timestamp of when it was generated
- Each solution has its own `.env` file in its respective directory

## Important Notes

### GCP-Specific Considerations

- **Project ID**: All scripts expect `GOOGLE_CLOUD_PROJECT` environment variable to be set (automatically set in Cloud Shell)
- **API Enablement**: First-time setup enables required GCP APIs (can take 1-2 minutes)
- **Long-Running Operations**: 
  - Cloud SQL creation: ~10 minutes
  - MIG creation with instance templates: 3-5 minutes
  - Autoscaling triggers: 5-10 minutes after first load
- **Default Region/Zone**: Solutions default to `us-central1`/`us-central1-a`

### Worker Instance Debugging

To debug worker instances in bulk-processing solution:
```bash
# View instance console output
gcloud compute instances get-serial-port-output <instance-name> --zone=$ZONE

# SSH to running worker
gcloud compute ssh <instance-name> --zone=$ZONE

# Check startup script logs
sudo journalctl -u google-startup-scripts.service
```

### Load Testing

For bulk processing pipeline, use GNU `parallel` (from moreutils) to generate high load:
```bash
sudo apt-get install moreutils
parallel -j 50 bash -c "./ingest.sh gs://$INGEST_BUCKET" -- $(seq 1 1000 | xargs echo)
```

### Instance Template Updates

When modifying MIG configurations (scripts 07 and 08), you must:
1. Delete the existing MIG
2. Delete the instance template
3. Re-run the script with modifications

Updating in-place is not supported by these scripts.

## File Organization

```
cloudx-associate-gcp-devops/
├── tasks/                        # Task definitions and reference implementations
│   ├── bulk-processing/         # Python workers (unpack.py, transform.py)
│   ├── *.md                     # Task specifications
│   └── */requirements.txt       # Python dependencies
├── solutions/                    # Solution implementations
│   ├── basic-network/
│   ├── dynamic-serverless-website/
│   └── bulk-processing/
│       ├── 01-setup.sh          # Environment setup (source this)
│       ├── 02-08-*.sh           # Sequential deployment scripts
│       ├── 99-project-cleanup.sh # Resource cleanup
│       └── test/                # Automated tests
└── README.md                    # Repository overview
```

## Python Dependencies

Bulk processing workers require:
```
google-cloud-pubsub
google-cloud-storage
```

These are installed automatically via startup scripts when MIGs create instances.
