#Evaluar una muestra aleatoria de juegos, para cada usuario, para obtener random rankings

#Tomar los 40 juegos más populares y ver cómo cambia

# games_pool <-  dta_train %>% 
#   group_by(app_id) %>% 
#   summarise(tot_playtime = sum(playtime_forever)) %>% 
#   arrange(-tot_playtime) %>%
#   head(250) %>% 
#   pull(app_id)


# sample_gms <- function(id) base::sample(games_pool,40, replace = F)

# random_pred_test <-  dta_test %>% 
# distinct(steam_id) %>% 
# mutate(app_id = map(steam_id, sample_gms)) %>% 
# unnest(app_id)

# dta_test_eval <- random_pred_test %>% 
#   bind_rows(dta_test)

# dta_test_eval %>% saveRDS('cache/dta_test_eval.rds')

# Evaluacion de resultados ------------------------------------------------

# Juntar predicciones del test set con predicciones de 20 juegos random por usuario
cat_apps_numeric <- readRDS('cache/cat_apps_numeric.rds')

eval <- predictions_tib %>% 
  # bind_rows(predictions_rdm_tib) %>% 
  arrange(steam_id, -prediction) %>% 
  group_by(steam_id) %>% 
  mutate(pos = row_number())%>% 
  mutate(pctile =  (pos-1)/(max(pos)-1)) %>% 
  ungroup()

eval %>% 
  print(n = 99)

rank_ui <- eval %>% 
  drop_na() %>% #print(n = 99)
  mutate(numerador = playtime_forever*pctile) %>% 
  group_by(steam_id) %>% 
  summarise(rank = sum(numerador)/sum(playtime_forever)) %>% 
  arrange(-rank)

rank_ui %>% 
  ggplot(aes(rank))+geom_histogram()

rank_ui %>% 
  filter(rank == 1)

eval %>% 
  drop_na() %>%
  mutate(numerador = playtime_forever*pctile) %>% 
  group_by(steam_id) %>%
  summarise(sum_rui = sum(playtime_forever),
            rank_ui = sum(numerador)/sum_rui) %>% 
  summarise(rank = weighted.mean(rank_ui, sum_rui))

id_val <- 159 #57 lo hace bien #159 lo hace mal

dta_train %>% 
  filter(steam_id == id_val) %>% 
  left_join(cat_apps_numeric) %>% 
  print(n = 99)


eval %>% 
  filter(steam_id == id_val) %>% 
  left_join(cat_apps_numeric) %>% 
  print(n = 99)

  

