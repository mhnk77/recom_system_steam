#####################################################################
## Descripcion: Automatizar proceso
##
## Fecha: 2021-05-14
## Autor: MH
#####################################################################

library(tidyverse)
library(SparkR, pos = 999999)


dta_train <- readRDS('cache/dta_train_spark.RDS')
dta_test <- readRDS('cache/dta_test_eval.rds')


#Cambiante

guarda_preds <- function(alpha_val = 40, rank_val = 20, lambda_val = 1){
  
  print("Iniciando sesion de spark ...")
  print(Sys.time())
  sparkR.session(master = "local[*]", sparkConfig = list(spark.driver.memory = "8g"))
  
  print("Cargando dfs...")
  print(Sys.time())
  train_tib <- as.DataFrame(dta_train)
  
  test_tib <- as.DataFrame(dta_test)
  
  print("Corriendo modelo...")
  print(Sys.time())
  model <- spark.als(train_tib, userCol = "steam_id", itemCol = "app_id",
                     ratingCol = "playtime_forever", alpha = alpha_val, rank = rank_val,
                     implicitPrefs = TRUE, regParam = lambda_val, nonnegative = FALSE)
  
  
  predictions <- SparkR::predict(model, test_tib)
  print("Collecting predicciones...")
  print(Sys.time())
  predictions_collect <- SparkR::collect(predictions)
  
  predictions_tib <- predictions_collect %>% 
    as_tibble() %>% 
    filter(!is.nan(prediction))
  
  
  ruta <- paste0('cache/predictions_results/preds_alpha',alpha_val,
                 '_rank',rank_val,'_lambda',lambda_val,'.rds')
  
  print("Guardando predicciones...")
  print(Sys.time())
  saveRDS(predictions_tib, ruta)
  
  sparkR.session.stop()
  gc()
  ruta <- paste0(ruta, "")
  
  return(ruta)
  
}

model_grid <- expand.grid(alphas = c(1),  ranks =  c(20,80), lambdas = c(1,150,500)) %>% 
  bind_rows(tibble(alphas = 1, ranks = 160, lambdas = 150)) %>% 
  tail(6)

pmap(.l  = list(model_grid$alphas, model_grid$ranks, model_grid$lambdas),
     .f = guarda_preds)



