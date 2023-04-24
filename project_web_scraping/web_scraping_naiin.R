library(tidyverse)
library(rvest)

url <- "https://www.naiin.com/category?type_book=best_seller&product_type_id=1"

product_urls <- url %>%
  read_html() %>%
  html_elements("a.itemname") %>%
  html_attr("href")

descriptions <- vector("character", length(product_urls))
muadmu <- vector("character", length(product_urls))

for (i in seq_along(product_urls)) {
  descriptions[i] <- product_urls[i] %>%
  read_html() %>%
  html_element(".book-decription p+ p") %>%
  html_text2()
}

for (i in seq_along(product_urls)) {
  muadmu[i] <- product_urls[i] %>%
    read_html() %>%
    html_element("p~ p+ p .link-book-detail") %>%
    html_text2()
}

book <- url %>%
  read_html() %>%
  html_elements(".itemname") %>%
  html_text2()

price <- url %>%
  read_html() %>%
  html_elements(".txt-price") %>%
  html_text2()

rating <- url %>%
  read_html() %>%
  html_elements(".item-vote") %>%
  html_text2()

author <- url %>%
  read_html() %>%
  html_elements(".txt-custom-light .inline-block") %>%
  html_text2()

df <- data.frame(
  book,
  price,
  author,
  rating,
  muadmu,
  descriptions
)

View(df)

write.csv(df, "Cloud\\project\\naiin.csv", row.names=FALSE)
