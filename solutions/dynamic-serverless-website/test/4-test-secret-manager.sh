#!/bin/bash

# Test: Database credentials are stored in Secret Manager

echo "=========================================="
echo "Test 4: Verify credentials in Secret Manager"
echo "=========================================="

echo "Checking secret: $SECRET_NAME"
echo ""

# Check if secret exists
SECRET_EXISTS=$(gcloud secrets list --filter="name:$SECRET_NAME" --format="value(name)")

if [ -z "$SECRET_EXISTS" ]; then
    echo "❌ FAILED: Secret '$SECRET_NAME' does not exist in Secret Manager"
    exit 1
fi

echo "✓ Secret exists: $SECRET_NAME"

# Get the secret value
SECRET_VALUE=$(gcloud secrets versions access latest --secret="$SECRET_NAME" 2>/dev/null)

if [ -z "$SECRET_VALUE" ]; then
    echo "❌ FAILED: Could not access secret value"
    exit 1
fi

echo "✓ Secret is accessible"
echo ""

# Validate JSON format
if ! echo "$SECRET_VALUE" | jq . > /dev/null 2>&1; then
    echo "❌ FAILED: Secret is not valid JSON"
    exit 1
fi

echo "✓ Secret is valid JSON"

# Check required fields
HOST=$(echo "$SECRET_VALUE" | jq -r '.host // empty')
USERNAME=$(echo "$SECRET_VALUE" | jq -r '.username // empty')
PASSWORD=$(echo "$SECRET_VALUE" | jq -r '.password // empty')

echo ""
echo "Secret contents:"
echo "  - host: ${HOST:-(not set)}"
echo "  - username: ${USERNAME:-(not set)}"
echo "  - password: ${PASSWORD:+[REDACTED]}"
echo ""

if [ -z "$HOST" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "❌ FAILED: Secret is missing required fields (host, username, password)"
    exit 1
fi

echo "✅ PASSED: Database credentials are properly stored in Secret Manager"
echo "   - All required fields present (host, username, password)"
exit 0
