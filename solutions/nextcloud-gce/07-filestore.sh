#!/bin/bash
set -e

echo "Creating Filestore instance (this takes ~5 minutes)..."
gcloud filestore instances create $FILESTORE_INSTANCE_NAME \
    --zone=$ZONE_A \
    --tier=BASIC_HDD \
    --file-share=name=$FILESTORE_SHARE_NAME,capacity=$FILESTORE_CAPACITY \
    --network=name=$NETWORK_NAME

echo "Filestore instance created successfully."
