library(tidyverse)


training <- readRDS('cache/training.rds')
cat_apps <- readRDS('cache/cat_apps.rds')

training_gms <-  training %>% 
  left_join(cat_apps) 

missing_gms <-  c("Metro 2033", "Burnout Paradise: The Ultimate Box", "Nosgoth", "Grand Theft Auto: San Andreas",
  "Red Orchestra 2: Heroes of Stalingrad Beta", "Strike Vector","Loadout", "Defiance", "Firefall",
  "HAWKEN", "Magic 2014", "Mortal Kombat Komplete Edition", "Magic: The Gathering - Duels of the Planeswalkers",
  "Rochard","Magic: The Gathering — Duels of the Planeswalkers","Test Drive Unlimited 2","SiN Multiplayer",
  "Midnight Club II","Section 8: Prejudice","Magic: The Gathering - Duels of the Planeswalkers",
  "Transformers: War for Cybertron","Galcon Fusion","Driver San Francisco",
  "Spintires","Woodle Tree Adventures","La Tale","Magic 2015","Sam & Max 101: Culture Shock",
  "Sam & Max 102: Situation: Comedy","Sam & Max 103","Shoot Many Robots","1... 2... 3... KICK IT!",
  "Sam & Max 105","Sam & Max 106", "Transformers","Sam & Max 104","Royal Quest","DARK BLOOD ONLINE","Obulis",
  "F1 2010","The Banner Saga: Factions","Day One: Garry's Incident","GRID Autosport","F1 2011","Prime World",
  "Amazing World","Blacklight: Tango Down","Grand Theft Auto: San Andreas","Forsaken World","Frontline Tactics","Space Siege",
  "Pressure","Wild Metal Country","Anno 1404","RISK Factions","Shadow Man", "City of Steam: Arkadia","Dawn of Discovery",
  "War of the Immortals","Pole Position 2012","NASCAR The Game: 2013","Conquest of Champions","Clickr",
  "Dawn of Discovery - Venice","Aztaka","Anno 1404: Venice",
  "Reaxxion","Minimum","Rocket Mania!","Evolution RTS","Rescue: Everyday Heroes","Warhammer 40,000: Kill Team",
  "Magical Drop V","Vox","Entropy","YOU DON'T KNOW JACK","Monopoly","Blazing Angels 2","Manhunter",
  "Mad Riders","Max Payne","Doctor Who: The Eternity Clock","BlackSoul Extended Edition","Cabelas Trophy Bucks",
  "Cloudberry Kingdom","Dysan the Shapeshifter","Farming Giant","Risk","Doctor Who: The Adventure Games",
  "Cabela's Big Game Hunter Pro Hunts","Vancouver 2010","Catan","Arcadia","Glare",
  "Max Payne 2","BIT.TRIP FLUX","Pat & Mat","Zooloretto","Racing Manager 2014","Always Sometimes Monsters Demo",
  "Zombies Monsters Robots","NASCAR '14","Pixel Boy and the Ever Expanding Dungeon","Cabela's® Dangerous Hunts 2013",
  "TRANSFORMERS: Rise of the Dark Spark", "Colin McRae Rally","Super Splatters","Cabela's® Hunting Expeditions",
  "Cabela's African Adventures","The Game of Life","Total Pro Golf 3","Nancy Drew: Ransom of the Seven Ships",
  "Chernobyl Commando","PAC-MAN MUSEUM","Vlad the Impaler","PAC-MAN","Super Comboman", "Sky Nations","Young Justice: Legacy",
  "Epic Space","Battleship","Scrabble","MEVO & the Grooveriders","PCMark 8","Rover Rescue","Max Payne 2","RIDGE RACER",
  "Cloud Chamber","Mahjong Towers Eternity","Forsaken Uprising","Counter-Strike Global Offensive","Maya LT","Bedlam",
  "Psichodelya","Ford Racing 3","DOOM 4","Conversion")

cat_apps_patch <- training_gms %>% 
  filter(is.na(app_name)) %>% 
  count(appid) %>% 
  arrange(-n) %>% 
  mutate(app_name = missing_gms) %>% 
  select(-n)
  
patched_cat_apps <- cat_apps %>% 
  bind_rows(cat_apps_patch) %>% 
  arrange(appid)


patched_cat_apps %>% 
  saveRDS('cache/cat_apps_def.rds')

# Igual con validation ---------------------------------------------------

validation <- readRDS('cache/validation.rds')

validation %>% 
  left_join(patched_cat_apps) %>% 
  filter(is.na(app_name))


