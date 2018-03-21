





library(tidyverse)
library(BayesFactor)

# simulation-based frequentist power analysis with known ES
ES <- .5
n_sims <- 100
ns <- c(2, 5, 10, 20, 50, 100)

sims <- as.tibble(expand.grid(sim = 1:n_sims, 
                      n = ns)) %>%
  mutate(idx = 1:n()) %>%
  split(.$idx) %>%
  map_df(function (x) {
    d1 <- rnorm(n = x$n)
    d2 <- rnorm(n = x$n, mean = ES)
    x$p <- t.test(d1, d2)$p.value
    return(x)
  })

sims %>%
  group_by(n) %>%
  summarise(power = mean(p < .05))

# simulation-based frequentist power analysis with prior over ES
ES_mean <- .5
ES_sd <- .25
n_sims <- 1000
ns <- c(2, 5, 10, 20, 50, 100)

sims <- as.tibble(expand.grid(sim = 1:n_sims, 
                              n = ns)) %>%
  mutate(idx = 1:n()) %>%
  split(.$idx) %>%
  map_df(function (x) {
    mu_es <- rnorm(n = 1, mean = ES_mean, sd = ES_sd)
    d1 <- rnorm(n = x$n)
    d2 <- rnorm(n = x$n, mean = mu_es)
    x$p <- t.test(d1, d2)$p.value
    return(x)
  })

sims %>%
  group_by(n) %>%
  summarise(power = mean(p < .05))


# simulation-based bayesian power analysis with prior over ES
ES_mean <- .5
ES_sd <- .25
n_sims <- 100
ns <- c(2, 5, 10, 20, 50, 100)

sims <- as.tibble(expand.grid(sim = 1:n_sims, 
                              n = ns)) %>%
  mutate(idx = 1:n()) %>%
  split(.$idx) %>%
  map_df(function (x) {
    mu_es <- rnorm(n = 1, mean = ES_mean, sd = ES_sd)
    d1 <- rnorm(n = x$n)
    d2 <- rnorm(n = x$n, mean = mu_es)
    x$p <- t.test(d1, d2)$p.value
    x$bf <- extractBF(BayesFactor::ttestBF(d1, d2))$bf
    return(x)
  })

sims %>%
  group_by(n) %>%
  summarise(power = mean(p < .05), 
            meanbf = mean(bf > 6) )