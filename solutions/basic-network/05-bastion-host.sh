#!/bin/bash

# Create bastion host with external IP
gcloud compute instances create bastion-host \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --subnet=$SUBNET_NAME \
    --tags=bastion \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --metadata enable-oslogin=TRUE

