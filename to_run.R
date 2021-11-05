#-------------------------------
# MINERVA script
# v1.2 - 5 November 2021
# authors: Olga Paoletti, Claudia Bartolini, Rosa Gini

# changelog v1.2
# debugged presence at 1 Jan
# added time-dependent age
# parameterised year

#parameters----------------------------------------------
rm(list=ls(all.names=TRUE))

#------------------------------------------------------------------------
# To run the script on your data converted to one of the four supported CDMs,
# please set the followng parameter to one among
# "ConcePTION", "OMOP", "Nordic", "TheShinISS"

CDMs <- c("ConcePTION","OMOP","TheShinISS","Nordic")

#------------------------------------------------------------------------
# To run the script on your data, set the years

years <- c("2015","2016","2017","2018","2019")

#------------------------------------------------------------------------
# To run the script on your data, of you wish, set the agebands

Agebands <- c(-1, 19, 29, 39, 49, 59, 69, 80, Inf)
Labels <- c("0-19","20-29", "30-39", "40-49","50-59","60-69", "70-79","80+")


#-------------------------------------
# DON't MODIFY FROM HERE

#set the directory where the file is saved as the working directory
if (!require("rstudioapi")) install.packages("rstudioapi")
if (!require("data.table")) install.packages("data.table")
if (!require("lubridate")) install.packages("lubridate")

thisdir<-setwd(dirname(rstudioapi::getSourceEditorContext()$path))
thisdir<-setwd(dirname(rstudioapi::getSourceEditorContext()$path))

#-------------------------------------
# function to compute age

age_fast = function(from, to) {
  from_lt = as.POSIXlt(from)
  to_lt = as.POSIXlt(to)
  
  age = to_lt$year - from_lt$year
  
  ifelse(to_lt$mon < from_lt$mon |
           (to_lt$mon == from_lt$mon & to_lt$mday < from_lt$mday),
         age - 1, age)
}


# -------------------------
# set and create directories
dirinput <- vector(mode="list")
for (CDM in CDMs){ 
  dirinput[[CDM]] <- paste0(thisdir,"/i_input_",CDM,"/")
  }
  
diroutput <- paste0(thisdir,"/g_output/") 
dirtemp<- paste0(thisdir,"/g_intermediate/")
dirmacro <- paste0(thisdir,"/p_macro/")
suppressWarnings(if (!file.exists(diroutput)) dir.create(file.path( diroutput)))
suppressWarnings(if (!file.exists(dirmacro)) dir.create(file.path( dirmacro)))

# -------------------------
# load functions

source(paste0(dirmacro,"CreateSpells_v14.R"))

# -------------------------
# run steps

for (CDM in CDMs){
  source(paste0(thisdir,"/step_1_T2_create_study_variable_datasets_D3.R"))
}
source(paste0(thisdir,"/step_2_check_that_all_D3s_are_equal.R"))
source(paste0(thisdir,"/step_3_T3_apply_study_design_and_T4_statistical_analysis.R"))

