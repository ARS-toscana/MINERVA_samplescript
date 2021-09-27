#-------------------------------
# MINERVA script
# v1 - 10 September 2021
# author: Olga Paoletti


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
dirinput <- paste0(thisdir,"/i_input_ConcePTION/") 
diroutput <- paste0(thisdir,"/g_output/") 
suppressWarnings(if (!file.exists(diroutput)) dir.create(file.path( diroutput)))


#IMPORT TABLES
OBSERVATION_PERIODS<-fread(paste0(dirinput,"OBSERVATION_PERIODS.csv"))
PERSONS<-fread(paste0(dirinput,"PERSONS.csv"))

#SELECT ONLY THE VARIABLES OF INTEREST
PERSONS<-PERSONS[,.(person_id,sex_at_instance_creation,day_of_birth,month_of_birth,year_of_birth)]
setnames(PERSONS,"sex_at_instance_creation","gender")
OBSERVATION_PERIODS<-OBSERVATION_PERIODS[,.(person_id,op_start_date,op_end_date )]

#CREATE BIRTH DATES
D3<-merge(PERSONS,OBSERVATION_PERIODS,all.x=T)[,day_of_birth:=as.character(day_of_birth)][,month_of_birth:=as.character(month_of_birth)]
D3[nchar(day_of_birth)<=1,day_of_birth:=paste0(0,day_of_birth)][nchar(month_of_birth)<=1,month_of_birth:=paste0(0,month_of_birth)]
D3[,date_of_birth:=paste0(year_of_birth,month_of_birth,day_of_birth)][,year_of_birth:=NULL][,month_of_birth:=NULL][,day_of_birth:=NULL]
D3[,date_of_birth:=as_date(date_of_birth)][,op_start_date:=as_date(as.character(op_start_date))][,op_end_date:=as_date(as.character(op_end_date))]


#COMPUTE AGE
D3<-D3[,age:=age_fast(date_of_birth,as_date("20190101"))]
D3<-D3 [,age_bands:=cut(age, breaks = Agebands,  labels = c("0-19","20-29", "30-39", "40-49","50-59","60-69", "70-79","80+"))]

 
# #CHECK PRESENCE PER YEAR (2015-2019)
D3[ op_start_date<=as_date("20151231") & op_start_date>=as_date("20150101") , "2015":=1]
D3[ op_start_date<=as_date("20161231") & op_start_date>=as_date("20160101") , "2016":=1]
D3[ op_start_date<=as_date("20171231") & op_start_date>=as_date("20170101") , "2017":=1]
D3[ op_start_date<=as_date("20181231") & op_start_date>=as_date("20180101") , "2018":=1]
D3[ op_start_date<=as_date("20191231") & op_start_date>=as_date("20190101") , "2019":=1]

#EXPORT D3
fwrite(D3,file=paste0(diroutput,"D3.csv"))


