# List of specific file paths to import (without the extension, adding it manually later is a bit more modular so could be changed for other types of file)
#############################
### MANUALLY ENTER VALUES ###
#############################
import_list <- list("data-raw/W-,RT_at_RT", "data-raw/W-,RT_at_29", "data-raw/W-,29_at_29", "data-raw/W-,29_at_RT", "data-raw/PGRP-LE,RT_at_RT","data-raw/PGRP-LE,RT_at_29","data-raw/PGRP-LE,29_at_29","data-raw/PGRP-LE,29_at_RT")



# Only runs when there are files to import in the list, very rudimentary validation-
# Just to show I'm thinking about it, was more useful in previous version where list was diminished as iterated over
if (length(import_list) != 0) {
  
  # Iterate over the list and import then add the data to the processed_df data frame
  for (index in 1:length(import_list)) {
    
    # Save result of this iteration to be assigned later, saves running heavy function multiple times
    return_data <- Bespoke_xlsx_reader(import_list[index])
    
    
    # First iteration produces the data frame for later iterations to rbind() to
    if (index==1) {
      
      processed_df <- return_data
      
    } else {
      
      # Combine into a large processed data frame to write to processed-data location 
      processed_df <- rbind(processed_df, return_data)
    }
    
    # Characters after "data-raw/" and before ","
    genotype = str_extract(import_list[index],"(?<=data-raw/).+(?=,)")
    
    # Create a TemperatureCombo class object for every imported temperature combination
    # Instantiate the object with a name pulled from file name concatenated with "obj_", matches all characters after the ","
    # (assign() is the coolest function ever, being able to assign variable names with other variables!)
    assign(paste("obj_",str_extract(import_list[index],"(?<=,).+"),swap(genotype,"-","_"),sep = ""),TemperatureCombo$new(return_data,genotype))
  }
}

# Write to a new file 
file <- "data-processed/processed_data.txt"
write_delim(processed_df, file)
