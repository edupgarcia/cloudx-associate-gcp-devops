#!/bin/bash

# Create instance template and managed instance group for unpack workers

echo "Creating unpack worker instance template..."

# Read worker files
UNPACK_SCRIPT=$(gcloud storage cat gs://$INGEST_BUCKET/workers/unpack.py | base64 -w 0)
REQUIREMENTS=$(gcloud storage cat gs://$INGEST_BUCKET/workers/requirements.txt | base64 -w 0)

# Create startup script
cat > /tmp/unpack-startup.sh << 'EOFSTARTUP'
#!/bin/bash
set -e

# Install Python and pip
apt-get update
apt-get install -y python3 python3-pip zip unzip

# Get metadata
PROJECT_ID=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/project-id)
SUBSCRIPTION=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/subscription)
TOPIC=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/topic)
BUCKET=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/bucket)

# Create working directory
mkdir -p /opt/worker
cd /opt/worker

# Download and decode worker files
echo "$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/worker-script)" | base64 -d > unpack.py
echo "$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/requirements)" | base64 -d > requirements.txt

# Install Python dependencies
pip3 install -r requirements.txt

# Set environment variables
export PROJECT_ID=$PROJECT_ID
export SUBSCRIPTION=$SUBSCRIPTION
export TOPIC=$TOPIC
export BUCKET=$BUCKET

# Run worker with auto-restart
while true; do
    echo "Starting unpack worker..."
    python3 unpack.py || echo "Worker crashed, restarting in 5 seconds..."
    sleep 5
done
EOFSTARTUP

# Create instance template
gcloud compute instance-templates create $UNPACK_TEMPLATE \
    --machine-type=$MACHINE_TYPE \
    --image-family=$IMAGE_FAMILY \
    --image-project=$IMAGE_PROJECT \
    --scopes=cloud-platform \
    --metadata-from-file=startup-script=/tmp/unpack-startup.sh \
    --metadata=subscription=$INGEST_SUBSCRIPTION,topic=$UNPACK_TOPIC,bucket=$UNPACK_BUCKET,worker-script=$UNPACK_SCRIPT,requirements=$REQUIREMENTS \
    --tags=worker

echo "✓ Created instance template: $UNPACK_TEMPLATE"

# Create managed instance group
gcloud compute instance-groups managed create $UNPACK_MIG \
    --template=$UNPACK_TEMPLATE \
    --size=$MIN_INSTANCES \
    --zone=$ZONE

echo "✓ Created managed instance group: $UNPACK_MIG"

# Configure autoscaling based on Pub/Sub queue depth
gcloud compute instance-groups managed set-autoscaling $UNPACK_MIG \
    --zone=$ZONE \
    --min-num-replicas=$MIN_INSTANCES \
    --max-num-replicas=$MAX_INSTANCES \
    --stackdriver-metric-filter="resource.type=pubsub_subscription AND resource.labels.subscription_id=$INGEST_SUBSCRIPTION" \
    --stackdriver-metric-utilization-target=$TARGET_QUEUE_DEPTH \
    --stackdriver-metric-single-instance-assignment=$TARGET_QUEUE_DEPTH

echo "✓ Configured autoscaling for $UNPACK_MIG"
echo "  Min instances: $MIN_INSTANCES"
echo "  Max instances: $MAX_INSTANCES"
echo "  Target queue depth: $TARGET_QUEUE_DEPTH messages per instance"

# Cleanup
rm /tmp/unpack-startup.sh

echo ""
echo "Unpack worker MIG created successfully."
