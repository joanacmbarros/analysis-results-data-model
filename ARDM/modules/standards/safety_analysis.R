# The safety analysis returns the AE crude and exposure adjusted 
# incidence rates

# Helper functions ----

add_ae_outcomes <- function(connection, analysis_id){
  
  data <- dbGetQuery(connection, "SELECT * FROM treatment_per_subject
                     INNER JOIN outcomes_per_subject_ae USING (subject_id)
                     INNER JOIN adverse_events USING (ae_id)") 
  
  outcome_frequency <- data %>%
    dplyr::select(study_id, treatment_id, SOC, PT, outcome_id) %>%
    dplyr::group_by(treatment_id, outcome_id) %>% 
    dplyr::add_tally(name = "N") %>% 
    dplyr::group_by(treatment_id, outcome_id, SOC) %>% 
    dplyr::add_tally(name = "N_SOC") %>% 
    dplyr::group_by(treatment_id, outcome_id, PT) %>%
    dplyr::add_tally(name = "N_PT") %>% 
    dplyr::mutate("P_SOC" = round(N_SOC/N*100, 2),
                  "P_PT" = round(N_PT/N*100, 2))
  
  outcome_frequency$analysis_id <- analysis_id
  dbWriteTable(connection, "outcomes_per_ae", outcome_frequency, append = T)
  
}

# ==== Crude ====

crude_serious <- function(data){
  
  crude_serious <- data %>%
    dplyr::select(study_id, treatment_id, SOC, PT, serious_ae) %>%
    dplyr::filter(serious_ae == "Y") %>% 
    dplyr::group_by(treatment_id) %>% 
    dplyr::add_tally(name = "N") %>% 
    dplyr::group_by(treatment_id, SOC) %>% 
    dplyr::add_tally(name = "N_SOC") %>% 
    dplyr::group_by(treatment_id, PT) %>%
    dplyr::add_tally(name = "N_PT") %>% 
    dplyr::mutate("P_SOC" = round(N_SOC/N*100, 2),
                  "P_PT" = round(N_PT/N*100, 2)) %>% 
    dplyr::rename("ae_serious" = serious_ae) %>% 
    dplyr::filter(!is.na(PT))
  
  return(crude_serious)
  
}

crude_severity <- function(data){
  
  crude_severity <- data %>%
    dplyr::select(study_id, treatment_id, SOC, PT, ae_severity) %>%
    dplyr::group_by(ae_severity, treatment_id) %>% 
    dplyr::add_tally(name = "N") %>% 
    dplyr::group_by(ae_severity, treatment_id, SOC) %>% 
    dplyr::add_tally(name = "N_SOC") %>% 
    dplyr::group_by(ae_severity, treatment_id, PT) %>%
    dplyr::add_tally(name = "N_PT") %>% 
    dplyr::mutate("P_SOC" = round(N_SOC/N*100, 2),
                  "P_PT" = round(N_PT/N*100, 2))%>% 
    dplyr::filter(!is.na(PT))
  
  return(crude_severity)
  
}

crude_temergent <- function(data){
  
  crude_temergent <- data %>%
    dplyr::select(study_id, treatment_id, SOC, PT, treatment_emergent) %>%
    dplyr::group_by(treatment_id, treatment_emergent) %>% 
    dplyr::add_tally(name = "N") %>% 
    dplyr::group_by(treatment_id, SOC) %>% 
    dplyr::add_tally(name = "N_SOC") %>% 
    dplyr::group_by(treatment_id, PT) %>%
    dplyr::add_tally(name = "N_PT") %>% 
    dplyr::mutate("P_SOC" = round(N_SOC/N*100, 2),
                  "P_PT" = round(N_PT/N*100, 2))%>% 
    dplyr::filter(!is.na(PT))
  
  return(crude_temergent)
}

crude_trelated <- function(data){
  
  crude_trelated <- data %>%
    dplyr::select(study_id, treatment_id, SOC, PT, related) %>%
    dplyr::group_by(related) %>% 
    dplyr::add_tally(name = "N") %>% 
    dplyr::group_by(treatment_id, SOC) %>% 
    dplyr::add_tally(name = "N_SOC") %>% 
    dplyr::group_by(treatment_id, PT) %>%
    dplyr::add_tally(name = "N_PT") %>% 
    dplyr::mutate("P_SOC" = round(N_SOC/N*100, 2),
                  "P_PT" = round(N_PT/N*100, 2)) %>% 
    dplyr::rename("treatment_related" = related) %>% 
    dplyr::filter(!is.na(PT))
  
  return(crude_trelated)
}

add_crude <- function(connection, analysis_id){
 
  data <- dbGetQuery(connection, "SELECT * FROM treatment_per_subject
                     INNER JOIN ae_per_subject USING (subject_id)
                     INNER JOIN adverse_events USING (PT, ae_id)")
  
  data <- data %>% 
    dplyr::select(-c(subject_id, analysis_start_date, analysis_end_date, analysis_duration))
  
  crude_rates <- data %>%
    dplyr::select(study_id, treatment_id, SOC, PT) %>%
    dplyr::group_by(treatment_id) %>% 
    dplyr::add_tally(name = "N") %>% 
    dplyr::group_by(treatment_id, SOC) %>% 
    dplyr::add_tally(name = "N_SOC") %>% 
    dplyr::group_by(treatment_id, PT) %>%
    dplyr::add_tally(name = "N_PT") %>% 
    dplyr::mutate("P_SOC" = round(N_SOC/N*100, 2),
                  "P_PT" = round(N_PT/N*100, 2))
  
  crude_rates$analysis_id <- analysis_id
  dbWriteTable(connection, "crude_incidence", crude_rates, append = T)
  
  crude_serious <- crude_serious(data)
  crude_serious$analysis_id <- analysis_id
  dbWriteTable(connection, "crude_incidence_serious", crude_serious, append = T)

  crude_severity <- crude_severity(data)
  crude_severity$analysis_id <- analysis_id
  dbWriteTable(connection, "crude_incidence_severity", crude_severity, append = T)
  
  crude_trelated <- crude_trelated(data)
  crude_trelated$analysis_id <- analysis_id
  dbWriteTable(connection, "crude_incidence_trelated", crude_trelated, append = T)
  
  crude_temergent <- crude_temergent(data)
  crude_temergent$analysis_id <- analysis_id
  dbWriteTable(connection, "crude_incidence_temergent", crude_temergent, append = T)
}

add_crude_aeinterest <- function(connection, aes_interest, analysis_id){
  
  aes_interest <- str_to_sentence(aes_interest)
  
  data <- dbGetQuery(connection, "SELECT * FROM treatment_per_subject
                                  INNER JOIN ae_per_subject USING (subject_id)
                     INNER JOIN adverse_events USING (PT)")
  
  data <- data %>% 
    dplyr::select(-c(subject_id, analysis_start_date, analysis_end_date, analysis_duration))
  
  crude_interest <- data %>%
    dplyr::select(study_id, treatment_id, treatment, SOC, PT) %>% 
    dplyr::filter(PT %in% aes_interest) %>%
    dplyr::group_by(treatment) %>% 
    dplyr::add_tally(name = "N") %>% 
    dplyr::group_by(treatment, SOC) %>% 
    dplyr::add_tally(name = "N_SOC") %>% 
    dplyr::group_by(treatment, PT) %>%
    dplyr::add_tally(name = "N_PT") %>% 
    dplyr::mutate("P_SOC" = round(N_SOC/N*100, 2),
                  "P_PT" = round(N_PT/N*100, 2))
  
  crude_interest$analysis_id <- analysis_id
  dbWriteTable(connection, "crude_incidence_interest", crude_interest, append = T)

}

# ==== Exposure-adjusted rates ====

exposure_adjusted_serious <- function(data){
  
  exp_adjusted_serious <- data %>%
    dplyr::select(study_id, treatment_id, SOC, PT, person_years, serious_ae) %>%
    dplyr::filter(serious_ae == "Y") %>% 
    dplyr::group_by(treatment_id) %>% 
    dplyr::add_tally(name = "N") %>% 
    dplyr::group_by(treatment_id, SOC) %>% 
    dplyr::add_tally(name = "N_SOC") %>% 
    dplyr::group_by(treatment_id, PT) %>%
    dplyr::add_tally(name = "N_PT") %>% 
    dplyr::mutate("A_SOC" = N_SOC/person_years,
                  "A_PT" = N_PT/person_years) %>% 
    dplyr::mutate("P_SOC" = round(N_SOC/person_years*100, 2),
                  "P_PT" = round(N_PT/person_years*100, 2)) %>% 
    dplyr::filter(!is.na(PT)) %>% 
    dplyr::rename("ae_serious" = serious_ae)
  
  return(exp_adjusted_serious)
  
}

exposure_adjusted_severity <- function(data){
  
  exp_adjusted_severity <- data %>%
    dplyr::select(study_id, treatment_id, SOC, PT, ae_severity, person_years) %>%
    dplyr::group_by(ae_severity, treatment_id) %>% 
    dplyr::add_tally(name = "N") %>% 
    dplyr::group_by(ae_severity, treatment_id, SOC) %>% 
    dplyr::add_tally(name = "N_SOC") %>% 
    dplyr::group_by(ae_severity, treatment_id, PT) %>%
    dplyr::add_tally(name = "N_PT") %>% 
    dplyr::mutate("A_SOC" = N_SOC/person_years,
                  "A_PT" = N_PT/person_years) %>% 
    dplyr::mutate("P_SOC" = round(N_SOC/person_years*100, 2),
                  "P_PT" = round(N_PT/person_years*100, 2)) %>% 
    dplyr::filter(!is.na(PT))
  
  return(exp_adjusted_severity)
  
}

exposure_adjusted_temergent <- function(data){
  
  exp_adjusted_temergent <- data %>%
    dplyr::select(study_id, treatment_id, SOC, PT, treatment_emergent, person_years) %>%
    dplyr::filter(treatment_emergent == "Y") %>% 
    dplyr::group_by(treatment_id) %>% 
    dplyr::add_tally(name = "N") %>% 
    dplyr::group_by(treatment_id, SOC) %>% 
    dplyr::add_tally(name = "N_SOC") %>% 
    dplyr::group_by(treatment_id, PT) %>%
    dplyr::add_tally(name = "N_PT") %>% 
    dplyr::mutate("A_SOC" = N_SOC/person_years,
                  "A_PT" = N_PT/person_years) %>% 
    dplyr::mutate("P_SOC" = round(N_SOC/person_years*100, 2),
                  "P_PT" = round(N_PT/person_years*100, 2)) %>% 
    dplyr::filter(!is.na(PT))
  
  return(exp_adjusted_temergent)
}

exposure_adjusted_trelated <- function(data){
  
  exp_adjusted_trelated <- data %>%
    dplyr::select(study_id, treatment_id, SOC, PT, related, person_years) %>%
    dplyr::group_by(related) %>% 
    dplyr::add_tally(name = "N") %>% 
    dplyr::group_by(treatment_id, SOC) %>% 
    dplyr::add_tally(name = "N_SOC") %>% 
    dplyr::group_by(treatment_id, PT) %>%
    dplyr::add_tally(name = "N_PT") %>% 
    dplyr::mutate("A_SOC" = N_SOC/person_years,
                  "A_PT" = N_PT/person_years) %>% 
    dplyr::mutate("P_SOC" = round(N_SOC/person_years*100, 2),
                  "P_PT" = round(N_PT/person_years*100, 2)) %>% 
    dplyr::filter(!is.na(PT)) %>% 
    dplyr::rename("treatment_related" = related)
  
  return(exp_adjusted_trelated)
}

add_exposure_adjusted_rates <- function(connection, analysis_id){
  
  data <- dbGetQuery(connection, "SELECT * FROM ae_per_subject 
                                  INNER JOIN adverse_events USING (PT)
                                  INNER JOIN treatment_per_subject USING (subject_id)
                                  INNER JOIN events_per_subject USING (subject_id)")
  
  person_years <- data %>%
    dplyr::select(study_id, treatment_id, treatment, days) %>% 
    tidyr::drop_na(days) %>%
    dplyr::mutate(analysis_duration = as.numeric(days)) %>% 
    group_by(treatment) %>% 
    summarise(person_years = (sum(days+30))/365.25,
              N = n())
  
  data <- inner_join(data %>% dplyr::select(!ae_id), person_years, by = "treatment") %>% 
    select(-c(subject_id, analysis_start_date, analysis_end_date, analysis_duration, days))
  
  exposure_adjusted_rates <- data %>% 
    dplyr::select(study_id, treatment_id, SOC, PT, person_years) %>% 
    dplyr::group_by(treatment_id) %>% 
    dplyr::add_tally(name = "N") %>% 
    dplyr::group_by(treatment_id, SOC) %>% 
    dplyr::add_tally(name = "N_SOC") %>% 
    dplyr::group_by(treatment_id, PT) %>%
    dplyr::add_tally(name = "N_PT") %>% 
    dplyr::mutate("A_SOC" = N_SOC/person_years,
                  "A_PT" = N_PT/person_years) %>% 
    dplyr::mutate("P_SOC" = round(N_SOC/person_years*100, 2),
                  "P_PT" = round(N_PT/person_years*100, 2)) %>% 
    dplyr::filter(!is.na(PT))

  exposure_adjusted_rates$analysis_id <- analysis_id
  dbWriteTable(connection, "exposure_adjusted_incidence", exposure_adjusted_rates, append = T)
  
  exp_adjusted_serious <- exposure_adjusted_serious(data)
  exp_adjusted_serious$analysis_id <- analysis_id
  dbWriteTable(connection, "exposure_adjusted_incidence_serious", exp_adjusted_serious, append = T)
  
  exp_adjusted_severity <- exposure_adjusted_severity(data)
  exp_adjusted_severity$analysis_id <- analysis_id
  dbWriteTable(connection, "exposure_adjusted_incidence_severity", exp_adjusted_severity, append = T)
  
  exp_adjusted_trelated <- exposure_adjusted_trelated(data)
  exp_adjusted_trelated$analysis_id <- analysis_id
  dbWriteTable(connection, "exposure_adjusted_incidence_trelated", exp_adjusted_trelated, append = T)
  
  exp_adjusted_temergent <- exposure_adjusted_temergent(data)
  exp_adjusted_temergent$analysis_id <- analysis_id
  dbWriteTable(connection, "exposure_adjusted_incidence_temergent", exp_adjusted_temergent, append = T)
}

add_exposure_adjusted_interest <- function(connection, aes_interest, analysis_id){
  
  aes_interest <- str_to_sentence(aes_interest)
    
  data <- dbGetQuery(connection, "SELECT * FROM ae_per_subject 
                                  INNER JOIN adverse_events USING (PT)
                       INNER JOIN treatment_per_subject USING (subject_id)
                       INNER JOIN events_per_subject USING (subject_id)")
  
  person_years <- data %>%
    dplyr::select(study_id, treatment_id, treatment, days) %>% 
    tidyr::drop_na(days) %>%
    dplyr::mutate(analysis_duration = as.numeric(days)) %>% 
    group_by(treatment) %>% 
    summarise(person_years = (sum(days+30))/365.25,
              N = n())
  
  data <- inner_join(data, person_years, by = "treatment") %>% 
    select(-c(subject_id, analysis_start_date, analysis_end_date, analysis_duration))
  
  exp_adjusted_interest <- data %>%
    dplyr::filter(PT %in% aes_interest) %>% 
    dplyr::select(study_id, treatment_id, treatment, SOC, PT, person_years) %>%
    dplyr::group_by(treatment) %>% 
    dplyr::add_tally(name = "N") %>% 
    dplyr::group_by(treatment, SOC) %>% 
    dplyr::add_tally(name = "N_SOC") %>% 
    dplyr::group_by(treatment, PT) %>%
    dplyr::add_tally(name = "N_PT") %>% 
    dplyr::mutate("A_SOC" = N_SOC/person_years,
                  "A_PT" = N_PT/person_years) %>% 
    dplyr::mutate("P_SOC" = round(N_SOC/person_years*100, 2),
                  "P_PT" = round(N_PT/person_years*100, 2)) %>% 
    dplyr::filter(!is.na(PT))
  
  exp_adjusted_interest$analysis_id <- analysis_id
  dbWriteTable(connection, "exposure_adjusted_incidence_interest", exp_adjusted_interest, append = T)

}

# Storing functions ----

store_analysis_safety<- function(connection, aes_interest){
  
  # Prepare the analysis information
  analysis_ids <- dbGetQuery(connection, "SELECT analysis_id FROM analysis_standards")
  analysis_id <- as.numeric(str_extract(analysis_ids[nrow(analysis_ids),1], "\\d+$")) + 1
  
  analysis_info <- data.frame(analysis_id = paste0("AS",analysis_id),
                              name = "safety_analysis",
                              function_call = "store_analysis_safety()",
                              options = paste0("connection, ", 
                                               ifelse(aes_interest[1]== "","None",aes_interest)),
                              var_type = c(""),
                              default = c("N"),
                              stringsAsFactors = F)
  
  add_crude(connection, analysis_id = analysis_info$analysis_id)
  add_exposure_adjusted_rates(connection, analysis_id = analysis_info$analysis_id)
  add_ae_outcomes(connection, analysis_id = analysis_info$analysis_id)
  
  if(aes_interest[1] != ""){
    add_crude_aeinterest(connection, aes_interest, analysis_id = analysis_info$analysis_id)
    add_exposure_adjusted_interest(connection, aes_interest, analysis_id = analysis_info$analysis_id)}
}


  