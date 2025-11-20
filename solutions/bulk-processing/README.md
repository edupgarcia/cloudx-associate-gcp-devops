# Bulk Processing Solution

This solution implements an event-driven data processing pipeline on GCP with:
- Cloud Storage buckets for ingest, unpack, and transform stages
- Pub/Sub topics and subscriptions for event-driven messaging
- Managed Instance Groups with autoscaling based on Pub/Sub queue depth
- Python workers for unpacking compressed data and transforming JSON to CSV

## Architecture

**Flow:**
1. **Ingest**: Compressed `.zip` files uploaded to ingest bucket → triggers Pub/Sub message
2. **Unpack**: Worker instances pull messages → download/extract ZIP → upload JSON files → publish to unpack topic
3. **Transform**: Worker instances pull messages → read JSON files → transform to CSV (temperature, humidity, pressure) → publish to transform topic

**Autoscaling**: Both managed instance groups scale based on number of unprocessed messages in their respective Pub/Sub subscriptions.

## Execution Order

Run the scripts in sequence:

```bash
# 1. Setup environment variables and enable APIs
source 01-setup.sh

# 2. Create storage buckets
./02-storage.sh

# 3. Create Pub/Sub topics and subscriptions
./03-pubsub.sh

# 4. Configure bucket notifications
./04-bucket-notifications.sh

# 5. Prepare unpack worker application
./05-unpack-worker.sh

# 6. Prepare transform worker application
./06-transform-worker.sh

# 7. Create unpack worker MIG (takes a few minutes)
./07-unpack-mig.sh

# 8. Create transform worker MIG (takes a few minutes)
./08-transform-mig.sh
```

## Testing

### Test Data Ingestion

Copy the ingest helper scripts:
```bash
cp ../../tasks/bulk-processing/ingest.sh .
cp ../../tasks/bulk-processing/generator.py .
```

Ingest a single test file:
```bash
./ingest.sh gs://$INGEST_BUCKET
```

Check the pipeline:
```bash
# Check ingest bucket (original ZIP files)
gcloud storage ls gs://$INGEST_BUCKET/

# Check unpack bucket (extracted JSON files)
gcloud storage ls gs://$UNPACK_BUCKET/

# Check transform bucket (CSV files organized by metric)
gcloud storage ls gs://$TRANSFORM_BUCKET/
gcloud storage ls gs://$TRANSFORM_BUCKET/temperature/
gcloud storage ls gs://$TRANSFORM_BUCKET/humidity/
gcloud storage ls gs://$TRANSFORM_BUCKET/pressure/
```

### Monitor Pub/Sub Subscriptions

```bash
# Check message counts
gcloud pubsub subscriptions describe $INGEST_SUBSCRIPTION --format="value(numUnacknowledgedMessages)"
gcloud pubsub subscriptions describe $UNPACK_SUBSCRIPTION --format="value(numUnacknowledgedMessages)"
gcloud pubsub subscriptions describe $TRANSFORM_SUBSCRIPTION --format="value(numUnacknowledgedMessages)"
```

### Monitor Instance Groups

```bash
# Check unpack workers
gcloud compute instance-groups managed list-instances $UNPACK_MIG --zone=$ZONE

# Check transform workers
gcloud compute instance-groups managed list-instances $TRANSFORM_MIG --zone=$ZONE

# View autoscaler status
gcloud compute instance-groups managed describe $UNPACK_MIG --zone=$ZONE
gcloud compute instance-groups managed describe $TRANSFORM_MIG --zone=$ZONE
```

### Load Testing (Optional)

For massive data ingestion, install `parallel` from `moreutils`:
```bash
sudo apt-get install moreutils
```

Generate 1000 files with 50 parallel jobs:
```bash
parallel -j 50 bash -c "./ingest.sh gs://$INGEST_BUCKET" -- $(seq 1 1000 | xargs echo)
```

Watch autoscaling in action:
```bash
watch -n 5 "gcloud compute instance-groups managed list-instances $UNPACK_MIG --zone=$ZONE"
```

## Acceptance Criteria

✓ Data ingestion triggers unpack and transformation (check content of `unpack` and `transform` buckets)  
✓ Managed groups autoscale based on number of unprocessed messages in Pub/Sub subscriptions  

## Cleanup

To delete all resources:
```bash
source 01-setup.sh
./99-project-cleanup.sh
```

## Architecture Details

- **Storage Buckets**: Three regional buckets for each pipeline stage
- **Pub/Sub Topics**: Three topics for inter-stage messaging
- **Pub/Sub Subscriptions**: Pull subscriptions with 600s ack deadline
- **Bucket Notifications**: Cloud Storage triggers Pub/Sub on OBJECT_FINALIZE events
- **Worker Instances**: e2-medium Debian 11 instances with Python 3
- **Managed Instance Groups**: Regional MIGs with autoscaling (1-10 instances)
- **Autoscaling**: Based on Pub/Sub queue depth (target: 5 messages/instance)
- **IAM**: Instances run with cloud-platform scope for full API access

## Data Format

**Ingest**: ZIP files containing 100 JSON sensor files  
**Unpack**: Individual JSON files with sensor data (id, temperature, humidity, pressure, timestamp)  
**Transform**: CSV files organized by metric type:
- `temperature/<timestamp>.csv` - Sensor ID, Timestamp, Temperature
- `humidity/<timestamp>.csv` - Sensor ID, Timestamp, Humidity  
- `pressure/<timestamp>.csv` - Sensor ID, Timestamp, Pressure
