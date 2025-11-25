#!/bin/bash

set -e
BUCKET="$1"
TIMESTAMP="$(date +%s).$$"

WORKDIR=$(mktemp -d /tmp/data-ingest.XXXXXXX)
python3 generator.py "${WORKDIR}"
pushd "${WORKDIR}"
zip -q -r "${WORKDIR}.zip" .
gsutil cp "${WORKDIR}.zip" "${BUCKET}/${TIMESTAMP}.zip"
rm -fr "${WORKDIR}" "${WORKDIR}.zip"
echo DONE
