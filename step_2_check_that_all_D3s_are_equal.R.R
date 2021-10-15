# in this step the four files D3_CDM.csv are proved to e equaland one of them is saved as D3

dirinput <- diroutput
namefileoutput <- paste0(diroutput,"D3.csv")

print(paste0("creating study variables from mock data converted to the ",CDM," CDM"))

#IMPORT TABLES
CDMcheck <- "ConcePTION"
for (CDMcheck in c("ConcePTION","OMOP","Nordic","TheShinISS")) {
  temp <- fread(paste0(dirinput,"D3_",CDMcheck,".csv"))
  temp <- temp[,.(person_id,gender,age_bands,'2015','2016','2017','2018','2019')]
  for (varname in c('2015','2016','2017','2018','2019') ){
    setnames(temp,varname,paste0(varname,CDMcheck) )
  }
  if (CDM == "ConcePTION"){
    check_file <- fread(paste0(dirinput,"D3_ConcePTION.csv"))
  }else{
    check_file <- merge(check_file,temp,all = T)
  }
}  


#export D3 using any of the existing D3s (since they are all equal)
temp <- fread(paste0(dirinput,"D3_ConcePTION.csv"))
fwrite(temp,file = namefileoutput)
  
rm(check_file,temp)


