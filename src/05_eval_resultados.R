#####################################################################
## Descripcion: Evaluacion de resultados
##
## Fecha: 2021-05-12
## Autor: MH
#####################################################################

library(tidyverse)

source('src/02_split_dta.R')

dta_group <- dta_train %>% 
  group_by(steamid) %>% 
  arrange(-playtime_forever)


dta_arranged <-  dta_train %>% 
  arrange(steamid, -playtime_forever)


set.seed(987654321)
sample_usuarios <- dta_arranged %>% 
  distinct(steamid) %>% 
  sample_frac(.025) %>% 
  pull(steamid)

dta_sample <-  dta_arranged %>% 
  filter(steamid %in% sample_usuarios)

dt2 <- dta_sample %>% 
  group_by(steamid) %>% 
  mutate(pos = row_number())



dt2 %>% 
  mutate(pctile = pos/max(pos)) %>% 
  select(-pos) %>% 
  group_by(app_name) %>% 
  # mutate(rank_p = cumsum(pos*pctile)/cumsum(pos)) %>% #Creo?
  summarise(sum_r_x_pctile = sum(playtime_forever*pctile),
            sum_r = sum(playtime_forever)) %>% #Creo?
  mutate(rank_j = sum_r_x_pctile/sum_r) %>% 
  arrange(rank_j) %>% 
  summarise(rank = weighted.mean(rank_j, sum_r)) %>% 
  print(n = 29)

