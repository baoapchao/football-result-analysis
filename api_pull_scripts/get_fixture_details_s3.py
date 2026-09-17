import common_functions
import time
all_ids = common_functions.get_all_fixture_ids_from_folder('daily_fixtures')

missing_ids = [str(id) for id in all_ids if not common_functions.file_exists_in_s3_check_contains_string('fixture_details', str(id))]

for id in all_ids:
    common_functions.get_fixture_details_to_s3_json_file(id, 'fixture_details')
    time.sleep(5)