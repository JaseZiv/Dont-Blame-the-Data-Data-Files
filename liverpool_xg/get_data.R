# libraries
# devtools::install_github("JaseZiv/worldfootballR")
library(tidyverse)
library(worldfootballR)


# Match Results -----------------------------------------------------------

xg_data <- get_match_results(country = "ENG", gender = "M", season_end_year = c(2018:2021))
saveRDS(xg_data, "xg_data.rds")


# League Table ------------------------------------------------------------

end_season_summary <- get_season_team_stats(country = "ENG", gender = "M", season_end_year = c(2018:2021), stat_type = "league_table")
saveRDS(end_season_summary, "season_summary.rds")