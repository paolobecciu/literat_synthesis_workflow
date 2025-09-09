renv::init()
install.packages(c("targets","tidyverse","readxl","janitor","stringr","stringdist","fuzzyjoin","revtools","metagear","bibliometrix","PRISMA2020","lubridate","ggplot2","quanteda","yaml")) 
renv::snapshot()

# targets gives you a deterministic pipeline; 
# revtools/metagear handle dedup + screening; 
# bibliometrix eats WoS exports; 
# PRISMA2020 produces the flow diagram; 
# quanteda handles dictionary tagging.