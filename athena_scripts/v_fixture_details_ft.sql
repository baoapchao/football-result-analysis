CREATE OR REPLACE VIEW "v_fixture_details_ft" AS 
SELECT
  parameters.fixture fixture_id
, item.team.id team_id
, item.team.name team_name
, stat.type type
, stat.value value
FROM
  ((fixture_details_half
CROSS JOIN UNNEST(response) t (item))
CROSS JOIN UNNEST(item.statistics) s (stat))
