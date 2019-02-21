library(tidyverse)
library(rvest)
library(RSelenium)
library(googledrive)

# functions -------------------------

# START SELENIUM SERVER FIRST BEFORE RUNNING THIS
# in terminal: "java -jar selenium-server-standalone-2.53.1.jar -port 5556"

# opens the browser
browser <- remoteDriver(port = 5556, browser = "phantomjs")
browser$open(silent = FALSE)

scrape_votes <- function(url, bill) {
  
  browser$navigate(url)
  
  yays <- read_html(browser$getPageSource()[[1]]) %>% 
    html_nodes(".icon-thumbs-up") %>% 
    html_text() %>% 
    trimws()
  
  nays <- read_html(browser$getPageSource()[[1]]) %>% 
    html_nodes(".icon-thumbs-up-2") %>% 
    html_text() %>% 
    trimws()
  
  votes <- tibble(
    bill = bill,
    rep = c(yays, nays),
    vote = c(rep("yay", length(yays)), rep("nay", length(nays)))
  )
  
  votes[votes$rep != "", ]

}

# import bills and url ------------------------

drive_download(
  as_id("1wmfqOo1KQWru6puuqdkWR9CGramN_xfqwYBNUVlOSRM"),
  here::here("data/pa house bills 2017-18.csv"),
  overwrite = TRUE
)

bills <- read_csv(here::here("data/pa house bills 2017-18.csv"))

# scrape and write ---------------------------

bill_votes <- map2_dfr(bills$url, bills$bill, scrape_votes)

write_csv(bill_votes, here::here("data/bill_votes.csv"))
