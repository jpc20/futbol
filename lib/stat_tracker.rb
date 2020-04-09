require 'csv'
require_relative 'game_team'
require_relative 'game'
require_relative 'team'

class StatTracker
  attr_reader :games, :teams, :game_teams

  def self.from_csv(locations)
    games_path = locations[:games]
    teams_path = locations[:teams]
    game_teams_path = locations[:game_teams]
    StatTracker.new(games_path, teams_path, game_teams_path)
  end

  def initialize(games_path, teams_path, game_teams_path)
    Game.from_csv(games_path)
    GameTeam.from_csv(game_teams_path)
    Team.from_csv(teams_path)

    @games = Game.all
    @teams = Team.all
    @game_teams = GameTeam.all
  end

  def percentage_home_wins
    home_wins = @games.find_all do |game|
      game.home_goals > game.away_goals
    end
    (home_wins.length.to_f / @games.length.to_f).round(2)
  end

  def percentage_visitor_wins
    away_wins = @games.find_all do |game|
      game.away_goals > game.home_goals
    end
    (away_wins.length.to_f / @games.length.to_f).round(2)
  end

  def percentage_ties
    ties = @game_teams.find_all {|team| team.result == "TIE"}
    (ties.length.to_f / @game_teams.length).round(2)
  end

  def count_of_games_by_season
    games_by_season = @games.group_by {|game| game.season}
    games_by_season.transform_values {|season| season.length}
  end

  def highest_total_score
    highest_scoring_game = @games.max_by do |game| game.away_goals + game.home_goals
    end
    highest_scoring_game.away_goals + highest_scoring_game.home_goals
  end

  def lowest_total_score
    lowest_scoring_game = @games.min_by do |game| game.away_goals + game.home_goals
    end
    lowest_scoring_game.away_goals + lowest_scoring_game.home_goals
  end

  def average_goals_per_game
    sum_of_goals = @games.sum do |game|
      game.home_goals + game.away_goals
    end
    (sum_of_goals.to_f / @games.length).round(2)
  end

  def sum_of_goals_in_a_season(season)
    full_season = @games.find_all do |game|
      game.season == season
    end
    full_season.sum do |game|
      game.home_goals + game.away_goals
    end
  end

  def average_of_goals_in_a_season(season)
    by_season = @games.find_all do |game|
      game.season == season
    end
    (sum_of_goals_in_a_season(season).to_f / by_season.length).round(2)
  end

  def average_goals_by_season
    average_goals_by_season = @games.group_by do |game|
      game.season
    end
    average_goals_by_season.transform_values do |season|
      average_of_goals_in_a_season(season.first.season)
    end
  end

  def least_accurate_team(season)
    season_games = @games.find_all{|game| game.season == season}
    season_game_ids = season_games.map{|game| game.game_id}
    team_performances = @game_teams.find_all{|team| season_game_ids.include?(team.game_id)}
    performance_by_team = team_performances.group_by{|team| team.team_id}
    team_accuracy = performance_by_team.transform_values do |team|
      team.sum {|game| game.goals}.to_f / team.sum {|game| game.shots}
    end
    @teams.find {|team| team.team_id == team_accuracy.min[0]}.team_name
  end

  def count_of_teams
    @teams.length
  end

  def most_accurate_team(season)
    season_games = @games.find_all{|game| game.season == season}
    season_game_ids = season_games.map{|game| game.game_id}
    team_performances = @game_teams.find_all{|team| season_game_ids.include?(team.game_id)}
    performance_by_team = team_performances.group_by{|team| team.team_id}
    team_accuracy = performance_by_team.transform_values do |team|
      team.sum {|game| game.goals}.to_f / team.sum {|game| game.shots}
    end
    @teams.find {|team| team.team_id == team_accuracy.max[0]}.team_name
  end
end
