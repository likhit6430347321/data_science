library(tidyverse)
library(rvest)
library(ggplot2)

url <- "https://www.officialcharts.com/charts/singles-chart/"

songs <- url %>%
  read_html() %>%
  html_elements(".title a") %>%
  html_text2()

records <- url %>%
  read_html() %>%
  html_elements(".label-cat .label") %>%
  html_text2()

artists <- url %>%
  read_html() %>%
  html_elements(".artist a") %>%
  html_text2()

peak_pos <- url %>%
  read_html() %>%
  html_elements("td:nth-child(4)") %>%
  html_text2() %>%
  as.numeric()

WoC <- url %>%
  read_html() %>%
  html_elements("td:nth-child(5)") %>%
  html_text2() %>%
  as.numeric()

LW <- url %>%
  read_html() %>%
  html_elements(".last-week") %>%
  html_text2() %>%
  str_replace_all("\r", "") %>%
  as.numeric() ## return NA for non-numeric value

pos <- url %>%
  read_html() %>%
  html_elements(".position") %>%
  html_text2() %>%
  as.numeric()

top100 <- data.frame(
  songs,
  artists,
  records,
  pos,
  peak_pos,
  LW
)


record_count <- top100 %>%
  group_by(records) %>%
  tally() 

record_count <- record_count[record_count$n != 1, ]

ggplot(record_count, aes(records, n)) + geom_bar(stat = "identity", fill = "#003f5c") +
  labs(title = "Frequency of Records with more than one song in Top 100 songs", x = "Records", y = "Frequency") +
  theme(axis.text.x = element_text(angle = 90))
