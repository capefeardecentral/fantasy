defmodule Fantasy.Util do
  def normalize_name(name) do
    name
    |> String.downcase()
    |> String.replace(".", "")
    |> String.replace("'", "")
  end
end