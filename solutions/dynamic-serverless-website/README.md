# Dynamic Serverless Website Solution

This solution implements a serverless architecture on GCP with:
- Cloud Storage for static content
- Cloud Functions for dynamic API requests
- Cloud SQL (MySQL) with private IP only
- Secret Manager for credentials
- Load Balancer with path-based routing
- Cloud Armor for IP-based access control

## Execution Order

Run the scripts in sequence:

```bash
# 1. Setup environment variables and enable APIs
source 1-setup.sh

# Update your external IP
export EXTERNAL_IP="$(curl -s ifconfig.me)/32"

# 2. Create VPC and private service connection
./2-vpc.sh

# 3. Create VPC connector for Cloud Functions
./3-vpc-connector.sh

# 4. Create Cloud SQL instance with private IP (takes ~10 minutes)
./4-cloudsql.sh

# 5. Create secret in Secret Manager
./5-secret-manager.sh

# 6. Create Cloud Storage bucket and upload static files
./6-storage-bucket.sh

# 7. Deploy Cloud Function
./7-cloud-function.sh

# 8. Create Load Balancer with routing rules
./8-load-balancer.sh

# 9. Apply Cloud Armor security policy
./9-cloud-armor.sh
```

## Testing

After deployment, get the load balancer IP:
```bash
LB_IP=$(gcloud compute addresses describe $IP_NAME --global --format="value(address)")
echo "Access your application at: http://$LB_IP"
```

Test the endpoints:
- `http://<LB_IP>/` - Should display database time
- `http://<LB_IP>/nonexistent` - Should show 404 page
- `http://<LB_IP>/api/` - Should return database time (direct API call)

## Acceptance Criteria

✓ Database time is printed when opening `http://<LB IP>/`  
✓ `Page not found` error for `http://<LB IP>/nonexistant`  
✓ SQL database has only private IP address  
✓ Database credentials are stored in Secret Manager  
✓ Access denied for unknown locations (test with VPN from different IP)  

## Cleanup

To delete all resources:
```bash
source 1-setup.sh
./99-project-cleanup.sh
```

## Architecture

- **VPC**: Custom VPC with private subnet for Cloud SQL
- **Cloud SQL**: MySQL instance with private IP only
- **VPC Connector**: Allows Cloud Function to access Cloud SQL via private IP
- **Secret Manager**: Stores database credentials securely
- **Cloud Storage**: Hosts static HTML files
- **Cloud Function**: Handles `/api/*` requests and queries database
- **Load Balancer**: Routes `/*` to storage bucket, `/api/*` to function
- **Cloud Armor**: Restricts access to specific IP addresses
