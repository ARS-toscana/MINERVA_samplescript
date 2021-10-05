#################################################################################################
## ETL ConcePTION ARS ####

# Version 2.2
# 04-10-2021
# Author: CB 

#################################################################################################

rm(list=ls(all.names=TRUE))

# set the directory where the file is saved as the working directory
thisdir<-dirname(rstudioapi::getSourceEditorContext()$path)
setwd(thisdir)

#load parameters
source(paste0(thisdir,"/parameters/parameters_Nordic.R"))
setwd(thisdir)


# 01.	Use ANAFULL to populate PERSONS, OBSERVATION_PERIODS --------
ANAFULL <- fread(paste0(dirinput,"/ANAFULL.csv"))
setkeyv(ANAFULL,"ID")

## PERSONS:
# Action: all rows of ANAFULL for the same person_id have the same variables below, so one single row of PERSONS is generated

#create person_id as number that identifier uniquely person, used to link across tables. (Primary key)
PERSONS<-copy(ANAFULL)

#renamed vars
setnames(PERSONS,"ID","person_id_src")
setnames(PERSONS,"DATA_NASCITA","birth_date")
setnames(PERSONS,"DATA_MORTE_MARSI","death_date")
setnames(PERSONS,"SESSO","sex")

# make the data unique
PERSONS<-unique(PERSONS[,.(person_id_src,birth_date,sex,death_date)])

# keep only needed vars.
PERSONS<-PERSONS[,person_id:=1:.N]
PERSONS<-PERSONS[,.(person_id,person_id_src,birth_date,sex,death_date)]

fwrite(PERSONS, paste0(diroutput,"/PERSONS.csv"), quote = "auto")



## OBSERVATION_PERIODS: 
# Action: one row of ANAGRAFE_ASSISTITI generates one row of OBSERVATION_PERIODS (multiple observations per person are possible)

OBSERVATION_PERIODS<-copy(ANAFULL)[,source:="ALL"][,obs_period_id:=1:.N]

#usa CreateSpells prima di fare OBSERVATION_PERIODS

#renamed vars
setnames(OBSERVATION_PERIODS,"ID","person_id")
setnames(OBSERVATION_PERIODS,"INI_RECORD","obs_period_start_date")
setnames(OBSERVATION_PERIODS,"FINE_RECORD","obs_period_end_date")
setnames(OBSERVATION_PERIODS,"DATA_NASCITA","birth_date")
setnames(OBSERVATION_PERIODS,"DATA_MORTE_MARSI","death_date")
setnames(OBSERVATION_PERIODS,"SESSO","sex")

# create obs_period_end_reason
OBSERVATION_PERIODS<-OBSERVATION_PERIODS[obs_period_end_date==date_end, obs_period_end_reason:=1]
OBSERVATION_PERIODS<-OBSERVATION_PERIODS[obs_period_end_date==death_date, obs_period_end_reason:=2]
OBSERVATION_PERIODS<-OBSERVATION_PERIODS[is.na(death_date) & obs_period_end_date!=date_end, obs_period_end_reason:=3]

# keep only needed vars.
OBSERVATION_PERIODS<-OBSERVATION_PERIODS[,.(obs_period_id,person_id,source,obs_period_start_date,obs_period_end_date,obs_period_end_reason)]

fwrite(OBSERVATION_PERIODS, paste0(diroutput,"/OBSERVATION_PERIODS.csv"), quote = "auto")

rm(ANAFULL, PERSONS, OBSERVATION_PERIODS)
