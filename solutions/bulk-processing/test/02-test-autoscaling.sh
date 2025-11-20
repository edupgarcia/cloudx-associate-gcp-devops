#!/bin/bash

# Test: Managed groups autoscale based on Pub/Sub subscription messages

echo "=========================================="
echo "Test 2: Verify autoscaling configuration"
echo "=========================================="
echo ""

# Check unpack MIG autoscaling
echo "1. Checking unpack worker autoscaling..."
UNPACK_AUTOSCALER=$(gcloud compute instance-groups managed describe $UNPACK_MIG --zone=$ZONE --format="value(autoscaler)")

if [ -z "$UNPACK_AUTOSCALER" ]; then
    echo "   ❌ FAILED: No autoscaler configured for $UNPACK_MIG"
    exit 1
fi

echo "   ✓ Autoscaler configured: $UNPACK_AUTOSCALER"

# Get autoscaler details
UNPACK_MIN=$(gcloud compute instance-groups managed describe $UNPACK_MIG --zone=$ZONE --format="value(autoscaler.autoscalingPolicy.minNumReplicas)")
UNPACK_MAX=$(gcloud compute instance-groups managed describe $UNPACK_MIG --zone=$ZONE --format="value(autoscaler.autoscalingPolicy.maxNumReplicas)")
UNPACK_CURRENT=$(gcloud compute instance-groups managed describe $UNPACK_MIG --zone=$ZONE --format="value(targetSize)")

echo "   Min replicas: $UNPACK_MIN"
echo "   Max replicas: $UNPACK_MAX"
echo "   Current size: $UNPACK_CURRENT"

echo ""

# Check transform MIG autoscaling
echo "2. Checking transform worker autoscaling..."
TRANSFORM_AUTOSCALER=$(gcloud compute instance-groups managed describe $TRANSFORM_MIG --zone=$ZONE --format="value(autoscaler)")

if [ -z "$TRANSFORM_AUTOSCALER" ]; then
    echo "   ❌ FAILED: No autoscaler configured for $TRANSFORM_MIG"
    exit 1
fi

echo "   ✓ Autoscaler configured: $TRANSFORM_AUTOSCALER"

# Get autoscaler details
TRANSFORM_MIN=$(gcloud compute instance-groups managed describe $TRANSFORM_MIG --zone=$ZONE --format="value(autoscaler.autoscalingPolicy.minNumReplicas)")
TRANSFORM_MAX=$(gcloud compute instance-groups managed describe $TRANSFORM_MIG --zone=$ZONE --format="value(autoscaler.autoscalingPolicy.maxNumReplicas)")
TRANSFORM_CURRENT=$(gcloud compute instance-groups managed describe $TRANSFORM_MIG --zone=$ZONE --format="value(targetSize)")

echo "   Min replicas: $TRANSFORM_MIN"
echo "   Max replicas: $TRANSFORM_MAX"
echo "   Current size: $TRANSFORM_CURRENT"

echo ""

# Check Pub/Sub queue depths
echo "3. Checking Pub/Sub subscription status..."
INGEST_MSGS=$(gcloud pubsub subscriptions describe $INGEST_SUBSCRIPTION --format="value(numUnacknowledgedMessages)" 2>/dev/null || echo "0")
UNPACK_MSGS=$(gcloud pubsub subscriptions describe $UNPACK_SUBSCRIPTION --format="value(numUnacknowledgedMessages)" 2>/dev/null || echo "0")
TRANSFORM_MSGS=$(gcloud pubsub subscriptions describe $TRANSFORM_SUBSCRIPTION --format="value(numUnacknowledgedMessages)" 2>/dev/null || echo "0")

echo "   Ingest subscription unacked messages: $INGEST_MSGS"
echo "   Unpack subscription unacked messages: $UNPACK_MSGS"
echo "   Transform subscription unacked messages: $TRANSFORM_MSGS"

echo ""

# List current instances
echo "4. Current worker instances..."
echo ""
echo "   Unpack workers:"
gcloud compute instance-groups managed list-instances $UNPACK_MIG --zone=$ZONE --format="table(instance,status)"

echo ""
echo "   Transform workers:"
gcloud compute instance-groups managed list-instances $TRANSFORM_MIG --zone=$ZONE --format="table(instance,status)"

echo ""
echo "✅ PASSED: Autoscaling is configured for both MIGs"
echo ""
echo "To test autoscaling in action:"
echo "  1. Generate load: parallel -j 50 bash -c \"./ingest.sh gs://\$INGEST_BUCKET\" -- \$(seq 1 100 | xargs echo)"
echo "  2. Watch scaling: watch -n 5 \"gcloud compute instance-groups managed list-instances \$UNPACK_MIG --zone=\$ZONE\""
exit 0
