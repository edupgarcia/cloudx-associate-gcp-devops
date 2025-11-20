#!/bin/bash

# Create Pub/Sub topics and subscriptions for the data pipeline

echo "Creating Pub/Sub topics..."

# Create ingest topic
gcloud pubsub topics create $INGEST_TOPIC
echo "✓ Created topic: $INGEST_TOPIC"

# Create unpack topic
gcloud pubsub topics create $UNPACK_TOPIC
echo "✓ Created topic: $UNPACK_TOPIC"

# Create transform topic
gcloud pubsub topics create $TRANSFORM_TOPIC
echo "✓ Created topic: $TRANSFORM_TOPIC"

echo ""
echo "Creating Pub/Sub subscriptions..."

# Create ingest subscription
gcloud pubsub subscriptions create $INGEST_SUBSCRIPTION \
    --topic=$INGEST_TOPIC \
    --ack-deadline=600

echo "✓ Created subscription: $INGEST_SUBSCRIPTION"

# Create unpack subscription
gcloud pubsub subscriptions create $UNPACK_SUBSCRIPTION \
    --topic=$UNPACK_TOPIC \
    --ack-deadline=600

echo "✓ Created subscription: $UNPACK_SUBSCRIPTION"

# Create transform subscription
gcloud pubsub subscriptions create $TRANSFORM_SUBSCRIPTION \
    --topic=$TRANSFORM_TOPIC \
    --ack-deadline=600

echo "✓ Created subscription: $TRANSFORM_SUBSCRIPTION"

echo ""
echo "All Pub/Sub topics and subscriptions created successfully."
