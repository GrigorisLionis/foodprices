
xls_data_fruits<-function(filename){
  suppressMessages(x1<-try(readxl::read_excel(path=filename)))
  #print(class(x1))
  if ("try-error" %in% class(x1)){
    message("Error. Error reading xls file")
    return(NULL)
    }
  
  x1<-as.data.frame(x1)
  str1="\u039b\u0391\u03a7\u0391\u039d\u0399\u039a\u0391"#"ΛΑΧΑΝΙΚΑ"
  str1a="\u039b\u0020\u0391\u0020\u03a7\u0020\u0391\u0020\u039d\u0020\u0399\u0020\u039a\u0020\u0391"#"Λ Α Χ Α Ν Ι Κ Α"
  str2="\u03a6\u03a1\u039f\u03a5\u03a4\u0391" #"ΦΡΟΥΤΑ"
  date2<-as.Date(stringr::str_extract(filename,"[0-9]{8}"),"%Y%m%d")

  x1$RN<-row.names(x1)
  unlist(x1$RN[ grepl(str1,x1$`...2`)| grepl(str1a,x1$`...2`)]) -> dRow #find row where data begins
  unlist(x1$RN[grepl(str2,x1$`...2`)])->pRow
  #x1 %>% filter(grepl(str2,`...2`)) %>% select(RN) %>% unlist() ->pRow #find row where data ends
  if(length(dRow)==2)
  {
    message("Warning. One code word found twice. Compensating")
    pRow<-dRow[2]
    dRow<-dRow[1]
  }
  #x1 %>% filter(RN>=dRow & RN!=pRow,!is.na(`...1`)) -> df #pick data portion of xl file 
  x1[x1$RN>=dRow & x1$RN!=pRow,]->tmp1
  tmp1[!is.na(tmp1$`...1`)]->df
  #print(dRow)
  #x1 %>% filter(RN==dRow) %>% sapply(f1) -> l1 # first line of data is  header
  #l1 %>% str_trim() %>% str_replace_all("\n"," ") %>% str_replace("€","") %>% str_trim() -> l1 
  #x11<-select(x1,-RN)
  x11<-x1
  x11$RN<-NULL
  txt<-apply(x11,1,function(x) paste(x,collapse=""))
  df<-x1[grepl("[0-9,]{2,}",txt),] #keep lines with numbers
  
  if(length(df)==10) #in some excel, there is an extra column, empyt... remove it
    df[,8]<-NULL
  
  utils::capture.output(names(df)<-c("num","CAT","EXTRA","RANGEI","RANGEII","DOMINANT","DOMINANT_1Y","DOMINANT_1W","RN"),file=NULL)
  df$BCAT<-ifelse(df$RN<pRow,"VEGS","FRUITS")
  l1<-df$CAT
  l2<-df$BCAT
  names(l2)<-l1
  corr<-data.frame(l1,l2)
  df$BCAT<-NULL
  df$num<-NULL
  df$RN<-NULL 
  stats::reshape(df,idvar="CAT",varying=list(2:7),direction="long",new.row.names = 1:1000) -> tmp1
  tmp1$time<-names(df)[tmp1$time+1]
  names(tmp1)<-c("CAT","PRICE","value")
  tmp1$date<-date2
  tmp1$BCAT=l2[tmp1$CAT]
  
  return(tmp1)
  
  
}

return_date<-function(string){
  date_string<-stringr::str_extract_all(string,"[0-9]{8}") #extract 8 numeric digit
  date_d<-as.Date(unlist(date_string),"%Y%m%d") #cast them as date
  return(date_d)
 }


