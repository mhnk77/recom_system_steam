#####################################################################
## Descripcion: Visualizar mejor modelo
##
## Fecha: 2021-05-16
## Autor: MH
#####################################################################

library(tidyverse)

# Obtener mejor modelo ----------------------------------------------------

preds <- read_rds('cache/predictions_results/preds_alpha1_rank160_lambda150.rds')

ranks_ui <- preds%>% 
  arrange(steam_id, -prediction) %>% 
  group_by(steam_id) %>% 
  mutate(pos = row_number())%>% 
  mutate(pctile =  (pos-1)/(max(pos)-1)) %>% 
  ungroup() %>% 
  drop_na() %>% 
  mutate(numerador = playtime_forever*pctile) %>%
  group_by(steam_id) %>%
  summarise(rank = sum(numerador)/sum(playtime_forever)) 


ranks_ui %>% 
  ggplot(aes(rank))+ 
  geom_histogram(fill = "deepskyblue4")+
  theme_minimal()+
  labs(title = "Distribución de rank por usuario",
       subtitle = "Evaluación del mejor modelo")+
  scale_x_continuous(labels = scales::percent)+
  ggsave('imgs/histograma_ranks_usuario.pdf', width = 8, height = 5)


ranks_ui %>% 
  arrange(-rank)


# Visualizar desempenio ---------------------------------

num_evals <-  preds %>% 
  drop_na() %>% 
  group_by(steam_id) %>%
  summarise(n = n(), tot_time = mean(playtime_forever)) %>% 
  arrange(-n) %>% 
  left_join(ranks_ui)

sample_proba <- Vectorize(function(n){
  
  if(n < 10) out_num <- rbinom(1,1,.01)
  else if (n<50) out_num <- rbinom(1,1,.1) 
  else if (n<100) out_num <- rbinom(1,1,.5)
  else out_num <- 1
  
  return(out_num)
})


plot_df <- num_evals %>% 
  mutate(ind = sample_proba(n)) %>% 
  filter(ind == 1) %>% 
  select(-ind)


plot_df %>% 
  ggplot(aes(n, rank))+
  geom_point(color = "deepskyblue4")+
  theme_minimal()+
  scale_y_continuous(labels = scales::percent)+
  labs(title = "Rank vs. número de juegos jugados por usuario",
       subtitle = "En conjunto de prueba",
    x = "Número de juegos")+
  ggsave('imgs/scatterplot_rank_numjuegos.pdf', width = 8, height = 5)
  

dta_train <- readRDS('cache/dta_train_spark.RDS')
cat_apps <- readRDS('cache/cat_apps_numeric.rds')

adictos_dota <- preds %>% 
  filter(!is.na(playtime_forever)) %>% 
  filter(app_id == 1045) %>% 
  filter(playtime_forever > 150) %>% 
  pull(steam_id)

num_evals %>% 
  filter(n < 50 & n > 10) %>% 
  filter(tot_time > 80) %>% 
  filter(!steam_id %in% adictos_dota) %>% 
  arrange(-rank) 


id_val <- 470126 #bad job 430917 #good job

dta_train %>% 
  filter(steam_id == id_val) %>% 
  arrange(-playtime_forever) %>% 
  left_join(cat_apps) %>% 
  select(-steam_id, - app_id) %>% 
  clipr::write_clip()
  print(n = 99)


preds %>% 
  filter(steam_id == id_val) %>% 
  arrange(-prediction)%>% 
  group_by(steam_id) %>% 
  mutate(pos = row_number())%>% 
  mutate(pctile =  (pos-1)/(max(pos)-1)) %>% 
  ungroup() %>% 
  select(-pos) %>% 
  left_join(cat_apps) %>% 
  drop_na() %>% 
  select(prediction, pctile, playtime = playtime_forever, app_name) %>% 
  clipr::write_clip()
  print(n = 99)
