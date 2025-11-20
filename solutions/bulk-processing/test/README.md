# Bulk Processing - Test Suite

This directory contains automated tests to verify all acceptance criteria for the Bulk Processing solution.

## Prerequisites

Before running tests, ensure:
1. The solution has been fully deployed (all scripts 01-08 executed)
2. Environment variables are loaded: `source ../01-setup.sh`
3. Worker instances are running (check with `gcloud compute instances list`)

## Running Tests

### Run All Tests

Execute all acceptance criteria tests:
```bash
cd test
./run-all-tests.sh
```

### Run Individual Tests

Execute specific tests:
```bash
# Test 1: End-to-end pipeline functionality
./01-test-pipeline.sh

# Test 2: Autoscaling configuration
./02-test-autoscaling.sh

# Test 3: MIG configuration
./03-test-mig-configuration.sh
```

### Run Unit Tests

Run Python unit tests for MIG validation:
```bash
cd test
python3 test_mig_validation.py -v
```

## Test Coverage

### Test 1: Pipeline Functionality
**Acceptance Criterion**: Data ingestion will trigger data unpack and transformation.

Verifies:
- Test data can be ingested to ingest bucket
- ZIP files are unpacked to JSON files in unpack bucket
- JSON files are transformed to CSV files in transform bucket
- CSV files are organized by metric type (temperature, humidity, pressure)

**Note**: This test ingests one file and waits 50 seconds for processing. If buckets are empty, workers may need more time (workers process data within 2-5 minutes typically).

### Test 2: Autoscaling Configuration
**Acceptance Criterion**: Managed groups autoscale based on number of unprocessed messages in Pub/Sub subscriptions.

Verifies:
- Unpack MIG has autoscaler configured
- Transform MIG has autoscaler configured
- Min and max replica counts are set
- Current instance counts
- Pub/Sub subscription message counts
- Lists all running worker instances

### Test 3: MIG Configuration
**Acceptance Criterion**: MIGs are created with correct base instance names and zones.

Verifies:
- Unpack MIG has correct base instance name (`unpack-worker`)
- Transform MIG has correct base instance name (`transform-worker`)
- Unpack MIG is in the correct zone
- Transform MIG is in the correct zone

### Unit Tests: MIG Validation
Python unit tests that mock GCP API calls to validate MIG configuration logic.

Tests include:
1. **Unpack MIG base instance name validation** - Valid and invalid cases
2. **Transform MIG base instance name validation** - Valid and invalid cases
3. **Unpack MIG zone validation** - Valid and invalid cases
4. **Transform MIG zone validation** - Valid and invalid cases
5. **Error handling** - Non-existent MIG handling
6. **Helper functions** - Zone extraction and name format validation

Run with: `python3 test_mig_validation.py -v`

## Manual Testing

### Verify Pipeline End-to-End

1. Copy ingest scripts:
```bash
cp ../../../tasks/bulk-processing/ingest.sh .
cp ../../../tasks/bulk-processing/generator.py .
```

2. Ingest test data:
```bash
./ingest.sh gs://$INGEST_BUCKET
```

3. Monitor progress:
```bash
# Check buckets
watch -n 5 "gcloud storage ls gs://$INGEST_BUCKET/ | wc -l && gcloud storage ls gs://$UNPACK_BUCKET/**/*.json 2>/dev/null | wc -l && gcloud storage ls gs://$TRANSFORM_BUCKET/**/*.csv 2>/dev/null | wc -l"
```

### Test Autoscaling

1. Generate load (requires `moreutils` package):
```bash
sudo apt-get install moreutils
parallel -j 50 bash -c "./ingest.sh gs://$INGEST_BUCKET" -- $(seq 1 100 | xargs echo)
```

2. Watch instance scaling:
```bash
# Watch unpack workers scale up
watch -n 5 "gcloud compute instance-groups managed list-instances $UNPACK_MIG --zone=$ZONE"

# Watch transform workers scale up
watch -n 5 "gcloud compute instance-groups managed list-instances $TRANSFORM_MIG --zone=$ZONE"
```

3. Monitor Pub/Sub queues:
```bash
watch -n 5 "echo 'Ingest:' && gcloud pubsub subscriptions describe $INGEST_SUBSCRIPTION --format='value(numUnacknowledgedMessages)' && echo 'Unpack:' && gcloud pubsub subscriptions describe $UNPACK_SUBSCRIPTION --format='value(numUnacknowledgedMessages)' && echo 'Transform:' && gcloud pubsub subscriptions describe $TRANSFORM_SUBSCRIPTION --format='value(numUnacknowledgedMessages)'"
```

### Verify Transformed Data

Download and inspect CSV files:
```bash
# List CSV files
gcloud storage ls gs://$TRANSFORM_BUCKET/temperature/
gcloud storage ls gs://$TRANSFORM_BUCKET/humidity/
gcloud storage ls gs://$TRANSFORM_BUCKET/pressure/

# Download a sample file
gcloud storage cp gs://$TRANSFORM_BUCKET/temperature/$(gcloud storage ls gs://$TRANSFORM_BUCKET/temperature/ | head -1 | awk '{print $2}') /tmp/sample.csv

# View contents
cat /tmp/sample.csv
```

Expected CSV format:
```
"Sensor ID","Timestamp","Temperature"
"0","1700000000","25"
"1","1700000000","32"
...
```

## Troubleshooting

### No files in unpack/transform buckets
**Cause**: Workers need time to process, or workers may have crashed  
**Solution**: 
1. Wait 2-5 minutes for processing
2. Check worker logs: `gcloud compute instances get-serial-port-output <instance-name> --zone=$ZONE`
3. Verify workers are running: `gcloud compute instances list --filter="name~worker"`

### Autoscaling not working
**Cause**: Pub/Sub metrics may take time to populate  
**Solution**: 
1. Wait 5-10 minutes after first ingestion
2. Generate more load to trigger scaling
3. Check autoscaler status: `gcloud compute instance-groups managed describe $UNPACK_MIG --zone=$ZONE`

### Worker startup failures
**Cause**: Metadata encoding issues or dependency installation failures  
**Solution**:
1. SSH into a worker instance
2. Check startup script logs: `sudo journalctl -u google-startup-scripts.service`
3. Verify Python dependencies installed correctly

## Expected Behavior

**Normal Operation:**
- Minimum 1 instance per MIG when idle
- Scales up to 10 instances per MIG under load
- Target: 5 unacked messages per instance
- Processing time: ~30-60 seconds per ZIP file (100 JSON files)
- Scale-down occurs after queue is processed (5-10 minutes)
