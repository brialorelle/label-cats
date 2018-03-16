na_out_missing <- function(data, prop = .5) {
  
  max_trials <- length(unique(data$trial))
  
  na_props <- data %>%
    group_by(subj, trial) %>%
    summarise(na_prop = sum(is.na(aoi)) / length(aoi))
  
  complete_data <- na_props %>%
    filter(na_prop <= prop) %>%
    select(-na_prop) %>%
    left_join(data)
  
  missing_data <- na_props %>%
    filter(na_prop > prop) %>%
    select(-na_prop) %>%
    left_join(mutate(data, aoi = NA))
  
  missing_trials <- missing_data %>%
    group_by(subj) %>%
    summarise(num_trials = length(unique(trial))) %>%
    filter(num_trials > (max_trials * prop))
  
  together_data <- bind_rows(complete_data,missing_data)
  
  drop_subjs <- together_data %>%
    filter(subj %in% missing_trials$subj) %>%
    mutate(aoi = NA)
  
  bind_rows(filter(together_data, !subj %in% missing_trials$subj),
            drop_subjs) %>%
    arrange(subj, trial,Time) 
}

test_data <- na_out_missing(raw_test_data) 
learn_data <- na_out_missing(raw_learn_data)

na_exclusions <- function(data) {
  
  na_data <- data %>%
    group_by(group, subj, trial) %>%
    summarise(na_trial = (sum(is.na(aoi)/length(aoi))) == 1) %>%
    group_by(group, subj) %>%
    summarise(na_trial = mean(na_trial)) %>%
    mutate(na_subj = na_trial == 1)
  
  left_join(summarise(na_data, na_subj = mean(na_subj)),
            summarise(filter(na_data, !na_subj), na_trial = mean(na_trial)))
}

na_test_exclusions <- na_exclusions(test_data)
na_learn_exclusions <- na_exclusions(learn_data)

kable(na_test_exclusions)
kable(na_learn_exclusions)