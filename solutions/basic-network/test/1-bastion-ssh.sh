#!/bin/bash

# Test SSH connection (should work from VPN, fail from other locations)
gcloud compute ssh --project=$PROJECT_ID --zone=$ZONE bastion-host

