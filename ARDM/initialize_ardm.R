library(haven)
library(here)
library(tidyverse)
library(DBI)
library(RSQLite)
library(survival)
library(stringr)

# ---- Load R files ----

source(here::here("modules/create_tables.R"))
source(here::here("modules/add_to_tables.R"))
source(here::here("modules/standards/descriptive_analysis.R"))
source(here::here("modules/standards/safety_analysis.R"))
source(here::here("modules/standards/survival_analysis.R"))

# ---- Load ADaM datasets ----

data_adsl <- read_xpt(here::here("data/adsl.xpt"))
data_adtte <- read_xpt(here::here("data/adtte.xpt"))
data_adae <- read_xpt(here::here("data/adae.xpt"))

data_adsl[data_adsl == ""] <- NA
data_adtte[data_adtte == ""] <- NA
data_adae[data_adae == ""] <- NA

data_adae <- data_adae %>% mutate_all(as.character)
data_adsl <- data_adsl %>% mutate_all(as.character)
data_adtte <- data_adtte %>% mutate_all(as.character)

# ---- Open database connection ----

connection <- dbConnect(RSQLite::SQLite(), dbname = "database/ardm.sqlite")

# ---- Create empty tables according to the data model schema ----

# Metadata tables 
create_metadata_tables(connection)

# Analysis standards
create_analysis_standards(connection)

# Create results tables 
create_demog_baselines_results_tables(connection)
create_ae_crude_incidence_tables(connection)
create_ae_exposure_adjusted_incidence_tables(connection)
create_ae_survival_table(connection)

# ---- Populate metadata and intermediate tables ----

# Add metadata to tables
add_demographics(connection)
add_baselines(connection)
add_analysis_standards(connection)
add_studies(connection, data_adsl)
add_subject(connection, data_adsl)
add_treatment(connection, data_adsl) 
add_adverse_events(connection, data_adae)
add_tte(connection, data_adtte)
add_outcomes(connection, data_adae)

add_ae_per_subject(connection, data_adae)
add_treatment_per_subject(connection, data_adsl)
add_demographics_per_subject(connection, data_adsl)
add_baselines_per_subject(connection, data_adsl)
add_event_per_subject(connection, data_adtte)
add_outcome_per_subject_ae(connection, data_adae)

# ---- Populate results tables ----

# Check the existing standards and how to call them
standards <- dbGetQuery(connection, "SELECT name, function_call, options FROM analysis_standards") %>% 
  dplyr::distinct()
(standards)

# Demographics and baselines
store_analysis_results_continuous(connection, group_by_treatment = F, parameter = "")
store_analysis_results_categorical(connection, group_by_treatment = T, parameter = "")

# Safety
store_analysis_safety(connection, aes_interest = "") # aes_interest is a vector of preferred terms of interest
store_analysis_survival(connection)

# ---- Disconnect from database ----

dbDisconnect(connection)

