defmodule Fantasy.CffSite do
  @moduledoc """
  Documentation for `Fantasy.CffSite`.
  """

  def load_projections(file) do
    file
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Enum.take(2)
  end
end
