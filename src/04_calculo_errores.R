#####################################################################
## Descripcion: sec
##
## Fecha: 2021-05-12
## Autor: MH
#####################################################################

library(tidyverse)

error_explicito <- function(uv){
  u <- matrix(uv[1:dim(imp_mat)[1]], ncol = 1)
  v <- matrix(uv[(dim(imp_mat)[1]+1):sum(dim(imp_mat))], ncol = 1)
  sum((imp_mat - u %*% t(v))^2)
}

error_implicito <- function(uv = uv_inicial){
  
  u <- matrix(uv[1:dim(imp_mat)[1]], ncol = 1)
  
  v <- matrix(uv[(dim(imp_mat)[1]+1):sum(dim(imp_mat))], ncol = 1)
  pref_mat <- as.numeric(imp_mat > 0) - u %*% t(v)
  confianza <- 1 + 10 * imp_mat
  sum(confianza * pref_mat^2 )
}

dta_train <- readRDS('cache/dta_train.RDS')

dta_train %>%

dta_wide <- dta_train %>% 
  group_by(steamid, app_name) %>% 
  summarise_at(vars(playtime_forever), ~sum(.)) %>% #Importante 
  pivot_wider(names_from = "app_name", values_from = "playtime_forever", values_fill = 0)
  

imp_mat <-  dta_wide %>% 
  ungroup() %>% 
  select(-steamid) %>% 
  as.matrix()

uv_inicial <- runif(sum(dim(imp_mat)))
opt_exp <- optim(par = uv_inicial, error_explicito, method = "BFGS")

opt_exp$par[7:9]


