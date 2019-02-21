library(tidyverse)

# functions ------------------

# import --------------------

bill_votes <- read_csv(here::here("data/bill_votes.csv"))

bills <- read_csv(here::here("data/pa house bills 2017-18.csv"))

election <- read_csv(here::here("data/election_results.csv"))

# merge -----------------------

election %>% 
  filter(pct_dem > 0.5) %>% 
  mutate(name = str_split(dem, " "),
         name = lapply(name, "[", -1)) %>% View()
  