#'[Mapa animado das cidades]

# bibliotecas utilizadas
library(data.table)
library(leaflet)
library(geobr)
library(lubridate)
library(tidyverse)
library(gganimate)
library(transformr)
library(av)
library(ggspatial)
source("calcula_mm.R")



# leitura dos dados diretamente do github
dados_cidades <- fread("https://github.com/wcota/covid19br/raw/master/cases-brazil-cities-time.csv.gz")

# formata a data
dados_cidades$date <- as_date(dados_cidades$date)

# dados das cidades do BR
sf <- read_municipality()

# une as duas bases
sf_covid <- inner_join(dados_cidades, sf, by = c("ibgeID" = "code_muni"))

# plot de teste
sf_covid |> filter(date == "2021-03-23")|> ggplot() +
  geom_sf(aes(fill = newCases, geometry = geom),color = NA)

# criando o group necessario para animar
sf_covid$group<- as.numeric(sf_covid$date - min(sf_covid$date))

# cria o grafico animado
gpl1 <- sf_covid |>  filter(group %in% c(380,384))|>
  ggplot() +
  geom_sf(aes(fill = newCases,group = group ,geometry = geom),color = NA)+
  ggtitle("Novos casos diários", subtitle = "{frame_time}")+
  transition_time(date)

# faz a animação (nao testei ainda)
ani <- animate(gpl1)

