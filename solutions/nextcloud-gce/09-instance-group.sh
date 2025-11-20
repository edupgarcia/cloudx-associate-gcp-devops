#!/bin/bash
set -e

echo "Creating instance template..."
gcloud compute instance-templates create $INSTANCE_TEMPLATE \
    --machine-type=$MACHINE_TYPE \
    --image-family=$IMAGE_FAMILY \
    --image-project=$IMAGE_PROJECT \
    --boot-disk-size=$DISK_SIZE \
    --boot-disk-type=pd-balanced \
    --network=$NETWORK_NAME \
    --subnet=$SUBNET_NAME \
    --no-address \
    --tags=nextcloud-server \
    --scopes=cloud-platform \
    --metadata=secret-id=$SECRET_ID,secret-version=$SECRET_VERSION \
    --metadata-from-file=startup-script=startup-script.sh

echo "Creating managed instance group..."
gcloud compute instance-groups managed create $INSTANCE_GROUP \
    --template=$INSTANCE_TEMPLATE \
    --size=$MIN_INSTANCES \
    --zones=$ZONE_A,$ZONE_B,$ZONE_C \
    --instance-redistribution-type=NONE \
    --target-distribution-shape=BALANCED

echo "Configuring autoscaling..."
gcloud compute instance-groups managed set-autoscaling $INSTANCE_GROUP \
    --region=$REGION \
    --min-num-replicas=$MIN_INSTANCES \
    --max-num-replicas=$MAX_INSTANCES \
    --target-cpu-utilization=0.6 \
    --cool-down-period=60

echo "Configuring named port for load balancer..."
gcloud compute instance-groups managed set-named-ports $INSTANCE_GROUP \
    --region=$REGION \
    --named-ports=http:80

echo "Instance group created successfully."
