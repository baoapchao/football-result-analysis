CREATE OR REPLACE VIEW "mart_fixture_stats_ft_new" AS 
SELECT
  *
, (GOALS_SCORED - GOALS_CONCEDED) GOALS_HDC
, (CAST(CORNER_KICKS AS INT) - CAST(CORNER_KICKS_CONCEDED AS INT)) CORNER_KICKS_HDC
FROM
  (
   SELECT
     CONCAT(CAST(ft.FIXTURE_ID AS VARCHAR), '-', CAST(ft.TEAM_ID AS VARCHAR)) FIXTURE_TEAM_ID
   , ft.FIXTURE_ID
   , ft.TEAM_NAME
   , (CASE WHEN (ft.team_id = dt.home_team_id) THEN dt.home_Team_logo ELSE dt.away_team_logo END) TEAM_LOGO
   , (CASE WHEN (ft.team_id = dt.home_team_id) THEN 'Home' ELSE 'Away' END) HOME_AWAY
   , (CASE WHEN (ft.team_id = dt.home_team_id) THEN dt.fulltime_home ELSE dt.fulltime_away END) GOALS_SCORED
   , (CASE WHEN (ft.team_id = dt.home_team_id) THEN dt.fulltime_away ELSE dt.fulltime_home END) GOALS_CONCEDED
   , (dt.fulltime_home + dt.fulltime_away) GOALS_TOTAL_SCORED_CONCEDED
   , MAX(ft.value) FILTER (WHERE (ft.type = 'goals_prevented')) GOALS_PREVENTED
   , MAX(ft.value) FILTER (WHERE (ft.type = 'Fouls')) FOULS
   , MAX(ft.value) FILTER (WHERE (ft.type = 'Corner Kicks')) CORNER_KICKS
   , MAX(ft_oppo.value) FILTER (WHERE (ft_oppo.type = 'Corner Kicks')) CORNER_KICKS_CONCEDED
   , (MAX(TRY_CAST(ft.value AS INT)) FILTER (WHERE (ft.type = 'Corner Kicks')) + MAX(TRY_CAST(ft_oppo.value AS INT)) FILTER (WHERE (ft_oppo.type = 'Corner Kicks'))) CORNER_KICKS_TOTAL_WON_CONCEDED
   , MAX(ft.value) FILTER (WHERE (ft.type = 'Offsides')) OFFSIDES
   , MAX(ft.value) FILTER (WHERE (ft.type = 'Passes accurate')) PASSES_ACCURATE
   , MAX(ft.value) FILTER (WHERE (ft.type = 'Shots on Goal')) SHOTS_ON_GOAL
   , MAX(ft.value) FILTER (WHERE (ft.type = 'Shots outsidebox')) SHOTS_OUTSIDEBOX
   , MAX(ft.value) FILTER (WHERE (ft.type = 'Free Kicks')) FREE_KICKS
   , MAX(ft.value) FILTER (WHERE (ft.type = 'Shots off Goal')) SHOTS_OFF_GOAL
   , MAX((TRY_CAST(REPLACE(ft.value, '%', '') AS DOUBLE) / 100)) FILTER (WHERE (ft.type = 'Ball Possession')) BALL_POSSESSION
   , MAX(ft.value) FILTER (WHERE (ft.type = 'Total Shots')) TOTAL_SHOTS
   , MAX(ft.value) FILTER (WHERE (ft.type = 'Yellow Cards')) YELLOW_CARDS
   , MAX(ft.value) FILTER (WHERE (ft.type = 'Shots insidebox')) SHOTS_INSIDEBOX
   , MAX(ft.value) FILTER (WHERE (ft.type = 'Red Cards')) RED_CARDS
   , MAX(ft.value) FILTER (WHERE (ft.type = 'Goalkeeper Saves')) GOALKEEPER_SAVES
   , MAX(ft.value) FILTER (WHERE (ft.type = 'expected_goals')) EXPECTED_GOALS
   , MAX(ft.value) FILTER (WHERE (ft.type = 'Blocked Shots')) BLOCKED_SHOTS
   , MAX(ft.value) FILTER (WHERE (ft.type = 'Total passes')) TOTAL_PASSES
   , MAX((TRY_CAST(REPLACE(ft.value, '%', '') AS DOUBLE) / 100)) FILTER (WHERE (ft.type = 'Passes %')) PASSES_PERCENT
   FROM
     ((daily_fixtures_db.v_fixture_details_ft ft
   INNER JOIN daily_fixtures_db.v_fixture_details dt ON (CAST(ft.fixture_id AS INT) = CAST(dt.fixture_id AS INT)))
   INNER JOIN daily_fixtures_db.v_fixture_details_ft ft_oppo ON ((ft.fixture_id = ft_oppo.fixture_id) AND (ft.team_id <> ft_oppo.team_id) AND (ft.type = ft_oppo.type)))
   GROUP BY CONCAT(CAST(ft.FIXTURE_ID AS VARCHAR), '-', CAST(ft.TEAM_ID AS VARCHAR)), ft.FIXTURE_ID, ft.TEAM_NAME, (CASE WHEN (ft.team_id = dt.home_team_id) THEN 'Home' ELSE 'Away' END), (CASE WHEN (ft.team_id = dt.home_team_id) THEN dt.fulltime_home ELSE dt.fulltime_away END), (CASE WHEN (ft.team_id = dt.home_team_id) THEN dt.home_Team_logo ELSE dt.away_team_logo END), (CASE WHEN (ft.team_id = dt.home_team_id) THEN dt.fulltime_away ELSE dt.fulltime_home END), (dt.fulltime_home + dt.fulltime_away)
)  t
