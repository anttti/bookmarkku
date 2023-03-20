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

Markku.Repo.insert!(%Markku.Accounts.User{
  email: "test@test.com",
  hashed_password: Bcrypt.hash_pwd_salt("test"),
  confirmed_at: ~N[2021-01-01 00:00:00]
})

tag_dev =
  Markku.Repo.insert!(%Markku.Bookmarks.Tag{
    name: "Development"
  })

tag_tech =
  Markku.Repo.insert!(%Markku.Bookmarks.Tag{
    name: "Tech"
  })

tag_media =
  Markku.Repo.insert!(%Markku.Bookmarks.Tag{
    name: "Media"
  })

tag_saas =
  Markku.Repo.insert!(%Markku.Bookmarks.Tag{
    name: "SaaS"
  })

verge =
  Markku.Repo.insert!(%Markku.Bookmarks.Bookmark{
    title: "The Verge",
    url: "https://www.theverge.com",
    description:
      "The Verge is about technology and how it makes us feel. Founded in 2011, we offer our audience everything from breaking news to reviews to award-winning features and investigations, on our site, in video, and in podcasts.",
    unread: true,
    tags: [tag_tech, tag_media]
  })

mtv =
  Markku.Repo.insert!(%Markku.Bookmarks.Bookmark{
    title: "MTV Katsomo – Katso suosikkiohjelmasi maksutta koska haluat",
    url: "https://www.mtv.fi",
    description:
      "Suomen suosituimmat viihdeohjelmat ja kuumimmat puheenaiheet. Parasta aikaa MTV Katsomossa!",
    unread: true,
    tags: [tag_media]
  })

fly =
  Markku.Repo.insert!(%Markku.Bookmarks.Bookmark{
    title: "Deploy app servers close to your users · Fly",
    url: "https://fly.io",
    description: "",
    unread: true,
    tags: [tag_dev, tag_tech, tag_saas]
  })
