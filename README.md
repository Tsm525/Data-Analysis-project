# Reproducable Analysis of W- Drosophila Larvae Crawling in Response to Temperature Stress

## Goal of the code:

  Analyse messy data produced from the ImageJ wrmtracker plugin that was processed in excel, reproducibility in R.

## R Pre-Requisites

R version 4.1.2  
R packages, need to be up to date:  
[can be installed/updated via install.packages("packagename")]  

* tidyverse
  + *Important for data tidying and reading*
* readxl
  + *Handles importing of excel files*
* usethis
  + *Makes project structure organisation and augmentation easy, may not be necessary after creation until updates are required*
* knitr
  + *Greatly helps R markdown writing, cross-referencing and knitting*
* ggplot2
  + *More control over graph creation than base plot, useful for readability*
* bookdown
  + *Used for R markdown knitting to multiple file types*
* RefManageR
  + *Makes referencing easier*
* grid
  + *Base package to arrange multiple plots into one large figure*
* gridExtra
  + *Works alongside, and provides more customization than base grid*
* R6
  + ***Very Important!*** *Handles creation and behavior of the cornerstone encapsulated class of this data analysis, TemperatureCombo*
* stringr
  + *Formats strings for readability*
* wordcountaddin
  + *Word counts for readme and rmd, not currently working so code copied into "R/functions/wordcount.R" which requires the "tidytext" package to run*

# File Naming Conventions

  The project relies on some file naming conventions to streamline data processing

* File extension should be .xlsx **exclusively**, future versions will support more
* File name is split into sections, for example "W-,25_at_29.xlsx"
  + "W-,"
    - W- denotes the genotype
    - The "," is a break between genotype and temperatures and is **required**
  + "25_at_29"
    - "25", the first number, is the temperature the larvae are reared/raised at (&deg;C)
    - "_at_" is used as a break between the two temperatures
    - "29", the last temperature, is the temperature the larval crawling measurements were taken at (&deg;C)
Files should all be stored in a data-raw folder such as how this project is organised
 
# Data importing

  Bespoke_xlsx_reader() will take care of all data importing and tidying. It requires manual entering of the file paths **WITHOUT THE EXTENSION\*** to data (for example ".../data-raw/W-,25_at_25") into the list ,"import_list", in 01-import.R.  
  
* The custom function will remove unwanted data and compress rows to create a data frame with only useful data and one row per observation(individual larva).   

* It takes one input, the file path (the "name" parameter), creates a data frame of the file, removes useless columns, compresses individuals across multiple rows into one per individual, then gleams the genotype and temperatures from the file name using regex. Finally it returns a processed data frame.  

* In 01-import.R the list of file paths is iterated over so a large processed data frame is created to be saved in the processed-data folder. 

* For each file name in import_list a TemperatureCombo object is created   

\* N.B. Reason for no extension is that future versions will automatically apply the correct extension via catching errors and using if/else statements until data is found  

# TemperatureCombo class guide

  The goal of this class was to use encapsulated object oriented programming methods in R, which is mainly functional, because we believe it to be a good solution to this problem for the following reasons:  

* More intuitive than base R as the custom commands require less input 
* Streamlines the analysis and graphing by defining methods for the class, called in one line
* Allows future data to undergo exactly the same analysis and should require little/no change in code for foreseeable project future
* Easily up-scaled to bigger data sets
* Modular design allows for easy application of updates to all objects/data
* Could transfer to other languages (e.g. python)

**How it use it:**

To create a new object of this class you need to use the $set() method as below:  

* obj_25_at_25 <- TemperatureCombo$set(Data_Frame,genotype,time=NULL) *time being optional to include and overwrite the default*

* It has 3 parameters for instantiation (creation)
  + **Required:** Source_Data, the data frame returned from bespoke_xlsx_reader 
  + **Required:** genotype, in future versions this will be automatically assigned from Source_Data, requires a string
  + **Optional:**  time, currently set at a default of "120 Seconds", requires a string with units included

* There are 4 methods (excluding initialize which is the constructor)
  + All called by object$method(parameters)
  + obj_25_at_25$graph(object_2,attribute,x_lab=NULL, y_lab=NULL, title=NULL)
    - **Parameters**:
      - object_2, the other TemperatureCombo object you are comparing data with
      - attribute, a string of the attribute name you want to test for i.e. distance, max_speed, avg_speed (may add formatting to allow inputs like max speed)
      - x_lab, y_lab and title are all optional values that can overwrite the custom default values applied by the method
    - This method creates a geom_point graph comparing the entered attribute between object_2 and the object you call the function from, it will generate specific titles, axis labels, and any significance lines with a p-value.
    - Provides more control over graph properties than graph_all()
    - returns a ggplot() object
    
  + graph_all
    - obj_25_at_25$graphall(object_2)
    - **Parameters**:
      - object_2, the other TemperatureCombo object you are comparing data from
    - Function calls graph() for all 3 variables (only 3 needed so hard coded) and creates a grid with them via grid and gridExtra R packages
    - returns a GridExtra arrangeGrob() object
  + shapiro_then_stats
    - obj_25_at_25$shapiro_then_stats(object_2, attribute)
    - **Parameters**:
      - object_2 is the other object to variables with
      - attribute is a string of the attribute name you want to compare
    - Runs a shapiro.test() to check normality then applies either a t.test() or wilcox.test() depending on Shapiro result
    - returns an object with results from the applied stats test
  + stats_all
    - obj_25_at_25$stats_all(object_2)
    - **Parameters**:
      - object_2 is the other object to compare with, used to run 3 shaprio_then_stats() tests with.
    - Returns a list of 3 stats test, one per variable (distance,max_speed and avg_speed)
    
    




