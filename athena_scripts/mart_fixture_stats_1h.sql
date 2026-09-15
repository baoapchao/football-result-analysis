CREATE OR REPLACE VIEW "mart_fixture_stats_1h" AS 
SELECT
  *
, (GOALS_SCORED - GOALS_CONCEDED) GOALS_HDC
, (CAST(CORNER_KICKS AS INT) - CAST(CORNER_KICKS_CONCEDED AS INT)) CORNER_KICKS_HDC
FROM
  (
   SELECT
     CONCAT(CAST(h1.FIXTURE_ID AS VARCHAR), '-', CAST(h1.TEAM_ID AS VARCHAR)) FIXTURE_TEAM_ID
   , h1.FIXTURE_ID
   , h1.TEAM_NAME
   , (CASE WHEN (h1.team_id = ft.home_team_id) THEN ft.home_Team_logo ELSE ft.away_team_logo END) TEAM_LOGO
   , (CASE WHEN (h1.team_id = ft.home_team_id) THEN 'Home' ELSE 'Away' END) HOME_AWAY
   , (CASE WHEN (h1.team_id = ft.home_team_id) THEN ft.halftime_home ELSE ft.halftime_away END) GOALS_SCORED
   , (CASE WHEN (h1.team_id = ft.home_team_id) THEN ft.halftime_away ELSE ft.halftime_home END) GOALS_CONCEDED
   , (ft.halftime_home + ft.halftime_away) GOALS_TOTAL_SCORED_CONCEDED
   , MAX(h1.value) FILTER (WHERE (h1.type = 'goals_prevented')) GOALS_PREVENTED
   , MAX(h1.value) FILTER (WHERE (h1.type = 'Fouls')) FOULS
   , MAX(h1.value) FILTER (WHERE (h1.type = 'Corner Kicks')) CORNER_KICKS
   , MAX(h1_oppo.value) FILTER (WHERE (h1_oppo.type = 'Corner Kicks')) CORNER_KICKS_CONCEDED
   , (MAX(TRY_CAST(h1.value AS INT)) FILTER (WHERE (h1.type = 'Corner Kicks')) + MAX(TRY_CAST(h1_oppo.value AS INT)) FILTER (WHERE (h1_oppo.type = 'Corner Kicks'))) CORNER_KICKS_TOTAL_WON_CONCEDED
   , MAX(h1.value) FILTER (WHERE (h1.type = 'Offsides')) OFFSIDES
   , MAX(h1.value) FILTER (WHERE (h1.type = 'Passes accurate')) PASSES_ACCURATE
   , MAX(h1.value) FILTER (WHERE (h1.type = 'Shots on Goal')) SHOTS_ON_GOAL
   , MAX(h1.value) FILTER (WHERE (h1.type = 'Shots outsidebox')) SHOTS_OUTSIDEBOX
   , MAX(h1.value) FILTER (WHERE (h1.type = 'Free Kicks')) FREE_KICKS
   , MAX(h1.value) FILTER (WHERE (h1.type = 'Shots off Goal')) SHOTS_OFF_GOAL
   , MAX((TRY_CAST(REPLACE(h1.value, '%', '') AS DOUBLE) / 100)) FILTER (WHERE (h1.type = 'Ball Possession')) BALL_POSSESSION
   , MAX(h1.value) FILTER (WHERE (h1.type = 'Total Shots')) TOTAL_SHOTS
   , MAX(h1.value) FILTER (WHERE (h1.type = 'Yellow Cards')) YELLOW_CARDS
   , MAX(h1.value) FILTER (WHERE (h1.type = 'Shots insidebox')) SHOTS_INSIDEBOX
   , MAX(h1.value) FILTER (WHERE (h1.type = 'Red Cards')) RED_CARDS
   , MAX(h1.value) FILTER (WHERE (h1.type = 'Goalkeeper Saves')) GOALKEEPER_SAVES
   , MAX(h1.value) FILTER (WHERE (h1.type = 'expected_goals')) EXPECTED_GOALS
   , MAX(h1.value) FILTER (WHERE (h1.type = 'Blocked Shots')) BLOCKED_SHOTS
   , MAX(h1.value) FILTER (WHERE (h1.type = 'Total passes')) TOTAL_PASSES
   , MAX((TRY_CAST(REPLACE(h1.value, '%', '') AS DOUBLE) / 100)) FILTER (WHERE (h1.type = 'Passes %')) PASSES_PERCENT
   FROM
     ((daily_fixtures_db.v_fixture_details_1h h1
   INNER JOIN daily_fixtures_db.v_fixture_details ft ON (CAST(h1.fixture_id AS INT) = CAST(ft.fixture_id AS INT)))
   INNER JOIN daily_fixtures_db.v_fixture_details_1h h1_oppo ON ((h1.fixture_id = h1_oppo.fixture_id) AND (h1.team_id <> h1_oppo.team_id) AND (h1.type = h1_oppo.type)))
   GROUP BY CONCAT(CAST(h1.FIXTURE_ID AS VARCHAR), '-', CAST(h1.TEAM_ID AS VARCHAR)), h1.FIXTURE_ID, h1.TEAM_NAME, (CASE WHEN (h1.team_id = ft.home_team_id) THEN 'Home' ELSE 'Away' END), (CASE WHEN (h1.team_id = ft.home_team_id) THEN ft.halftime_home ELSE ft.halftime_away END), (CASE WHEN (h1.team_id = ft.home_team_id) THEN ft.home_Team_logo ELSE ft.away_team_logo END), (CASE WHEN (h1.team_id = ft.home_team_id) THEN ft.halftime_away ELSE ft.halftime_home END), (ft.halftime_home + ft.halftime_away)
)  t
