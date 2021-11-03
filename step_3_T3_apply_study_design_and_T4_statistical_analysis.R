
#LOAD THE D3 file and create the aggregated ones
D3<-fread(paste0(diroutput,"D3.csv"), skip=1, header=TRUE)

agebandss<-paste0("age_bands", years)
 
 D3_aggregate<-data.table::melt(D3,  measure = list(agebandss,years),variable.name="year",
                                value.name = c("age_bands","present"), na.rm = T)

 vect_recode_ANNI <- years
 names(vect_recode_ANNI) <- c(as.character(seq_len(length(years))))
 D3_aggregate[ , year := vect_recode_ANNI[year]]
 
D3_aggregate<-D3_aggregate[age_bands!="",]
D3_aggregate<-unique(D3_aggregate[,.(person_id,gender,age_bands,year)])
                      
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
if (!require("rmarkdown")) install.packages("rmarkdown")
if (!require("ggplot")) install.packages("ggplot")
if (!require("plotly")) install.packages("plotly")
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

