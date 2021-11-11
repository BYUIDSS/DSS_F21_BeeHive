library(pacman)
pacman::p_load(tidyverse, tidycensus, httr, jsonlite)

branches <- read_csv("../raw_data/branches.csv")
base_url <- 
  "https://geo.fcc.gov/api/census/block/find?latitude=%f&longitude=%f&format=json"

branches <- branches %>%
  mutate(url = sprintf(base_url, Lat, Long)) %>%
  rowwise() %>%
  mutate(txt = rawToChar(GET(url)$content)) %>%
  mutate(blockid = fromJSON(txt)$Block$FIPS) %>%
  mutate(block_group_id = substr(blockid, 1, 12)) %>%
  ungroup() %>%
  select(-c(url,txt,blockid))

census_data <- get_acs(geography="block group",year=2019,
                        variables=c(medincome="B19013_001"),
                        state="ID",geometry=FALSE)