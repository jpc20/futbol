require './test/test_helper'
require './lib/stat_tracker'


class StatTrackerTest < MiniTest::Test

   def setup
     @stat_tracker = StatTracker.from_csv({
       games: "./test/fixtures/games_fixture.csv",
       teams: "./data/teams.csv",
       game_teams: "./test/fixtures/games_teams_fixture.csv"})
   end

  def test_it_exists
    assert_instance_of StatTracker, @stat_tracker
  end

  def test_has_attributes
    assert_instance_of GameStats, @stat_tracker.game_stats
    assert_instance_of TeamStats, @stat_tracker.team_stats
    assert_instance_of LeagueStats, @stat_tracker.league_stats
    assert_instance_of SeasonStats, @stat_tracker.season_stats
  end

  def test_percentage_home_wins
    assert_equal 0.64, @stat_tracker.percentage_home_wins
  end

  def test_percentage_visitor_wins
    assert_equal 0.27, @stat_tracker.percentage_visitor_wins
  end

  def test_percentage_ties
    assert_equal 0.09, @stat_tracker.percentage_ties
  end

  def test_count_of_games_by_season
    expected = {"20122013" => 3,
                "20132014" => 3,
                "20172018" => 5}
    assert_equal expected, @stat_tracker.count_of_games_by_season
  end

  def test_it_can_find_highest_scoring_game
    assert_equal 6, @stat_tracker.highest_total_score
  end

  def test_it_can_find_lowest_scoring_game
    assert_equal 2, @stat_tracker.lowest_total_score
  end

  def test_it_can_find_average_goals
    assert_equal 4.09 , @stat_tracker.average_goals_per_game
  end

  def test_it_can_return_a_season_with_average_goals
    assert_equal ({"20172018" => 3.8, "20132014" => 4.0, "20122013" => 4.67}), @stat_tracker.average_goals_by_season
  end

  def test_count_of_teams
    assert_equal 32, @stat_tracker.count_of_teams
  end

  def test_best_offense
    @stat_tracker.league_stats.stubs(:average_goals_by_team).returns(1)
    @stat_tracker.league_stats.stubs(:average_goals_by_team).with("1").returns(2)
    assert_equal 'Atlanta United', @stat_tracker.best_offense
  end

  def test_worst_offense
    @stat_tracker.league_stats.stubs(:average_goals_by_team).returns(2)
    @stat_tracker.league_stats.stubs(:average_goals_by_team).with("2").returns(1)
    assert_equal 'Seattle Sounders FC', @stat_tracker.worst_offense
  end

  def test_highest_scoring_visitor
    @stat_tracker.league_stats.stubs(:average_goals_by_team).returns(1)
    @stat_tracker.league_stats.stubs(:average_goals_by_team).with("24", "away").returns(2)
    assert_equal 'Real Salt Lake', @stat_tracker.highest_scoring_visitor
  end

  def test_highest_scoring_home_team
    @stat_tracker.league_stats.stubs(:average_goals_by_team).returns(1)
    @stat_tracker.league_stats.stubs(:average_goals_by_team).with("6", "home").returns(2)
    assert_equal 'FC Dallas', @stat_tracker.highest_scoring_home_team
  end

  def test_lowest_scoring_visitor
    @stat_tracker.league_stats.stubs(:average_goals_by_team).returns(2)
    @stat_tracker.league_stats.stubs(:average_goals_by_team).with("23", "away").returns(1)
    assert_equal 'Montreal Impact', @stat_tracker.lowest_scoring_visitor
  end

  def test_lowest_scoring_home_team
    @stat_tracker.league_stats.stubs(:average_goals_by_team).returns(2)
    @stat_tracker.league_stats.stubs(:average_goals_by_team).with("19", "home").returns(1)
    assert_equal 'Philadelphia Union', @stat_tracker.lowest_scoring_home_team
  end

  def test_most_accurate_team
    assert_equal "Portland Thorns FC", @stat_tracker.most_accurate_team("20172018")
  end

  def test_it_can_find_least_accurate_team
    assert_equal "Orlando City SC", @stat_tracker.least_accurate_team("20172018")
  end

  def test_winningest_coach
    assert_equal "Paul Maurice", @stat_tracker.winningest_coach("20172018")
  end

  def test_worst_coach
    assert_equal "Bruce Boudreau", @stat_tracker.worst_coach("20172018")
  end

  def test_it_can_find_team_with_most_season_tackles
    assert_equal "Portland Thorns FC", @stat_tracker.most_tackles("20172018")
  end

  def test_it_can_find_team_with_least_season_tackles
    assert_equal "Orlando City SC", @stat_tracker.fewest_tackles("20172018")
  end

  def test_it_can_return_a_teams_info
     assert_equal ({"team_id" => "1",
       "franchise_id" => "23",
       "team_name" => "Atlanta United",
       "abbreviation" => "ATL",
       "link" => "/api/v1/teams/1"}), @stat_tracker.team_info("1")
  end

  def test_it_can_find_teams_best_season
    assert_equal '20172018', @stat_tracker.best_season('52')
  end

  def test_it_can_find_teams_worst_season
    assert_equal '20172018', @stat_tracker.worst_season('52')
  end

  def test_it_can_find_the_average_winrate_for_a_team
     assert_equal  0.2 , @stat_tracker.average_win_percentage("30")
  end

  def test_most_goals_scored
    assert_equal 4, @stat_tracker.most_goals_scored("6")
  end

  def test_fewest_goals_scored
    assert_equal 0, @stat_tracker.fewest_goals_scored("30")
  end

  def test_find_favorite_opponent
    assert_equal "LA Galaxy", @stat_tracker.favorite_opponent("29")
  end

  def test_find_rival
    assert_equal "Real Salt Lake", @stat_tracker.rival("29")
  end
end
