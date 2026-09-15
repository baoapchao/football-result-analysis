import os
import json
import boto3
from datetime import datetime, date, timezone
from zoneinfo import ZoneInfo

import common_functions

aws_credentials_path = os.path.join("config", "aws_credentials.json")

with open(aws_credentials_path, "r", encoding="utf-8") as f:
    aws_credentials = json.load(f)

s3 = boto3.client(
    "s3",
    aws_access_key_id=aws_credentials["aws_access_key_id"],
    aws_secret_access_key=aws_credentials["aws_secret_access_key"],
    region_name=aws_credentials["region_name"]
)

bucket = aws_credentials["bucket"]

def download_from_s3(BUCKET_NAME, PREFIX):
    paginator = s3.get_paginator("list_objects_v2")
    pages = paginator.paginate(Bucket=BUCKET_NAME, Prefix=PREFIX)
    os.makedirs(os.path.join("..", "data", PREFIX), exist_ok=True)
    latest_folder_modified_datetime = common_functions.get_latest_modified_datetime(os.path.join("..", "data", PREFIX))
    if latest_folder_modified_datetime is None:
        latest_folder_modified_datetime = datetime(1900, 1, 1, tzinfo=ZoneInfo("Asia/Ho_Chi_Minh"))
    for page in pages:
        for obj in page.get("Contents", []):
            key = obj["Key"]
            s3_last_modified = obj["LastModified"]
            if key.endswith(".json") and s3_last_modified > latest_folder_modified_datetime:
                local_path = os.path.join(PREFIX.rstrip("/"), os.path.basename(key))
                print(f"Downloading {key} -> {local_path}")
                s3.download_file(BUCKET_NAME, key, local_path)

    print(f"Downloading {PREFIX} Done")

download_from_s3("bao-better-bucket", "daily_fixtures")

download_from_s3("bao-better-bucket", "fixture_details/")

download_from_s3("bao-better-bucket", "fixture_details_half")
