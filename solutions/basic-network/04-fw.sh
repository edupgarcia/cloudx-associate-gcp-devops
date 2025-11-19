#!/bin/bash

# Allow SSH from specific IP to bastion only
gcloud compute firewall-rules create allow-ssh-bastion \
    --network=$NETWORK_NAME \
    --allow=tcp:22 \
    --source-ranges=$SUBNET_RANGE \
    --target-tags=bastion \
    --priority=1000

# Allow SSH from bastion to internal instances
gcloud compute firewall-rules create allow-ssh-internal \
    --network=$NETWORK_NAME \
    --allow=tcp:22 \
    --source-tags=bastion \
    --target-tags=internal \
    --priority=1000

# Allow internal communication
gcloud compute firewall-rules create allow-internal \
    --network=$NETWORK_NAME \
    --allow=tcp,udp,icmp \
    --source-ranges=$SUBNET_RANGE \
    --priority=1000

# Deny all other SSH access (implicit, but explicit rule for clarity)
gcloud compute firewall-rules create deny-ssh-default \
    --network=$NETWORK_NAME \
    --action=deny \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --priority=65534

