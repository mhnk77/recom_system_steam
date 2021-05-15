#####################################################################
## Descripcion: sec
##
## Fecha: 2021-05-13
## Autor: MH
#####################################################################

# devtools::install_github('apache/spark@v3.1.1', subdir = 'R/pkg')

library(tidyverse)
library(SparkR, pos = 999999)

sparkR.session(master = "local[*]", sparkConfig = list(spark.driver.memory = "9g"))

# Cargar datos a local ----------------------------------------------------
# cat_apps_numeric <- readRDS('cache/cat_apps_numeric.rds')
# cat_users_numeric <- readRDS('cache/cat_users_numeric.rds')
# 
# #Transformar a numericas todas las variables
# dta_train <- read_rds('cache/dta_train.RDS') %>% 
#   left_join(cat_apps_numeric) %>% 
#   left_join(cat_users_numeric) %>% 
#   dplyr::select(-app_name, -steamid) %>% 
#   mutate_at(vars(playtime_forever), ~(./60)) #pasar a horas
# 
# dta_train %>% 
#   saveRDS('cache/dta_train_spark.RDS')

dta_train <- readRDS('cache/dta_train_spark.RDS')

# dta_test <- read_rds('cache/dta_validation.RDS') %>% 
#   left_join(cat_apps_numeric) %>% 
#   left_join(cat_users_numeric) %>% 
#   dplyr::select(-app_name, -steamid) %>% 
#   mutate_at(vars(playtime_forever), ~(./60)) #pasar a horas

# dta_test %>%  saveRDS('cache/dta_test_spark.RDS')

dta_test <- readRDS('cache/dta_test_spark.RDS')

train_tib <- as.DataFrame(dta_train)

model <- spark.als(train_tib, userCol = "steam_id", itemCol = "app_id",
                   ratingCol = "playtime_forever", alpha = 20, rank = 20,
                   implicitPrefs = TRUE, nonnegative = FALSE)


test_tib <- as.DataFrame(dta_test_eval)

predictions <- SparkR::predict(model, test_tib)
predictions_collect <- SparkR::collect(predictions)

predictions_tib <- predictions_collect %>% 
  as_tibble() %>% 
  filter(!is.nan(prediction))

predictions_tib %>% 
  saveRDS('cache/sandbox/preds_alpha20_rank20_neg_comp.RDS')
