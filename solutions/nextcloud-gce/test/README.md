# Nextcloud GCE - Test Suite

This directory contains automated tests to verify the Nextcloud deployment on Google Compute Engine.

## Prerequisites

Before running tests, ensure:
1. The solution has been fully deployed (all scripts 01-13 executed)
2. Environment variables are loaded: `source ../01-setup.sh` or `source ../.env`

## Running Tests

### Run Unit Tests

Run Python unit tests for uptime check validation:
```bash
cd test
python3 test_uptime_check.py -v
```

## Test Coverage

### Unit Tests: Uptime Check Configuration

Python unit tests that mock GCP API calls to validate uptime check configuration.

**Tests validate that:**
1. The uptime check is created with the correct display name
2. The uptime check is created with the correct host
3. The uptime check is created with the correct project ID label
4. The uptime check is configured with the correct monitoring period
5. The uptime check is configured with the correct path and port

**Test Classes:**

#### TestUptimeCheckConfiguration
Main test suite validating uptime check configuration:
- `test_uptime_check_display_name` - Verifies display name is "Nextcloud Uptime Check"
- `test_uptime_check_host` - Verifies host IP is correctly set
- `test_uptime_check_project_id_label` - Verifies project_id label is set
- `test_uptime_check_monitoring_period` - Verifies period is "60s" (1 minute)
- `test_uptime_check_path_and_port` - Verifies path is "/" and port is 80
- `test_uptime_check_timeout` - Verifies timeout is "10s"
- `test_uptime_check_not_found` - Tests error handling for non-existent uptime checks

#### TestUptimeCheckValidationHelpers
Helper validation tests for format and range validation:
- `test_validate_display_name_format` - Validates display name format rules
- `test_validate_ip_address_format` - Validates IP address format (xxx.xxx.xxx.xxx)
- `test_validate_period_format` - Validates period format (e.g., "60s", "300s")
- `test_validate_path_format` - Validates HTTP path format (must start with "/")
- `test_validate_port_range` - Validates port range (1-65535)

#### TestUptimeCheckFullConfiguration
Complete configuration validation:
- `test_complete_uptime_check_configuration` - Validates all required fields are present and correct

Run with: `python3 test_uptime_check.py -v`

## Manual Testing

### Verify Uptime Check

Check that the uptime check was created:
```bash
gcloud monitoring uptime list --format="table(displayName,monitoredResource.labels.host)"
```

Get detailed uptime check configuration:
```bash
gcloud monitoring uptime describe "Nextcloud Uptime Check" --format=json
```

Expected output includes:
```json
{
  "displayName": "Nextcloud Uptime Check",
  "monitoredResource": {
    "type": "uptime_url",
    "labels": {
      "host": "<LOAD_BALANCER_IP>",
      "project_id": "<YOUR_PROJECT_ID>"
    }
  },
  "httpCheck": {
    "path": "/",
    "port": 80
  },
  "period": "60s",
  "timeout": "10s"
}
```

### Verify Alert Policy

List alert policies:
```bash
gcloud alpha monitoring policies list --format="table(displayName,enabled)"
```

Get detailed alert policy configuration:
```bash
gcloud alpha monitoring policies list --filter="displayName='Nextcloud Application Down'" --format=json
```

### Monitor Uptime Check Results

View uptime check results in Cloud Console:
1. Go to Cloud Console > Monitoring > Uptime checks
2. Click on "Nextcloud Uptime Check"
3. View the check status and history

### Test Uptime Check Manually

Verify the check URL is accessible:
```bash
LB_IP=$(gcloud compute addresses describe $IP_NAME --global --format="value(address)")
curl -I http://$LB_IP/
```

Expected response: HTTP 200 OK

## Troubleshooting

### Uptime check not found
**Cause**: Monitoring script (13-monitoring.sh) may not have run successfully  
**Solution**: 
1. Re-run the monitoring script: `./13-monitoring.sh`
2. Verify the load balancer IP exists: `gcloud compute addresses list`

### Alert policy creation failed
**Cause**: UPTIME_CHECK_NAME variable may not be set correctly  
**Solution**: 
1. Check environment variables: `echo $UPTIME_CHECK_NAME`
2. Re-source setup script: `source 01-setup.sh`
3. Re-run monitoring script: `./13-monitoring.sh`

### Uptime check showing down
**Cause**: Load balancer or backend service may not be healthy  
**Solution**: 
1. Check load balancer status: `gcloud compute forwarding-rules list`
2. Check backend service health: `gcloud compute backend-services get-health $BACKEND_SERVICE_NAME --global`
3. Verify instances are running: `gcloud compute instance-groups managed list-instances $INSTANCE_GROUP --zone=$ZONE_A`

## Expected Behavior

**Normal Operation:**
- Uptime check runs every 60 seconds (1 minute)
- Check timeout is 10 seconds
- Monitors HTTP endpoint at http://<LB_IP>/
- Alert triggers when check fails (more than 1 failure in 60 seconds)
- Alert auto-closes after 30 minutes (1800s) of successful checks
