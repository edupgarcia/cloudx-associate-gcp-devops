#!/bin/bash

# Delete instances
gcloud compute instances delete bastion-host workstation --zone=$ZONE

# Delete firewall rules
gcloud compute firewall-rules delete allow-ssh-bastion allow-ssh-internal allow-internal deny-ssh-default

# Delete Cloud NAT and router
gcloud compute routers nats delete nat-config --router=nat-router --region=$REGION
gcloud compute routers delete nat-router --region=$REGION

# Delete subnet and network
gcloud compute networks subnets delete private-subnet --region=$REGION
gcloud compute networks delete custom-vpc

