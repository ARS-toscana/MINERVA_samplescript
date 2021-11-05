# in this step the four files D3_CDM.csv are proved to e equaland one of them is saved as D3

dirinput <- dirtemp
namefileoutput <- paste0(dirtemp,"D3.csv")

print(paste0("creating study variables from mock data converted to the ",CDM," CDM"))

#IMPORT TABLES

if (length(CDMs)>1) {
  
  combs<-combn(CDMs, 2, simplify = FALSE)
  
  for (i in 1:length(combs)) {
    for (CDMcheck in list(combs[[i]])) {
      temp1<-fread(paste0(dirinput,"D3_",CDMcheck[[1]],".csv"),header = T)
      temp2<-fread(paste0(dirinput,"D3_",CDMcheck[[2]],".csv"),header = T)
      if (identical(temp1,temp2)==F) warning("The dataset ",CDMcheck[[1]]," and ", CDMcheck[[2]]," are not identical")
      if (identical(temp1,temp2)==T) message("The datasets ",CDMcheck[[1]]," and ", CDMcheck[[2]]," are identical")
    }  
  }
  #export D3 using any of the existing D3s (since they are all equal)
  temp <- fread(paste0(dirinput,"D3_ConcePTION.csv"))
  fwrite(temp,file = namefileoutput)
}else{
  #export D3 using any of the existing D3s (since they are all equal)
  temp <- fread(paste0(dirinput,"D3_",CDMs,".csv"))
  fwrite(temp,file = namefileoutput)
}





  
rm(temp)


