#!/usr/bin/env bash

# 05-gke-cluster.sh
# Create regional private GKE cluster with private nodes and public control plane

set -e

MASTER_AUTHORIZED_NETWORKS="${EXTERNAL_IP:-0.0.0.0/0}"

echo "Creating GKE cluster ${GKE_CLUSTER_NAME}... (this may take several minutes)"
gcloud container clusters create "${GKE_CLUSTER_NAME}" \
  --project "${PROJECT_ID}" \
  --region "${GKE_CLUSTER_LOCATION}" \
  --node-locations "${GKE_CLUSTER_ZONES}" \
  --num-nodes "${GKE_NODE_COUNT}" \
  --machine-type "${GKE_MACHINE_TYPE}" \
  --network "${NETWORK_NAME}" \
  --subnetwork "${SUBNET_NAME}" \
  --enable-ip-alias \
  --cluster-secondary-range-name "${GKE_PODS_RANGE_NAME}" \
  --services-secondary-range-name "${GKE_SERVICES_RANGE_NAME}" \
  --enable-private-nodes \
  --enable-master-authorized-networks \
  --master-authorized-networks "${MASTER_AUTHORIZED_NETWORKS}" \
  --enable-private-endpoint=false \
  --enable-shielded-nodes \
  --service-account "${GKE_SA_EMAIL}" \
  --workload-pool "${PROJECT_ID}.svc.id.goog" \
  --enable-autorepair \
  --enable-autoupgrade \
  --enable-dataplane-v2 \
  --master-ipv4-cidr "${GKE_MASTER_IPV4_CIDR}"

echo "Fetching cluster credentials..."
gcloud container clusters get-credentials "${GKE_CLUSTER_NAME}" \
  --project "${PROJECT_ID}" --region "${GKE_CLUSTER_LOCATION}"

echo "GKE cluster ready."
