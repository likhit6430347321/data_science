library(tidyverse)
library(ggplot2)
library(stringr)
library(dplyr)

appearances <- read_csv("/Users/slick/Downloads/archive-2/appearances.csv", )
values <- read_csv("/Users/slick/Downloads/archive-2/player_valuations.csv")
players <- read_csv("/Users/slick/Downloads/archive-2/players.csv")
competitions <- read_csv("/Users/slick/Downloads/archive-2/competitions.csv")

appearances <- appearances %>%
  select(player_id,
         player_name, 
         competition_id, 
         yellow_cards, 
         red_cards, 
         goals, 
         assists, 
         minutes_played)

values <- values %>%
  select(player_id,
         current_club_id,
         market_value_in_eur,
         player_club_domestic_competition_id)

players <- players %>%
  select(player_id,
         current_club_id,
         current_club_name,
         country_of_citizenship,
         date_of_birth,
         position,
         foot,
         height_in_cm,
         current_club_domestic_competition_id)

competitions <- competitions %>%
  select(competition_id,
         name,
         type,
         country_name)



sum_players <- appearances %>%
  inner_join(values, by = "player_id", multiple = "all") %>%
  group_by(player_name, player_id) %>%
  summarise(
    yellow_cards = sum(yellow_cards),
    red_cards = sum(red_cards),
    goals = sum(goals),
    assists = sum(assists),
    total_minutes_played = sum(minutes_played),
    market_value_eur = max(market_value_in_eur)
  ) %>%
  left_join(players, by = c("player_id" = "player_id")) %>%
  left_join(competitions, by = c("current_club_domestic_competition_id" = "competition_id"))

  
sum_players[c("year_of_birth", "month_of_birth", "date_of_birth")] <- str_split_fixed(sum_players$date_of_birth, "-", 3)

sum_players$age <- 2023 - as.numeric(sum_players$year_of_birth)

# average height by country

average_height_by_country <- sum_players %>%
  group_by(country_of_citizenship) %>%
  summarise(heights = mean(height_in_cm[height_in_cm > 0], na.rm = TRUE)) %>%
  na.omit()

ggplot(average_height_by_country, aes(x = heights)) +
  geom_histogram(binwidth = 2, fill = "#F24645") +
  labs(title = "Distribution of Average Height by Country", 
       x = "Average Height (cm)", 
       y = "Frequency")+
  theme_minimal()

# average height by age

sum_players %>%
  group_by(position) %>%
  na.omit() %>%
  ggplot(aes(x = position, y = height_in_cm)) +
  geom_boxplot(fill = "#F24645") +
  ylim(155, NA) +
  labs(title = "Height Distribution of Footballers by Position", 
       y = "Heights (cm)")







