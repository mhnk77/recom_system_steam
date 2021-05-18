#####################################################################
## Descripcion: Evaluacion de resultados
##
## Fecha: 2021-05-15
## Autor: MH
#####################################################################

library(tidyverse)


file_list <- list.files("cache/predictions_results/")

evalua_preds <- function(in_file){
  
  predictions_tib <- read_rds(paste0("cache/predictions_results/", in_file))
  
  eval <- predictions_tib %>% 
    arrange(steam_id, -prediction) %>% 
    group_by(steam_id) %>% 
    mutate(pos = row_number())%>% 
    mutate(pctile =  (pos-1)/(max(pos)-1)) %>% 
    ungroup()
  
  # rank_ui <- eval %>% 
   
  
  rank <- eval %>% 
    drop_na() %>%
    mutate(numerador = playtime_forever*pctile) %>% 
    group_by(steam_id) %>%
    summarise(sum_rui = sum(playtime_forever),
              rank_ui = sum(numerador)/sum_rui) %>% 
    summarise(rank = weighted.mean(rank_ui, sum_rui))
  
  print(Sys.time())
  return(rank)
  
}

res <- file_list %>% 
  enframe(NULL, "file_cache") %>% 
  mutate(rank = map(file_cache, evalua_preds))%>% 
  unnest(rank)

extra_row1 <- bind_cols(file_cache = "preds_alpha10_rank160_lambda150.rds",
                       rank = evalua_preds("preds_alpha10_rank160_lambda150.rds"))

extra_row2 <- bind_cols(file_cache = "preds_alpha20_rank160_lambda1.rds",
                       rank = evalua_preds("preds_alpha20_rank160_lambda1.rds"))
res_final <- res %>%
  bind_rows(extra_row1, extra_row) %>% 
  arrange(rank) 

res_final %<>% 
  separate(file_cache, c("preds", "alpha", "rank", "lambda"))  %>% 
  bind_cols(rank_val = res_final$rank)

#long
res_final %>% 
  select(-preds) %>% 
  mutate_at(vars(alpha, rank, lambda), ~as.numeric(str_extract(.,"\\d+"))) %>% 
  # pivot_wider(names_from = "rank", values_from = "rank_val") %>% 
  arrange(rank, alpha, lambda) %>% 
  select(rank, alpha, lambda, rank_val) %>% 
  clipr::write_clip()
  
#Wide
res_final %>% 
  select(-preds) %>% 
  mutate_at(vars(alpha, rank, lambda), ~as.numeric(str_extract(.,"\\d+"))) %>% 
  pivot_wider(names_from = "rank", values_from = "rank_val") %>% 
  arrange(alpha, lambda) %>% 
  copi
