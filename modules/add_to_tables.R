# This script fills the database tables prior to running an analysis  

# ---- Metadata ----

# stores the studies id
add_studies <- function(connection, adsl){
  
  study_names <- unique(adsl$STUDYID)
  studies <- data.frame(study_names, stringsAsFactors = F)
  studies <- studies %>% 
    dplyr::rename("study_id" = study_names) %>% 
    dplyr::mutate(across(everything(), ~ replace(., . == "", NA)))
  
  dbWriteTable(connection, "studies", studies, append = T) 
}

# stores demographics
add_demographics <- function(connection){
  
  demographics <- data.frame (name = c("Age", "Sex", "Race"),
                              adam_column = c("AGE", "SEX", "RACE"),
                              unit = c("years", "", ""),
                              var_type = c("continuous", "categorical", "categorical"),
                              stringsAsFactors = F)

  demographics <- demographics %>% 
    mutate(parameter_id = paste0("DEMOG", row_number())) %>% 
    dplyr::mutate(across(everything(), ~ replace(., . == "", NA)))
  
  dbWriteTable(connection, "demographics", demographics, append = T)
}

# stores the specified baselines
add_baselines <- function(connection){
  
  baselines <- tibble(
    name = c("Weight", "Height", "BMI"),
    adam_column = c("WEIGHTBL", "HEIGHTBL", "BMIBL"),
    unit = c("kg", "cm", "kg/m^2"),
    var_type = c("continuous", "continuous", "continuous")
  )
  
  baselines <- baselines %>% 
    mutate(parameter_id = paste0("BASE", row_number())) %>% 
    dplyr::mutate(across(everything(), ~ replace(., . == "", NA)))
  
  dbWriteTable(connection, "baselines", baselines, append = T)
}

# stores the subject 
add_subject <- function(connection, adsl){
  
  subject <- adsl  %>%
    dplyr::rename("subject_id" = USUBJID,
                  "study_id" = STUDYID) %>% 
    dplyr::select(subject_id, study_id)
  
  dbWriteTable(connection, "subjects", subject, append = T)  
}

# stores exposure
add_treatment <- function(connection, adsl){
  
  treatment <- adsl %>% 
    dplyr::select(STUDYID, TRT01P) %>%
    dplyr::rename("study_id" = STUDYID, "treatment" = TRT01P) %>% 
    dplyr::distinct() %>% 
    dplyr::mutate(treatment_id = paste0("TREAT", row_number()),
                  treatment = str_to_sentence(treatment))
  
  dbWriteTable(connection, "treatments", treatment, append = T)
  
}

# stores time to event data
add_tte <- function(connection, adtte){
  
  event <- adtte %>% 
    dplyr::select(PARAM) %>%
    dplyr::rename(event = PARAM) %>% 
    dplyr::distinct() %>% 
    dplyr::mutate("event_id" = paste0("EVENT", row_number()),
                  event = str_to_sentence(event))
  
  dbWriteTable(connection, "events", event, append = T)
}

# stores aes
add_adverse_events <- function(connection, adae){
  
  ae_ids <- adae %>% 
    dplyr::select(AETERM) %>% 
    dplyr::distinct() %>% 
    dplyr::mutate(ae_id = paste0("AE", row_number()))
  
  ae <- adae %>% 
    dplyr::select(AETERM, AESOC) %>%
    dplyr::inner_join(ae_ids, by = "AETERM") %>% 
    dplyr::mutate(AETERM = str_to_sentence(AETERM),
           AESOC = str_to_sentence(AESOC)) %>% 
    dplyr::distinct() %>% 
    dplyr::rename("PT" = AETERM,"SOC" = AESOC)
  
  dbWriteTable(connection, "adverse_events", ae, append = T)
}

# stores ae outcomes
add_outcomes <- function(connection, adae){
  
  ae_outcomes <- adae %>% 
    dplyr::select(AEOUT) %>% 
    dplyr::mutate(AEOUT = str_to_sentence(AEOUT)) %>% 
    dplyr::distinct() %>% 
    dplyr::rename("outcome" = AEOUT) %>% 
    dplyr::mutate(outcome_id = paste0("OUT", row_number()))
  
  dbWriteTable(connection, "outcomes", ae_outcomes, append = T)
}

# ---- Intermediate Transformations ----

# stores the subjects demographics and baselines data
add_demographics_per_subject <- function(connection, adsl){
  
  demog <- dbGetQuery(connection, "SELECT name, adam_column, unit, var_type, parameter_id FROM demographics")
  
  subject_demog <- adsl %>% dplyr::select(c("USUBJID", demog$adam_column)) %>% 
    tidyr::pivot_longer(demog$adam_column , values_to = "value", names_to = "adam_column") %>% 
    dplyr::inner_join(demog, by = "adam_column") %>% 
    dplyr::mutate(value = str_to_title(value)) %>% 
    dplyr::select(-adam_column) %>% 
    dplyr::rename("subject_id" = USUBJID) %>% 
    dplyr::mutate(across(everything(), ~ replace(., . == "", NA))) %>% 
    drop_na(c("subject_id", "parameter_id"))
  
  dbWriteTable(connection, "demographics_per_subject", subject_demog, append = T) 
}

# stores the subjects demographics and baselines data
add_baselines_per_subject <- function(connection, adsl){
  
  baseln <- dbGetQuery(connection, "SELECT name, adam_column, unit, var_type, parameter_id  FROM baselines")
 
  subject_baseln <- adsl %>% dplyr::select(c("USUBJID", baseln$adam_column)) %>% 
    tidyr::pivot_longer(baseln$adam_column , values_to = "value", names_to = "adam_column") %>% 
    dplyr::inner_join(baseln, by = "adam_column") %>% 
    dplyr::mutate(value = str_to_title(value)) %>%
    dplyr::select(-adam_column) %>% 
    dplyr::rename("subject_id" = USUBJID) %>% 
    dplyr::mutate(across(everything(), ~ replace(., . == "", NA))) %>% 
    drop_na(c("subject_id", "parameter_id"))
  
  dbWriteTable(connection, "baselines_per_subject", subject_baseln, append = T) 
}

# stores aes per subject
add_ae_per_subject <- function(connection, adae){
 
  aes <- adae %>% 
    dplyr::select(USUBJID, AETERM, ASTDT, AENDT, ADURN, TRTEMFL, AESER, AESEV, AEREL) %>%
    dplyr::rename("subject_id" = USUBJID, "PT" = AETERM, "analysis_start_date" = ASTDT, 
                  "analysis_end_date" = AENDT, "analysis_duration" = ADURN, "treatment_emergent" = TRTEMFL, 
                  "serious_ae" = AESER, "ae_severity" = AESEV, "related" = AEREL) %>% 
    dplyr::distinct() %>% 
    dplyr::mutate(PT = str_to_sentence(PT),
                  analysis_end_date = as.character(analysis_end_date),
                  analysis_start_date = as.character(analysis_start_date),
                  ae_severity = str_to_sentence(ae_severity),
                  related = str_replace(related, "NO", "N"),
                  related = str_replace(related, "YES", "Y"),
                  related = str_to_sentence(related))  %>% 
    tidyr::drop_na(c("subject_id", "PT"))
  
  ae_ids <- dbGetQuery(connection, "SELECT * FROM adverse_events")
    
  ae_per_subject <- dplyr::left_join(aes, ae_ids, by = "PT") %>% 
    dplyr::select(-"SOC")
  
  dbWriteTable(connection, "ae_per_subject", ae_per_subject, append = T)
}

# stores ae outcomes per subject
add_outcome_per_subject_ae <- function(connection, adae){
  
  outcomes <- adae %>% 
    dplyr::select(USUBJID, AEOUT, AETERM) %>%
    dplyr::rename("subject_id" = USUBJID, "outcome" = AEOUT, "PT" = AETERM) %>% 
    dplyr::distinct() %>% 
    dplyr::mutate(outcome = str_to_sentence(outcome), 
                  PT = str_to_sentence(PT)) %>% 
    drop_na()
  
  outcomes_id <- dbGetQuery(connection, "SELECT * FROM outcomes")
  ae_ids <- dbGetQuery(connection, "SELECT * FROM adverse_events")
  
  outcomes_per_subject <- left_join(outcomes, outcomes_id, by = "outcome")
  outcomes_per_subject_ae <- left_join(ae_ids, outcomes_per_subject, by = "PT") %>% 
    dplyr::select(-c(PT, SOC))
  
  dbWriteTable(connection, "outcomes_per_subject_ae", outcomes_per_subject_ae, append = T)
}

# stores treatment per subject
add_treatment_per_subject <- function(connection, adsl){
  
  treatments <- dbGetQuery(connection, "SELECT * FROM treatments")
  
  treatment <- adsl %>% 
    dplyr::select(USUBJID, STUDYID, TRT01P) %>%
    dplyr::rename("subject_id" = USUBJID, "study_id" = STUDYID, "treatment" = TRT01P) %>% 
    dplyr::mutate(treatment = str_to_sentence(treatment)) %>% 
    left_join(treatments, by = c("study_id", "treatment")) %>% 
    drop_na(c("subject_id", "study_id", "treatment_id"))
  
  dbWriteTable(connection, "treatment_per_subject", treatment, append = T)
}

# stores events per subject 
add_event_per_subject <- function(connection, adtte){

  events_ids <- dbGetQuery(connection, "SELECT * FROM events")

  event <- adtte %>% 
    dplyr::select(USUBJID,PARAM, CNSR, ADT, STARTDT) %>%
    dplyr::rename(event = PARAM) %>% 
    dplyr::mutate(event = str_to_sentence(event)) %>% 
    dplyr::left_join(events_ids, by = "event") %>% 
    dplyr::rename("subject_id" = USUBJID, 
                  "censoring_flag" = CNSR, 
                  "analysis_date" = ADT,
                  "tte_startdate" = STARTDT) %>% 
    dplyr::mutate("days" = as.Date(analysis_date) - as.Date(tte_startdate) + 1) %>% 
    dplyr::select(event_id, subject_id, event, censoring_flag, days)
  
  dbWriteTable(connection, "events_per_subject", event, append = T)
}

# ---- Analysis standards ----

add_analysis_standards <- function(connection){
  
  analysis_standards <- data.frame (name = c("descriptive_analysis", "descriptive_analysis", 
                                             "safety_analysis()","survival_analysis"),
                              function_call = c("store_analysis_results_continuous()", 
                                                "store_analysis_results_categorical()", 
                                                "store_analysis_safety()",
                                                "store_analysis_survival()"),
                              options = c("connection, group_by_treatment, parameter", 
                                          "connection, group_by_treatment, parameter", 
                                          "connection, aes_interest", 
                                          "connection"),
                              var_type = c("continuous", "categorical", "", ""),
                              default = c("Y", "Y", "Y", "Y"),
                              stringsAsFactors = F)
  
  analysis_standards <- analysis_standards %>% 
    mutate(analysis_id = paste0("AS", row_number()))
  
  dbWriteTable(connection, "analysis_standards", analysis_standards, append = T)
}
