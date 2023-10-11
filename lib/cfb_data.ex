defmodule Fantasy.CFBData do
  @team_data File.read!("data/cfb_data_teams.json") |> Poison.decode!()

  def get_team_stats(team, year) do
    endpoint = "stats/season"

    params = %{
      "year" => year,
      "team" => team
    }

    {_, stats} = make_request(endpoint, params)
    Poison.decode!(stats.body)
  end

  def get_team_player_stats(team, year) do
    endpoint = "stats/player/season"

    params = %{
      "year" => year,
      "team" => team
    }

    {_, stats} = make_request(endpoint, params)
    Poison.decode!(stats.body)
  end

  def get_team_game_stats(team, year) do
    endpoint = "games/teams"

    params = %{
      "year" => year,
      "team" => team
    }

    make_request(endpoint, params)
    {_, stats} = make_request(endpoint, params)
    Poison.decode!(stats.body)
  end

  def get_week_odds(week, year) do
    endpoint = "lines"

    params = %{
      "year" => year,
      "week" => week
    }

    make_request(endpoint, params)
    {_, odds} = make_request(endpoint, params)
    Poison.decode!(odds.body)
  end

  def get_week_games(week, year) do
    endpoint = "games"

    params = %{
      "year" => year,
      "week" => week,
      "division" => "fbs"
    }

    make_request(endpoint, params)
    {_, games} = make_request(endpoint, params)
    Poison.decode!(games.body)
  end

  def compile_season_defense_stats(games, offense_team) do
    # get opponents from each game
    opponent_stats =
      Enum.map(games, fn game ->
        Enum.find(game["teams"], fn team -> team["school"] != offense_team end)
      end)

    total_stats = %{
      "games_played" => 0,
      "points_against" => 0,
      "rushing_tds" => 0,
      "rushing_yds" => 0,
      "passing_tds" => 0,
      "passing_yds" => 0,
      "total_yds" => 0
    }

    Enum.reduce(opponent_stats, total_stats, fn game, acc ->
      acc = Map.put(acc, "games_played", acc["games_played"] + 1)
      acc = Map.put(acc, "points_against", acc["points_against"] + game["points"])
      stats = game["stats"]

      rushing_tds =
        String.to_integer(
          Enum.find(stats, fn stat -> stat["category"] == "rushingTDs" end)["stat"]
        )

      rushing_yds =
        String.to_integer(
          Enum.find(stats, fn stat -> stat["category"] == "rushingYards" end)["stat"]
        )

      passing_tds =
        String.to_integer(
          Enum.find(stats, fn stat -> stat["category"] == "passingTDs" end)["stat"]
        )

      passing_yds =
        String.to_integer(
          Enum.find(stats, fn stat -> stat["category"] == "netPassingYards" end)["stat"]
        )

      total_yds =
        String.to_integer(
          Enum.find(stats, fn stat -> stat["category"] == "totalYards" end)["stat"]
        )

      acc = Map.put(acc, "rushing_tds", acc["rushing_tds"] + rushing_tds)
      acc = Map.put(acc, "rushing_yds", acc["rushing_yds"] + rushing_yds)
      acc = Map.put(acc, "passing_tds", acc["passing_tds"] + passing_tds)
      acc = Map.put(acc, "passing_yds", acc["passing_yds"] + passing_yds)
      Map.put(acc, "total_yds", acc["total_yds"] + total_yds)
    end)
  end

  def find_team_id_by_name(name) do
    team =
      Enum.find(@team_data, fn team ->
        compare_team_names(team["school"], name) ||
          compare_team_names(team["alt_name1"], name) ||
          compare_team_names(team["alt_name2"], name) ||
          compare_team_names(team["alt_name3"], name)
      end)

    if team do
      %{team: team["school"], id: team["id"]}
    else
      nil
    end
  end

  defp compare_team_names(nil, _), do: false
  defp compare_team_names(_, nil), do: false

  defp compare_team_names(name1, name2) do
    name1 = String.downcase(name1)
    name2 = String.downcase(name2)

    name1 == name2
  end

  def compile_player_stats(stats) do
    %{
      "passing" => get_category_stats(stats, "passing"),
      "rushing" => get_category_stats(stats, "rushing"),
      "receiving" => get_category_stats(stats, "receiving")
    }
  end

  defp get_category_stats(stats, category) do
    passing_stats = Enum.filter(stats, fn stat -> stat["category"] == category end)

    players =
      Enum.map(passing_stats, fn stat -> stat["player"] end)
      |> Enum.uniq()

    Enum.map(players, fn player ->
      player_stats =
        Enum.filter(passing_stats, fn stat -> stat["player"] == player end)
        |> Enum.reduce(%{"player" => player}, fn stat, acc ->
          IO.inspect(stat)
          Map.put(acc, stat["statType"], stat["stat"])
        end)
    end)
  end

  def validate_teams(teams) do
    Enum.reduce_while(teams, [], fn name, acc ->
      case find_team_id_by_name(name) do
        nil ->
          {:halt, {:error, "Team not recognized: #{name}"}}

        data ->
          {:cont, acc ++ [data]}
      end
    end)
  end

  def make_request(endpoint, params \\ %{}) do
    headers = [
      {"Accept", "application/json"},
      {"Authorization", "Bearer #{System.get_env("CFB_DATA_API_KEY")}"}
    ]

    url =
      "https://api.collegefootballdata.com/#{endpoint}" <>
        if params == %{}, do: "", else: "?#{URI.encode_query(params)}"

    HTTPoison.get(url, headers)
  end
end
