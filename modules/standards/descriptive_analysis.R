# The descriptive analysis calculates descriptive statistics
#  for the demographics and baselines

# Help functions ---------------------------------------

# Filter the population given a set of parameters and remove NA
filter_population <- function(con, parameter, var_type){
  
  parameter <- str_to_sentence(parameter)
  
  
  data_per_subject <- dbGetQuery(con, "SELECT * FROM (SELECT * 
                                 FROM demographics_per_subject
                                 UNION
                                 SELECT * FROM baselines_per_subject)
                                 AS newtable
                                 INNER JOIN treatment_per_subject
                                 USING (subject_id)
                                 WHERE var_type = :x", params = list(x = var_type))
  

  if (parameter[1] != "All" & parameter[1]  != ""){
    
    #Confirms the parameter(s) is present in the data
    parameter_names <- dbGetQuery(con, "SELECT * 
                                  FROM (SELECT name, adam_column FROM demographics 
                                  UNION
                                  SELECT name, adam_column FROM baselines
                                  ) AS newtable
                                  WHERE 
                                  newtable.name = :x", params = list(x = parameter))
    
  
    if(length(intersect(parameter, parameter_names$name)) > 0){
      # Filter the data_per_subject to only include the wanted parameters
      data_per_subject <- data_per_subject %>% 
        filter(name %in% parameter_names$name)
    } else{
      data_per_subject <- NA}
  }
  
  
  return(data_per_subject)
}

# Results functions ---------------------------------------

# Calculates the descriptive statistics for categorical and numeric data
calculate_descriptive <- function(data, group_by_treatment, var_type){
  
  groups <- "parameter_id"
  if(group_by_treatment == T){ groups <- c("treatment_id", groups)}
  
  if(var_type == "continuous") {
    
    results <- data %>%  
      dplyr::group_by_at(groups) %>%
      dplyr::mutate(value = as.numeric(value)) %>% 
      dplyr::summarise(N = n(),
                       missing = sum(is.na(value)),
                       distinct = n_distinct(value),
                       min = ifelse(N == missing, NA, min(value, na.rm = T)),
                       max = ifelse(N == missing, NA, max(value, na.rm = T)),
                       mean = ifelse(N == missing, NA, mean(value, na.rm = T)),
                       sd = sd(value, na.rm = T),
                       median = median(value, na.rm = T),
                       variance = var(value, na.rm = T),
                       qnt_05   = quantile(value, probs= 0.05, na.rm = T),
                       qnt_10  = quantile(value, probs= 0.10, na.rm = T),
                       qnt_25  = quantile(value, probs= 0.25, na.rm = T),
                       qnt_50  = quantile(value, probs= 0.50, na.rm = T),
                       qnt_75  = quantile(value, probs= 0.75, na.rm = T),
                       qnt_90  = quantile(value, probs= 0.90, na.rm = T),
                       qnt_95 = quantile(value, probs= 0.95, na.rm = T),
                       outliers = ifelse(N == missing, NA, ifelse(length(boxplot(value, plot = F)$out) > 0, 
                                                                         paste0(boxplot(value, plot = F)$out, collapse = ", "), 
                                                                         NA)
                                                                  ),
                       outliers = paste0(boxplot(value, plot = F)$out, collapse = ", "),
                       var_type = unique(var_type),
                       treatment_id = unique(treatment_id),
                       unit = unique(unit),
                       study_id = unique(study_id), 
                       .groups = "keep") %>% 
      dplyr::arrange(parameter_id) %>%
      dplyr::select(study_id, treatment_id, parameter_id, everything())
    
    }
  
  if(var_type == "categorical") {
    
    second_groups <- c(groups, "value")
    
    results <- data %>%
      dplyr::group_by_at(groups) %>%
      dplyr::add_tally(name = "N") %>%
      dplyr::group_by_at(second_groups) %>%
      dplyr::summarise(N = unique(N),
                       frequency = n(),
                       missing = sum(is.na(value)),
                       proportion = frequency / N,
                       var_type = unique(var_type),
                       name = unique(name), 
                       study_id = unique(study_id),
                       treatment_id = unique(treatment_id),
                       .groups = "keep") %>%
      dplyr::distinct() %>%
      dplyr::group_by(parameter_id) %>%
      dplyr::mutate(distinct = n_distinct(value)) %>%
      dplyr::ungroup() %>%
      dplyr::select(study_id, treatment_id, parameter_id, N, missing, distinct, value, frequency, proportion, var_type)
  
    }
  
return(results)
}

# Storing functions ---------------------------------------

store_analysis_results_continuous <- function(con, group_by_treatment, parameter){
  
  # Prepare the analysis information
  analysis_ids <- dbGetQuery(con, "SELECT analysis_id FROM analysis_standards")
  analysis_id <- as.numeric(str_extract(analysis_ids[nrow(analysis_ids),1], "\\d+$")) + 1
  
  analysis_info <- data.frame(analysis_id = paste0("AS",analysis_id),
                              name = "descriptive_analysis",
                              function_call = "store_analysis_results_continuous()",
                              options = paste0("connection, ", 
                                               group_by_treatment, ", ", 
                                               ifelse(parameter[1]== "","All",parameter), ", "),
                              var_type = c("continuous"),
                              default = c("N"),
                              stringsAsFactors = F)
  
  
  # Calculate the results
  filtered_population <- filter_population(con, parameter, var_type = "continuous")

  if(class(filtered_population) == "data.frame"){
    analysis_results <- calculate_descriptive(filtered_population, group_by_treatment = T, var_type = "continuous")
    
    # Split by demographics and baselines
    demographics_results <- analysis_results %>% filter(str_detect(parameter_id, "^DEMOG"))
    baselines_results <- analysis_results %>% filter(str_detect(parameter_id, "^BASE"))
    
    demographics_results$analysis_id <- analysis_info$analysis_id
    baselines_results$analysis_id <- analysis_info$analysis_id
    
    dbWriteTable(con, "descriptive_demographics_continuous", demographics_results, append = T)
    dbWriteTable(con, "descriptive_baselines_continuous", baselines_results, append = T)
    
    dbWriteTable(con, "analysis_standards", analysis_info, append = T)
  }
}

store_analysis_results_categorical <- function(con, group_by_treatment, parameter){
  
  # Prepare the analysis information
  analysis_ids <- dbGetQuery(con, "SELECT analysis_id FROM analysis_standards")
  analysis_id <- as.numeric(str_extract(analysis_ids[nrow(analysis_ids),1], "\\d+$")) + 1
  
  analysis_info <- data.frame(analysis_id = paste0("AS",analysis_id),
                              name = "descriptive_analysis",
                              function_call = "store_analysis_results_categorical()",
                              options = paste0("connection, ", 
                                               group_by_treatment, ", ", 
                                               ifelse(parameter[1]== "","All",parameter), ", "),
                              var_type = c("categorical"),
                              default = c("N"),
                              stringsAsFactors = F)
  
  
  # Calculate the results
  filtered_population <- filter_population(con, parameter, var_type = "categorical")
  
  if(class(filtered_population) == "data.frame"){
    
    analysis_results <- calculate_descriptive(filtered_population, group_by_treatment, var_type = "categorical")
    
    demographics_results <- analysis_results %>% filter(str_detect(parameter_id, "^DEMOG"))
    baselines_results <- analysis_results %>% filter(str_detect(parameter_id, "^BASE"))
    
    demographics_results$analysis_id <- analysis_info$analysis_id
    baselines_results$analysis_id <- analysis_info$analysis_id
    
    dbWriteTable(con, "descriptive_demographics_categorical", demographics_results, append = T)
    dbWriteTable(con, "descriptive_baselines_categorical", baselines_results, append = T)
    
    dbWriteTable(con, "analysis_standards", analysis_info, append = T)
    
  }

}
