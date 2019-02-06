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
                      col.names = c("indep", "dem", "rep"))

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
  mutate(distict = row_number())
