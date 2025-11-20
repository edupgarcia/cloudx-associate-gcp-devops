#!/bin/bash

# Create instance template and managed instance group for transform workers

echo "Creating transform worker instance template..."

# Read worker files
TRANSFORM_SCRIPT=$(gcloud storage cat gs://$INGEST_BUCKET/workers/transform.py | base64 -w 0)
REQUIREMENTS=$(gcloud storage cat gs://$INGEST_BUCKET/workers/requirements.txt | base64 -w 0)

# Create startup script
cat > /tmp/transform-startup.sh << 'EOFSTARTUP'
#!/bin/bash
set -e

# Install Python and pip
apt-get update
apt-get install -y python3 python3-pip

# Get metadata
PROJECT_ID=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/project/project-id)
SUBSCRIPTION=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/subscription)
TOPIC=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/topic)
BUCKET=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/bucket)

# Create working directory
mkdir -p /opt/worker
cd /opt/worker

# Download and decode worker files
echo "$(curl -s -H 'Metadata-Flavor: Google' http://metadata.google.internal/computeMetadata/v1/instance/attributes/worker-script)" | base64 -d > transform.py
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
    echo "Starting transform worker..."
    python3 transform.py || echo "Worker crashed, restarting in 5 seconds..."
    sleep 5
done
EOFSTARTUP

# Create instance template
gcloud compute instance-templates create $TRANSFORM_TEMPLATE \
    --machine-type=$MACHINE_TYPE \
    --image-family=$IMAGE_FAMILY \
    --image-project=$IMAGE_PROJECT \
    --scopes=cloud-platform \
    --metadata-from-file=startup-script=/tmp/transform-startup.sh \
    --metadata=subscription=$UNPACK_SUBSCRIPTION,topic=$TRANSFORM_TOPIC,bucket=$TRANSFORM_BUCKET,worker-script=$TRANSFORM_SCRIPT,requirements=$REQUIREMENTS \
    --tags=worker

echo "✓ Created instance template: $TRANSFORM_TEMPLATE"

# Create managed instance group
gcloud compute instance-groups managed create $TRANSFORM_MIG \
    --zone=$ZONE \
    --template=$TRANSFORM_TEMPLATE \
    --base-instance-name=transform-worker \
    --size=$MIN_INSTANCES

echo "✓ Created managed instance group: $TRANSFORM_MIG"

# Configure autoscaling based on Pub/Sub queue depth
gcloud compute instance-groups managed set-autoscaling $TRANSFORM_MIG \
    --zone=$ZONE \
    --min-num-replicas=$MIN_INSTANCES \
    --max-num-replicas=$MAX_INSTANCES \
    --stackdriver-metric-filter="resource.type=pubsub_subscription AND resource.labels.subscription_id=$UNPACK_SUBSCRIPTION" \
    --stackdriver-metric-utilization-target=$TARGET_QUEUE_DEPTH \
    --stackdriver-metric-single-instance-assignment=$TARGET_QUEUE_DEPTH

echo "✓ Configured autoscaling for $TRANSFORM_MIG"
echo "  Min instances: $MIN_INSTANCES"
echo "  Max instances: $MAX_INSTANCES"
echo "  Target queue depth: $TARGET_QUEUE_DEPTH messages per instance"

# Cleanup
rm /tmp/transform-startup.sh

echo ""
echo "Transform worker MIG created successfully."
