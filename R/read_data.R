
xls_data<-function(filename){
  
  suppressMessages(x1<-try(readxl::read_excel(path=filename)))
  if ("try-error" %in% class(x1)) return(NULL)
  
  #check dates to see if match
  #tests SHOULD be more elaborate...
  x1<-as.data.frame(x1) 
  c(apply(x1,1,function(x) paste(x,collapse="")),names(x1))->tmp1 
  paste(tmp1,collapse = "")->tmp1 
  stringr::str_extract(tmp1,"[0-9]{2}/[0-9]{2}/[0-9]{4}") ->tmp1 
  date1<-as.Date(tmp1,"%d/%m/%Y")
  #collapse all text into a single string, and pick nn/nn/nnnn as a date
  date2<-return_date(filename)
  if(date1!=date2){
    base::message("Error. Dates do not match")
    return(NULL)
  }
  
  str1="\u0395\u0399\u0394\u039f\u03a3"#"ΕΙΔΟΣ"
  str2="\u03a0\u03b1\u03c1\u03b1\u03c4\u03b7\u03c1\u03ae"#"Παρατηρή"
  
  #x1 %>% mutate(RN=row_number()) -> x1 #add row number
  x1$RN<-row.names(x1)
  
  #x1 %>% filter(grepl(str1,`...2`)) %>% select(RN) %>% unlist() -> dRow #find row where data begins
  unlist(x1$RN[grepl(str1,x1$`...2`)])->dRow
  unlist(x1$RN[grepl(str2,x1$`...2`)])->pRow
  
  #x1 %>% filter(grepl(str2,`...2`)) %>% select(RN) %>% unlist() ->pRow #find row where data ends
  #x1 %>% filter(RN>=dRow & RN<pRow) -> picked_data #pick data portion of xl file 
  picked_data<-x1[x1$RN>dRow & x1$RN<pRow,]
  
  sapply(x1[x1$RN==dRow,], function(x) return(x[[1]])) -> l1 # first line of data is  header
  
  
  stringr::str_trim(l1) -> tmp1
  stringr::str_replace_all(tmp1,"\n","") ->tmp1
  stringr::str_replace(tmp1,"\u0080","")->tmp1
  stringr::str_trim(tmp1) -> l1
  #remove from header new files, euro sing, 

  utils::capture.output(names(picked_data)<-l1,file=NULL)
  #change column names
  
  picked_data<-picked_data[2:5]
  names(picked_data)<-c("CAT","LOWER","HIGHER","DOMINANT")
  res<-picked_data[picked_data$CAT!="\u0395\u0399\u0394\u039f\u03a3",] #ΕΙΔΟΣ
  res[!(is.na(res$CAT)),]->res
  res$LOWER<-as.numeric(res$LOWER)
  res$HIGHER<-as.numeric(res$HIGHER)
  res$DOMINANT<-as.numeric(res$DOMINANT)
  #remove first columun, keep only 4 columns, change to numeric
  
  
  
  stats::reshape(res,idvar="CAT",varying=list(2:4),direction="long",new.row.names = 1:1000) -> tmp1
  tmp1$time<-names(res)[tmp1$time+1]
  names(tmp1)<-c("CAT","PRICE","value")
  tmp1$BCAT<-"MEAT"
  tmp1$date<-date1
  return(tmp1)
  
  
}

return_date<-function(string){
  date_string<-stringr::str_extract_all(string,"[0-9]{8}") #extract 8 numeric digit
  date_d<-as.Date(unlist(date_string),"%Y%m%d") #cast them as date
  return(date_d)
 
}

