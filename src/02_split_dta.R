#####################################################################
## Descripcion: Crear conjunto de validacion y conjunto de entrenamiento
##
## Fecha: 2021-05-12
## Autor: MH
#####################################################################

library(tidyverse)

dta <- read_rds('cache/data_clean.RDS')

cat_apps_numeric <- dta %>% 
  dplyr::distinct(app_name) %>% 
  dplyr::arrange(app_name) %>% 
  rowid_to_column("app_id")

cat_apps_numeric %>% 
  saveRDS('cache/cat_apps_numeric.rds')

cat_users_numeric <- dta %>% 
  dplyr::distinct(steamid) %>% 
  dplyr::arrange(steamid) %>% 
  rowid_to_column("steam_id")

cat_users_numeric %>% 
  saveRDS('cache/cat_users_numeric.rds')

set.seed(987654321)

usuarios_val <- dta %>% 
  distinct(steamid) %>% 
  sample_frac(.5)

set.seed(987654321)
apps_val <- dta %>% 
  distinct(app_name) %>% 
  sample_frac(.5)


dta_val <- dta %>% 
  semi_join(usuarios_val, by = "steamid") %>% 
  semi_join(apps_val, by = "app_name")


dta_val %>% saveRDS('cache/dta_validation.RDS')

dta_train <- dta %>% 
  anti_join(dta_val, by = c("steamid", "playtime_forever", "app_name"))

nrow(dta_val)/nrow(dta)


dta_train %>% saveRDS('cache/dta_train.RDS')

