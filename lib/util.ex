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
end
