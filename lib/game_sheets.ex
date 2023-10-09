defmodule Fantasy.GameSheets do
  def get_all_game_data(games) do
    teams = Enum.map(games, &Map.take(&1, ["home_team", "away_team"]))
    # validate teams
    case Fantasy.CFBData.validate_teams(teams) do
      {:ok, team_data} ->
        # get data for each game
        Enum.map(team_data, fn team ->
          get_game_data(team)
        end)

      {:error, message} ->
        IO.puts(message)
    end
  end

  # get data for a single game
  def get_game_data(game) do
  end
end
