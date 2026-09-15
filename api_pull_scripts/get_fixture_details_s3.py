import json
import os
import requests
import time 
from datetime import date, datetime, timedelta
from zoneinfo import ZoneInfo

import boto3
import json

import common_functions

aws_credentials_path = os.path.join("config", "aws_credentials.json")
football_api_credentials_path = os.path.join("config", "football_api_credentials.json")

with open(aws_credentials_path, "r", encoding="utf-8") as f:
    aws_credentials = json.load(f)

with open(football_api_credentials_path, "r", encoding="utf-8") as f:
    football_api_credentials = json.load(f)

s3 = boto3.client(
    "s3",
    aws_access_key_id=aws_credentials["aws_access_key_id"],
    aws_secret_access_key=aws_credentials["aws_secret_access_key"],
    region_name=aws_credentials["region_name"]
)

bucket = aws_credentials["bucket"]

API_KEY = football_api_credentials["api_key"]

leagues = {39 #Premier League
            , 135 #Serie A
            , 140 #La Liga
            , 2 #UEFA Champions League
            , 3 #UEFA Europa League
            , 40 #Championship
            , 61 #Ligue 1
            , 78 #Bundesliga
            } 

read_folder = 'daily_fixtures'
write_folder = 'fixture_details'

url = "https://v3.football.api-sports.io/fixtures"

def get_fixture_ids_from_folder():
    fixture_ids = []

    # Loop through all files in the folder
    response = s3.list_objects_v2(Bucket=bucket, Prefix=read_folder)

    latest_folder_modified_datetime = common_functions.get_latest_modified_datetime(os.path.join("..", "data", read_folder))

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

headers = {
    "x-rapidapi-host": "api-football-v1.p.rapidapi.com",
    "x-rapidapi-key": API_KEY
}

def get_fixture_details_to_s3_json_file(id):
    querystring = {
        "id": id,
    }

    response = requests.get(url, headers=headers, params=querystring)
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

all_ids = get_fixture_ids_from_folder()

missing_ids = [str(id) for id in all_ids if not common_functions.file_exists_in_s3_check_contains_string(bucket, write_folder, str(id))]

for id in all_ids:
    get_fixture_dmissing_idsetails_to_s3_json_file(id)
    time.sleep(5)