#!/bin/bash

# Test: SQL database has only private IP address

echo "=========================================="
echo "Test 3: Verify Cloud SQL has only private IP"
echo "=========================================="

# Get Cloud SQL instance details
echo "Checking Cloud SQL instance: $DB_INSTANCE_NAME"
echo ""

# Get IP addresses
SQL_IPS=$(gcloud sql instances describe $DB_INSTANCE_NAME --format="json" | grep -A 10 "ipAddresses")
PUBLIC_IP=$(gcloud sql instances describe $DB_INSTANCE_NAME --format="value(ipAddresses[0].ipAddress)" 2>/dev/null)
PRIVATE_IP=$(gcloud sql instances describe $DB_INSTANCE_NAME --format="value(ipAddresses.filter(type:PRIVATE).ipAddress)")

echo "SQL Instance IP Configuration:"
echo "$SQL_IPS"
echo ""

# Check if private IP exists
if [ -z "$PRIVATE_IP" ]; then
    echo "❌ FAILED: Cloud SQL instance does not have a private IP address"
    exit 1
fi

echo "Private IP: $PRIVATE_IP"

# Check that public IP is not configured
IP_CONFIG=$(gcloud sql instances describe $DB_INSTANCE_NAME --format="value(settings.ipConfiguration.ipv4Enabled)")

if [ "$IP_CONFIG" = "True" ]; then
    echo "❌ FAILED: Cloud SQL instance has public IP enabled"
    echo "Public IP: $PUBLIC_IP"
    exit 1
fi

echo ""
echo "✅ PASSED: Cloud SQL has only private IP address"
echo "   Private IP: $PRIVATE_IP"
echo "   Public IP: Not configured"
exit 0
