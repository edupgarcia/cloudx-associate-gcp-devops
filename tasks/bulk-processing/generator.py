#!/usr/bin/env python3
import sys
import json
import os
from datetime import datetime, timedelta, timezone
from random import random

def generateSensorData(sensor_id):
    data = {}
    data["id"] = sensor_id
    data["temperature"] = round(random() * 40, 0)
    data["humidity"] = round(random() * 100, 0)
    data["pressure"] = round(random() * 100 + 950, 0)
    return data

def main():
    if len(sys.argv) > 1:
        destination = sys.argv[1]
    else:
        destination = "."
    if not os.path.exists(destination) and os.path.isdir(destination):
        print("Destination directory not exist or not a directory: {}".format(destination))
        sys.exit(1)
    
    timestamp = datetime.utcnow().strftime("%s")
    for i in range(100):
        data = generateSensorData(i)
        data["timestamp"] = timestamp
        f = open(os.path.join(destination, "sensor{}.json".format(i)), "w")
        f.write(json.dumps(data))
        f.close()

if __name__ == "__main__":
    main()
