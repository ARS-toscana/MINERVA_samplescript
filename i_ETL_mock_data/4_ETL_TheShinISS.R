#################################################################################################
## ETL TheShinISS ARS ####

# Version 1.0
# 04-10-2021
# Author: CB 

#################################################################################################

rm(list=ls(all.names=TRUE))

# set the directory where the file is saved as the working directory
thisdir<-dirname(rstudioapi::getSourceEditorContext()$path)
setwd(thisdir)

#load parameters
source(paste0(thisdir,"/parameters/parameters_TheShinISS.R"))
setwd(thisdir)


# 01.	Use ARS_ANAG_MED_RES_storico to populate ANAGRAFE_ASSISTITI --------

ANAFULL <- fread(paste0(dirinput,"/ANAFULL.csv"))
setkeyv(ANAFULL,"ID")


ANAGRAFE_ASSISTITI<-ANAFULL[,FINE_RECORD:=as.Date(FINE_RECORD)]

setnames(ANAGRAFE_ASSISTITI, "ID","id")
setnames(ANAGRAFE_ASSISTITI, "DATA_NASCITA","datanas")
setnames(ANAGRAFE_ASSISTITI, "DATA_MORTE_MARSI","datadec")
setnames(ANAGRAFE_ASSISTITI, "SESSO","sesso")
setnames(ANAGRAFE_ASSISTITI, "INI_RECORD","data_inizioass")
setnames(ANAGRAFE_ASSISTITI, "FINE_RECORD","data_fineass")

ANAGRAFE_ASSISTITI<-ANAGRAFE_ASSISTITI[,`:=`(datanas= format(datanas, "%Y%m%d"), data_inizioass= format(data_inizioass, "%Y%m%d"), datadec= format(datadec, "%Y%m%d"),data_fineass= format(data_fineass, "%Y%m%d"))]
ANAGRAFE_ASSISTITI<-ANAGRAFE_ASSISTITI[,.(id,sesso,datanas,data_inizioass,data_fineass,datadec)]

fwrite(ANAGRAFE_ASSISTITI, paste0(diroutput,"/ANAGRAFE_ASSISTITI.csv"), quote = "auto")

rm(ANAFULL)
