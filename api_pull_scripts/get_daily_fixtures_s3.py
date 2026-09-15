import requests
import json 
from datetime import date, datetime, timedelta
import boto3
import json
import os
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

url = "https://v3.football.api-sports.io/fixtures"

headers = {
    "x-rapidapi-host": "api-football-v1.p.rapidapi.com",
    "x-rapidapi-key": API_KEY
}

folder = "daily_fixtures"

def get_daily_fixtures_to_s3_json_file(date):
    querystring = {
        "date": date
    }
    response = requests.get(url, headers=headers, params=querystring)
    
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

today = date.today()

dates = [datetime.strftime(date, "%Y-%m-%d") for date in [
    today - timedelta(days=1), 
    today + timedelta(days=1),
    today
]
]

# dates = common_functions.generate_dates("2026-09-15", "2026-09-15")

for date in dates:
    get_daily_fixtures_to_s3_json_file(date)