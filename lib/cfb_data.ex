defmodule Fantasy.CFBData do
  @team_data load_team_data

  def get_team_stats(team, year) do
    endpoint = "stats/season"

    params = %{
      "year" => year,
      "team" => team
    }

    make_request(endpoint, params)
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
      acc = Map.put(acc, "total_yds", acc["total_yds"] + total_yds)
    end)
  end

  def load_team_data() do
    {:ok, data} = File.read("data/cfb_data_teams.json")
    Poison.decode!(data)
  end

  defp find_team_id_by_name(name) do
    team =
      Enum.find(@team_data, fn team ->
        team["school"] == name ||
          team["alt_name1"] == name ||
          team["alt_name2"] == name ||
          team["alt_name3"] == name
      end)

    if team do
      team["id"]
    else
      nil
    end
  end

  def validate_teams(teams) do
    Enum.reduce_while(teams, [], fn name, acc ->
      case find_team_id_by_name(name) do
        nil ->
          {:halt, {:error, "Team not recognized: #{name}"}}

        id ->
          {:cont, acc ++ [%{team: name, id: id}]}
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
