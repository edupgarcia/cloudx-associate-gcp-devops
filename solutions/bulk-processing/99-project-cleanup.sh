#!/bin/bash

echo "=========================================="
echo "Cleaning up Bulk Processing resources"
echo "=========================================="
echo ""

# Delete managed instance groups
echo "Deleting managed instance groups..."
gcloud compute instance-groups managed delete $UNPACK_MIG --zone=$ZONE --quiet 2>/dev/null || echo "  Unpack MIG not found or already deleted"
gcloud compute instance-groups managed delete $TRANSFORM_MIG --zone=$ZONE --quiet 2>/dev/null || echo "  Transform MIG not found or already deleted"

# Delete instance templates
echo "Deleting instance templates..."
gcloud compute instance-templates delete $UNPACK_TEMPLATE --quiet 2>/dev/null || echo "  Unpack template not found or already deleted"
gcloud compute instance-templates delete $TRANSFORM_TEMPLATE --quiet 2>/dev/null || echo "  Transform template not found or already deleted"

# Delete Pub/Sub subscriptions
echo "Deleting Pub/Sub subscriptions..."
gcloud pubsub subscriptions delete $INGEST_SUBSCRIPTION --quiet 2>/dev/null || echo "  Ingest subscription not found or already deleted"
gcloud pubsub subscriptions delete $UNPACK_SUBSCRIPTION --quiet 2>/dev/null || echo "  Unpack subscription not found or already deleted"
gcloud pubsub subscriptions delete $TRANSFORM_SUBSCRIPTION --quiet 2>/dev/null || echo "  Transform subscription not found or already deleted"

# Delete Pub/Sub topics
echo "Deleting Pub/Sub topics..."
gcloud pubsub topics delete $INGEST_TOPIC --quiet 2>/dev/null || echo "  Ingest topic not found or already deleted"
gcloud pubsub topics delete $UNPACK_TOPIC --quiet 2>/dev/null || echo "  Unpack topic not found or already deleted"
gcloud pubsub topics delete $TRANSFORM_TOPIC --quiet 2>/dev/null || echo "  Transform topic not found or already deleted"

# Delete storage buckets (with all objects)
echo "Deleting storage buckets..."
gcloud storage rm -r gs://$INGEST_BUCKET --quiet 2>/dev/null || echo "  Ingest bucket not found or already deleted"
gcloud storage rm -r gs://$UNPACK_BUCKET --quiet 2>/dev/null || echo "  Unpack bucket not found or already deleted"
gcloud storage rm -r gs://$TRANSFORM_BUCKET --quiet 2>/dev/null || echo "  Transform bucket not found or already deleted"

echo ""
echo "=========================================="
echo "Cleanup complete!"
echo "=========================================="
