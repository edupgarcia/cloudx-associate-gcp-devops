#!/bin/bash

# Master test runner for Bulk Processing solution

echo "=========================================="
echo "Bulk Processing - Test Suite"
echo "=========================================="
echo ""

# Check if environment variables are loaded
if [ -z "$PROJECT_ID" ] || [ -z "$INGEST_BUCKET" ] || [ -z "$UNPACK_MIG" ]; then
    echo "❌ ERROR: Environment variables not loaded"
    echo "Please run: source ../01-setup.sh"
    echo ""
    exit 1
fi

echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo "Zone: $ZONE"
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
run_test "./1-test-pipeline.sh"
run_test "./2-test-autoscaling.sh"

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
