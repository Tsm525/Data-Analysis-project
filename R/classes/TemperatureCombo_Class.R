# Designing an R6 class as proof of concept
# Constructor does the summary breakdown
# Naming follows R6 naming conventions according to : https://adv-r.hadley.nz/r6.html
# No need for private attributes here as there's no sensitive data (could add a field for whoever carried out the measurements as an example)

TemperatureCombo <- R6Class("TemperatureCombo", public = list(
  # Allows user to pass a data frame in object instantiation, so values aren't hard-coded 
  # Thus, allowing it to be applied to any data frame that could exist, as long as it is formatted by Bespoke_xlsx_reader()
  # Setting all values up here, can use $set() to create new attributes outside of constructor but this seems better practice as they are required for each object.
  
  reared_temp = NULL,
  measured_temp = NULL,
  au_factor = NULL,
  
  mean_distance = NULL,
  mean_max_speed = NULL,
  mean_avg_speed = NULL,
  
  std_distance = NULL,
  std_max_speed = NULL,
  std_avg_speed = NULL,
  
  n = NULL,
  se_distance = NULL,
  se_max_speed = NULL,
  se_avg_speed = NULL,
  
  distance = NULL,
  max_speed = NULL,
  avg_speed = NULL,
  
  error_bar_df = NULL,
  
  genotype = NULL,
  time = NULL,
  
  # Constructor # 
  
  # Source_Data will be a data frame of a specific temperature combination, genotype is the larvae genotype, time is the time measured for (set to a default value of 120 Seconds here)
  initialize = function(Source_Data,genotype,time="120 Seconds",au_factor = 0.23622) {
    
    # For future expansion to mutants
    self$genotype <- genotype
    self$time <- time
    
    
    # The distance column is useless data as it isnt total distance travelled, length is, so quick fix was just changing the data for the attribute to the Length column
    
    # Essentially, create an attribute per column in the data frame, could iterate over the columns in future versions, if new columns are used
    # Should really add the unit here as it's printed so many times and no need for numeric temperature value as of yet
    # Au factor converts pixels/sec to mm/s
    self$reared_temp <- Source_Data$base_temp[1]       
    self$measured_temp <- Source_Data$measured_temp[1]
    
    # 2 different factors as some videos are different distances, band aid fix because crunch time
    if (genotype == "PGRP-LE" || Source_Data$measured_temp == "RT" && Source_Data$base_temp == "RT"){
      self$au_factor <- 0.24258
    } else {
      self$au_factor <- au_factor
    }
    
    
    # Store summary data for use in graphing as attributes instead of a separate table
    self$mean_distance <- mean(Source_Data$length*self$au_factor)
    self$mean_max_speed <- mean(Source_Data$max_speed*self$au_factor)
    self$mean_avg_speed <- mean(Source_Data$avg_speed*self$au_factor)
    
    self$std_distance <- sd(Source_Data$length*self$au_factor)
    self$std_max_speed <- sd(Source_Data$max_speed*self$au_factor)
    self$std_avg_speed <- sd(Source_Data$avg_speed*self$au_factor)
    
    # Same n for all calculations below
    self$n <- length(Source_Data$length*self$au_factor)               
    self$se_distance <- self$std_distance/sqrt(self$n)
    self$se_max_speed <- self$std_max_speed/sqrt(self$n)
    self$se_avg_speed <- self$std_avg_speed/sqrt(self$n)
    
    # Store the columns as lists of data points
    self$distance <- Source_Data$length*self$au_factor
    self$max_speed <- Source_Data$max_speed*self$au_factor
    self$avg_speed <- Source_Data$avg_speed*self$au_factor
    
    # Exists solely for the $graph() method below, can't find a more concise way of including all the attributes, will create a 1 row df
    self$error_bar_df <- data.frame(measured_temp = self$measured_temp, reared_temp = self$reared_temp, 
                               mean_distance = self$mean_distance, mean_max_speed = self$mean_max_speed, mean_avg_speed = self$mean_avg_speed,
                               std_distance = self$std_distance, std_max_speed = self$std_max_speed, std_avg_speed = self$std_avg_speed, 
                               n = self$n,
                               se_distance = self$se_distance, se_max_speed = self$se_max_speed, se_avg_speed = self$se_avg_speed,
                               genotype=self$genotype)
    
  },
  
  # Will create a graph summarizing the data of two objects for the variable attribute, x axis will always be temperature
  # labs and titles are NULL here instead of default text values so they can be written using data from attribute and object_2 below if not set manually
  graph = function(object_2, attribute, x_var = "measured_temp",x_lab=NULL, y_lab=NULL, title=NULL) {
    

    
    
    # Colour blind friendly
    cbPalette = c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#999999")
    
    # Using "=" a lot here as these only need to exist locally and not globally, as with <-
    
    # Get only important values below, allows this to be a general purpose graphing method
    
    # ggplot seems to prefer a data frame so going with a temp data frame, may be less computationally efficient
    # Indexes object attributes to get data into a readable data frame
    self_temp_df = data.frame(measured_temp = self$measured_temp,
                                 reared_temp = self$reared_temp,
                                 attribute = self[[attribute]],
                              genotype = self$genotype)
    
    other_temp_df = data.frame(measured_temp = object_2$measured_temp,
                                 reared_temp = object_2$reared_temp,
                                 attribute = object_2[[attribute]],
                               genotype = object_2$genotype)
    
    # Combine data frames of both objects for ggplot
    temp_graph_df <- rbind(self_temp_df,other_temp_df)
    temp_summary_df <- rbind(self$error_bar_df, object_2$error_bar_df)
    
    
    # Create strings to get correct column names
    temp_mean = paste("mean",attribute,sep="_")
    temp_se = paste("se",attribute,sep="_")
    
    # Renaming specific columns i.e."mean_distance" to general "mean" allowing plot below to use general variable names
    # Makes function much more encapsulated and concise, no need for "If distance{}, if max_speed{} etc"
    names(temp_summary_df)[names(temp_summary_df) == temp_mean] <- "mean"
    names(temp_summary_df)[names(temp_summary_df) == temp_se] <- "se"
    
    # For use in titles later, replaces "_" with space to make it user friendly
    written_attribute = str_to_title(gsub("_"," ", attribute, fixed = TRUE))
    
    # Get the measured and reared temp, means title isn't repeating same values if both objects share a temperature
    if(self$reared_temp == object_2$reared_temp) {
      written_reared_temp = paste(self$reared_temp,"(\u00B0C)",sep="")
    } else {
      written_reared_temp = paste(self$reared_temp,"(\u00B0C)"," and ",object_2$reared_temp,"(\u00B0C)",sep="")
    }
    
    if(self$measured_temp == object_2$measured_temp){
      written_measured_temp = paste(self$measured_temp,"(\u00B0C)",sep="")
    } else {
      written_measured_temp = paste(self$measured_temp,"(\u00B0C)"," and ",object_2$measured_temp,"(\u00B0C) Respectively",sep="")
    }
    
    # Automatically set ylim to an appropriate value
    # Used below to get y_lim variable
    max_self = max(self[[attribute]])
    max_other = max(object_2[[attribute]])
    
    # Get a reasonable y_lim value that leave space to draw significance lines later
    if (max_self > max_other ){
      y_lim = max_self * 1.3
    } else {
      y_lim = max_other * 1.3
    }
    
    # Get a formatted title for the x variable
    if (x_var == "genotype") {
      x_var_title <- "Genotype of Fly"
    }
    if (x_var == "measured_temp"){
      x_var_title <- "Temperature When Measured(\u00B0C)"
    }
    
    # Standard ggplot point plot with error bars
    fig1 <- ggplot() + 
      geom_point(data = temp_graph_df,
                 aes(x = .data[[x_var]], y = attribute, shape = reared_temp, colour = .data[[x_var]]),
                 position = position_jitter(width = 0.25, height = 0)) +
      geom_errorbar(data = temp_summary_df,
                    aes(x = .data[[x_var]], ymin = mean - se, ymax = mean + se),
                    width = 0.3) +
      geom_errorbar(data = temp_summary_df, 
                    aes(x = .data[[x_var]], ymin = mean, ymax = mean),
                    width = 0.2) +
      
      # NA auto sets the bottom end sensibly 
      ylim(NA,y_lim) +
      
      # Check if x or y labels have been manually entered, if not set to a default 
      xlab( if(is.null(x_lab)) {
          label = "Measured Temperature (\u00B0C)" 
          } else {
            label = x_lab
          } 
          ) +
      ylab( if(is.null(y_lab)) {
          label = written_attribute
          } else {
          label = y_lab
          } 
          ) +
      
      # Default title concatenating many attributes, trying to hard code as little as possible, could add attributes for units but for now keeping them included with the constructor parameters
      ggtitle( if(is.null(title)){
        label = str_to_title(paste("Difference in",written_attribute,"over",self$time,"in",self$genotype,"drosophila \nlarvae Reared at",written_reared_temp,"then Measured at",written_measured_temp,sep=" "))
      } else{
        label = title
      }
      ) +
      
      # Each variable needs a distinguishing visual feature
      labs(shape = "Reared Temperature (\u00B0C)", colour = x_var_title) +
      
      # Apply colour blind friendly colours
      scale_colour_manual(values = cbPalette) +
      theme_minimal()
    
    
    # Check stats to see if need to add a significance line
    p = self$shapiro_then_stats(object_2,attribute)
    # Check p.value
    if (between(p$p.value,0.01 , 0.05)){
      # Add a significance star, p value and line, room to add more confidence levels with more if statements
      # R treats categorical x axis as positions starting from 1, so x values below represent that
      fig1 = fig1 + 
        geom_segment(aes(x=1,y=(y_lim*0.89),xend=2,yend=(y_lim*0.89)))+
        annotate("text",x = 1.5,y = y_lim*0.98, label = "*", size = 5) +
        annotate("text",x = 1.5, y = y_lim*0.945,label = paste("p =",signif(p$p.value,5)),size = 3.5) 
    } 
    if (between(p$p.value,0.001 , 0.01)){
      # Add a significance star, p value and line, room to add more confidence levels with more if statements
      # R treats categorical x axis as positions starting from 1, so x values below represent that
      fig1 = fig1 + 
        geom_segment(aes(x=1,y=(y_lim*0.89),xend=2,yend=(y_lim*0.89)))+
        annotate("text",x = 1.5,y = y_lim*0.98, label = "**", size = 5) +
        annotate("text",x = 1.5, y = y_lim*0.945,label = paste("p =",signif(p$p.value,5)),size = 3.5) 
    } 
    if (between(p$p.value, 0.0001 ,0.001)){
      # Add a significance star, p value and line, room to add more confidence levels with more if statements
      # R treats categorical x axis as positions starting from 1, so x values below represent that
      fig1 = fig1 + 
        geom_segment(aes(x=1,y=(y_lim*0.89),xend=2,yend=(y_lim*0.89)))+
        annotate("text",x = 1.5,y = y_lim*0.98, label = "***", size = 5) +
        annotate("text",x = 1.5, y = y_lim*0.945,label = paste("p =",signif(p$p.value,5)),size = 3.5) 
    } 
    if (p$p.value < 0.0001){
      # Add a significance star, p value and line, room to add more confidence levels with more if statements
      # R treats categorical x axis as positions starting from 1, so x values below represent that
      fig1 = fig1 + 
        geom_segment(aes(x=1,y=(y_lim*0.89),xend=2,yend=(y_lim*0.89)))+
        annotate("text",x = 1.5,y = y_lim*0.98, label = "****", size = 5) +
        annotate("text",x = 1.5, y = y_lim*0.945,label = paste("p =",signif(p$p.value,5)),size = 3.5) 
    }
    
    
    
    # Return result without printing it like return() does, same for all below
    invisible(fig1)
    },
  
  # Make a plot for all 3 variables (only 3 for the foreseeable future)
  graph_all = function(object_2,x_var = "measured_temp",x_lab=NULL,title=NULL){
    
    # Copied from graph() above, could be its own function if needed again, creates strings formatted for the title later
    if(self$reared_temp == object_2$reared_temp) {
      written_reared_temp = paste(self$reared_temp,"(\u00B0C)",sep="")
      
    } else {
      written_reared_temp = paste(self$reared_temp,"(\u00B0C)"," and ",object_2$reared_temp,"(\u00B0C)",sep="")
    }
    
    if(self$measured_temp == object_2$measured_temp){
      written_measured_temp = paste(self$measured_temp,"(\u00B0C)",sep="")
      
    } else {
      written_measured_temp = paste(self$measured_temp,"(\u00B0C)"," and ",object_2$measured_temp,"(\u00B0C)",sep="")
    }
    
    # Use previously defined graph method 3 times for creating temp variables
    fig1_distance = self$graph(object_2,x_var = x_var ,attribute =  "distance", y_lab = "Total Distance travelled (mm)",  title = "",x_lab=x_lab)
    fig1_max_speed = self$graph(object_2,x_var = x_var, attribute = "max_speed", y_lab = "Maximum Speed (mm/s)",  title = "",x_lab=x_lab) + theme(legend.position = "none")
    fig1_avg_speed = self$graph(object_2,x_var = x_var, attribute = "avg_speed", y_lab = "Average Speed (mm/s)",  title ="",x_lab=x_lab) + theme(legend.position = "none")
    
    # Sets the layout to have distance on top and the speeds below side by side
    layout = rbind(c(1,1),
                   c(2,3))
    
    if (is.null(title)){
      
    Grob_title = str_to_title(paste("Difference in larval crawling in",self$genotype,"drosophila larvae Reared at",written_reared_temp,"\nthen Measured at",written_measured_temp,sep=" "))
    } else {
      Grob_title <- title
    }
    # Create a grid of figures to output results
    # Using arrangeGrob() so it is save-able to a file, grid.draw() required for printable output
    fig_all = arrangeGrob(fig1_distance,
                    fig1_max_speed,
                    fig1_avg_speed,
                    nrow = ,
                    layout_matrix = layout,
                    top = textGrob(Grob_title,
                                   gp=gpar(fontsize=12,font=2)))
    invisible(fig_all)
  },
  
  # Function that applies correct statistical test to data based on checked normality assumption, more checks could be added
  # Mean is already calculated, future potential improvement to eliminate the need to recalculate here and just use the mean values
  shapiro_then_stats = function(object_2, attribute) {
    
    # Check normality of the attribute for both groups
    # Found out post-final draft that {{ }} allows you to index without attribute as a string, treats it like $, whereas [[ ]] returns the entire column, may implement in other areas in new version
    s1 = shapiro.test(self[[attribute]])
    s2 = shapiro.test(object_2[[attribute]])
    
    # If the p-value is >0.05 it is assumed to be normally distributed, both must be for t test hence the AND
    if (s1$p.value > 0.05 && s2$p.value > 0.05) {
      
      # Assign result as attribute for later use
      stats = t.test(self[[attribute]], object_2[[attribute]])
      
    } else {
      
      # If significantly not normal then use a non-parametric test, paired = FALSE as different population sizes so paired test throws error and isn't applicable 
      stats = wilcox.test(self[[attribute]], object_2[[attribute]], paired = FALSE)
      
    }
    
    invisible(stats)
  },
  
  #Similar purpose to graph_all, essentially it just applies the shaprio_then_stats method to all 3 variables measured
  stats_all = function(object_2) {
    
    
    distance_stats = self$shapiro_then_stats(object_2, "distance")
    # Make the print more informative, could add this line to the shapiro_then_stats, but it would result in 3 if statements in order to get the correct units and variable name
    distance_stats$data.name = paste("Larvae at ", self$reared_temp,"\u00B0C at ",
                                     self$measured_temp,"\u00B0C and ",
                                     object_2$reared_temp,"\u00B0C at",
                                     object_2$measured_temp, "\u00B0CDistanceTravelled (mm)", 
                                     sep="")
    
    max_speed_stats = self$shapiro_then_stats(object_2, "max_speed")
    max_speed_stats$data.name = paste("Larvae at ", 
                                      self$reared_temp,"\u00B0C at ",
                                      self$measured_temp,"\u00B0C and ",
                                      object_2$reared_temp,"\u00B0C at ",
                                      object_2$measured_temp, "\u00B0C Maximum speed (mm/s)", 
                                      sep="")
    
    avg_speed_stats = self$shapiro_then_stats(object_2, "avg_speed")
    avg_speed_stats$data.name = paste("Larvae at ", 
                                      self$reared_temp,"\u00B0C at ",
                                      self$measured_temp,"\u00B0C and ",
                                      object_2$reared_temp,"\u00B0C at ",
                                      object_2$measured_temp, "\u00B0C Average Speed (mm/s)", 
                                      sep="")
    
     
    
    # Can only return 1 object so put results in a list
    results = list(distance_stats,
                   max_speed_stats,
                   avg_speed_stats)
    
    invisible(results)
    }
  
  )
)


