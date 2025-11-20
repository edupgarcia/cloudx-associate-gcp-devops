#!/bin/bash

# Prepare and upload unpack worker application

echo "Preparing unpack worker application..."

# Create temporary directory for worker files
WORKER_DIR=$(mktemp -d)

# Copy worker files
cp ../../tasks/bulk-processing/unpack.py $WORKER_DIR/
cp ../../tasks/bulk-processing/requirements.txt $WORKER_DIR/

# Create startup script
cat > $WORKER_DIR/startup.sh << 'EOF'
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

# Download worker files from metadata
curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/worker-script > unpack.py
curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/requirements > requirements.txt

# Install Python dependencies
pip3 install -r requirements.txt

# Set environment variables
export PROJECT_ID=$PROJECT_ID
export SUBSCRIPTION=$SUBSCRIPTION
export TOPIC=$TOPIC
export BUCKET=$BUCKET

# Run worker in background with auto-restart
while true; do
    echo "Starting unpack worker..."
    python3 unpack.py || echo "Worker crashed, restarting in 5 seconds..."
    sleep 5
done
EOF

chmod +x $WORKER_DIR/startup.sh

# Upload files to temporary bucket for distribution
echo "Uploading worker files to gs://$INGEST_BUCKET/workers/..."
gcloud storage cp $WORKER_DIR/unpack.py gs://$INGEST_BUCKET/workers/unpack.py
gcloud storage cp $WORKER_DIR/requirements.txt gs://$INGEST_BUCKET/workers/requirements.txt
gcloud storage cp $WORKER_DIR/startup.sh gs://$INGEST_BUCKET/workers/unpack-startup.sh

# Cleanup
rm -rf $WORKER_DIR

echo "✓ Unpack worker application prepared"
echo ""
echo "Worker files available at: gs://$INGEST_BUCKET/workers/"
