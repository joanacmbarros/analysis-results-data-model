# This script specifies the database schema.  
# It creates empty tables with pre-determined fields, field types, primary and 
# foreign keys.


# ---- Metadata ----

# ==== Metadata and intermediate tables ====
create_metadata_tables <- function(connection){
  
  create_demographics <- dbExecute(connection, 
                                   statement = "CREATE TABLE demographics
                                  (parameter_id varchar NOT NULL PRIMARY KEY,
                                  name varchar NOT NULL,
                                  adam_column varchar NOT NULL,
                                  unit varchar,
                                  var_type varchar CHECK (var_type IN ('continuous', 'categorical'))
                                  )")
  
  create_baselines <- dbExecute(connection, 
                                statement = "CREATE TABLE baselines
                                (parameter_id varchar NOT NULL PRIMARY KEY,
                                name varchar NOT NULL,
                                adam_column varchar NOT NULL,
                                unit varchar,
                                var_type varchar CHECK (var_type IN ('continuous', 'categorical'))
                                )")
  
  create_studies <- dbExecute(connection, 
                              statement = "CREATE TABLE studies
                              (study_id varchar NOT NULL PRIMARY KEY,
                              name varchar)")
  
  
  
  create_subjects <- dbExecute(connection, 
                               statement = "CREATE TABLE subjects
                                (subject_id varchar NOT NULL PRIMARY KEY,
                                study_id varchar NOT NULL,
                                FOREIGN KEY (study_id) REFERENCES studies(study_id)
                                )")
  
  
  create_treatments <- dbExecute(connection, 
                                 statement = "CREATE TABLE treatments
                                (treatment_id varchar NOT NULL PRIMARY KEY,
                                study_id varchar NOT NULL,
                                treatment varchar NOT NULL,
                                FOREIGN KEY (study_id) REFERENCES studies(study_id)
                                )") 
  
  create_adverse_events <- dbExecute(connection, 
                                     statement = "CREATE TABLE adverse_events
                                    (ae_id varchar NOT NULL PRIMARY KEY,
                                    PT varchar,
                                    SOC varchar
                                    )")
  
  create_events <- dbExecute(connection, 
                             statement = "CREATE TABLE events
                              (event_id varchar NOT NULL,
                              event varchar
                              )")
  
  create_outcomes <- dbExecute(connection, 
                             statement = "CREATE TABLE outcomes
                             (outcome_id varchar NOT NULL,
                             outcome varchar
                             )")
  
  create_demographics_per_subject <- dbExecute(connection, 
                                               statement = "CREATE TABLE demographics_per_subject
                                              (subject_id varchar NOT NULL,
                                              parameter_id varchar NOT NULL,
                                              name varchar NOT NULL,
                                              value varchar,
                                              unit varchar,
                                              var_type varchar CHECK (var_type IN ('continuous', 'categorical')),
                                              FOREIGN KEY (subject_id) REFERENCES subject(subject_id),
                                              FOREIGN KEY (parameter_id) REFERENCES demographics(parameter_id)
                                              )")
  
  create_baselines_per_subject <- dbExecute(connection, 
                                            statement = "CREATE TABLE baselines_per_subject
                                            (subject_id varchar NOT NULL,
                                            parameter_id varchar NOT NULL,
                                            name varchar NOT NULL,
                                            value varchar,
                                            unit varchar,
                                            var_type varchar CHECK (var_type IN ('continuous', 'categorical')),
                                            FOREIGN KEY (subject_id) REFERENCES subject(subject_id),
                                            FOREIGN KEY (parameter_id) REFERENCES baselines(parameter_id)
                                            )")
  
  create_treatment_per_subject <- dbExecute(connection, 
                                            statement = "CREATE TABLE treatment_per_subject
                                            (treatment_id varchar NOT NULL,
                                            study_id varchar NOT NULL,
                                            subject_id varchar NOT NULL,
                                            treatment varchar NOT NULL,
                                            FOREIGN KEY (study_id) REFERENCES studies(study_id),
                                            FOREIGN KEY (subject_id) REFERENCES subject(subject_id)
                                            FOREIGN KEY (treatment_id) REFERENCES treatment(treatment_id)
                                            )")
  
  
  create_events_per_subject <- dbExecute(connection, 
                                         statement = "CREATE TABLE events_per_subject
                                          (event_id varchar NOT NULL,
                                          subject_id varchar NOT NULL,
                                          event varchar NOT NULL,
                                          censoring_flag integer,
                                          days integer,
                                          FOREIGN KEY (subject_id) REFERENCES subject(subject_id),
                                          FOREIGN KEY (event_id) REFERENCES events(event_id)
                                          )")
  
  create_outcomes_per_subject_ae <- dbExecute(connection, 
                                         statement = "CREATE TABLE outcomes_per_subject_ae
                                          (outcome_id varchar NOT NULL,
                                          subject_id varchar NOT NULL,
                                          ae_id varchar NOT NULL,
                                          outcome varchar NOT NULL,
                                          FOREIGN KEY (subject_id) REFERENCES subject(subject_id),
                                          FOREIGN KEY (outcome_id) REFERENCES outcome(outcome_id),
                                          FOREIGN KEY (ae_id) REFERENCES adverse_events(ae_id)
                                          )")
  
  
  create_ae_per_subject <- dbExecute(connection, 
                                     statement = "CREATE TABLE ae_per_subject
                                     (subject_id varchar NOT NULL,
                                      ae_id varchar NOT NULL,
                                      PT varchar,
                                      analysis_start_date varchar,
                                      analysis_end_date varchar,
                                      analysis_duration integer,
                                      treatment_emergent integer,
                                      serious_ae integer,
                                      related integer,
                                      ae_severity varchar,
                                      FOREIGN KEY (subject_id) REFERENCES subject(subject_id),
                                      FOREIGN KEY (ae_id) REFERENCES adverse_events(ae_id)
                                      )")
}

# ==== Analysis standards ====
create_analysis_standards <- function(connection){
  
  create_standards <- dbExecute(connection, 
            statement = "CREATE TABLE analysis_standards
            (analysis_id varchar NOT NULL PRIMARY KEY,
            name varchar NOT NULL,
            function_call varchar NOT NULL,
            options varchar,
            var_type varchar,
            `default` varchar NOT NULL
            )")
}

# ---- Analysis results ----

# ==== Baselines and demographics descriptive results ====
create_demog_baselines_results_tables <- function(connection){
  
  
  create_descriptive_demog_categorical <- dbExecute(connection, 
                                              statement = "CREATE TABLE descriptive_demographics_categorical
                                             (analysis_id varchar NOT NULL,
                                             study_id varchar NOT NULL,
                                             treatment_id varchar NOT NULL,
                                             parameter_id varchar NOT NULL,
                                             value varchar NOT NULL,
                                             N integer,
                                             `distinct` integer,
                                             missing integer,
                                             frequency integer,
                                             proportion double,
                                             var_type varchar NOT NULL,
                                             FOREIGN KEY (parameter_id) REFERENCES demographics(demographic_id)
                                             )")
  
  create_descriptive_basel_categorical <- dbExecute(connection, 
                                              statement = "CREATE TABLE descriptive_baselines_categorical
                                              (analysis_id varchar NOT NULL,
                                              study_id varchar NOT NULL,
                                              treatment_id varchar NOT NULL,
                                              parameter_id varchar NOT NULL,
                                              value varchar NOT NULL,
                                              N integer,
                                              `distinct` integer,
                                              missing integer,
                                              frequency integer,
                                              proportion double,
                                              var_type varchar NOT NULL,
                                              FOREIGN KEY (parameter_id) REFERENCES baselines(baseline_id)
                                              )")
  
  create_descriptive_basel_continuous <- dbExecute(connection, 
                                             statement = "CREATE TABLE descriptive_baselines_continuous
                                             (analysis_id varchar NOT NULL,
                                             study_id varchar NOT NULL,
                                             treatment_id varchar NOT NULL,
                                             parameter_id varchar NOT NULL,
                                             N integer,
                                             `distinct` integer,
                                             missing integer,
                                             min integer,
                                             max integer, 
                                             mean integer,
                                             sd integer,
                                             median integer,
                                             ginimd integer,
                                             variance integer,
                                             qnt_05 integer,
                                             qnt_10 integer,
                                             qnt_25 integer,
                                             qnt_50 integer,
                                             qnt_75 integer,
                                             qnt_90 integer,
                                             qnt_95 integer,
                                             outliers text,
                                             unit varchar NOT NULL,
                                             var_type varchar NOT NULL,
                                             FOREIGN KEY (parameter_id) REFERENCES baselines(baseline_id)
                                             )")
  
  create_descriptive_demog_continuous <- dbExecute(connection, 
                                                   statement = "CREATE TABLE descriptive_demographics_continuous
                                                   (analysis_id varchar NOT NULL,
                                                   study_id varchar NOT NULL,
                                                   treatment_id varchar NOT NULL,
                                                   parameter_id varchar NOT NULL,
                                                   N integer,
                                                   `distinct` integer,
                                                   missing integer,
                                                   min integer,
                                                   max integer, 
                                                   mean integer,
                                                   sd integer,
                                                   median integer,
                                                   ginimd integer,
                                                   variance integer,
                                                   qnt_05 integer,
                                                   qnt_10 integer,
                                                   qnt_25 integer,
                                                   qnt_50 integer,
                                                   qnt_75 integer,
                                                   qnt_90 integer,
                                                   qnt_95 integer,
                                                   outliers text,
                                                   unit varchar NOT NULL,
                                                   var_type varchar NOT NULL,
                                                   FOREIGN KEY (parameter_id) REFERENCES demographics(demographic_id)
                                                   )")
 
}

# ==== Outcomes per AE ====
create_outcomes_per_ae <- function(connection){

  outcomes_per_ae <- dbExecute(connection, 
                                          statement = "CREATE TABLE outcomes_per_subject_ae
                                          (analysis_id varchar NOT NULL,
                                          study_id varchar NOT NULL,
                                          treatment_id varchar,outcome_id varchar NOT NULL,
                                          outcome_id varchar NOT NULL,
                                          ae_id varchar NOT NULL,
                                          N integer,
                                          SOC varchar,
                                          PT  varchar,
                                          N_SOC integer,
                                          N_PT integer,
                                          P_SOC double,
                                          P_PT double,
                                          FOREIGN KEY (study_id) REFERENCES studies(study_id),
                                          FOREIGN KEY (outcome_id) REFERENCES outcome(outcome_id),
                                          FOREIGN KEY (ae_id) REFERENCES adverse_events(ae_id),
                                          FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id)
                                          )")
  }

# ==== AE crude incidence rate ====
create_ae_crude_incidence_tables <- function(connection){

  crude_incidence <- dbExecute(connection, 
                     statement = "CREATE TABLE crude_incidence
                                  (analysis_id varchar NOT NULL,
                                  study_id varchar NOT NULL,
                                  treatment_id varchar,
                                  N integer,
                                  SOC varchar,
                                  PT  varchar,
                                  N_SOC integer,
                                  N_PT integer,
                                  P_SOC double,
                                  P_PT double,
                                  FOREIGN KEY (PT) REFERENCES adverse_events(preferred_term),
                                  FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id))")
  
  crude_incidence_serious <- dbExecute(connection, 
                             statement = "CREATE TABLE crude_incidence_serious
                                  (analysis_id varchar NOT NULL,
                                  study_id varchar NOT NULL,
                                  treatment_id varchar,
                                  ae_serious varchar,
                                  N integer,
                                  SOC varchar,
                                  PT  varchar,
                                  N_SOC integer,
                                  N_PT integer,
                                  P_SOC double,
                                  P_PT double,
                                  FOREIGN KEY (PT) REFERENCES adverse_events(preferred_term),
                                  FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id))")
  
  crude_incidence_trelated <- dbExecute(connection, 
                              statement = "CREATE TABLE crude_incidence_trelated
                                  (analysis_id varchar NOT NULL,
                                  study_id varchar NOT NULL,
                                  treatment_id varchar,
                                  treatment_related varchar,
                                  N integer,
                                  SOC varchar,
                                  PT  varchar,
                                  N_SOC integer,
                                  N_PT integer,
                                  P_SOC double,
                                  P_PT double,
                                  FOREIGN KEY (PT) REFERENCES adverse_events(preferred_term),
                                  FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id))")
  
  crude_incidence_temergent <- dbExecute(connection, 
                               statement = "CREATE TABLE crude_incidence_temergent
                                  (analysis_id varchar NOT NULL,
                                  study_id varchar NOT NULL,
                                  treatment_id varchar,
                                  treatment_emergent varchar,
                                  N integer,
                                  SOC varchar,
                                  PT  varchar,
                                  N_SOC integer,
                                  N_PT integer,
                                  P_SOC double,
                                  P_PT doublepreferred_term,
                                  FOREIGN KEY (PT) REFERENCES adverse_events(preferred_term),
                                  FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id))")
  
  crude_incidence_severity <- dbExecute(connection, 
                              statement = "CREATE TABLE crude_incidence_severity
                                  (analysis_id varchar NOT NULL,
                                  study_id varchar NOT NULL,
                                  treatment_id varchar,
                                  ae_severity varchar,
                                  N integer,
                                  SOC varchar,
                                  PT  varchar,
                                  N_SOC integer,
                                  N_PT integer,
                                  P_SOC double,
                                  P_PT double,
                                  FOREIGN KEY (PT) REFERENCES adverse_events(preferred_term),
                                  FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id))")
  
  crude_incidence_interest <- dbExecute(connection, 
                              statement = "CREATE TABLE crude_incidence_interest
                                  (analysis_id varchar NOT NULL,
                                  study_id varchar NOT NULL,
                                  treatment_id varchar,
                                  N integer,
                                  SOC varchar,
                                  PT  varchar,
                                  N_SOC integer,
                                  N_PT integer,
                                  P_SOC double,
                                  P_PT double,
                                  FOREIGN KEY (PT) REFERENCES adverse_events(preferred_term),
                                  FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id))")
  
}

# ==== Exposure adjusted incidence rate ====
create_ae_exposure_adjusted_incidence_tables <- function(connection){
  
  exposure_adjusted_incidence <- dbExecute(connection, 
                            statement = "CREATE TABLE exposure_adjusted_incidence
                                  (analysis_id varchar NOT NULL,
                                  study_id varchar NOT NULL,
                                  treatment_id varchar,
                                  N integer,
                                  SOC varchar,
                                  PT  varchar,
                                  person_years double,
                                  N_SOC integer,
                                  N_PT integer,
                                  A_SOC double,
                                  A_PT double,
                                  P_SOC double,
                                  P_PT double,
                                  FOREIGN KEY (PT) REFERENCES adverse_events(preferred_term),
                                  FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id))")
  
  exposure_adjusted_incidence_serious <- dbExecute(connection, 
                                statement = "CREATE TABLE exposure_adjusted_incidence_serious
                                  (analysis_id varchar NOT NULL,
                                  study_id varchar NOT NULL,
                                  treatment_id varchar,
                                  ae_serious varchar,
                                  N integer,
                                  SOC varchar,
                                  PT  varchar,
                                  person_years double,
                                  N_SOC integer,
                                  N_PT integer,
                                  A_SOC double,
                                  A_PT double,
                                  P_SOC double,
                                  P_PT double,
                                  FOREIGN KEY (PT) REFERENCES adverse_events(preferred_term),
                                  FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id))")
  
  exposure_adjusted_incidence_trelated <- dbExecute(connection, 
                                statement = "CREATE TABLE exposure_adjusted_incidence_trelated
                                  (analysis_id varchar NOT NULL,
                                  study_id varchar NOT NULL,
                                  treatment_id varchar,
                                  treatment_related varchar,
                                  N integer,
                                  SOC varchar,
                                  PT  varchar,
                                  person_years double,
                                  N_SOC integer,
                                  N_PT integer,
                                  A_SOC double,
                                  A_PT double,
                                  P_SOC double,
                                  P_PT double,
                                  FOREIGN KEY (PT) REFERENCES adverse_events(preferred_term),
                                  FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id))")
  
  exposure_adjusted_incidence_temergent <- dbExecute(connection, 
                                 statement = "CREATE TABLE exposure_adjusted_incidence_temergent
                                  (analysis_id varchar NOT NULL,
                                  study_id varchar NOT NULL,
                                  treatment_id varchar,
                                  treatment_emergent varchar,
                                  N integer,
                                  SOC varchar,
                                  PT  varchar,
                                  person_years double,
                                  N_SOC integer,
                                  N_PT integer,
                                  A_SOC double,
                                  A_PT double,
                                  P_SOC double,
                                  P_PT double,
                                  FOREIGN KEY (PT) REFERENCES adverse_events(preferred_term),
                                  FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id))")
  
  exposure_adjusted_incidence_severity <- dbExecute(connection, 
                                statement = "CREATE TABLE exposure_adjusted_incidence_severity
                                  (analysis_id varchar NOT NULL,
                                  study_id varchar NOT NULL,
                                  treatment_id varchar,
                                  ae_severity varchar,
                                  N integer,
                                  SOC varchar,
                                  PT  varchar,
                                  person_years double,
                                  N_SOC integer,
                                  N_PT integer,
                                  A_SOC double,
                                  A_PT double,
                                  P_SOC double,
                                  P_PT double,
                                  FOREIGN KEY (PT) REFERENCES adverse_events(preferred_term),
                                  FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id))")
  
  exposure_adjusted_incidence_interest <- dbExecute(connection, 
                                statement = "CREATE TABLE exposure_adjusted_incidence_interest
                                  (analysis_id varchar NOT NULL,
                                  study_id varchar NOT NULL,
                                  treatment_id varchar,
                                  N integer,
                                  SOC varchar,
                                  PT  varchar,
                                  person_years double,
                                  N_SOC integer,
                                  N_PT integer,
                                  A_SOC double,
                                  A_PT double,
                                  P_SOC double,
                                  P_PT double,
                                  FOREIGN KEY (PT) REFERENCES adverse_events(preferred_term),
                                  FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id))")
}

# ==== AE hazard ration analysis results ====
create_ae_survival_table <- function(connection){
  
  
  survival_analysis <- dbExecute(connection, 
                      statement = "CREATE TABLE survival_analysis
                                  (analysis_id varchar NOT NULL,
                                  study_id varchar NOT NULL,
                                  strata varchar NOT NULL,
                                  time integer NOT NULL,
                                  n_risk integer NOT NULL, 
                                  n_event integer NOT NULL,
                                  n_censor integer NOT NULL,
                                  estimate integer NOT NULL,
                                  std_error double NOT NULL,
                                  CI_lower double NOT NULL,
                                  CI_upper double NOT NULL)")
}

