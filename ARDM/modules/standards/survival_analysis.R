# The survival analysis applies a Cox model
#  to estimate the probability of survival over time

store_analysis_survival <- function(connection){
  
  # Prepare the analysis information
  analysis_ids <- dbGetQuery(connection, "SELECT analysis_id FROM analysis_standards")
  analysis_id <- as.numeric(str_extract(analysis_ids[nrow(analysis_ids),1], "\\d+$")) + 1
  
  analysis_info <- data.frame(analysis_id = paste0("AS",analysis_id),
                              name = "survivaly_analysis",
                              function_call = "store_analysis_survival()",
                              options = paste0("connection"),
                              var_type = c(""),
                              default = c("N"),
                              stringsAsFactors = F)
  
  data <- dbGetQuery(connection, "SELECT * FROM events_per_subject 
                     INNER JOIN treatment_per_subject USING (subject_id)")
  
  fit <- survival::survfit(formula = survival::Surv(days, 1 - censoring_flag) ~ treatment, data = data)
  median <- data.frame("median" = unname(unlist(summary(fit)$table[,'median'])),
                       "strata" = names(fit$strata))
  
  tidy_fit <- broom::tidy(fit) %>% 
    dplyr::rename(CI_upper = conf.high,
                  CI_lower = conf.low,
                  n_risk = n.risk,
                  n_event = n.event,
                  n_censor = n.censor,
                  std_error = std.error) %>% 
    dplyr::mutate(study_id = unique(data$study_id))
  
  tidy_fit <- left_join(tidy_fit, median, by = "strata")
  
  tidy_fit$analysis_id <- analysis_info$analysis_id
  dbWriteTable(connection, "survival_analysis", tidy_fit, append = T)
  
}

