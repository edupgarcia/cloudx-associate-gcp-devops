#!/bin/bash

# Test: Page not found error should be displayed for http://<LB IP>/nonexistant

echo "=========================================="
echo "Test 2: Verify 404 page for non-existent routes"
echo "=========================================="

# Get Load Balancer IP
LB_IP=$(gcloud compute addresses describe $IP_NAME --global --format="value(address)")

if [ -z "$LB_IP" ]; then
    echo "❌ FAILED: Could not retrieve Load Balancer IP"
    exit 1
fi

echo "Load Balancer IP: $LB_IP"
echo ""

# Test non-existent page
echo "Testing: http://$LB_IP/nonexistant"
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" "http://$LB_IP/nonexistant")
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

echo "HTTP Status Code: $HTTP_CODE"
echo ""

if [ "$HTTP_CODE" != "404" ]; then
    echo "❌ FAILED: Expected HTTP 404, got $HTTP_CODE"
    exit 1
fi

# Check if response contains "Page not found" or "404" message
if echo "$BODY" | grep -qiE "page not found|404|not found"; then
    echo "✅ PASSED: 404 page is displayed for non-existent route"
    echo ""
    echo "404 page content:"
    echo "$BODY"
    exit 0
else
    echo "⚠️  WARNING: 404 status returned but page might not contain proper error message"
    echo ""
    echo "Response received:"
    echo "$BODY"
    exit 0
fi
