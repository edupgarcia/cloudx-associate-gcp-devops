#!/bin/bash

# Test: Managed Instance Groups are created with correct base instance names and zones

echo "=================================================="
echo "Test 3: Verify MIG configuration"
echo "=================================================="
echo ""

# Test 1: Check unpack MIG base instance name
echo "1. Checking unpack MIG base instance name..."
UNPACK_BASE_NAME=$(gcloud compute instance-groups managed describe $UNPACK_MIG \
    --zone=$ZONE \
    --format="value(baseInstanceName)")

if [ "$UNPACK_BASE_NAME" != "unpack-worker" ]; then
    echo "   ❌ FAILED: Expected base instance name 'unpack-worker', got '$UNPACK_BASE_NAME'"
    exit 1
fi

echo "   ✓ Unpack MIG has correct base instance name: $UNPACK_BASE_NAME"
echo ""

# Test 2: Check transform MIG base instance name
echo "2. Checking transform MIG base instance name..."
TRANSFORM_BASE_NAME=$(gcloud compute instance-groups managed describe $TRANSFORM_MIG \
    --zone=$ZONE \
    --format="value(baseInstanceName)")

if [ "$TRANSFORM_BASE_NAME" != "transform-worker" ]; then
    echo "   ❌ FAILED: Expected base instance name 'transform-worker', got '$TRANSFORM_BASE_NAME'"
    exit 1
fi

echo "   ✓ Transform MIG has correct base instance name: $TRANSFORM_BASE_NAME"
echo ""

# Test 3: Check unpack MIG zone
echo "3. Checking unpack MIG zone..."
UNPACK_ZONE=$(gcloud compute instance-groups managed describe $UNPACK_MIG \
    --zone=$ZONE \
    --format="value(zone)")

# Extract zone name from full URL (e.g., https://www.googleapis.com/compute/v1/projects/PROJECT/zones/ZONE)
UNPACK_ZONE_NAME=$(basename $UNPACK_ZONE)

if [ "$UNPACK_ZONE_NAME" != "$ZONE" ]; then
    echo "   ❌ FAILED: Expected zone '$ZONE', got '$UNPACK_ZONE_NAME'"
    exit 1
fi

echo "   ✓ Unpack MIG is in correct zone: $UNPACK_ZONE_NAME"
echo ""

# Test 4: Check transform MIG zone
echo "4. Checking transform MIG zone..."
TRANSFORM_ZONE=$(gcloud compute instance-groups managed describe $TRANSFORM_MIG \
    --zone=$ZONE \
    --format="value(zone)")

# Extract zone name from full URL
TRANSFORM_ZONE_NAME=$(basename $TRANSFORM_ZONE)

if [ "$TRANSFORM_ZONE_NAME" != "$ZONE" ]; then
    echo "   ❌ FAILED: Expected zone '$ZONE', got '$TRANSFORM_ZONE_NAME'"
    exit 1
fi

echo "   ✓ Transform MIG is in correct zone: $TRANSFORM_ZONE_NAME"
echo ""

# Summary
echo "✅ PASSED: All MIG configuration tests passed"
echo ""
echo "Summary:"
echo "  - Unpack MIG base instance name: $UNPACK_BASE_NAME"
echo "  - Transform MIG base instance name: $TRANSFORM_BASE_NAME"
echo "  - Unpack MIG zone: $UNPACK_ZONE_NAME"
echo "  - Transform MIG zone: $TRANSFORM_ZONE_NAME"
exit 0
