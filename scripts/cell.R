# Load in libraries
library(pacman)
pacman::p_load(tidyverse, rstudioapi)

# Load in the data from the correct directory
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path))
safegraph_base <- 
  "../raw_data/safegraph/ID-CORE_POI-PATTERNS-2021_0%d-2021-10-18"
mydir <- sprintf(safegraph_base,7)
filename <- sprintf("%s/core_poi-patterns.csv",mydir)
df <- read_csv(filename)