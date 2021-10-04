#################################################################################################
## ETL ConcePTION ARS ####

# Version 2.2
# 04-19-2021
# Author: CB 

#################################################################################################

rm(list=ls(all.names=TRUE))

# set the directory where the file is saved as the working directory
thisdir<-dirname(rstudioapi::getSourceEditorContext()$path)
setwd(thisdir)

#load parameters
source(paste0(thisdir,"/parameters/parameters_ConcePTION.R"))
setwd(thisdir)



# 01.	Use ANAFULL to populate PERSONS and OBSERVATIONS_PERIODS --------

ANAFULL <- fread(paste0(dirinput,"/ANAFULL.csv"))
setkeyv(ANAFULL,"ID")

## Specification table PERSONS: 
# The local tables feeding this CDM table are: ANAFULL 
#- ANAFULL: Select all the distinct values of ID having at least one record with COD_REGIONE=’090’; for each of them select the values as follows

PERSON_<-ANAFULL[,.(ID, DATA_NASCITA, DATA_MORTE_MARSI,SESSO)]
PERSON<-unique(PERSON_)

PERSON<-PERSON[,DATA_NASCITA:=as.Date(DATA_NASCITA)]
PERSON<-PERSON[,DATA_MORTE_MARSI:=lubridate::ymd(DATA_MORTE_MARSI)]

PERSON<-PERSON[,`:=`(race="",country_of_birth="", quality="reliable")]
PERSON<-PERSON[,`:=`(day_of_birth=as.character(day(DATA_NASCITA)),
                     month_of_birth=as.character(month(DATA_NASCITA)), year_of_birth=as.character(year(DATA_NASCITA)),
                     day_of_death=as.character(day(DATA_MORTE_MARSI)), month_of_death=as.character(month(DATA_MORTE_MARSI)), year_of_death=as.character(year(DATA_MORTE_MARSI)))]
rm(PERSON_)
##21/12: change in modality of sex_at_instance_creation
PERSON<-PERSON[,SESSO:=as.character(SESSO)]
PERSON<-PERSON[SESSO=="1",SESSO:="M"][SESSO=="2",SESSO:="F"]

##22/04: added 0 if is not present, is mandatory to have2 digits
PERSON<-PERSON[nchar(day_of_birth)==1,day_of_birth:=paste0("0",day_of_birth)]
PERSON<-PERSON[nchar(month_of_birth)==1,month_of_birth:=paste0("0",month_of_birth)]
PERSON<-PERSON[nchar(year_of_birth)==1,year_of_birth:=paste0("0",year_of_birth)]
PERSON<-PERSON[nchar(month_of_death)==1,month_of_death:=paste0("0",month_of_death)]
PERSON<-PERSON[nchar(day_of_death)==1,day_of_death:=paste0("0",day_of_death)]
PERSON<-PERSON[nchar(year_of_birth)==1,year_of_birth:=paste0("0",year_of_birth)]

setnames(PERSON, "ID","person_id")
#setnames(PERSON, "DATA_NASCITA","date_birth")
#setnames(PERSON, "DATA_MORTE_MARSI","date_death")
setnames(PERSON, "SESSO","sex_at_instance_creation")

# PERSONS<-PERSON[,`:=`(date_birth=format(date_birth, "%Y%m%d"),
#   date_death=format(date_death, "%Y%m%d"))]
PERSONS<-PERSON[,.(person_id,day_of_birth, month_of_birth,year_of_birth,day_of_death,month_of_death,year_of_death,sex_at_instance_creation,race, country_of_birth,quality)]

fwrite(PERSONS, paste0(diroutput,"/PERSONS.csv"), quote = "auto")
rm(PERSON)

## Specification table OBSERVATION_PERIODS: 
# The local tables feeding this CDM table are: ARS_ANAG_MED_RES_storico 

#- ARS_ANAG_MED_RES_storico: For each record with COD_REGIONE=’090’, fill the column of this table as follows 

## added criteria of 60 days after date of birth as date of birth
OBSERVATION_PERIODS_<-ANAFULL[,.(ID,INI_RECORD,FINE_RECORD, DATA_NASCITA)]

OBSERVATION_PERIODS_<-OBSERVATION_PERIODS_[,INI_RECORD:=as.Date(INI_RECORD)]
OBSERVATION_PERIODS_<-OBSERVATION_PERIODS_[,FINE_RECORD:=as.Date(FINE_RECORD)]
OBSERVATION_PERIODS_<-OBSERVATION_PERIODS_[,DATA_NASCITA:=as.Date(DATA_NASCITA)]

#OBSERVATION_PERIODS_[, diff:=INI_RECORD-DATA_NASCITA]
OBSERVATION_PERIODS_[DATA_NASCITA+60>=INI_RECORD & DATA_NASCITA<INI_RECORD,INI_RECORD:=DATA_NASCITA]


OBSERVATION_PERIODS_<-OBSERVATION_PERIODS_[,`:=`(op_origin="ARS_ANAG_MED_RES_storico",
                                                 op_meaning="healthcare_office")]

setnames(OBSERVATION_PERIODS_, "ID","person_id")
setnames(OBSERVATION_PERIODS_, "INI_RECORD","op_start_date")
setnames(OBSERVATION_PERIODS_, "FINE_RECORD","op_end_date")

OBSERVATION_PERIODS_<-OBSERVATION_PERIODS_[,`:=`(op_start_date= format(op_start_date, "%Y%m%d"), op_end_date= format(op_end_date, "%Y%m%d"))]
OBSERVATION_PERIODS<-OBSERVATION_PERIODS_[,.(person_id,op_start_date,op_end_date,op_meaning,op_origin)]

fwrite(OBSERVATION_PERIODS, paste0(diroutput,"/OBSERVATION_PERIODS.csv"), quote = "auto")

rm(ANAFULL, OBSERVATION_PERIODS_, OBSERVATION_PERIODS, PERSONS)

