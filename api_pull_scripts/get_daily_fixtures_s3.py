from datetime import date, datetime, timedelta
import time
import common_functions

today = date.today()

dates = [datetime.strftime(date, "%Y-%m-%d") for date in [
    today - timedelta(days=1), 
    today + timedelta(days=1),
    today
]
]

# dates = common_functions.generate_dates("2026-09-15", "2026-09-15")

for date in dates:
    common_functions.get_daily_fixtures_to_s3_json_file(date, "daily_fixtures")