# Nextcloud GCE Solution

This solution implements a production-ready, high-availability Nextcloud deployment on Google Cloud Platform with:

- **Filestore**: User files storage (NFS)
- **Cloud SQL MySQL**: Relational database with regional HA
- **Memorystore Redis**: Cache and session storage
- **Secret Manager**: Secure credentials storage
- **Cloud Scheduler**: Nextcloud cron job execution
- **Global HTTP(S) Load Balancer**: Internet-facing application access
- **Cloud Armor**: Protection from unauthorized access
- **Cloud Logging**: Application logs storage
- **Cloud Monitoring**: Uptime checks and alerting
- **Regional Managed Instance Group**: Multi-zone deployment for high availability

## Architecture

The solution provides:
- **High Availability**: Multi-zone instance deployment withstands single zone failures
- **Autoscaling**: Instance group scales based on CPU utilization (60% target)
- **Security**: Cloud Armor IP-based access control, SSL communication to Cloud SQL
- **Monitoring**: Uptime checks with alerting on application downtime
- **Logging**: Structured application logs sent to Cloud Logging
- **Shared Storage**: Filestore NFS for shared data across all instances

## Prerequisites

- Active GCP project with billing enabled
- Sufficient quotas for:
  - Compute Engine instances (e2-standard-2)
  - Cloud SQL (db-n1-standard-2)
  - Filestore (1TB Basic HDD)
  - Memorystore Redis (1GB Standard tier)
- `gcloud` CLI installed and authenticated

## Execution Order

Run the scripts in sequence:

```bash
# 1. Setup environment variables and enable APIs (MUST use source)
source 01-setup.sh

# 2. Create VPC network and subnet
./02-vpc.sh

# 3. Create firewall rules
./03-firewall.sh

# 4. Create VPC connector for Cloud Scheduler (takes ~2 minutes)
./04-vpc-connector.sh

# 5. Create Cloud SQL MySQL instance (takes ~10 minutes)
./05-cloudsql.sh

# 6. Create Memorystore Redis instance (takes ~5 minutes)
./06-redis.sh

# 7. Create Filestore instance (takes ~5 minutes)
./07-filestore.sh

# 8. Create secret in Secret Manager
./08-secret-manager.sh

# 9. Create instance template and managed instance group (takes ~5 minutes)
./09-instance-group.sh

# 10. Create load balancer with health checks
./10-load-balancer.sh

# 11. Update secret with load balancer IP (IMPORTANT)
export NEXTCLOUD_FQDN=$(gcloud compute addresses describe $IP_NAME --global --format="value(address)")
./08-secret-manager.sh

# 12. Apply Cloud Armor security policy
export EXTERNAL_IP="$(curl -s ifconfig.me)/32"
./11-cloud-armor.sh

# 13. Create Cloud Scheduler cron job
./12-scheduler.sh

# 14. Configure monitoring and alerting
./13-monitoring.sh
```

**Total deployment time**: ~30-40 minutes

## Important Notes

### Environment Variables

All configuration is stored in environment variables. After running `source 01-setup.sh`:
- Variables are exported to your current shell session
- Variables are saved to `.env` file for reference
- Passwords are auto-generated and saved in `.env`

**Keep the `.env` file secure!** It contains:
- Nextcloud admin password
- MySQL password
- Redis AUTH string

### Two-Step Secret Creation

The secret must be created twice:
1. First run (step 8): Creates secret without load balancer IP
2. Second run (step 11): Updates secret with load balancer IP as `NEXTCLOUD_FQDN`

This is necessary because:
- The load balancer IP doesn't exist before step 10
- Nextcloud needs the IP in its trusted domains configuration

### Startup Time

After creating the instance group:
- First instance takes ~5-10 minutes to fully start
- Subsequent instances take ~3-5 minutes
- Monitor progress: `gcloud compute instances list --filter="name~nextcloud"`

## Testing

### Access Nextcloud

After deployment is complete:

```bash
# Get load balancer IP
LB_IP=$(gcloud compute addresses describe $IP_NAME --global --format="value(address)")

# Access in browser
echo "http://$LB_IP"

# Login credentials
source 01-setup.sh
echo "Username: $NEXTCLOUD_USERNAME"
echo "Password: $NEXTCLOUD_PASSWORD"
```

Or retrieve from `.env` file:
```bash
cat .env | grep -E "NEXTCLOUD_USERNAME|NEXTCLOUD_PASSWORD"
```

### Verify Acceptance Criteria

**1. Login with admin credentials**
```bash
# Open in browser
echo "http://$(gcloud compute addresses describe $IP_NAME --global --format='value(address)')"

# Credentials from .env file
grep NEXTCLOUD .env
```

**2. Upload files**
- Login to Nextcloud web interface
- Click "+" icon → Upload file
- File should appear in file list

**3. Verify cron job is running**
- In Nextcloud: Settings → Administration → Basic Settings
- Under "Background jobs", check "Last job ran X seconds ago"
- Should show job ran within last 5 minutes

**4. Test Cloud Armor protection**
- Use VPN to connect from different IP address
- Access should be denied with 403 error
- Or temporarily remove your IP from policy:
  ```bash
  gcloud compute security-policies rules delete 1000 --security-policy=$SECURITY_POLICY_NAME
  # Access should now be blocked
  ```

**5. Test monitoring alert**
- Stop Cloud SQL instance:
  ```bash
  gcloud sql instances patch $SQL_INSTANCE_NAME --activation-policy=NEVER
  ```
- Wait 2-3 minutes for uptime check to fail
- Check alert status in Cloud Console → Monitoring → Alerting
- Restart database:
  ```bash
  gcloud sql instances patch $SQL_INSTANCE_NAME --activation-policy=ALWAYS
  ```

**6. Verify encrypted database communication**
- SSH into an instance:
  ```bash
  gcloud compute ssh $(gcloud compute instances list --filter="name~nextcloud" --format="value(name)" --limit=1) --tunnel-through-iap
  ```
- Capture traffic:
  ```bash
  sudo tcpdump -i any -n host 127.0.0.1 and port 3306 -A | head -100
  ```
- Traffic should be encrypted (no readable SQL queries)
- Cloud SQL Proxy uses SSL/TLS for all connections

**7. Test high availability (single zone failure)**
- List instances:
  ```bash
  gcloud compute instances list --filter="name~nextcloud"
  ```
- Delete one instance:
  ```bash
  INSTANCE=$(gcloud compute instances list --filter="name~nextcloud" --format="value(name)" --limit=1)
  ZONE=$(gcloud compute instances list --filter="name:$INSTANCE" --format="value(zone)")
  gcloud compute instances delete $INSTANCE --zone=$ZONE --quiet
  ```
- Application should remain accessible on load balancer IP
- Managed instance group will automatically recreate the deleted instance

## Monitoring

### View Application Logs

```bash
# View Nextcloud application logs
gcloud logging read "resource.type=gce_instance AND jsonPayload.message:nextcloud" --limit=50

# View instance startup logs
INSTANCE=$(gcloud compute instances list --filter="name~nextcloud" --format="value(name)" --limit=1)
ZONE=$(gcloud compute instances list --filter="name:$INSTANCE" --format="value(zone)")
gcloud compute instances get-serial-port-output $INSTANCE --zone=$ZONE | tail -100
```

### Check Uptime Status

```bash
# Check uptime check status
gcloud monitoring uptime list

# View uptime check results
gcloud monitoring uptime describe $UPTIME_CHECK_NAME
```

### Check Instance Health

```bash
# List all instances
gcloud compute instance-groups managed list-instances $INSTANCE_GROUP --region=$REGION

# Check backend service health
gcloud compute backend-services get-health $BACKEND_SERVICE_NAME --global
```

## Maintenance

### Update Nextcloud Configuration

To modify Nextcloud settings, SSH into an instance:

```bash
INSTANCE=$(gcloud compute instances list --filter="name~nextcloud" --format="value(name)" --limit=1)
gcloud compute ssh $INSTANCE --tunnel-through-iap

# Run occ commands as www-data user
cd /var/nextcloud/webroot
sudo -u www-data php occ <command>
```

### Rolling Updates

To update the instance template (e.g., new startup script):

```bash
# Create new template
gcloud compute instance-templates create nextcloud-template-v2 \
    --source-instance-template=$INSTANCE_TEMPLATE \
    --metadata-from-file=startup-script=startup-script.sh

# Start rolling update
gcloud compute instance-groups managed rolling-action start-update $INSTANCE_GROUP \
    --region=$REGION \
    --version=template=nextcloud-template-v2 \
    --max-unavailable=1
```

### Add More IP Addresses to Cloud Armor

```bash
# Add new allowed IP
gcloud compute security-policies rules create 1001 \
    --security-policy=$SECURITY_POLICY_NAME \
    --expression="inIpRange(origin.ip, 'X.X.X.X/32')" \
    --action=allow \
    --description="Allow from office IP"
```

### Manual Cron Execution

```bash
# Trigger scheduler job manually
gcloud scheduler jobs run $SCHEDULER_JOB_NAME --location=$REGION

# Or directly on an instance
INSTANCE=$(gcloud compute instances list --filter="name~nextcloud" --format="value(name)" --limit=1)
gcloud compute ssh $INSTANCE --tunnel-through-iap --command="cd /var/nextcloud/webroot && sudo -u www-data php cron.php"
```

## Troubleshooting

### Instances not starting

**Symptoms**: Instances show as running but health check fails

**Solutions**:
1. Check startup script execution:
   ```bash
   INSTANCE=$(gcloud compute instances list --filter="name~nextcloud" --format="value(name)" --limit=1)
   ZONE=$(gcloud compute instances list --filter="name:$INSTANCE" --format="value(zone)")
   gcloud compute instances get-serial-port-output $INSTANCE --zone=$ZONE | grep FINISHED
   ```
2. SSH and check Apache status:
   ```bash
   gcloud compute ssh $INSTANCE --tunnel-through-iap
   systemctl status apache2
   ```

### Cannot access Nextcloud

**Symptoms**: HTTP 403 error

**Causes**:
- Cloud Armor blocking your IP
- Nextcloud trusted domains not configured

**Solutions**:
1. Check your current IP matches allowed IP:
   ```bash
   curl -s ifconfig.me
   gcloud compute security-policies describe $SECURITY_POLICY_NAME
   ```
2. Temporarily disable Cloud Armor:
   ```bash
   gcloud compute backend-services update $BACKEND_SERVICE_NAME --no-security-policy --global
   ```
3. Check Nextcloud trusted domains:
   ```bash
   INSTANCE=$(gcloud compute instances list --filter="name~nextcloud" --format="value(name)" --limit=1)
   gcloud compute ssh $INSTANCE --tunnel-through-iap --command="cd /var/nextcloud/webroot && sudo -u www-data php occ config:system:get trusted_domains"
   ```

### Cron job not running

**Symptoms**: "Last job ran" shows hours or days ago

**Causes**:
- Cloud Scheduler job not created
- VPC connector not working
- Instances not accessible from scheduler

**Solutions**:
1. Check scheduler job status:
   ```bash
   gcloud scheduler jobs describe $SCHEDULER_JOB_NAME --location=$REGION
   ```
2. Manually trigger job:
   ```bash
   gcloud scheduler jobs run $SCHEDULER_JOB_NAME --location=$REGION
   ```
3. Check job execution history:
   ```bash
   gcloud logging read "resource.type=cloud_scheduler_job AND resource.labels.job_id=$SCHEDULER_JOB_NAME" --limit=10
   ```

### High database latency

**Symptoms**: Slow page loads, timeouts

**Causes**:
- Cloud SQL under-resourced
- Too many connections

**Solutions**:
1. Check Cloud SQL CPU/memory:
   ```bash
   gcloud sql instances describe $SQL_INSTANCE_NAME --format="value(settings.tier)"
   ```
2. Upgrade instance tier:
   ```bash
   gcloud sql instances patch $SQL_INSTANCE_NAME --tier=db-n1-standard-4
   ```

## Cleanup

To delete all resources:

```bash
source 01-setup.sh
./99-project-cleanup.sh
```

**Warning**: This will permanently delete:
- All Nextcloud data in Filestore
- All database data in Cloud SQL
- All instances and configurations

The script deletes resources in reverse order to handle dependencies correctly. Total cleanup time: ~15-20 minutes.

## Cost Estimation

Approximate monthly costs (us-central1 region):

| Resource | Specifications | Estimated Cost |
|----------|---------------|----------------|
| Compute Engine (3 instances) | e2-standard-2 (2 vCPU, 8GB RAM) | ~$150 |
| Cloud SQL MySQL | db-n1-standard-2, Regional HA | ~$250 |
| Filestore | 1TB Basic HDD | ~$200 |
| Memorystore Redis | 1GB Standard tier | ~$50 |
| Load Balancer | Global HTTP(S) LB | ~$20 |
| Cloud Nat | (if needed for egress) | ~$50 |
| Network Egress | Depends on usage | Variable |

**Total**: ~$720/month (excluding network egress)

To reduce costs:
- Use Cloud SQL `db-f1-micro` for testing (~$15/month)
- Use Filestore Basic SSD with smaller capacity
- Reduce instance group min size to 1
- Use preemptible instances (not recommended for production)

## Security Considerations

### Implemented Security Measures

1. **Network Isolation**
   - Instances have no public IP addresses
   - All services on private VPC network
   - Cloud NAT not deployed (not needed with proper IAM)

2. **Access Control**
   - Cloud Armor IP-based whitelisting
   - IAP for SSH access (no public SSH)
   - Secret Manager for credential storage

3. **Encryption**
   - SSL/TLS for Cloud SQL connections (via Cloud SQL Proxy)
   - Encryption at rest for Cloud SQL, Filestore
   - HTTPS recommended for production (add SSL certificate)

4. **Monitoring**
   - Application logs sent to Cloud Logging
   - Uptime checks with alerting
   - Backend service logging enabled

### Additional Security Recommendations

For production deployments:

1. **Enable HTTPS**
   ```bash
   # Create SSL certificate
   gcloud compute ssl-certificates create nextcloud-cert --domains=your-domain.com
   
   # Add HTTPS frontend
   gcloud compute target-https-proxies create nextcloud-https-proxy \
       --ssl-certificates=nextcloud-cert \
       --url-map=$URL_MAP_NAME
   ```

2. **Use Cloud CDN**
   ```bash
   gcloud compute backend-services update $BACKEND_SERVICE_NAME --enable-cdn --global
   ```

3. **Configure backup retention**
   ```bash
   gcloud sql instances patch $SQL_INSTANCE_NAME --backup-start-time=03:00 --retained-backups-count=7
   ```

4. **Enable audit logging**
   - Configure org-level logging policies
   - Monitor admin actions in Cloud Logging

5. **Use Cloud KMS for encryption keys**
   - Encrypt secrets with CMEK
   - Rotate keys periodically

## Architecture Decisions

### Why Managed Instance Group instead of Cloud Run?

- Nextcloud requires persistent connections and file locking
- Full control over Apache/PHP configuration
- Better for traditional LAMP stack applications
- Direct NFS mount to Filestore

### Why Filestore instead of Cloud Storage?

- Nextcloud requires POSIX filesystem
- File locking support essential for multi-instance deployment
- Better performance for small file operations
- Direct NFS mount simplifies deployment

### Why Regional MIG instead of Zonal?

- Provides high availability across zones
- Automatic instance redistribution
- Survives single zone failures
- Required for production SLA

### Why Cloud SQL Proxy instead of Private IP?

- Encrypted connections without manual SSL setup
- Automatic credential rotation
- Connection pooling and management
- Simpler firewall configuration
