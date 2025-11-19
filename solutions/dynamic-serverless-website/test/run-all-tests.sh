#!/bin/bash

# Master test runner for Dynamic Serverless Website solution
# Runs all acceptance criteria tests

echo "=========================================="
echo "Dynamic Serverless Website - Test Suite"
echo "=========================================="
echo ""

# Check if environment variables are loaded
if [ -z "$PROJECT_ID" ] || [ -z "$IP_NAME" ] || [ -z "$DB_INSTANCE_NAME" ] || [ -z "$SECRET_NAME" ]; then
    echo "❌ ERROR: Environment variables not loaded"
    echo "Please run: source ../01-setup.sh"
    echo ""
    exit 1
fi

echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo ""

# Track test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run a test script
run_test() {
    local test_script=$1
    local test_name=$(basename "$test_script" .sh)
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo ""
    echo "=========================================="
    echo "Running: $test_name"
    echo "=========================================="
    
    if bash "$test_script"; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo "✅ $test_name: PASSED"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo "❌ $test_name: FAILED"
    fi
}

# Run all tests in order
run_test "./01-test-homepage.sh"
run_test "./02-test-404.sh"
run_test "./03-test-sql-private-ip.sh"
run_test "./04-test-secret-manager.sh"
run_test "./05-test-api-endpoint.sh"
run_test "./06-test-cloud-armor.sh"

# Print summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Total Tests:  $TOTAL_TESTS"
echo "Passed:       $PASSED_TESTS"
echo "Failed:       $FAILED_TESTS"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo "✅ All acceptance criteria tests passed!"
    exit 0
else
    echo "❌ Some tests failed. Please review the output above."
    exit 1
fi
