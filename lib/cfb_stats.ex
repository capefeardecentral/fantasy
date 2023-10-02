defmodule Fantasy.CFBStats do
  use Crawly.Spider
  @impl Crawly.Spider
  def base_url do
    "https://cfbstats.com"
  end

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "http://cfbstats.com/2023/team/index.html"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    {:ok, document} = Floki.parse_document(response.body)

    IO.inspect(response)

    urls =
      document
      |> Floki.find("div.conferences div.conference ul li a")
      |> Floki.attribute("href")

    requests =
      Enum.map(urls, fn url ->
        build_absolute_url(url)
        |> Crawly.Utils.request_from_url()
      end)

    name =
      Floki.find(document, "div.conference ul li a")
      |> Floki.text()

    %Crawly.ParsedItem{
      :requests => requests,
      :items => [
        %{
          :name => name
        }
      ]
    }
  end

  defp build_absolute_url(request_url) do
    IO.inspect(request_url)
    IO.inspect(base_url)

    URI.merge(base_url, request_url)
    |> to_string()
  end
end
