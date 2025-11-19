#!/bin/bash

# Test: API endpoint returns database time

echo "=========================================="
echo "Test 5: Verify API endpoint functionality"
echo "=========================================="

# Get Load Balancer IP
LB_IP=$(gcloud compute addresses describe $IP_NAME --global --format="value(address)")

if [ -z "$LB_IP" ]; then
    echo "❌ FAILED: Could not retrieve Load Balancer IP"
    exit 1
fi

echo "Load Balancer IP: $LB_IP"
echo ""

# Test API endpoint
echo "Testing: http://$LB_IP/api/"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" "http://$LB_IP/api/")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

echo "HTTP Status Code: $HTTP_CODE"
echo ""

if [ "$HTTP_CODE" != "200" ]; then
    echo "❌ FAILED: Expected HTTP 200, got $HTTP_CODE"
    exit 1
fi

# Check if response contains a timestamp
if echo "$BODY" | grep -qE "[0-9]{4}-[0-9]{2}-[0-9]{2}|[0-9]{2}:[0-9]{2}:[0-9]{2}"; then
    echo "✅ PASSED: API endpoint returns database time"
    echo ""
    echo "Response:"
    echo "$BODY"
    exit 0
else
    echo "❌ FAILED: API response does not contain timestamp"
    echo ""
    echo "Response received:"
    echo "$BODY"
    exit 1
fi
