
#LOAD THE D3 file and create the aggregated ones
D3<-fread(paste0(dirtemp,"D3.csv"), skip=1, header=TRUE)

agebandss<-paste0("age_bands", years)

#aggregation of values by gender agebands and years
D3_aggregated<-D3[, .(count = .N), by = c(agebandss,years,"gender")]


 D3_melt<-data.table::melt(D3_aggregated, measure = list(agebandss,years),variable.name="year",
                                value.name = c("age_bands","present"), na.rm = T)

 vect_recode_years <- years
 names(vect_recode_years) <- c(as.character(seq_len(length(years))))
 D3_melt[ , year := vect_recode_years[year]]
 
 D3_melt<-D3_melt[age_bands!="",][,present:=NULL]

                      
#sum of aggregated value
RES_ageband_by_gender<-D3_melt[, N:=sum(count), by = c("year","age_bands","gender")]

RES_ageband<-D3_melt[,.(count,year,age_bands)]
RES_ageband<-RES_ageband[, N:=sum(count), by = c("year","age_bands")]

RES_gender<-D3_melt[,.(count,year,gender)]
RES_gender<-RES_gender[, N:=sum(count), by = c("year","gender")]

#calculation of percentages by ageband and gender
RES_ageband_by_gender<-unique(RES_ageband_by_gender[,count:=NULL])
RES_ageband_by_gender[,perc :=round(N/sum(N), 4)*100, by = c("year","gender")]
RES_ageband_by_gender<-RES_ageband_by_gender[order(year,age_bands,gender)]

fwrite(RES_ageband_by_gender,file=paste0(diroutput,"RES_ageband_by_gender.csv"))


#calculation of percentages by ageband 
RES_ageband<-unique(RES_ageband[,count:=NULL])
RES_ageband[,perc := paste0(round(N/sum(N), 4)*100, "%"), by = c("year")]
RES_ageband<-RES_ageband[order(year,age_bands)]

fwrite(RES_ageband_by_gender,file=paste0(diroutput,"RES_ageband.csv"))


#calculation of percentages by  gender
RES_gender<-unique(RES_gender[,count:=NULL])
RES_gender[,perc := paste0(round(N/sum(N), 4)*100, "%"), by = c("year")]
RES_gender<-RES_gender[order(year,gender)]

fwrite(RES_gender,file=paste0(diroutput,"RES_gender.csv"))

#
if (!require("rmarkdown")) install.packages("rmarkdown")
if (!require("ggplot2")) install.packages("ggplot2")
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

