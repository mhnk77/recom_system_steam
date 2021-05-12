library(tidyverse)

validation <- read_tsv('data/dta_1_200k_ids.csv',
                       col_types = list(col_character(), col_double(), col_double())) %>% 
  drop_na()


training <- read_tsv('data/dta_2_800k_ids.csv',
                     col_types = list(col_character(), col_double(), col_double()))

validation %>% saveRDS('cache/validation.rds')

training %>% saveRDS('cache/training.rds')

cat_apps <- read_csv('https://raw.githubusercontent.com/dgibbs64/SteamCMD-AppID-List/master/steamcmd_appid.csv',
                     col_names = c("appid", "app_name"))


cat_apps %>% saveRDS('cache/cat_apps.rds')


