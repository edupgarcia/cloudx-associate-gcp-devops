#!/usr/bin/env bash

# 99-project-cleanup.sh
# Delete resources created by final task scripts

set -euo pipefail

if [[ -z "${PROJECT_ID:-}" ]]; then
  echo "ERROR: PROJECT_ID is not set. Run: source 01-setup.sh or source .env" >&2
  exit 1
fi

read -rp "This will delete GKE cluster, Cloud SQL, Redis, bucket, and other resources in project ${PROJECT_ID}. Continue? [y/N] " ANSWER
case "${ANSWER}" in
  [yY][eE][sS]|[yY]) ;;
  *) echo "Aborting cleanup."; exit 0;;
esac

set +e

# Nextcloud Helm release and nginx ingress
helm uninstall nextcloud -n default 2>/dev/null
helm uninstall nginx-ingress -n ingress-nginx 2>/dev/null
kubectl delete namespace ingress-nginx 2>/dev/null

# Redis
gcloud redis instances delete "${REDIS_INSTANCE_NAME}" \
  --project "${PROJECT_ID}" --region "${REDIS_REGION}" --quiet 2>/dev/null

# Cloud SQL
gcloud sql instances delete "${SQL_INSTANCE_NAME}" \
  --project "${PROJECT_ID}" --quiet 2>/dev/null

# GKE cluster
gcloud container clusters delete "${GKE_CLUSTER_NAME}" \
  --project "${PROJECT_ID}" --region "${GKE_CLUSTER_LOCATION}" --quiet 2>/dev/null

# Bucket
gcloud storage rm -r "gs://${NEXTCLOUD_BUCKET}" --quiet 2>/dev/null

# IAM service accounts
gcloud iam service-accounts delete "${GKE_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --project "${PROJECT_ID}" --quiet 2>/dev/null

gcloud iam service-accounts delete "${NEXTCLOUD_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --project "${PROJECT_ID}" --quiet 2>/dev/null

# Cloud NAT and router
gcloud compute routers nats delete "${NAT_NAME}" \
  --router "${CLOUD_ROUTER_NAME}" --region "${NAT_REGION}" \
  --project "${PROJECT_ID}" --quiet 2>/dev/null

gcloud compute routers delete "${CLOUD_ROUTER_NAME}" \
  --region "${NAT_REGION}" --project "${PROJECT_ID}" --quiet 2>/dev/null

# Private service range and VPC
gcloud compute addresses delete "${PRIVATE_SERVICE_CONNECT_RANGE_NAME}" \
  --region "${REGION}" --project "${PROJECT_ID}" --quiet 2>/dev/null

gcloud compute networks subnets delete "${SUBNET_NAME}" \
  --region "${SUBNET_REGION}" --project "${PROJECT_ID}" --quiet 2>/dev/null

gcloud compute networks delete "${NETWORK_NAME}" \
  --project "${PROJECT_ID}" --quiet 2>/dev/null

set -e

echo "Cleanup complete."