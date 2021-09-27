
# D4_aggregate<-reshape(D4, idvar = "person_id", varying = list(8:12),
#                       v.names = "year", direction = "long")

cols_tokeep<-colnames(D3)[!grepl("20",colnames(D3))]
measures<-colnames(D3)[grepl("20",colnames(D3))]

D3_aggregate<-melt(D3, id.vars = cols_tokeep, measure.vars = measures,
                   variable.name = "year", na.rm = T)
                      
#AGGREGATION BY AGEBAND AND GENDER
RES_ageband_by_gender<-D3_aggregate[, .(N = .N), by = c("year","age_bands","gender")]
RES_ageband_by_gender[,perc :=round(N/sum(N), 4)*100, by = c("year","gender")]

RES_ageband_by_gender<-RES_ageband_by_gender[order(year,age_bands,gender)]

fwrite(RES_ageband_by_gender,file=paste0(diroutput,"RES_ageband_by_gender.csv"))

#AGGREGATION BY AGEBAND 
RES_ageband<-D3_aggregate[, .(N = .N), by = c("year","age_bands")]
RES_ageband[,perc := paste0(round(N/sum(N), 4)*100, "%"), by = c("year")]
RES_ageband<-RES_ageband[order(year,age_bands)]

fwrite(RES_ageband_by_gender,file=paste0(diroutput,"RES_ageband.csv"))

#AGGREGATION BY GENDER
RES_gender<-D3_aggregate[, .(N = .N), by = c("year","gender")]
RES_gender[,perc := paste0(round(N/sum(N), 4)*100, "%"), by = c("year")]
RES_gender<-RES_gender[order(year,gender)]

fwrite(RES_gender,file=paste0(diroutput,"RES_gender.csv"))

#
install.packages("rmarkdown")
library(rmarkdown)
library(ggplot2)
library(plotly)
library(ggthemes)
render(paste0(thisdir,"/graphs.Rmd"),           
       output_dir = diroutput,
       output_file = "HTML_graphs", 
       params=list(RES_ageband = RES_ageband,
                   RES_gender = RES_gender,
                   RES_ageband_by_gender= RES_ageband_by_gender))

