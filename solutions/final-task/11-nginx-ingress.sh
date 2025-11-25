#!/usr/bin/env bash

# 11-nginx-ingress.sh
# Deploy Bitnami nginx-ingress-controller Helm chart

set -euo pipefail

# Ensure kubeconfig is pointing at the GKE cluster created earlier
if ! kubectl config current-context >/dev/null 2>&1; then
  echo "ERROR: No Kubernetes context set. Run 05-gke-cluster.sh first." >&2
  exit 1
fi

# Add Bitnami repo
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Install or upgrade nginx-ingress-controller
RELEASE_NAME="nginx-ingress"
NAMESPACE="ingress-nginx"

kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1 || kubectl create namespace "${NAMESPACE}"

if helm status "${RELEASE_NAME}" -n "${NAMESPACE}" >/dev/null 2>&1; then
  echo "Upgrading existing nginx-ingress release..."
  helm upgrade "${RELEASE_NAME}" bitnami/nginx-ingress-controller -n "${NAMESPACE}"
else
  echo "Installing nginx-ingress release..."
  helm install "${RELEASE_NAME}" bitnami/nginx-ingress-controller -n "${NAMESPACE}"
fi

echo "nginx-ingress-controller deployed."

echo "To get the external IP once provisioned:"
echo "  kubectl get svc -n ${NAMESPACE} -l app.kubernetes.io/name=nginx-ingress-controller"