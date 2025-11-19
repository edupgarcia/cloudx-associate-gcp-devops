#!/bin/bash

# Test: Database time is printed when opening http://<LB IP>/ in browser

echo "=========================================="
echo "Test 1: Verify homepage displays database time"
echo "=========================================="

# Get Load Balancer IP
LB_IP=$(gcloud compute addresses describe $IP_NAME --global --format="value(address)")

if [ -z "$LB_IP" ]; then
    echo "❌ FAILED: Could not retrieve Load Balancer IP"
    exit 1
fi

echo "Load Balancer IP: $LB_IP"
echo ""

# Test homepage
echo "Testing: http://$LB_IP/"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" "http://$LB_IP/")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

echo "HTTP Status Code: $HTTP_CODE"
echo ""

if [ "$HTTP_CODE" != "200" ]; then
    echo "❌ FAILED: Expected HTTP 200, got $HTTP_CODE"
    exit 1
fi

# Check if response contains a timestamp pattern (e.g., 2024-11-19 or similar date/time format)
if echo "$BODY" | grep -qE "[0-9]{4}-[0-9]{2}-[0-9]{2}|[0-9]{2}:[0-9]{2}:[0-9]{2}"; then
    echo "✅ PASSED: Homepage displays database time"
    echo ""
    echo "Response preview:"
    echo "$BODY" | head -20
    exit 0
else
    echo "❌ FAILED: Homepage does not contain timestamp"
    echo ""
    echo "Response received:"
    echo "$BODY"
    exit 1
fi
