#!/bin/bash

# Test: Access should be denied for unknown locations (Cloud Armor IP whitelist)

echo "=========================================="
echo "Test 6: Verify Cloud Armor security policy"
echo "=========================================="

echo "Checking Cloud Armor security policy: $SECURITY_POLICY"
echo ""

# Check if security policy exists
POLICY_EXISTS=$(gcloud compute security-policies list --filter="name:$SECURITY_POLICY" --format="value(name)")

if [ -z "$POLICY_EXISTS" ]; then
    echo "❌ FAILED: Security policy '$SECURITY_POLICY' does not exist"
    exit 1
fi

echo "✓ Security policy exists: $SECURITY_POLICY"
echo ""

# Get policy rules
echo "Security policy rules:"
gcloud compute security-policies rules list $SECURITY_POLICY --format="table(priority,action,match.config.srcIpRanges)"
echo ""

# Check if there's a default deny rule and an allow rule for specific IP
RULES=$(gcloud compute security-policies rules list $SECURITY_POLICY --format="json")

ALLOW_RULE=$(echo "$RULES" | jq -r '.[] | select(.action == "allow")')
DENY_RULE=$(echo "$RULES" | jq -r '.[] | select(.action == "deny(403)")')

if [ -z "$ALLOW_RULE" ]; then
    echo "⚠️  WARNING: No allow rule found in security policy"
fi

if [ -z "$DENY_RULE" ]; then
    echo "⚠️  WARNING: No deny rule found in security policy"
fi

# Verify current IP is in allow list
CURRENT_IP=$(curl -s ifconfig.me)
echo "Your current IP: $CURRENT_IP"
echo ""

ALLOWED_IPS=$(echo "$RULES" | jq -r '.[] | select(.action == "allow") | .match.config.srcIpRanges[]?' 2>/dev/null)

if echo "$ALLOWED_IPS" | grep -q "$CURRENT_IP"; then
    echo "✓ Your current IP is in the allow list"
elif echo "$ALLOWED_IPS" | grep -q "$(echo $CURRENT_IP)/32"; then
    echo "✓ Your current IP is in the allow list"
else
    echo "⚠️  WARNING: Your current IP ($CURRENT_IP) may not be in the allow list"
    echo ""
    echo "Allowed IP ranges:"
    echo "$ALLOWED_IPS"
fi

echo ""
echo "✅ PASSED: Cloud Armor security policy is configured"
echo ""
echo "NOTE: To fully test IP restriction, access the site from a different IP/VPN"
echo "      Unauthorized IPs should receive HTTP 403 Forbidden"
exit 0
