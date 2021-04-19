library(worldfootballR)
library(tidyverse)

# code to get data using worldfootballR
aleague <- get_match_results(country = "AUS", gender = "M", season_end_year = c(2014:2021))

# remove any games not yet played
aleague <- aleague %>% 
  filter(!is.na(HomeGoals)) %>% 
  arrange(Season_End_Year, Date) %>% 
  distinct(Date, Home, Away, .keep_all = T)

# save data to minimise requests on fbref
saveRDS(aleague, here::here("elo", "bad-melb-victory", "aleague_results.rds"))




