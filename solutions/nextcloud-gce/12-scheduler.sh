#!/bin/bash
set -e

LB_IP=$(gcloud compute addresses describe $IP_NAME --global --format="value(address)")

echo "Creating Cloud Scheduler job for Nextcloud cron..."
gcloud scheduler jobs create http $SCHEDULER_JOB_NAME \
    --location=$REGION \
    --schedule="$CRON_SCHEDULE" \
    --uri="http://${LB_IP}/cron.php" \
    --http-method=GET \
    --attempt-deadline=300s \
    --description="Nextcloud background cron job"

echo "Cloud Scheduler job created successfully."
echo ""
echo "Cron job will run: $CRON_SCHEDULE (every 5 minutes)"
echo ""
echo "To manually trigger the job:"
echo "  gcloud scheduler jobs run $SCHEDULER_JOB_NAME --location=$REGION"
