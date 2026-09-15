import json
import os
import requests
import time 
from datetime import date, datetime, timedelta
from zoneinfo import ZoneInfo

import boto3
import json

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

leagues = {39 #Premier League
            , 135 #Serie A
            , 140 #La Liga
            , 2 #UEFA Champions League
            , 3 #UEFA Europa League
            , 40 #Championship
            , 61 #Ligue 1
            , 78 #Bundesliga
            }

def get_latest_modified_datetime(folder_path):
    HANOI_TZ = ZoneInfo("Asia/Ho_Chi_Minh")
    latest_time = None
    for root, _, files in os.walk(folder_path):
        for f in files:
            file_path = os.path.join(root, f)
            mtime = os.path.getmtime(file_path)
            # Local file time → Hanoi TZ
            dt = datetime.fromtimestamp(mtime, tz=HANOI_TZ)
            if latest_time is None or dt > latest_time:
                latest_time = dt
    return latest_time

def generate_dates(start_date, end_date):
    """
    Generate a list of date strings between start_date and end_date (inclusive).
    Format: "YYYY-MM-DD"
    """
    start = datetime.strptime(start_date, "%Y-%m-%d")
    end = datetime.strptime(end_date, "%Y-%m-%d")
    delta = end - start
    date_list = [(start + timedelta(days=i)).strftime("%Y-%m-%d") for i in range(delta.days + 1)]
    return date_list

def file_exists_in_s3_check_contains_string(bucket, prefix, string):
    """Check if the specified string is in any filenames in the S3 folder."""
    try:
        response = s3.list_objects_v2(Bucket=bucket, Prefix=prefix)
        if 'Contents' in response:
            for obj in response['Contents']:
                if string in obj['Key']:
                    return True
        return False
    except Exception as e:
        print(f"Error checking string in S3: {e}")
        return False

def file_exists_locally(fixture_id, folder_path):
    """Check if any fixture details file containing fixture_id exists in local Windows folder."""
    for filename in os.listdir(folder_path):
        if fixture_id in filename and filename.endswith('.json'):
            return True
    return False