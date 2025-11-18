#!/usr/bin/env python3
import json
import os
import sys
from google.cloud.pubsub import SubscriberClient, PublisherClient
from google.pubsub_v1.types import Encoding
from google.cloud import storage


def getEnvVar(var_name, def_value):
    result = def_value
    if var_name in os.environ and os.environ[var_name]:
        result = os.environ[var_name]
    return result

project_id = getEnvVar("PROJECT_ID", None)
if not project_id:
    print("PROJECT_ID environment variable is not set")
    sys.exit(1)

subscription_id = getEnvVar("SUBSCRIPTION", "data-unpack")
topic_id = getEnvVar("TOPIC", "data-transform")
destination_bucket = getEnvVar("BUCKET", f"{project_id}-transform")


def transformData(src_bucket_name, src_path, dst_bucket_name, dst_path):
    storage_client = storage.Client()
    src_bucket = storage_client.bucket(src_bucket_name)
    dst_bucket = storage_client.bucket(dst_bucket_name)
    temperature = "\"Sensor ID\",\"Timestamp\",\"Temperature\"\n"
    humidity = "\"Sensor ID\",\"Timestamp\",\"Humidity\"\n"
    pressure = "\"Sensor ID\",\"Timestamp\",\"Pressure\"\n"

    for blob in storage_client.list_blobs(src_bucket, prefix=src_path):
        data = json.loads(blob.download_as_string())
        temperature += f"\"{data['id']}\",{data['timestamp']}\",\"{data['temperature']}\"\n"
        humidity += f"\"{data['id']}\",\"{data['timestamp']}\",\"{data['humidity']}\"\n"
        pressure += f"\"{data['id']}\",\"{data['timestamp']}\",\"{data['pressure']}\"\n"
    blob = dst_bucket.blob(f"temperature/{dst_path}.csv")
    blob.upload_from_string(temperature)
    blob = dst_bucket.blob(f"humidity/{dst_path}.csv")
    blob.upload_from_string(humidity)
    blob = dst_bucket.blob(f"pressure/{dst_path}.csv")
    blob.upload_from_string(pressure)

    publisher_client = PublisherClient()
    topic_path = publisher_client.topic_path(project_id, topic_id)
    data = {"bucket": dst_bucket_name, "path": dst_path}
    data_str = json.dumps(data)
    data = data_str.encode("utf-8")
    future = publisher_client.publish(topic_path, data)
    print(f"Published message ID: {future.result()}")



def callback(message):
    data = json.loads(message.data)
    bucket = data["bucket"]
    path = data["path"]
    print(f"Transforming gs://{bucket}/{path} to gs://{destination_bucket}/{path}")
    transformData(bucket, path, destination_bucket, path)
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
