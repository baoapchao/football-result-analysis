from datetime import date, datetime, timedelta
import time
import common_functions

all_ids = common_functions.get_all_fixture_ids_from_folder('daily_fixtures')

print("All IDs:", all_ids)

missing_ids = [str(id) for id in all_ids if not common_functions.file_exists_in_s3_check_contains_string('fixture_details_half', str(id))]

print("Missing IDs:", missing_ids)

for id in missing_ids:
    common_functions.get_fixture_details_half_to_s3_json_file(id, 'fixture_details_half')
    time.sleep(5)