#!/bin/bash

# Get bastion external IP
BASTION_IP=$(gcloud compute instances describe bastion-host \
    --zone=$ZONE \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

# Test SSH connection (should work from VPN, fail from other locations)
ssh -o StrictHostKeyChecking=no $USER@$BASTION_IP

