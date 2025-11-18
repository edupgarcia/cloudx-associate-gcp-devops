#!/bin/bash

# Create workstation without external IP
gcloud compute instances create workstation \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --subnet=$SUBNET_NAME \
    --no-address \
    --tags=internal \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --metadata enable-oslogin=TRUE

echo ''
echo 'Insert SSH keys in the machine'
echo 'gcloud compute scp -i ~/.ssh/id_rsa ~/.ssh/id_rsa.* edupgarcia_ti@:~/.ssh'/

