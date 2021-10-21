#'[Mapa animado dos estados]


# bibliotecas utilizadas
library(data.table)
library(geobr)
library(tidyverse)
library(gganimate)
library(transformr)
library(av)
library(ggspatial)
# funcao para calcular a media movel
source("calcula_mm.R")

# leitura dos dados diretamente do github
dados_estados <- fread("https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv") |> calcula_mm()
dados_estados$date <- lubridate::as_date(dados_estados$date)


# geometrias dos estados
sf_states <- read_state()

# unir as duas bases
sf_covid_states <- inner_join(dados_estados, sf_states, by = c("state" = "abbrev_state"))

# plot teste de uma data especifica
sf_covid_states |> filter(date == "2021-03-23")|>
  ggplot() +
  geom_sf(aes(fill = var_mm_deaths,geometry = geom))+#,color = NA)+
  ggtitle("Variação na média móvel de óbitos", subtitle = "{frame_time}")+
  scale_fill_distiller(palette = "Spectral",limits = c(-100,100), na.value = "darkred",
                       labels = c("-100%", "-50%", "0%", "+50%", "+100%")) +
  labs(x = " ", y = " ",fill = " ") +
  theme(legend.position = c(0.86,0.22),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        panel.background = element_rect(fill = "transparent"))+
  guides(fill = guide_legend(override.aes = list(color = NA) ) )

# criando o group necessario para animar
sf_covid_states$group<- as.numeric(sf_covid_states$date - min(sf_covid_states$date))

# plota o mapa animado
gpl1 <- sf_covid_states |> #filter(group %in% c(380,400))|>
  ggplot() +
  geom_sf(aes(fill = var_mm_deaths,
              group = group,
              geometry = geom))+#,color = NA)+
  ggtitle("Variação na média móvel de óbitos",
          subtitle = "{frame_time}")+
  scale_fill_distiller(palette = "Spectral",limits = c(-100,100), na.value = "darkred",
                       labels = c("-100%", "-50%", "0%", "+50%", "+100%")) +
  labs(x = " ",
       y = " ",
       fill = " ") +
  theme(legend.position = c(0.86,0.22),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        panel.background = element_rect(fill = "transparent"),
        plot.background = element_rect(fill = "white"))+
  guides(fill = guide_legend(override.aes = list(color = NA) ) )+
  transition_time(date)+
  ease_aes('linear') +
  enter_fade() +
  exit_fade()

# faz a animação (demora um bocado)
#ani <- animate(gpl1, fps = 6)

# salva o gif na pasta do projeto
#anim_save("estados.gif", ani)

# faz a animação em vídeo (demora um bocado)
vid <- animate(gpl1,  nframes = max(sf_covid_states$group), fps = 5,renderer = av_renderer())

# salva o vídeo
anim_save("estados.webm", vid)

