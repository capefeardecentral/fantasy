defmodule Fantasy.Underdog do
  @moduledoc """
  Documentation for `Fantasy.Underdog`.
  """

  @api_root "https://api.underdogfantasy.com/beta/v4/"

  def merge_projections_and_props(projections) do
    props =
      get_props("CFB")
      |> Enum.map(fn prop ->
        projection =
          Enum.find(projections, fn projection ->
            projection["Player Name"] == prop.player_name
          end)

        IO.inspect(projection)

        if projection do
          case prop.stat do
            "rushing_yds" ->
              prop = Map.put(prop, :projection, projection["RuYds"])

            "receiving_yds" ->
              prop = Map.put(prop, :projection, projection["ReYds"])

            "passing_yds" ->
              prop = Map.put(prop, :projection, projection["PaYds"])

            "rushing_tds" ->
              prop = Map.put(prop, :projection, projection["RuTd"])

            "receiving_tds" ->
              prop = Map.put(prop, :projection, projection["ReTd"])

            "passing_tds" ->
              prop = Map.put(prop, :projection, projection["PaTd"])

            _ ->
              prop = Map.put(prop, :projection, nil)
          end
        end

        prop
      end)
  end

  def get_props(sport) do
    {:ok, response} = make_request("over_under_lines")

    data = Poison.decode!(response.body, keys: :atoms)

    appearances = data.appearances
    over_under = data.over_under_lines
    players = data.players

    players = get_players(players, sport)

    filtered_appearances =
      Enum.filter(appearances, fn %{player_id: player_id} ->
        Map.has_key?(players, player_id)
      end)

    Enum.map(filtered_appearances, fn %{id: appearance_id, player_id: player_id} ->
      player = players[player_id]

      ou_data =
        Enum.find(over_under, fn ou ->
          ou.over_under.appearance_stat.appearance_id == appearance_id
        end)

      %{
        player_name: player,
        stat: ou_data.over_under.appearance_stat.stat,
        over_under: ou_data.stat_value,
        title: ou_data.over_under.title
      }
    end)
  end

  defp make_request(endpoint) do
    headers = [
      "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:108.0) Gecko/20100101 Firefox/108.0"
    ]

    url = @api_root <> endpoint
    HTTPoison.get(url, headers)
  end

  defp get_players(players, sport) do
    Enum.map(players, fn player ->
      if player.sport_id == sport do
        %{
          id: player.id,
          name: player.first_name <> " " <> player.last_name
        }
      end
    end)
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.reduce(%{}, fn %{id: id, name: name}, acc ->
      Map.put(acc, id, name)
    end)
  end
end
