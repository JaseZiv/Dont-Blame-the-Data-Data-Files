library(httr)
library(tidyverse)
library(xml2)
library(rvest)

#=======================================================================================================
# Scrape ATP Tournament Results -----------------------------
#=======================================================================================================


results <- data.frame()
atp_seasons <- c(2001:2023)


for(j in atp_seasons) {
  Sys.sleep(2)
  res <- read.csv(paste0("https://github.com/JeffSackmann/tennis_atp/raw/master/atp_matches_", j, ".csv"))
  # res <- results %>% filter(tourney_name == "Australian Open")
  res <- res %>%
    mutate(winner_seed = as.numeric(winner_seed),
           loser_seed = as.numeric(loser_seed))
  results <- bind_rows(results, res)
}


# only keep grand slams
grand_slams <- results %>% filter(tourney_level == "G")

# save file
write.csv(grand_slams, "grand_slams.csv", row.names = F)

# make a df with columns that will be used in the scraping of elo ratings:
tourn_start <- grand_slams %>%
  group_by(tourney_id, tourney_name) %>%
  summarise(start_date = min(tourney_date)) %>% arrange(start_date) %>% ungroup() %>%
  mutate(start_date = lubridate::ymd(start_date),
         formatted_date = format(as.Date(start_date),'%d-%m-%Y'),
         tourney_year = gsub("-.*", "", tourney_id)) %>%
  mutate(rankType = case_when(
    tourney_name %in% c("Australian Open", "US Open", "Us Open") ~ "HARD_ELO_RANK",
    tourney_name == "Roland Garros" ~ "CLAY_ELO_RANK",
    tourney_name == "Wimbledon" ~ "GRASS_ELO_RANK"
  ))



#=======================================================================================================
# Scrape ELO ratings by relevant surface type -----------------------------
#=======================================================================================================

elo_df_grand_slams_surface <- data.frame()


for(i in 1:nrow(tourn_start)) {
  print(paste0("scraping date ", tourn_start$formatted_date[i]))
  params2 = list(
    `current` = "1",
    `rowCount` = "500",
    `sort[rank]` = "asc",
    `searchPhrase` = "",
    `rankType` = tourn_start$rankType[i],
    `season` = tourn_start$tourney_year[i],
    `date` = tourn_start$formatted_date[i]
  )

  # res2 <- httr::GET(url = "https://www.ultimatetennisstatistics.com/rankingsTableTable", httr::add_headers(.headers=headers2), query = params2, httr::set_cookies(.cookies = cookies2))
  Sys.sleep(3)
  res2 <- httr::GET(url = "https://www.ultimatetennisstatistics.com/rankingsTableTable", query = params2)

  b <- content(res2)

  # b$rows %>% bind_rows() %>% head()
  #
  #
  # "https://www.ultimatetennisstatistics.com/tournamentEvent?tournamentEventId=4527&tab=results"


  elo <- b$rows %>% bind_rows()

  # sometimes, the Elo rating is for the day beafore the tournament starts, so need error handling
  # to pass the day before if the initial scrape fails
  if(nrow(elo) == 0) {

    retry_date <- tourn_start$formatted_date[i] %>% lubridate::dmy() -1
    retry_date <- format(retry_date,'%d-%m-%Y')

    print(paste0("retrying date ", tourn_start$formatted_date[i]))
    params2 = list(
      `current` = "1",
      `rowCount` = "500",
      `sort[rank]` = "asc",
      `searchPhrase` = "",
      `rankType` = tourn_start$rankType[i],
      `season` = tourn_start$tourney_year[i],
      `date` = retry_date
    )

    # res2 <- httr::GET(url = "https://www.ultimatetennisstatistics.com/rankingsTableTable", httr::add_headers(.headers=headers2), query = params2, httr::set_cookies(.cookies = cookies2))
    Sys.sleep(3)
    res2 <- httr::GET(url = "https://www.ultimatetennisstatistics.com/rankingsTableTable", query = params2)

    b <- content(res2)

    elo <- b$rows %>% bind_rows()

  }
  # clean up data
  elo <- elo %>% distinct(playerId, .keep_all = T)
  elo$year_end <- tourn_start$tourney_year[i]
  elo$start_date <- tourn_start$start_date[i]
  elo$tourney_name = tourn_start$tourney_name[i]

  elo_df_grand_slams_surface <- bind_rows(elo_df_grand_slams_surface, elo)
}

# country column scrapes as a list, convert back to character
elo_df_grand_slams_surface$country <- as.character(elo_df_grand_slams_surface$country)

# save file
write.csv(elo_df_grand_slams_surface, "elo_df_grand_slams_surface.csv", row.names = F)


