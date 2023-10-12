defmodule Fantasy.Util do
  def normalize_name(name) do
    name
    |> String.downcase()
    |> String.replace(".", "")
    |> String.replace("'", "")
  end

  def load_csv(file) do
    file
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.to_list()
  end

  def string_to_num(string) do
    if string == nil do
      nil
    else
      # if a string has a decimal point convert it to a float
      if String.contains?(string, ".") do
        String.to_float(string)
      else
        String.to_integer(string)
      end
    end
  end

  def get_implied_team_total(spread, total, homeTeam) do
    case homeTeam do
      true -> total / 2 - spread / 2
      false -> total / 2 + spread / 2
    end
  end
end
