defmodule Fantasy.Underdog do
  @moduledoc """
  Documentation for `Fantasy.Underdog`.
  """

  @api_root "https://api.underdogfantasy.com/beta/v4/"

  def get_props(sport) do
    {:ok, response} = make_request("over_under_lines")

    data = Poison.decode!(response.body)

    appearances = Map.get(data, "appearances")
    over_under = Map.get(data, "over_under_lines")
    players = Map.get(data, "players")

    get_players(players, "CFB")
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
      if player["sport_id"] == sport do
        %{
          id: player["id"],
          name: player["first_name"] <> " " <> player["last_name"]
        }
      end
    end)
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.reduce(%{}, fn %{id: id, name: name}, acc ->
      Map.put(acc, id, name)
    end)
  end
end
