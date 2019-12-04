library(rvest)
library(tidyverse)
library(lubridate)

# get the last part of url string for each team
all_teams_url <- read_html("https://www.footywire.com/afl/footy/ft_teams") %>% html_nodes("form a") %>% html_attr("href") %>% str_replace("th", "tp")

# create an empty dataframe
age_table <- data.frame()

# loop through and scrape data
for(each in all_teams_url) {
  url <- read_html(paste0("https://www.footywire.com/afl/footy/", each))
  a <- url %>% html_table(".data", fill = T, header = T)
  a <- a[10]
  a <- data.frame(a)
  team <- rep(each, nrow(a)) 
  each_team_table <- cbind(team, a)
  
  age_table <- bind_rows(age_table, each_team_table)
}


###########################################################################
# Preprocessing -----------------------------------------------------------
###########################################################################
age_table <- age_table %>% 
  mutate(Date.of.Birth. = as.Date(Date.of.Birth., format = "%d %B %Y")) %>% # convert DOB to date type
  mutate(age_start_season = as.numeric((ymd("2020-03-19") - Date.of.Birth.) / 365)) # calculate the age of the player at the start of the season

age_table <- age_table %>% 
  mutate(team = str_replace(team, "tp-", "") %>% str_replace("-", " ") %>% toupper()) # clean up the team name and convert to uppercase


write.csv(age_table, "afl_player_age.csv", row.names = FALSE)
  
