#-------------------------------
# MINERVA script
# v1.1 - 15 October 2021
# authors: Olga Paoletti, Claudia Bartolini, Rosa Gini


#parameters----------------------------------------------
rm(list=ls(all.names=TRUE))

#set the directory where the file is saved as the working directory
if (!require("rstudioapi")) install.packages("rstudioapi")
if (!require("data.table")) install.packages("data.table")
if (!require("lubridate")) install.packages("lubridate")

thisdir<-setwd(dirname(rstudioapi::getSourceEditorContext()$path))
thisdir<-setwd(dirname(rstudioapi::getSourceEditorContext()$path))


#############################################
#FUNCTION TO COMPUTE AGE
#############################################
Agebands =c(-1, 19, 29, 39, 49, 59, 69, 80, Inf)

age_fast = function(from, to) {
  from_lt = as.POSIXlt(from)
  to_lt = as.POSIXlt(to)
  
  age = to_lt$year - from_lt$year
  
  ifelse(to_lt$mon < from_lt$mon |
           (to_lt$mon == from_lt$mon & to_lt$mday < from_lt$mday),
         age - 1, age)
}

#directories----

diroutput <- paste0(thisdir,"/g_output/") 
dirmacro <- paste0(thisdir,"/p_macro/")
suppressWarnings(if (!file.exists(diroutput)) dir.create(file.path( diroutput)))
suppressWarnings(if (!file.exists(dirmacro)) dir.create(file.path( dirmacro)))

source(paste0(dirmacro,"CreateSpells_v14.R"))

#Set the CDM parameter equal to: ConcePTION, Nordic or TheShinISS
# CDM <- "ConcePTION"
# CDM <- "Nordic"
# CDM <- "TheShinISS"
#CDM <- "OMOP"

for (CDM in c("ConcePTION","OMOP","Nordic","TheShinISS")){
  source(paste0(thisdir,"/step_1_T2_create_study_variable_datasets_D3.R"))
}
source(paste0(thisdir,"/step_2_check_that_all_D3s_are_equal.R"))
source(paste0(thisdir,"/step_3_T3_apply_study_design_and_T4_statistical_analysis.R"))

