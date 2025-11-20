#!/bin/bash
set -e

echo "Fetching service endpoints..."
SQL_CONNECTION="${PROJECT_ID}:${REGION}:${SQL_INSTANCE_NAME}"
REDIS_HOST=$(gcloud redis instances describe $REDIS_INSTANCE_NAME --region=$REGION --format="value(host)")
REDIS_PORT=$(gcloud redis instances describe $REDIS_INSTANCE_NAME --region=$REGION --format="value(port)")
NFS_HOST=$(gcloud filestore instances describe $FILESTORE_INSTANCE_NAME --zone=$ZONE_A --format="value(networks[0].ipAddresses[0])")
NFS_SHARE="/${FILESTORE_SHARE_NAME}"

# Get LB IP if it exists, otherwise leave empty
if gcloud compute addresses describe $IP_NAME --global &>/dev/null; then
    NEXTCLOUD_FQDN=$(gcloud compute addresses describe $IP_NAME --global --format="value(address)")
else
    NEXTCLOUD_FQDN=""
fi

echo "Creating secret content..."
cat > /tmp/nextcloud-secret.json <<EOF
{
    "nextcloud": {
        "username": "${NEXTCLOUD_USERNAME}",
        "password": "${NEXTCLOUD_PASSWORD}",
        "fqdn": "${NEXTCLOUD_FQDN}"
    },
    "mysql": {
        "connection": "${SQL_CONNECTION}",
        "username": "${SQL_USERNAME}",
        "password": "${SQL_PASSWORD}"
    },
    "redis": {
        "host": "${REDIS_HOST}",
        "port": ${REDIS_PORT},
        "auth": "${REDIS_AUTH}"
    },
    "nfs": {
        "host": "${NFS_HOST}",
        "share": "${NFS_SHARE}"
    }
}
EOF

echo "Creating secret in Secret Manager..."
if gcloud secrets describe $SECRET_ID &>/dev/null; then
    echo "Secret already exists, creating new version..."
    gcloud secrets versions add $SECRET_ID --data-file=/tmp/nextcloud-secret.json
else
    gcloud secrets create $SECRET_ID --data-file=/tmp/nextcloud-secret.json
fi

rm /tmp/nextcloud-secret.json

echo "Secret created successfully."
echo ""
echo "Credentials (save these securely):"
echo "  Nextcloud Admin Username: ${NEXTCLOUD_USERNAME}"
echo "  Nextcloud Admin Password: ${NEXTCLOUD_PASSWORD}"
echo "  MySQL Username: ${SQL_USERNAME}"
echo "  MySQL Password: ${SQL_PASSWORD}"
echo "  Redis AUTH: ${REDIS_AUTH}"
