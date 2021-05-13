#####################################################################
## Descripcion: Constuir predicciones y evaluar
##
## Fecha: 2021-05-12
## Autor: MH
#####################################################################

library(tidyverse)

source('src/02_split_dta.R')

recm <- function(calif, pred) sqrt(mean((calif - pred)^2))


pred_medias <- dta_train %>% 
  group_by(app_name) %>% 
  summarise(media_pred = mean(playtime_forever))


media_total_e <-  dta_train %>% 
  summarise(media = mean(playtime_forever)) %>% 
  pull(media)


dta_val_pred <-  dta_val %>% 
  left_join(pred_medias)

#Contar cuantas predicciones vacias hay
dta_val_pred %>% filter(is.na(media_pred)) %>% nrow()

#Sustituir con media general
dta_val_pred <- dta_val_pred %>% 
  mutate_at(vars(media_pred), ~replace_na(., media_total_e))

#Medir error.
dta_val_pred %>% 
  summarise(error = recm(playtime_forever, media_pred))


sample_usuarios <- dta_val %>% 
  distinct(steamid) %>% 
  sample_n(50) %>% 
  pull(steamid)

dta_val %>% 
  filter(steamid %in% sample_usuarios) %>% 
  group_by(steamid) %>% 
  mutate(mean = mean(playtime_forever)) %>% 
  ungroup() %>% 
  arrange(-mean) %>% 
  mutate(steamid = factor(steamid, levels = unique(.$steamid))) %>% 
  ggplot(aes(steamid, playtime_forever))+
  geom_point()+
  theme_minimal()+
  theme(axis.text.x=element_blank())





