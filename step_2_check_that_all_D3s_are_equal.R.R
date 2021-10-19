# in this step the four files D3_CDM.csv are proved to e equaland one of them is saved as D3

dirinput <- diroutput
namefileoutput <- paste0(diroutput,"D3.csv")

print(paste0("creating study variables from mock data converted to the ",CDM," CDM"))

#IMPORT TABLES
CDMcheck <- "ConcePTION"
for (CDMcheck in c("ConcePTION","OMOP","Nordic","TheShinISS")) {
  assign('temp', fread(paste0(dirinput,"D3_",CDMcheck,".csv"), header = T))
  # vartokeep <- c('person_id','gender','age_bands','2015','2016','2017','2018','2019')
  # temp <- temp[,..vartokeep]
  # for (varname in c('2015','2016','2017','2018','2019') ){
  #   setnames(temp,varname,paste0(varname,CDMcheck) )
  # }
  if (CDMcheck == "ConcePTION"){
    check_file <- temp
  }else{
    check_file <- merge(check_file,temp,by = colnames(check_file),all = F)
  }
}  


#export D3 using any of the existing D3s (since they are all equal)
temp <- fread(paste0(dirinput,"D3_ConcePTION.csv"))
fwrite(temp,file = namefileoutput)
  
rm(check_file,temp)


