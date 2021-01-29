library(worldfootballR)
library(tidyverse)

countries <- c("ENG", "ITA", "FRA", "GER", "ESP")

league_table <- get_season_team_stats(country = countries, gender = "M", season_end_year = c(2018:2021), stat_type = "league_table")
saveRDS(league_table, "league_table.rds")

passing <- get_season_team_stats(country = countries, gender = "M", season_end_year = c(2018:2021), stat_type = "passing")
saveRDS(passing, "passing.rds")