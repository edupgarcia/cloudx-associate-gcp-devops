#!/bin/bash
set -e

LB_IP=$(gcloud compute addresses describe $IP_NAME --global --format="value(address)")

echo "Creating uptime check..."
gcloud monitoring uptime create $UPTIME_CHECK_NAME \
    --resource-type=uptime-url \
    --host="$LB_IP" \
    --path="/" \
    --port=80 \
    --check-interval=60s \
    --timeout=10s \
    --display-name="Nextcloud Uptime Check"

echo "Waiting for uptime check to be created..."
sleep 10

echo "Creating alert policy for uptime check..."
cat > /tmp/alert-policy.json <<EOF
{
  "displayName": "Nextcloud Application Down",
  "conditions": [{
    "displayName": "Uptime check failure",
    "conditionThreshold": {
      "filter": "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND resource.type=\"uptime_url\" AND metric.label.check_id=\"${UPTIME_CHECK_NAME}\"",
      "comparison": "COMPARISON_GT",
      "thresholdValue": 1,
      "duration": "60s",
      "aggregations": [{
        "alignmentPeriod": "60s",
        "perSeriesAligner": "ALIGN_NEXT_OLDER",
        "crossSeriesReducer": "REDUCE_COUNT_FALSE",
        "groupByFields": []
      }]
    }
  }],
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": [],
  "alertStrategy": {
    "autoClose": "1800s"
  }
}
EOF

gcloud alpha monitoring policies create --policy-from-file=/tmp/alert-policy.json

rm /tmp/alert-policy.json

echo "Monitoring and alerting configured successfully."
echo ""
echo "Uptime check: $UPTIME_CHECK_NAME"
echo "Check target: http://$LB_IP/"
echo ""
echo "To add notification channels (email, SMS, etc.):"
echo "  1. Go to Cloud Console > Monitoring > Alerting > Edit Policy"
echo "  2. Add notification channels to the alert policy"
