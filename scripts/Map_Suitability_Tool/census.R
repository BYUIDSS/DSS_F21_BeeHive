library(pacman)
pacman::p_load(acs, tidyverse, tidycensus, maps, sf, leaflet)
library(shiny)

get_leaflet_map <- function(my_city, radius=5, var=1){
cities <- read_csv("../raw_data/uscities.csv")
id_cities <- cities %>% filter(state_id == "ID")
my_city <- cities %>% filter(city == my_city)
my_county <- my_city$county_name
coords <- c(my_city$lat,my_city$lng)
lat_radius <- radius / 69
lng_radius <- radius / 58


# https://walker-data.com/tidycensus/articles/basic-usage.html
api_key <- "0838892edce89bd9cad0150022aa9b0ef303fc6c"
api.key.install(api_key)
acs_vars <- load_variables(2010, "acs5", cache=TRUE)
cen_vars <- load_variables(2020, "pl",cache=TRUE)
# B19013_001 Median household income in the past 12 months
# B07001_001 Total geographical mobility
# B07001_017 Same house 1 yr ago
# B25034_001 Year structure built
# B25034_002 Built 2005 or later
# B25035_001 Median year structure built
# 4326 is rectangular projection
# Year built seems to work for block group, but mobility only for tract
#(which is) larger

b_data <- get_acs(
  geography="block group",year=2019,
  variables=c(medincome="B19013_001",pop="B01001_001",
              total_mobility="B07001_001",same_house="B07001_017",
              yr = "B25034_001", yr_new = "B25034_002"),
  state="ID",county=my_county,geometry=TRUE)

# Clean up data and create geometries
geometries <- b_data %>% select(GEOID, geometry) %>% distinct()
c_data <-
  b_data %>%
  mutate(area = st_area(.)) %>%
  st_drop_geometry() %>%
  select(-moe) %>%
  mutate(area_mi = as.numeric(area)/2.59e+6) %>%
  pivot_wider(names_from="variable",values_from="estimate") %>%
  mutate(pop_dens = pop/area_mi) %>%
  mutate(growth = 1 - (same_house/total_mobility)) %>%
  mutate(percent_new = yr_new/yr)
c_data$geometry = geometries$geometry

# https://rpubs.com/ials2un/leaflet_thin

# Graph it, based on the variable we chose
dat <- NA
if(var == 1)dat = c_data$percent_new
if(var == 2)dat = c_data$pop_dens
if(var == 3)dat = c_data$medincome
pal <- colorNumeric("Blues",domain=dat)
mymap <- leaflet(st_as_sf(c_data,crs=st_crs("+proj=longlat +datum=WGS84"))) %>%
  addPolygons(
    fillColor=~pal(dat),
    weight=0.5,
    fillOpacity=0.6
  ) %>%
  addTiles()
  # %>% setView(coords[1],coords[2], zoom=18)
  #fitBounds(coords[1]-lat_radius, coords[2]-lng_radius,
  #          coords[1]+lat_radius, coords[2]+lat_radius)
return(mymap)
}

#get_leaflet_map("Idaho Falls", 5, 1)
