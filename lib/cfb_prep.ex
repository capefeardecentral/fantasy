defmodule Fantasy.CFBPrep do
  alias Fantasy.CFBData
  alias Fantasy.Util

  def collect_slate_data(week, year) do
    games = CFBData.get_week_games(week, year)
    odds = CFBData.get_week_odds(week, year)

    Enum.map(games, fn game ->
      game_id = game["id"]

      # Handle odds for the game
      odds_data =
        Enum.find(odds, fn odd ->
          odd["id"] == game_id
        end)["lines"]
        |> hd

      spread = Util.string_to_num(odds_data["spread"])
      total = Util.string_to_num(odds_data["overUnder"])
      home_implied = Util.get_implied_team_total(spread, total, true)
      away_implied = Util.get_implied_team_total(spread, total, false)

      game_data = %{
        :home => game["home_team"],
        :away => game["away_team"],
        :opening_spread => Util.string_to_num(odds_data["spreadOpen"]),
        :spread => spread,
        :formatted_spread => odds_data["formattedSpread"],
        :opening_total => Util.string_to_num(odds_data["overUnderOpen"]),
        :total => total,
        :home_implied => home_implied,
        :away_implied => away_implied
      }
    end)
  end
end
