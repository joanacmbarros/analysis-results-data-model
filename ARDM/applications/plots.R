# Plots the continuous descriptive results using a box plot
plot_boxplot <- function(data){
  
  # Manually select the lower and upper bounds
  lower <- as.numeric(data$qnt_25) - 1.5 * 
    (as.numeric(data$qnt_75) - as.numeric(data$qnt_25))
  upper <- as.numeric(data$qnt_75) + 1.5 * 
    (as.numeric(data$qnt_75) - as.numeric(data$qnt_25))
  
  # Manually prepare the outliers to a suitable format for the bxp function
  outliers <- lapply(strsplit(data$outliers, split = ", "), as.numeric)
  names(outliers) <- seq(1:length(outliers))
  outliers_groups <- lapply(seq_along(outliers), function(x){rep(names(outliers[x]), length(outliers[x][[1]]))})
  
  plot <- bxp(list(stats = matrix(c(lower, 
                                    as.numeric(data$qnt_25), 
                                    as.numeric(data$median), 
                                    as.numeric(data$qnt_75), 
                                    upper), 
                                  ncol = length(unique(data$treatment)), 
                                  byrow = TRUE),
                   
                   n = as.numeric(data$N),
                   names = data$treatment,
                   out = unlist(outliers),
                   group = unlist(outliers_groups)
  ),
  horizontal = T,
  pars = list(ylim = c(min(c(unlist(outliers),lower))-5, 
                       max(c(unlist(outliers), upper))+6),
              xlab = paste("\n", unique(data$name), "\n"),
              yaxt = "n",
              boxfill = hue_pal()(length(unique(data$treatment))),
              boxwex = 0.4,
              axes = F)
  )
  
  # Add the axis
  axis(side=1, 
       at=round(seq(min(unlist(outliers),lower)-1, 
                    max(unlist(outliers), upper)+1)))
  
  legend("top", legend=data$treatment, horiz=TRUE,
         fill=hue_pal()(length(data$treatment)),
         inset = c(0, 0), bty="n")
}

# Plots the categorical descriptive results using a dot plot
plot_dotplot <- function(data){
  
  data <- data %>%
    mutate(value = ordered(value, levels = unique(value)))
  
  ggplot(data, aes(y = value, 
                   x = proportion,
                   col = treatment)) + 
    geom_point(alpha = 0.75, size = 4) +
    facet_wrap(~name, scales = "free") +
    theme_light() +
    theme(axis.title = element_blank(), 
          panel.grid.minor.x = element_blank(),
          panel.grid.major.y = element_line(colour="lightgray", size=0.075),
          legend.position = "top",
          legend.title = element_blank()) +
    labs(x = "Proportion")
  
}

# Plots the Kaplan-Meier curves from the survival analysis
plot_km <- function(data, add_median, add_median_treatment){
  
  plot <- ggplot(data, aes(x=time, y=estimate, col=strata)) +
    geom_line(aes(linetype=strata)) +
    labs(x = "Time to event", y ="Probability of surival") +
    theme_bw() +
    theme(legend.position = "top")
  
  if(add_median == TRUE){
    median <- data %>%
      filter(strata == paste0("treatment=", add_median_treatment)) %>% 
      select(median) %>% 
      distinct() %>% 
      pull(median)
      
    label <- paste(median, "days")
    
    plot <- plot +
      annotate("segment", x = median, xend = median, yend = 0.5, y = 0.0) +
      annotate("text", x = median - 5 , y = 0.00, label = label) +
      annotate("segment", x = 0, xend = median, yend = 0.5, y = 0.5)
  }
  plot
}

# Returns the at risk based on a given time index
risk_set_count <- function(timeindex, survivaltime) {
  
  atrisk <- NULL
  for (t in timeindex){
    atrisk <- c(atrisk, sum(survivaltime >= t))
  }
  
  atrisk
}

# Plots a number at risk
at_risk_table<- function(timeindex, data){
  
  at_risk <- list()
  at_risk[["Times"]] <- timeindex
  strata <- unique(data$strata)
  for (s in strata){
    at_risk[[s]] <- risk_set_count(timeindex, data$time[data$strata==s])
  }
  
  results <- do.call(cbind.data.frame, at_risk)
  colnames(results) <- gsub("treatment=","",colnames(results))
  table <- tableGrob(t(tibble(results)),
                     rows = colnames(results), 
                     theme = ttheme_minimal(rowhead=list(fg_params=list(hjust=0, x=0))))
  
  table
}
