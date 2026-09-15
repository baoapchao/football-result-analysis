CREATE OR REPLACE VIEW "mart_fixture_stats_2h" AS 
SELECT
  *
, (GOALS_SCORED - GOALS_CONCEDED) GOALS_HDC
, (CAST(CORNER_KICKS AS INT) - CAST(CORNER_KICKS_CONCEDED AS INT)) CORNER_KICKS_HDC
FROM
  (
   SELECT
     CONCAT(CAST(h2.FIXTURE_ID AS VARCHAR), '-', CAST(h2.TEAM_ID AS VARCHAR)) FIXTURE_TEAM_ID
   , h2.FIXTURE_ID
   , h2.TEAM_NAME
   , (CASE WHEN (h2.team_id = ft.home_team_id) THEN ft.home_Team_logo ELSE ft.away_team_logo END) TEAM_LOGO
   , (CASE WHEN (h2.team_id = ft.home_team_id) THEN 'Home' ELSE 'Away' END) HOME_AWAY
   , (CASE WHEN (h2.team_id = ft.home_team_id) THEN (ft.fulltime_home - ft.halftime_home) ELSE (ft.fulltime_away - ft.halftime_away) END) GOALS_SCORED
   , (CASE WHEN (h2.team_id = ft.home_team_id) THEN (ft.fulltime_away - ft.halftime_away) ELSE (ft.fulltime_home - ft.halftime_home) END) GOALS_CONCEDED
   , ((ft.fulltime_home - ft.halftime_home) + (ft.fulltime_away - ft.halftime_away)) GOALS_TOTAL_SCORED_CONCEDED
   , MAX(h2.value) FILTER (WHERE (h2.type = 'goals_prevented')) GOALS_PREVENTED
   , MAX(h2.value) FILTER (WHERE (h2.type = 'Fouls')) FOULS
   , MAX(h2.value) FILTER (WHERE (h2.type = 'Corner Kicks')) CORNER_KICKS
   , MAX(h2_oppo.value) FILTER (WHERE (h2_oppo.type = 'Corner Kicks')) CORNER_KICKS_CONCEDED
   , (MAX(TRY_CAST(h2.value AS INT)) FILTER (WHERE (h2.type = 'Corner Kicks')) + MAX(TRY_CAST(h2_oppo.value AS INT)) FILTER (WHERE (h2_oppo.type = 'Corner Kicks'))) CORNER_KICKS_TOTAL_WON_CONCEDED
   , MAX(h2.value) FILTER (WHERE (h2.type = 'Offsides')) OFFSIDES
   , MAX(h2.value) FILTER (WHERE (h2.type = 'Passes accurate')) PASSES_ACCURATE
   , MAX(h2.value) FILTER (WHERE (h2.type = 'Shots on Goal')) SHOTS_ON_GOAL
   , MAX(h2.value) FILTER (WHERE (h2.type = 'Shots outsidebox')) SHOTS_OUTSIDEBOX
   , MAX(h2.value) FILTER (WHERE (h2.type = 'Free Kicks')) FREE_KICKS
   , MAX(h2.value) FILTER (WHERE (h2.type = 'Shots off Goal')) SHOTS_OFF_GOAL
   , MAX((TRY_CAST(REPLACE(h2.value, '%', '') AS DOUBLE) / 100)) FILTER (WHERE (h2.type = 'Ball Possession')) BALL_POSSESSION
   , MAX(h2.value) FILTER (WHERE (h2.type = 'Total Shots')) TOTAL_SHOTS
   , MAX(h2.value) FILTER (WHERE (h2.type = 'Yellow Cards')) YELLOW_CARDS
   , MAX(h2.value) FILTER (WHERE (h2.type = 'Shots insidebox')) SHOTS_INSIDEBOX
   , MAX(h2.value) FILTER (WHERE (h2.type = 'Red Cards')) RED_CARDS
   , MAX(h2.value) FILTER (WHERE (h2.type = 'Goalkeeper Saves')) GOALKEEPER_SAVES
   , MAX(h2.value) FILTER (WHERE (h2.type = 'expected_goals')) EXPECTED_GOALS
   , MAX(h2.value) FILTER (WHERE (h2.type = 'Blocked Shots')) BLOCKED_SHOTS
   , MAX(h2.value) FILTER (WHERE (h2.type = 'Total passes')) TOTAL_PASSES
   , MAX((TRY_CAST(REPLACE(h2.value, '%', '') AS DOUBLE) / 100)) FILTER (WHERE (h2.type = 'Passes %')) PASSES_PERCENT
   FROM
     ((daily_fixtures_db.v_fixture_details_2h h2
   INNER JOIN daily_fixtures_db.v_fixture_details ft ON (CAST(h2.fixture_id AS INT) = CAST(ft.fixture_id AS INT)))
   INNER JOIN daily_fixtures_db.v_fixture_details_2h h2_oppo ON ((h2.fixture_id = h2_oppo.fixture_id) AND (h2.team_id <> h2_oppo.team_id) AND (h2.type = h2_oppo.type)))
   GROUP BY CONCAT(CAST(h2.FIXTURE_ID AS VARCHAR), '-', CAST(h2.TEAM_ID AS VARCHAR)), h2.FIXTURE_ID, h2.TEAM_NAME, (CASE WHEN (h2.team_id = ft.home_team_id) THEN 'Home' ELSE 'Away' END), (CASE WHEN (h2.team_id = ft.home_team_id) THEN (ft.fulltime_home - ft.halftime_home) ELSE (ft.fulltime_away - ft.halftime_away) END), (CASE WHEN (h2.team_id = ft.home_team_id) THEN ft.home_Team_logo ELSE ft.away_team_logo END), (CASE WHEN (h2.team_id = ft.home_team_id) THEN (ft.fulltime_away - ft.halftime_away) ELSE (ft.fulltime_home - ft.halftime_home) END), ((ft.fulltime_home - ft.halftime_home) + (ft.fulltime_away - ft.halftime_away))
)  t
