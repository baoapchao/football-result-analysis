CREATE OR REPLACE VIEW "v_fixture_details" AS 
SELECT
  item.fixture.id fixture_id
, item.fixture.referee referee
, item.fixture.timezone timezone
, item.fixture.date fixture_date
, item.fixture.timestamp fixture_timestamp
, item.fixture.periods.first first_period_ts
, item.fixture.periods.second second_period_ts
, item.fixture.venue.id venue_id
, item.fixture.venue.name venue_name
, item.fixture.venue.city venue_city
, item.fixture.status.long status_long
, item.fixture.status.short status_short
, item.fixture.status.elapsed elapsed
, item.fixture.status.extra extra
, item.league.id league_id
, item.league.name league_name
, item.league.country league_country
, item.league.logo league_logo
, item.league.flag league_flag
, item.league.season season
, item.league.round round
, item.league.standings standings
, item.teams.home.id home_team_id
, item.teams.home.name home_team_name
, item.teams.home.logo home_team_logo
, item.teams.home.winner home_winner
, item.teams.away.id away_team_id
, item.teams.away.name away_team_name
, item.teams.away.logo away_team_logo
, item.teams.away.winner away_winner
, CAST(item.goals.home AS INT) home_goals
, CAST(item.goals.away AS INT) away_goals
, CAST(item.goals.home AS INT) halftime_home
, CAST(item.score.halftime.away AS INT) halftime_away
, CAST(item.score.fulltime.home AS INT) fulltime_home
, CAST(item.score.fulltime.away AS INT) fulltime_away
, CAST(item.score.extratime.home AS INT) extratime_home
, CAST(item.score.extratime.away AS INT) extratime_away
, CAST(item.score.penalty.home AS INT) penalty_home
, CAST(item.score.penalty.away AS INT) penalty_away
FROM
  (fixture_details_raw
CROSS JOIN UNNEST(response) t (item))
WHERE (results > 0)
