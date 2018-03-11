

ES_mean_tones <- effectSizes_Targeted$meanEffect_Targeted[1]
ES_sd_tones <- effectSizes_Targeted$sdEffect_Targeted[1]

ES_mean_labels <- effectSizes_Targeted$meanEffect_Targeted[2]
ES_sd_labels <- effectSizes_Targeted$sdEffect_Targeted[2]

n_sims <- 500
sims <- as.tibble(expand.grid(sim = 1:n_sims)) %>%
  mutate(idx = 1:n()) %>%
  split(.$idx) %>%
  map_df(function (x) {
    mu_es_labels <- rnorm(n = 1, mean = ES_mean_labels, sd = ES_sd_labels) # simulate an effect size for labels from this   distribution
    mu_es_tones <- rnorm(n = 1, mean = ES_mean_tones, sd = ES_sd_tones) # simulate an effect size for tones
    es_diff_sim <- mu_es_labels - mu_es_tones # output simulated diff in effect size - labels vs. tones
    x$es_diff_sim = es_diff_sim
    return (x)
  })

ES_diff_estimate_mean = mean(sims$es_diff_sim)
ES_diff_estimate_sd = sd(sims$es_diff_sim)



n_sims <- 500
ns <- c(20,40,60,70,80,100)

sims <- as.tibble(expand.grid(sim = 1:n_sims, 
                              n = ns)) %>%
  mutate(idx = 1:n()) %>%
  split(.$idx) %>%
  map_df(function (x) {
    mu_es_labels <- rnorm(n = 1, mean = ES_mean_labels, sd = ES_sd_labels)
    mu_es_tones <- rnorm(n = 1, mean = ES_mean_tones, sd = ES_sd_tones)
    es_diff_sim <- mu_es_labels - mu_es_tones # output simulated diff in effect size - labels vs. tones
    
    d1 <- rnorm(n = x$n, mean = mu_es_labels)
    d2 <- rnorm(n = x$n, mean = mu_es_tones)
    x$p <- t.test(d1, d2)$p.value
    x$bf <- extractBF(BayesFactor::ttestBF(d1, d2))$bf
    x$es_diff_sim <- es_diff_sim
    return(x)
  })

sims %>%
  group_by(n) %>%
  summarise(power = mean(p < .05), 
            meanbf = mean(bf > 6) )

```

