library(tidyverse)
library(rvest)
library(RSelenium)


url <- "https://ballotpedia.org/Pennsylvania_House_of_Representatives_elections,_2016"

# START SELENIUM SERVER FIRST BEFORE RUNNING THIS
# in terminal: "java -jar selenium-server-standalone-2.53.1.jar -port 5556"

# opens the browser
browser <- remoteDriver(port = 5556, browser = "phantomjs")
browser$open(silent = FALSE)

browser$navigate(url)

page_text <- read_html(browser$getPageSource()[[1]]) %>% 
  html_nodes("td+ td , td+ td") %>% 
  html_text() %>% 
  .[41:length(.)] %>% 
  paste(., collapse = "")

results <- read.delim(text = page_text, header = FALSE,
                      col.names = c("indep", "dem", "rep"),
                      stringsAsFactors = FALSE)

# move independents up a row
indeps <- results %>% 
  mutate(row_number = row_number() - 1) %>% 
  filter(indep != "") %>% 
  select(-dem, -rep)

all <- results %>% 
  mutate(row_number = row_number()) %>% 
  filter(indep == "") %>% 
  select(-indep) %>% 
  left_join(indeps, by = "row_number") %>% 
  select(-row_number) %>% 
  mutate(district = row_number(),
         indep = if_else(district == length(district), NA_character_, indep))

votes <- all %>% 
  mutate_at(vars(dem, rep, indep), function(x) str_replace_all(x, ",", "")) %>%
  mutate_at(vars(dem, rep, indep), function(x) str_extract(x, "\\d+")) %>% 
  rename(dem_votes = dem, rep_votes = rep, indep_votes = indep) %>% 
  mutate_at(vars(ends_with("votes")), as.numeric)

all_votes <- all %>% 
  mutate_at(vars(dem, rep, indep), function(x) str_replace_all(x, ",", "")) %>% 
  mutate_at(vars(dem, rep, indep), function(x) str_replace_all(x, ": \\d+", "")) %>% 
  mutate_at(vars(dem, rep, indep), function(x) str_replace(x, " \\(I\\)", "")) %>% 
  mutate_at(vars(dem, rep, indep), trimws) %>% 
  mutate_at(vars(dem, rep, indep), function(x) str_replace(x, " a$|  a$", "")) %>% 
  full_join(votes, by = "district") %>% 
  replace_na(list(dem_votes = 0, rep_votes = 0, indep_votes = 0)) %>% 
  mutate(
    pct_dem = dem_votes / (dem_votes + rep_votes + indep_votes),
    pct_dem = case_when(
      is.nan(pct_dem) & dem == "No candidate" ~ 0,
      is.nan(pct_dem) & rep == "No candidate" ~ 1,
      TRUE ~ pct_dem
    )
  )

write_csv(all_votes, here::here("data/election_results.csv"))
