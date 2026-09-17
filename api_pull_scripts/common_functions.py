import json
import os
import requests
import time 
from datetime import date, datetime, timedelta
from zoneinfo import ZoneInfo

import boto3
import json

# AWS functions
aws_credentials_path = os.path.join(os.path.dirname(__file__), "config", "aws_credentials.json")

with open(aws_credentials_path, "r", encoding="utf-8") as f:
    aws_credentials = json.load(f)

s3 = boto3.client(
    "s3",
    aws_access_key_id=aws_credentials["aws_access_key_id"],
    aws_secret_access_key=aws_credentials["aws_secret_access_key"],
    region_name=aws_credentials["region_name"]
)

bucket = aws_credentials["bucket"]

# Football API functions
football_api_credentials_path = os.path.join(os.path.dirname(__file__), "config", "football_api_credentials.json")

with open(football_api_credentials_path, "r", encoding="utf-8") as f:
    football_api_credentials = json.load(f)

API_KEY = football_api_credentials["api_key"]

API_HEADERS = {
    "x-rapidapi-host": "api-football-v1.p.rapidapi.com",
    "x-rapidapi-key": API_KEY
}

API_STATISTICS_URL = "https://v3.football.api-sports.io/fixtures/statistics"

API_FIXTURES_URL = "https://v3.football.api-sports.io/fixtures"

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

def get_daily_fixtures_to_s3_json_file(date, folder):
    querystring = {
        "date": date
    }
    response = requests.get(API_FIXTURES_URL, headers=API_HEADERS, params=querystring)
    if response.status_code == 200:
        data = response.json()  # API response as JSON
        json_string = json.dumps(data, ensure_ascii=False)
        Key=f'{folder}/fixtures_{date}.json'

        # Write JSON to a file
        s3.put_object(
            Bucket=bucket,
            Key=Key,
            Body=json_string,
            ContentType="application/json"
        )

        print(f"Saved JSON to s3://{Key}")
    else:
        print(f"Request failed with status code {response.status_code}")

def get_fixture_ids_from_folder(read_folder):
    fixture_ids = []

    # Loop through all files in the folder
    response = s3.list_objects_v2(Bucket=bucket, Prefix=read_folder)

    latest_folder_modified_datetime = get_latest_modified_datetime(os.path.join(os.path.dirname(__file__), "..", "data", read_folder))

    for obj in response.get("Contents", []):
        key = obj["Key"]
        s3_last_modified = obj["LastModified"]

        # Skip folder "key"
        if key.endswith("/"):
            continue

        if key.endswith(".json") and s3_last_modified > latest_folder_modified_datetime:
            print("Loading:", key)

            # Read file content
            file_obj = s3.get_object(Bucket=bucket, Key=key)
            content = file_obj["Body"].read().decode("utf-8")

            # Convert to Python dict/list
            data = json.loads(content)

            ids = [
                    item["fixture"]["id"] 
                    for item in data.get("response", []) 
                    if item.get("league", {}).get("id") in leagues
                        and item.get("fixture", {}).get("status", {}).get("long") == 'Match Finished'
                        and (datetime.fromisoformat(item.get("fixture", {}).get("date"))).date() > date.today() - timedelta(days=3)
                        # and (datetime.fromisoformat(item.get("fixture", {}).get("date"))).date() >= datetime.strptime("2025-11-01", r"%Y-%m-%d").date()
                        # and (datetime.fromisoformat(item.get("fixture", {}).get("date"))).date() <= datetime.strptime("2025-11-25", r"%Y-%m-%d").date()
                        ]
        
            fixture_ids.extend(ids)

    return fixture_ids

def get_fixture_details_to_s3_json_file(id, write_folder):
    querystring = {
        "id": id,
    }

    response = requests.get(API_FIXTURES_URL, headers=API_HEADERS, params=querystring)
    if response.status_code == 200:
        data = response.json()  # API response as JSON
        json_string = json.dumps(data, ensure_ascii=False)
        Key=f'{write_folder}/fixtures_{id}.json'

        # Write JSON to a file
        s3.put_object(
            Bucket=bucket,
            Key=Key,
            Body=json_string,
            ContentType="application/json"
        )

        print(f"Saved JSON to s3://{Key}")
    else:
        print(f"Request failed with status code {response.status_code}")

def get_fixture_details_half_to_s3_json_file(id, write_folder):
    querystring = {
        "fixture": id,
        "half": "true",
    }

    response = requests.get(API_STATISTICS_URL, headers=API_HEADERS, params=querystring)
    if response.status_code == 200:
        data = response.json()  # API response as JSON
        json_string = json.dumps(data, ensure_ascii=False)
        Key=f'{write_folder}/fixtures_{id}_half.json'

        # Write JSON to a file
        s3.put_object(
            Bucket=bucket,
            Key=Key,
            Body=json_string,
            ContentType="application/json"
        )

        print(f"Saved JSON to s3://{Key}")
    else:
        print(f"Request failed with status code {response.status_code}")

# For backfill
def get_all_fixture_ids_from_folder(read_folder):
    fixture_ids = []

    # Loop through all files in the folder
    local_folder_path = os.path.join(os.path.dirname(__file__), "..", "data", read_folder)
    
    for filename in os.listdir(local_folder_path):
        file_path = os.path.join(local_folder_path, filename)
        
        # Skip if not a file
        if not os.path.isfile(file_path):
            continue
        
        if filename.endswith(".json"):
            print("Loading:", filename)
            
            # Read file content
            with open(file_path, "r", encoding="utf-8") as f:
                # content = f.read()
            
                # # Convert to Python dict/list
                # data = json.loads(content)
                data = json.load(f)

                ids = [
                        item["fixture"]["id"] 
                        for item in data.get("response", []) 
                        if item.get("league", {}).get("id") in leagues
                            and item.get("fixture", {}).get("status", {}).get("long") == 'Match Finished'
                            and (datetime.fromisoformat(item.get("fixture", {}).get("date"))).date() >= datetime.strptime("2025-11-01", r"%Y-%m-%d").date()
                            # and (datetime.fromisoformat(item.get("fixture", {}).get("date"))).date() <= datetime.strptime("2025-11-25", r"%Y-%m-%d").date()
                            ]
        
            fixture_ids.extend(ids)

    return fixture_ids

# Download from S3 folder to local folder
def download_from_s3(PREFIX):
    paginator = s3.get_paginator("list_objects_v2")
    pages = paginator.paginate(Bucket=bucket, Prefix=PREFIX)
    os.makedirs(os.path.join("..", "data"), exist_ok=True)
    latest_folder_modified_datetime = get_latest_modified_datetime(os.path.join("..", "data", PREFIX))
    if latest_folder_modified_datetime is None:
        latest_folder_modified_datetime = datetime(1900, 1, 1, tzinfo=ZoneInfo("Asia/Ho_Chi_Minh"))
    for page in pages:
        for obj in page.get("Contents", []):
            key = obj["Key"]
            s3_last_modified = obj["LastModified"]
            if key.endswith(".json") and s3_last_modified > latest_folder_modified_datetime:
                # local_path = os.path.join(PREFIX.rstrip("/"), os.path.basename(key))
                local_path = os.path.join("..", "data", PREFIX.rstrip("/"), os.path.basename(key))
                print(f"Downloading {key} -> {local_path}")
                s3.download_file(bucket, key, local_path)

    print(f"Downloading {PREFIX} Done")

