library(rvest)
library(tidyverse)

url <- "https://www.imdb.com/search/title/?groups=top_100&sort=user_rating,desc"

movies <- url %>%
  read_html() %>%
  html_elements("h3.lister-item-header") %>%
  html_text2() 

ratings <- url %>%
  read_html() %>%
  html_elements("div.ratings-imdb-rating") %>%
  html_text2() %>%
  as.numeric()

votes <- url %>%
  read_html() %>%
  html_elements("p.sort-num_votes-visible") %>%
  html_text2()

metascore_raw <- url %>%
  read_html() %>%
  html_elements("div.inline-block.ratings-metascore") %>%
  html_text2()

imdb_df <- data.frame(
  movies,
  ratings,
  votes,
  metascore_raw
)

imdb_df <- imdb_df %>%
  mutate(
    movies = movies,
    ratings = ratings,
    votes_total = str_match(votes,"Votes:\\s*(\\d+,?\\d+,?\\d+)")[,2],
    gross = str_match(votes, "Gross:\\s*\\$(\\d+\\.\\d+)")[,2],
    metascore = str_match(metascore_raw, "\\d+\\s*")[ ,1]
  ) %>%
  select(movies, ratings, votes_total, metascore, gross, metascore)

View(imdb_df)
