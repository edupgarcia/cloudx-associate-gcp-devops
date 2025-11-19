# Dynamic Serverless Website - Test Suite

This directory contains automated tests to verify all acceptance criteria for the Dynamic Serverless Website solution.

## Prerequisites

Before running tests, ensure:
1. The solution has been fully deployed (all scripts 01-09 executed)
2. Environment variables are loaded: `source ../01-setup.sh`

## Running Tests

### Run All Tests

Execute all acceptance criteria tests:
```bash
cd test
./run-all-tests.sh
```

### Run Individual Tests

Execute specific tests:
```bash
# Test 1: Homepage displays database time
./1-test-homepage.sh

# Test 2: 404 page for non-existent routes
./2-test-404.sh

# Test 3: Cloud SQL has only private IP
./3-test-sql-private-ip.sh

# Test 4: Database credentials in Secret Manager
./4-test-secret-manager.sh

# Test 5: API endpoint returns database time
./5-test-api-endpoint.sh

# Test 6: Cloud Armor security policy configured
./6-test-cloud-armor.sh
```

## Test Coverage

### Test 1: Homepage Database Time
**Acceptance Criterion**: Database time is printed when opening `http://<LB IP>/` in browser.

Verifies:
- Load balancer IP is accessible
- Homepage returns HTTP 200
- Response contains timestamp from database

### Test 2: 404 Page
**Acceptance Criterion**: `Page not found` error should be displayed for `http://<LB IP>/nonexistant`.

Verifies:
- Non-existent routes return HTTP 404
- Custom 404 page is displayed

### Test 3: SQL Private IP Only
**Acceptance Criterion**: SQL database has only private IP address.

Verifies:
- Cloud SQL instance has a private IP address
- Public IP (ipv4) is NOT enabled
- Instance is accessible only via VPC

### Test 4: Secret Manager
**Acceptance Criterion**: Database credentials are stored in Secret Manager.

Verifies:
- Secret exists in Secret Manager
- Secret is valid JSON format
- Required fields present: host, username, password

### Test 5: API Endpoint
**Acceptance Criterion**: API endpoint returns database time.

Verifies:
- `/api/` endpoint is accessible
- Returns HTTP 200
- Response contains database timestamp

### Test 6: Cloud Armor IP Restriction
**Acceptance Criterion**: Access to `http://<LB IP>/` or `http://<LB IP>/api/` should be denied for unknown locations.

Verifies:
- Cloud Armor security policy exists
- Policy has deny and allow rules configured
- Current IP is in the allow list

**Note**: To fully test IP restriction, access the site from a different IP address or VPN. Unauthorized IPs should receive HTTP 403 Forbidden.

## Expected Output

Successful test run:
```
==========================================
Dynamic Serverless Website - Test Suite
==========================================

Project ID: your-project-id
Region: us-central1

...

==========================================
Test Summary
==========================================
Total Tests:  6
Passed:       6
Failed:       0

✅ All acceptance criteria tests passed!
```

## Troubleshooting

### Environment Variables Not Loaded
```
❌ ERROR: Environment variables not loaded
Please run: source ../01-setup.sh
```
**Solution**: Run `source ../01-setup.sh` before executing tests

### Load Balancer IP Not Found
**Solution**: Ensure script `08-load-balancer.sh` completed successfully

### Cloud SQL Instance Not Found
**Solution**: Ensure script `04-cloudsql.sh` completed successfully (takes ~10 minutes)

### Secret Not Found
**Solution**: Ensure script `05-secret-manager.sh` completed successfully

### HTTP 403 Forbidden
**Solution**: Your IP address may have changed. Update with:
```bash
export EXTERNAL_IP="$(curl -s ifconfig.me)/32"
```
Then re-run `09-cloud-armor.sh` to update the security policy.
