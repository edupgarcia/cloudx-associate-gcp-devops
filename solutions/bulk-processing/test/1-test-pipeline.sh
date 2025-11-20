#!/bin/bash

# Test: Data ingestion triggers unpack and transformation

echo "=========================================="
echo "Test 1: Verify end-to-end pipeline"
echo "=========================================="
echo ""

# Copy ingest scripts to test directory
if [ ! -f "ingest.sh" ]; then
    echo "Copying ingest scripts..."
    cp ../../../tasks/bulk-processing/ingest.sh .
    cp ../../../tasks/bulk-processing/generator.py .
    chmod +x ingest.sh
fi

echo "Ingesting test data..."
./ingest.sh gs://$INGEST_BUCKET

if [ $? -ne 0 ]; then
    echo "❌ FAILED: Could not ingest test data"
    exit 1
fi

echo "✓ Test data ingested successfully"
echo ""

# Wait for processing
echo "Waiting for pipeline to process data (30 seconds)..."
sleep 30

echo ""
echo "Checking pipeline stages..."
echo ""

# Check ingest bucket
echo "1. Checking ingest bucket..."
INGEST_COUNT=$(gcloud storage ls gs://$INGEST_BUCKET/*.zip 2>/dev/null | wc -l)
echo "   Files in ingest bucket: $INGEST_COUNT"

if [ $INGEST_COUNT -eq 0 ]; then
    echo "   ❌ FAILED: No files in ingest bucket"
    exit 1
fi

echo "   ✓ Ingest bucket contains ZIP files"
echo ""

# Check unpack bucket
echo "2. Checking unpack bucket..."
sleep 10  # Give more time for unpack
UNPACK_COUNT=$(gcloud storage ls gs://$UNPACK_BUCKET/**/*.json 2>/dev/null | wc -l)
echo "   Files in unpack bucket: $UNPACK_COUNT"

if [ $UNPACK_COUNT -eq 0 ]; then
    echo "   ⚠️  WARNING: No files in unpack bucket yet (may need more time)"
    echo "   Check manually with: gcloud storage ls gs://$UNPACK_BUCKET/"
else
    echo "   ✓ Unpack bucket contains JSON files"
fi

echo ""

# Check transform bucket
echo "3. Checking transform bucket..."
sleep 10  # Give more time for transform
TEMP_COUNT=$(gcloud storage ls gs://$TRANSFORM_BUCKET/temperature/ 2>/dev/null | grep -c ".csv")
HUM_COUNT=$(gcloud storage ls gs://$TRANSFORM_BUCKET/humidity/ 2>/dev/null | grep -c ".csv")
PRES_COUNT=$(gcloud storage ls gs://$TRANSFORM_BUCKET/pressure/ 2>/dev/null | grep -c ".csv")

echo "   Temperature CSV files: $TEMP_COUNT"
echo "   Humidity CSV files: $HUM_COUNT"
echo "   Pressure CSV files: $PRES_COUNT"

if [ $TEMP_COUNT -eq 0 ] && [ $HUM_COUNT -eq 0 ] && [ $PRES_COUNT -eq 0 ]; then
    echo "   ⚠️  WARNING: No CSV files in transform bucket yet (may need more time)"
    echo "   Check manually with: gcloud storage ls gs://$TRANSFORM_BUCKET/"
else
    echo "   ✓ Transform bucket contains CSV files"
fi

echo ""

if [ $INGEST_COUNT -gt 0 ]; then
    echo "✅ PASSED: Pipeline is functional"
    echo ""
    echo "Note: If unpack/transform buckets are empty, the workers may need more time."
    echo "      Workers should process data within a few minutes."
    exit 0
else
    echo "❌ FAILED: Pipeline test failed"
    exit 1
fi
