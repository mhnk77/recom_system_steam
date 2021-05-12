#####################################################################
## Descripcion: Exploratorio de los datos
##
## Fecha: 2021-05-12
## Autor: MH
#####################################################################

library(tidyverse)

theme_set(theme_minimal())

cat_limpio <- read_rds('cache/cat_apps_def.rds') %>% 
  mutate_at(vars(app_name), ~str_remove_all(., " Russian$| Korean$| Asian$| Asia$")) %>% 
  mutate_at(vars(app_name), ~str_remove_all(., "\\-|\\—|™|®"))

cat_limpio %>% 
  saveRDS('cache/cat_apps_limpio.RDS')

dta <- read_rds('cache/training.rds') %>% 
  left_join(cat_limpio)%>% 
  filter(playtime_forever > 0)

dta %>% 
  saveRDS('cache/data_clean.RDS')

medias_apps <- dta %>% 
  group_by(app_name) %>% 
  summarise(media_app = mean(playtime_forever), num_app = n()) %>% 
  arrange(-media_app)

#Juegos más importantes
medias_apps %>% 
  arrange(-num_app) %>% 
  head(500) %>% 
  arrange(-media_app) %>% 
  print(n = 99)

#Distribución horas de juego vs num de jugadores
medias_apps %>% 
  mutate(label)
  ggplot(aes(num_app, media_app))+
  geom_point(alpha = 0.1)+ 
  xlab("Número de jugadores") + 
  ylab("Promedio de horas jugadas") 

