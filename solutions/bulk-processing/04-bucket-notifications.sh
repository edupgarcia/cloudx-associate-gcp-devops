#!/bin/bash

# Configure Cloud Storage bucket notifications to trigger Pub/Sub messages

echo "Configuring bucket notifications..."

# Get the Pub/Sub service account for Cloud Storage
SERVICE_ACCOUNT=$(gcloud storage service-agent --project=$PROJECT_ID)

echo "Cloud Storage service account: $SERVICE_ACCOUNT"

# Grant the service account permission to publish to the topic
gcloud pubsub topics add-iam-policy-binding $INGEST_TOPIC \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/pubsub.publisher"

echo "✓ Granted Pub/Sub publisher role to service account"

# Create notification configuration for ingest bucket
gcloud storage buckets notifications create gs://$INGEST_BUCKET \
    --topic=$INGEST_TOPIC \
    --event-types=OBJECT_FINALIZE

echo "✓ Created notification for gs://$INGEST_BUCKET -> $INGEST_TOPIC"

echo ""
echo "Bucket notification configured successfully."
echo "Files uploaded to gs://$INGEST_BUCKET will trigger Pub/Sub messages."
