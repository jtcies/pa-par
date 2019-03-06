library(tidyverse)
library(rvest)
library(RSelenium)

url <- "https://ballotpedia.org/Pennsylvania_House_of_Representatives_elections,_2018"

# START SELENIUM SERVER FIRST BEFORE RUNNING THIS
# in terminal: "java -jar selenium-server-standalone-2.53.1.jar -port 5556"

# opens the browser
browser <- remoteDriver(port = 5556, browser = "phantomjs")
browser$open(silent = FALSE)

browser$navigate(url)

page_text <- read_html(browser$getPageSource()[[1]]) %>% 
  html_nodes("td") %>% 
  magrittr::extract(16:826) %>% 
  html_text() %>% 
  paste0(collapse = "") %>% 
  str_replace_all(., "\\t", "")

#election_2018 <- 
  
read.delim(
    sep = "\n",
    text = page_text, 
    header = FALSE,
    stringsAsFactors = FALSE
)
