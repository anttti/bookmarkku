defmodule Markku.Bookmarks.Fetcher do
  def fetch_title(url) do
    with {:ok, uri} <- validate_url(url),
         {:ok, response} <- Finch.build(:get, uri) |> Finch.request(Markku.Finch),
         {:ok, document} <- Floki.parse_document(response.body) do
      title =
        with [{_, _, [title]}] <- Floki.find(document, "head>title") do
          title
        else
          _ -> ""
        end

      description =
        with [{_, meta, _}] <- Floki.find(document, "head>meta[name=description]") do
          first_match(meta)
        else
          _ -> ""
        end

      [title, description]
    else
      _ -> ["", ""]
    end
  end

  defp validate_url(url) do
    case URI.parse(url) do
      %URI{scheme: nil} ->
        {:error}

      %URI{} = uri ->
        if String.length(uri.host) > 0, do: {:ok, uri}, else: {:error}
    end
  end

  defp first_match(collection) do
    with {"content", description} <-
           Enum.find(collection, fn element -> match?({"content", _}, element) end) do
      description
    else
      _ -> ""
    end
  end
end
