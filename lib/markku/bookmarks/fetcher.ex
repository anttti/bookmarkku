defmodule Markku.Bookmarks.Fetcher do
  def fetch_title(url) do
    with {:ok, response} <- Finch.build(:get, url) |> Finch.request(Markku.Finch),
         {:ok, document} <- Floki.parse_document(response.body) do
      title =
        with [{_, _, [title]}] <- Floki.find(document, "head>title") do
          title
        else
          _ -> ""
        end

      description =
        with [{_, [{_, description}, _], _}] <- Floki.find(document, "meta[name=description]") do
          description
        else
          _ -> ""
        end

      [title, description]
    end
  end
end
