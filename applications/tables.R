# Creates a reactive table to show the AE incidence
create_AE_table <- function(data){
  
  reactable(data,
            groupBy = c("SOC", "PT"),
            columns = list(
              treatment = colDef(name = "Treatment",  maxWidth = 150),
              N_PT = colDef(name = "N", maxWidth = 90, aggregate = "sum"),
              P_PT = colDef(name = "P", maxWidth = 90, aggregate = "sum"),
              study_id = colDef(name ="Study", maxWidth = 90)),
            searchable = TRUE)

}