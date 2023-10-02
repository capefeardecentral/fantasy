defmodule Fantasy.CFBData do
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

    make_request(endpoint, params)
  end

  def get_game_team_stats(team, year) do
    endpoint = "games/teams"

    params = %{
      "year" => year,
      "team" => team
    }

    make_request(endpoint, params)
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
