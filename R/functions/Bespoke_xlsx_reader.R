##################################################################
# Function to import and clean data specific to this experiment  #
##################################################################

# This function is created for the unique demands of this specific project that is still underway,
# It is designed so the only thing a user needs to provide is the file name without the extension 

# Could read in and save a purely raw file from imageJ but there is little point as the collection method is not designed for *Drosophila larvae*,
# Hence there are many omitted rows that would be used if the organism was C.elegans 

# "name" is the file path to the data
Bespoke_xlsx_reader <- function(name){                                
  
  # Adding the extension for excel file to imported list of names, could have extension parameter, or could iterate over extensions until correct found in future?
  filename <- paste(name,"xlsx",sep = ".") 
 
  
  # Reading file found via filename
  raw_data <- read_xlsx(filename) 
  
  
  # Extracting temp grown at and temp that experiment was done at from the name using regex in two different ways
  Base_temp <- sub(".*,(.+)_at.*","\\1",name) 
  Measured_temp <- sub(".*at_", "", name)
  
  
  #Fix column name with bad characters
  colnames(raw_data)[colnames(raw_data) == "#Frames"] <- "Frames"
  colnames(raw_data)[colnames(raw_data) == "1stFrame"] <- "FirstFrame"
  colnames(raw_data)[colnames(raw_data) == "Time(s)"] <- "Time"
  
  # Remove NA rows 
  processed_data <- na.omit(raw_data)
  
  # Remove rows not important for statistical analysis 
  processed_data <- subset(processed_data, select = c(Individual,Length, MaxSpeed, avgSpeed))
  
  
  # Using this to work out how many times to iterate to combine rows for individuals
  n <- max(processed_data$Individual)
  
  # Create empty clone of the data frame to rebuild into
  compressed_data <- processed_data[0,]
  
  
  # Not the cleanest way to compress but the data is unique and messy, this was easiest with my understanding - wonder if there is a way to do it all in one line like in python
  # Iterate over each column and compress the rows into one row per individual
  for (individual_number in 1:n){
    
    # A data frame with only individual n values in
    individual_n_dataset <- subset(processed_data, Individual == individual_number)
    
    # Used multiple times so storing value here to save running nrow
    individual_rows <- nrow(individual_n_dataset)
    
    # If it's only 1 row, no compiling required
    if (individual_rows > 1) {
      
      # These only need to be done once, save comp power / time by doing outside of the nested loops, not sure if important?
      
      compressed_data[individual_number, "MaxSpeed"] <- max(individual_n_dataset$MaxSpeed)
      compressed_data[individual_number,"avgSpeed"] <- mean(individual_n_dataset$avgSpeed)
      
      # Now we iterate over each row in individual_n_dataset so we can compile the data one row at a time
      for (row in 1:individual_rows) {
        
        # For each column in the data frame of values for one individual, we need to compile the values. 
        # Different columns need different compiling
        for (column in 1:ncol(individual_n_dataset)) {
          
          # Individual column obsolete after data compiled so skipped
          # Using name of column over column number as its the lesser of the two evil hard codings
          
          # All require same treatment so added OR statements 
          if (colnames(compressed_data[column]) == "Length"){
            
            # Check to make sure there's a value to add to
            if (is.na(compressed_data[individual_number, column])==FALSE){
              
              # Individual number remains the same for all 6 iterations of column allowing compression into one row, add to previous result and repeat
              compressed_data[individual_number, column] <- compressed_data[individual_number, column] + individual_n_dataset[row,column]
              
            } else {
              
              # Adding to self doesn't work when it's NA, which it starts at as I created an empty data frame
              compressed_data[individual_number, column] <- individual_n_dataset[row,column]
            }
            
          }
          
        }
        
      }
      
    } else {
      # When just one row skip and add it
      compressed_data[individual_number,] <- individual_n_dataset[1,]
      
    }
    
  }
  
  
  # Add columns to data for base temp, measured temp and genotype, only need to be done at the end
  compressed_data$Base_temp <- Base_temp 
  compressed_data$Measured_temp <- Measured_temp
  compressed_data$Genotype <- str_extract(name,"(?<=data-raw/).+(?=,)")
  
  # Don't need Individual column now that it is compressed
  compressed_data <- subset(compressed_data, select = -c(Individual))
  
  # Clean the names because they're messy
  compressed_data <- janitor::clean_names(compressed_data)
  
  return(compressed_data)
  
}




