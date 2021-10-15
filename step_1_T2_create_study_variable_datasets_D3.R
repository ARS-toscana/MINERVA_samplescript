# in this step the file of study variables is created from the instance of the CDM

dirinput <- paste0(thisdir,"/i_input_",CDM,"/") 
namefileoutput <- paste0(diroutput,"D3_",CDM,".csv")

print(paste0("creating study variables from mock data converted to the ",CDM," CDM"))


if (CDM == "ConcePTION" | CDM == "OMOP") {
  
  #IMPORT TABLES
  OBSERVATION_PERIODS<-fread(paste0(dirinput,"OBSERVATION_PERIODS.csv"))
  PERSONS<-fread(paste0(dirinput,"PERSONS.csv"))
  
  #SELECT ONLY THE VARIABLES OF INTEREST
  if (CDM == "ConcePTION"){
    PERSONS <- PERSONS[,.(person_id,sex_at_instance_creation,day_of_birth,month_of_birth,year_of_birth)]
    setnames(PERSONS,"sex_at_instance_creation","gender")
    OBSERVATION_PERIODS <- OBSERVATION_PERIODS[,.(person_id,op_start_date,op_end_date )]
  }else if (CDM == "OMOP"){
    PERSONS <- PERSONS[,.(person_id,gender_concept_id,day_of_birth,month_of_birth,year_of_birth)]
    setnames(PERSONS,"gender_concept_id","gender")
    OBSERVATION_PERIODS <- OBSERVATION_PERIODS[,.(person_id,observation_period_start_date,observation_period_end_date )]
    setnames(OBSERVATION_PERIODS,"observation_period_start_date","op_start_date")
    setnames(OBSERVATION_PERIODS,"observation_period_end_date","op_end_date")
  }
  
  output_spells_category <- CreateSpells(
    dataset=OBSERVATION_PERIODS,
    id="person_id" ,
    start_date = "op_start_date",
    end_date = "op_end_date",
    gap_allowed = 21
  )
  
  #CREATE BIRTH DATES from the 3 separate columns (day_of_birth,month_of_birth and year_of_birth)
  D3<-merge(PERSONS,output_spells_category,all.x=T)[,day_of_birth:=as.character(day_of_birth)][,month_of_birth:=as.character(month_of_birth)]
  D3[nchar(day_of_birth)<=1,day_of_birth:=paste0(0,day_of_birth)][nchar(month_of_birth)<=1,month_of_birth:=paste0(0,month_of_birth)]
  D3[,birth_date:=paste0(year_of_birth,month_of_birth,day_of_birth)][,year_of_birth:=NULL][,month_of_birth:=NULL][,day_of_birth:=NULL]
  D3[,birth_date:=as_date(birth_date)][,entry_spell_category:=as_date(as.character(entry_spell_category))][,exit_spell_category:=as_date(as.character(exit_spell_category))]
  
  
  #COMPUTE AGE
  D3<-D3[,age:=age_fast(birth_date,as_date("20190101"))]
  D3<-D3 [,age_bands:=cut(age, breaks = Agebands,  labels = c("0-19","20-29", "30-39", "40-49","50-59","60-69", "70-79","80+"))]
  

  # #CHECK PRESENCE PER YEAR (2015-2019): a subject is present in the year if is for one day in survey observation
  D3[ entry_spell_category<=as_date("20151231") & exit_spell_category>= as_date("20150101") , "2015":=1]
  D3[ entry_spell_category<=as_date("20161231") & exit_spell_category>= as_date("20160101")  , "2016":=1]
  D3[ entry_spell_category<=as_date("20171231") & exit_spell_category>= as_date("20170101") , "2017":=1]
  D3[ entry_spell_category<=as_date("20181231") & exit_spell_category>= as_date("20180101") , "2018":=1]
  D3[ entry_spell_category<=as_date("20191231") & exit_spell_category>= as_date("20190101") , "2019":=1]

  rm(output_spells_category,PERSONS,OBSERVATION_PERIODS)
  
} else if (CDM == "Nordic") {
  #IMPORT TABLES
  OBSERVATION_PERIODS<-fread(paste0(dirinput,"OBSERVATION_PERIODS.csv"))
  PERSONS<-fread(paste0(dirinput,"PERSONS.csv"))
  
  #SELECT ONLY THE VARIABLES OF INTEREST
  PERSONS<-PERSONS[,.(person_id_src,sex,birth_date)]
  setnames(PERSONS,"sex","gender")
  setnames(PERSONS,"person_id_src","person_id")
  OBSERVATION_PERIODS<-OBSERVATION_PERIODS[,.(person_id,obs_period_start_date,obs_period_end_date,source )]
  
  
  output_spells_category <- CreateSpells(
    dataset=OBSERVATION_PERIODS,
    id="person_id" ,
    start_date = "obs_period_start_date",
    end_date = "obs_period_end_date",
    gap_allowed = 21
  )
  
  # #CREATE BIRTH DATES from the 3 separate columns (day_of_birth,month_of_birth and year_of_birth)
   D3<-merge(PERSONS,output_spells_category,all.x=T)
  # [,day_of_birth:=as.character(day_of_birth)][,month_of_birth:=as.character(month_of_birth)]
  # D3[nchar(day_of_birth)<=1,day_of_birth:=paste0(0,day_of_birth)][nchar(month_of_birth)<=1,month_of_birth:=paste0(0,month_of_birth)]
  # D3[,date_of_birth:=paste0(year_of_birth,month_of_birth,day_of_birth)][,year_of_birth:=NULL][,month_of_birth:=NULL][,day_of_birth:=NULL]
  # D3[,date_of_birth:=as_date(date_of_birth)][,op_start_date:=as_date(as.character(op_start_date))][,op_end_date:=as_date(as.character(op_end_date))]
  
  
  #COMPUTE AGE
  D3<-D3[,age:=age_fast(birth_date,as_date("20190101"))]
  D3<-D3 [,age_bands:=cut(age, breaks = Agebands,  labels = c("0-19","20-29", "30-39", "40-49","50-59","60-69", "70-79","80+"))]
  

  
  # #CHECK PRESENCE PER YEAR (2015-2019): a subject is present i the year if is for one day in survey observation
  D3[ entry_spell_category<=as_date("20151231") & exit_spell_category>= as_date("20150101") , "2015":=1]
  D3[ entry_spell_category<=as_date("20161231") & exit_spell_category>= as_date("20160101")  , "2016":=1]
  D3[ entry_spell_category<=as_date("20171231") & exit_spell_category>= as_date("20170101") , "2017":=1]
  D3[ entry_spell_category<=as_date("20181231") & exit_spell_category>= as_date("20180101") , "2018":=1]
  D3[ entry_spell_category<=as_date("20191231") & exit_spell_category>= as_date("20190101") , "2019":=1]
  
  
  rm(output_spells_category,PERSONS,OBSERVATION_PERIODS)
  
} else if (CDM == "TheShinISS") {
  
  #IMPORT TABLES
  ANAGRAFE_ASSISTITI<-fread(paste0(dirinput,"ANAGRAFE_ASSISTITI.csv"))

  #SELECT ONLY THE VARIABLES OF INTEREST
  OBSERVATION_PERIODS<-ANAGRAFE_ASSISTITI[,.(id,sesso,datanas,data_inizioass,data_fineass)]
  setnames(OBSERVATION_PERIODS,"sesso","gender")
  setnames(OBSERVATION_PERIODS,"id","person_id")
  setnames(OBSERVATION_PERIODS,"datanas","birth_date")
  setnames(OBSERVATION_PERIODS,"data_inizioass","op_start_date")
  setnames(OBSERVATION_PERIODS,"data_fineass","op_end_date")
  
  OBSERVATION_PERIODS[,birth_date:=as_date(as.character(birth_date))][,op_start_date:=as_date(as.character(op_start_date))][,op_end_date:=as_date(as.character(op_end_date))]
  
  output_spells_category <- CreateSpells(
    dataset=OBSERVATION_PERIODS,
    id="person_id" ,
    start_date = "op_start_date",
    end_date = "op_end_date",
    gap_allowed = 21
  )
  
  D3<-merge(unique(OBSERVATION_PERIODS[,.(person_id,gender,birth_date)]),output_spells_category[,.(person_id,entry_spell_category,exit_spell_category)],all.x=T)
  
  #COMPUTE AGE
  D3<-D3[,age:=age_fast(birth_date,as_date("20190101"))]
  D3<-D3 [,age_bands:=cut(age, breaks = Agebands,  labels = c("0-19","20-29", "30-39", "40-49","50-59","60-69", "70-79","80+"))]
  
  
  # #CHECK PRESENCE PER YEAR (2015-2019): a subject is present i the year if is for one day in survey observation
  D3[ entry_spell_category<=as_date("20151231") & exit_spell_category>= as_date("20150101") , "2015":=1]
  D3[ entry_spell_category<=as_date("20161231") & exit_spell_category>= as_date("20160101")  , "2016":=1]
  D3[ entry_spell_category<=as_date("20171231") & exit_spell_category>= as_date("20170101") , "2017":=1]
  D3[ entry_spell_category<=as_date("20181231") & exit_spell_category>= as_date("20180101") , "2018":=1]
  D3[ entry_spell_category<=as_date("20191231") & exit_spell_category>= as_date("20190101") , "2019":=1]
  
  rm(output_spells_category,ANAGRAFE_ASSISTITI,OBSERVATION_PERIODS)
  
}

#CLEAN AND EXPORT D3
D3 <- D3[,.(person_id,gender,age_bands,'2015','2016','2017','2018','2019')]
fwrite(D3,file = namefileoutput)
rm(D3)