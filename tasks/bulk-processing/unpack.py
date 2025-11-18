#!/usr/bin/env python3
import json
import os
import sys
import tempfile
from google.cloud.pubsub import SubscriberClient, PublisherClient
from google.pubsub_v1.types import Encoding
from google.cloud import storage
from zipfile import ZipFile
from pathlib import Path

def getEnvVar(var_name, def_value):
    result = def_value
    if var_name in os.environ and os.environ[var_name]:
        result = os.environ[var_name]
    return result

project_id = getEnvVar("PROJECT_ID", None)
if not project_id:
    print("PROJECT_ID environment variable is not set")
    sys.exit(1)

subscription_id = getEnvVar("SUBSCRIPTION", "data-ingest")
topic_id = getEnvVar("TOPIC", "data-unpack")
destination_bucket = getEnvVar("BUCKET", f"{project_id}-unpack")


def unpackArchive(src_bucket_name, src_object_name, dst_bucket_name, dst_object_prefix):
    print(f"Extracting gs://{src_bucket_name}/{src_object_name} to gs://{dst_bucket_name}/{dst_object_prefix}")
    storage_client = storage.Client()
    src_bucket = storage_client.bucket(src_bucket_name)
    blob = src_bucket.blob(src_object_name)
    with tempfile.TemporaryDirectory() as tmpdir:
        local_file = os.path.join(tmpdir, "data.zip")
        blob.download_to_filename(local_file)
        with ZipFile(local_file) as archive:
            archive.extractall(path=tmpdir)
        os.remove(local_file)
        dst_bucket = storage_client.bucket(dst_bucket_name)
        for datafile in os.listdir(tmpdir):
            if os.path.isfile(os.path.join(tmpdir,datafile)):
                if dst_object_prefix:
                    dst_object_name = f"{dst_object_prefix}/{datafile}"
                else:
                    dst_object_name = datafile
                blob = dst_bucket.blob(dst_object_name)
                blob.upload_from_filename(os.path.join(tmpdir, datafile))
    publisher_client = PublisherClient()
    topic_path = publisher_client.topic_path(project_id, topic_id)
    data = {"bucket": destination_bucket, "path": dst_object_prefix}
    data_str = json.dumps(data)
    data = data_str.encode("utf-8")
    future = publisher_client.publish(topic_path, data)
    print(f"Published message ID: {future.result()}")



def callback(message):
    if message.attributes.get("eventType") == "OBJECT_FINALIZE":
        source_bucket = message.attributes.get("bucketId")
        source_object = message.attributes.get("objectId")
        destination_prefix = Path(source_object).stem
        unpackArchive(source_bucket, source_object, destination_bucket, destination_prefix)
    message.ack()


def main():
    subscriber = SubscriberClient()
    subscription_path = subscriber.subscription_path(project_id, subscription_id)
    streaming_pull_future = subscriber.subscribe(subscription_path, callback=callback)
    print(f"Listening for messages on {subscription_path}..\n")
    with subscriber:
        streaming_pull_future.result()

if __name__ == "__main__":
    main()
