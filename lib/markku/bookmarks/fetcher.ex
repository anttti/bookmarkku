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
        with [{_, meta, _}] <- Floki.find(document, "meta[name=description]") do
          first_match(meta)
        else
          _ -> ""
        end

      [title, description]
    end
  end

  def first_match(collection) do
    with {"content", description} <-
           Enum.find(collection, fn element -> match?({"content", _}, element) end) do
      description
    else
      _ -> ""
    end
  end
end
