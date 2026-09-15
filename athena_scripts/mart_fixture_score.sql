CREATE OR REPLACE VIEW "mart_fixture_score" AS 
SELECT
  ft_home.FIXTURE_ID
, ft_home.GOALS_SCORED FULLTIME_HOME_GOALS
, ft_away.GOALS_SCORED FULLTIME_AWAY_GOALS
, ft_home.CORNER_KICKS FULLTIME_HOME_CORNER_KICKS
, ft_away.CORNER_KICKS FULLTIME_AWAY_CORNER_KICKS
, h1_home.GOALS_SCORED H1_HOME_GOALS
, h1_away.GOALS_SCORED H1_AWAY_GOALS
, h1_home.CORNER_KICKS H1_HOME_CORNER_KICKS
, h1_away.CORNER_KICKS H1_AWAY_CORNER_KICKS
, h2_home.GOALS_SCORED H2_HOME_GOALS
, h2_away.GOALS_SCORED H2_AWAY_GOALS
, h2_home.CORNER_KICKS H2_HOME_CORNER_KICKS
, h2_away.CORNER_KICKS H2_AWAY_CORNER_KICKS
FROM
  (((((daily_fixtures_db.MART_FIXTURE_STATS_FT ft_home
INNER JOIN daily_fixtures_db.MART_FIXTURE_STATS_FT_NEW ft_away ON ((ft_home.fixture_id = ft_away.fixture_id) AND (ft_home.home_away = 'Home') AND (ft_away.home_away = 'Away')))
INNER JOIN daily_fixtures_db.MART_FIXTURE_STATS_1H h1_home ON ((ft_home.fixture_id = h1_home.fixture_id) AND (h1_home.home_away = 'Home')))
INNER JOIN daily_fixtures_db.MART_FIXTURE_STATS_1H h1_away ON ((ft_home.fixture_id = h1_away.fixture_id) AND (h1_away.home_away = 'Away')))
INNER JOIN daily_fixtures_db.MART_FIXTURE_STATS_2H h2_home ON ((ft_home.fixture_id = h2_home.fixture_id) AND (h2_home.home_away = 'Home')))
INNER JOIN daily_fixtures_db.MART_FIXTURE_STATS_2H h2_away ON ((ft_home.fixture_id = h2_away.fixture_id) AND (h2_away.home_away = 'Away')))
