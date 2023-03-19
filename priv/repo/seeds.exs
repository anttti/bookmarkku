# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Markku.Repo.insert!(%Markku.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Markku.Repo.insert!(%Markku.Bookmarks.Bookmark{
  title: "The Verge",
  url: "https://www.theverge.com",
  description:
    "The Verge is about technology and how it makes us feel. Founded in 2011, we offer our audience everything from breaking news to reviews to award-winning features and investigations, on our site, in video, and in podcasts.",
  unread: true
})
