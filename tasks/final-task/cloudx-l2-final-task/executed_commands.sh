#!/bin/bash

# Get the status of the nginx-ingress-controller pod
kubectl get pod nginx-ingress-nginx-ingress-controller-546fd88ddc-pnwth

# Describe the nginx-ingress-controller pod to get more details
kubectl describe pod nginx-ingress-nginx-ingress-controller-546fd88ddc-pnwth

# Attempt to pull the original nginx-ingress-controller image
docker pull docker.io/bitnami/nginx-ingress-controller:1.13.1-debian-12-r1

# Attempt to pull the nginx-ingress-controller image from the bitnamilegacy repository
docker pull docker.io/bitnamilegacy/nginx-ingress-controller:1.13.1-debian-12-r1

# List all Helm releases
helm list

# Show the values for the nginx-ingress-controller Helm chart
helm show values bitnami/nginx-ingress-controller --version 12.0.7

# Upgrade the nginx-ingress Helm release to use the bitnamilegacy repository
helm upgrade nginx-ingress bitnami/nginx-ingress-controller --version 12.0.7 --namespace default --set image.repository=bitnamilegacy/nginx-ingress-controller

# Get the status of the nginx-ingress-controller pod again
kubectl get pod nginx-ingress-nginx-ingress-controller-546fd88ddc-pnwth

# List all pods associated with the nginx-ingress Helm release
kubectl get pods -l app.kubernetes.io/instance=nginx-ingress

# Upgrade the nginx-ingress Helm release to use the bitnamilegacy repository for both the controller and the default backend
helm upgrade nginx-ingress bitnami/nginx-ingress-controller --version 12.0.7 --namespace default --set image.repository=bitnamilegacy/nginx-ingress-controller --set defaultBackend.image.repository=bitnamilegacy/nginx

# List all pods associated with the nginx-ingress Helm release again
kubectl get pods -l app.kubernetes.io/instance=nginx-ingress

# Get the status of the nextcloud pod
kubectl get pod nextcloud-6c76cd864-w5cwn

# Describe the nextcloud pod to get more details
kubectl describe pod nextcloud-6c76cd864-w5cwn

# List all Helm releases
helm list

# Show the values for the nextcloud Helm chart
helm show values bitnami/nextcloud --version 8.6.0

# Search for the nextcloud chart in the Helm repositories
helm search repo nextcloud

# Update the Helm repositories
helm repo update

# Show the values for the nextcloud Helm chart again
helm show values bitnami/nextcloud --version 8.6.0

# Pull the nextcloud Helm chart
helm pull bitnami/nextcloud --version 8.6.0

# Show the values for the nextcloud Helm chart, specifying the repository name explicitly
helm show values nextcloud/nextcloud --version 8.6.0

# Upgrade the nextcloud Helm release to use the correct image
helm upgrade nextcloud nextcloud/nextcloud --version 8.6.0 --namespace default --set image.registry=docker.io --set image.repository=nextcloud --set image.tag=28.0.0-apache

# List all pods associated with the nextcloud Helm release
kubectl get pods -l app.kubernetes.io/instance=nextcloud

# Describe the new nextcloud pod
kubectl describe pod nextcloud-764896bfd9-wxwt8

# List all pods associated with the nextcloud Helm release
kubectl get pods -l app.kubernetes.io/instance=nextcloud

# Describe the new nextcloud pod again
kubectl describe pod nextcloud-764896bfd9-wxwt8

# List all pods associated with the nextcloud Helm release
kubectl get pods -l app.kubernetes.io/instance=nextcloud

# Get the status of the original nextcloud pod
kubectl get pod nextcloud-6c76cd864-w5cwn

# Execute curl inside the nextcloud pod to test internal service resolution
kubectl exec nextcloud-764896bfd9-wxwt8 -- curl http://nextcloud.kube.home

# Get the Kubernetes Service associated with the nextcloud Helm release
kubectl get svc -l app.kubernetes.io/instance=nextcloud

# Execute curl inside the nextcloud pod to test internal service resolution using the correct service name and port
kubectl exec nextcloud-764896bfd9-wxwt8 -- curl http://nextcloud:8080

# Upgrade the nextcloud Helm release to update the NEXTCLOUD_TRUSTED_DOMAINS environment variable
helm upgrade nextcloud nextcloud/nextcloud --version 8.6.0 --namespace default --set image.registry=docker.io --set image.repository=nextcloud --set image.tag=28.0.0-apache --set nextcloud.trustedDomains[0]=nextcloud --set nextcloud.trustedDomains[1]=nextcloud.kube.home

# List all pods associated with the nextcloud Helm release
kubectl get pods -l app.kubernetes.io/instance=nextcloud

# Execute curl inside the new nextcloud pod to verify that the 'Access through untrusted domain' warning is gone
kubectl exec nextcloud-76547bc8cf-zjblk -- curl http://nextcloud:8080

# Execute a verbose curl command inside the new nextcloud pod to get more details on the response
kubectl exec nextcloud-76547bc8cf-zjblk -- curl -v http://nextcloud:8080

# Execute a curl command with the -L flag to follow redirects and get the content of the login page
kubectl exec nextcloud-76547bc8cf-zjblk -- curl -L http://nextcloud:8080

# Apply the nextcloud-ingress.yaml manifest to create the Ingress resource
kubectl apply -f nextcloud-ingress.yaml

# Get the external IP address of the NGINX Ingress Controller service
kubectl get svc -l app.kubernetes.io/name=nginx-ingress-controller

# Describe the nextcloud-ingress resource to check its status and configuration
kubectl describe ingress nextcloud-ingress

# Apply the updated nextcloud-ingress.yaml manifest to associate the Ingress with the NGINX Ingress Controller
kubectl apply -f nextcloud-ingress.yaml
