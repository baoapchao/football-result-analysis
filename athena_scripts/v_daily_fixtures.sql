CREATE OR REPLACE VIEW "v_daily_fixtures" AS 
SELECT
  item.fixture.id fixture_id
, item.fixture.date fixture_date
, item.fixture.timestamp fixture_timestamp
, item.fixture.status.long status_long
, item.fixture.status.short status_short
, item.league.id league_id
, item.league.name league_name
, item.league.country league_country
, item.league.season league_season
, item.league.round league_round
, item.teams.home.id home_team_id
, item.teams.home.name home_team_name
, item.teams.away.id away_team_id
, item.teams.away.name away_team_name
, item.goals.home home_goals
, item.goals.away away_goals
FROM
  (daily_fixtures_db.daily_fixtures_raw
CROSS JOIN UNNEST(response) t (item))
