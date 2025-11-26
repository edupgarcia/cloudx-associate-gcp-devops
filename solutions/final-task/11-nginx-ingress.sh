#!/usr/bin/env bash

# 11-nginx-ingress.sh
# Deploy Bitnami nginx-ingress-controller Helm chart

set -e

RELEASE_NAME="nginx-ingress"
NAMESPACE="ingress-nginx"

echo "Adding Bitnami Helm repo..."
helm repo add bitnami https://charts.bitnami.com/bitnami

echo "Updating Helm repos..."
helm repo update

echo "Creating namespace ${NAMESPACE} (if needed)..."
kubectl create namespace "${NAMESPACE}" 2>/dev/null || true

echo "Installing nginx-ingress-controller..."
helm upgrade --install "${RELEASE_NAME}" bitnami/nginx-ingress-controller -n "${NAMESPACE}"

echo "nginx-ingress-controller deployed."

echo "To get the external IP once provisioned:"
echo "  kubectl get svc -n ${NAMESPACE} -l app.kubernetes.io/name=nginx-ingress-controller"
