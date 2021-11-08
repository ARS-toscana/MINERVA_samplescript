# in this step the file of study variables is created from the instance of the CDM

namefileoutput <- paste0(dirtemp,"D3_",CDM,".csv")

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
  
  



  rm(output_spells_category,PERSONS,OBSERVATION_PERIODS)
  
} else if (CDM == "Nordic") {
  #IMPORT TABLES
  OBSERVATION_PERIODS<-fread(paste0(dirinput,"OBSERVATION_PERIODS.csv"))
  PERSONS<-fread(paste0(dirinput,"PERSONS.csv"))
  
  #SELECT ONLY THE VARIABLES OF INTEREST
  PERSONS<-PERSONS[,.(person_id_src,sex,birth_date)]
  #setnames(PERSONS,"sex","gender")
  PERSONS<-PERSONS[sex == 2, gender := 'F'][sex == 1, gender := 'M'][,sex:=NULL]
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

  rm(output_spells_category,PERSONS,OBSERVATION_PERIODS)
  
} else if (CDM == "TheShinISS") {
  
  #IMPORT TABLES
  ANAGRAFE_ASSISTITI<-fread(paste0(dirinput,"ANAGRAFE_ASSISTITI.csv"))

  #SELECT ONLY THE VARIABLES OF INTEREST
  OBSERVATION_PERIODS<-ANAGRAFE_ASSISTITI[,.(id,sesso,datanas,data_inizioass,data_fineass)]
  OBSERVATION_PERIODS<-OBSERVATION_PERIODS[sesso == 2, gender := 'F'][sesso == 1, gender := 'M'][,sesso:=NULL]
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
  
  rm(output_spells_category,ANAGRAFE_ASSISTITI,OBSERVATION_PERIODS)
  
}


# #CHECK PRESENCE PER YEAR: a subject is present in the year if is for one day in survey observation
for ( i in 1:length(years)){
  D3[ entry_spell_category < as_date(paste0(years[i],"0101")) & exit_spell_category >= as_date(paste0(years[i],"0101")) , paste0("year_",years[i]):=1]
  
  #COMPUTE AGE
  D3<-D3[,paste0("age",years[i]):=age_fast(birth_date,as_date(paste0(years[i],"0101")))]
  D3<-D3 [,paste0("age_bands",years[i]):=cut(get(paste0("age",years[i])), breaks = Agebands,  labels = Labels)]
}


#CLEAN AND EXPORT D3
vartokeep <- c('person_id','gender',paste0("year_",years), paste0("age_bands", years))

# D3<-D3[!is.na(get(years[1])) & !is.na(get(years[2])) & !is.na(get(years[3])) & !is.na(get(years[4])) & !is.na(get(years[5])), ]
D3 <- unique(D3[,..vartokeep])

fwrite(D3,file = namefileoutput)
