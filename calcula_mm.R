# função para calcular a media movel
calcula_mm <- function(dados){
  # acrescentar a media_movel

  dados <- dados %>%
    arrange(desc(state)) %>%
    group_by(state,city) %>%
    mutate(
      mm7d_confirmed = frollmean(newCases, 7),
      mm7d_deaths = frollmean(newDeaths, 7)
    ) %>%
    mutate(
      var_mm_confirmed = replace_na((mm7d_confirmed / lag(mm7d_confirmed, 14) - 1) * 100, 0),
      var_mm_deaths = replace_na( (mm7d_deaths / lag(mm7d_deaths, 14) - 1) * 100, 0)) %>%
    ungroup()

  dados
}
