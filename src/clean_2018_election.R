library(tidyverse)

election_2018 <- read_csv(here::here("data/results_2018.csv"),
                          col_names = FALSE)

# just need a lsit of winners

to_remove <- "Green check mark transparent.png | \\(i\\)"

reps_2018 <- election_2018 %>% 
  rename(result = X1) %>% 
  mutate(
    winner = if_else(str_detect(result, "Green check mark"), 1L, 0L),
    rep = str_replace_all(trimws(result), to_remove, "")
  ) %>% 
  select(rep, winner) %>% 
  filter(winner == 1)

write_csv(reps_2018, here::here("data/reps_2018.csv"))
