library(tidyverse)
library(rvest)

url <- "https://www.legis.state.pa.us/CFDOCS/Legis/RC/Public/rc_view_action2.cfm?sess_yr=2017&sess_ind=0&rc_body=H&rc_nbr=1271"

# START SELENIUM SERVER FIRST BEFORE RUNNING THIS
# in terminal: "java -jar selenium-server-standalone-2.53.1.jar -port 5556"

# opens the browser
browser <- remoteDriver(port = 5556, browser = "phantomjs")
browser$open(silent = FALSE)

browser$navigate(url)
  
yays <- read_html(browser$getPageSource()[[1]]) %>% 
  html_nodes(".icon-thumbs-up") %>% 
  html_text() %>% 
  trimws()

nays <- read_html(browser$getPageSource()[[1]]) %>% 
  html_nodes(".icon-thumbs-up-2") %>% 
  html_text() %>% 
  trimws()
