#' function to read pdf with vegetable data
#' and helper function to dissect string into values
#' function pdf_read_fruts(fname) returns a data.frame if succesfull, NULL otherwise
#' function import utils and pdf_tools

dissect_str<-function(string){
  eid<-stringr::str_sub(string,3,35)
  eid<-stringr::str_remove_all(eid,"[0-9,-]")
  #string1<-str_sub(string,50,length(string))
  prices<-stringr::str_extract_all(string,"( [0-9,.]{2,}($| ))|(  -($| ))")
  l<-c(eid,unlist(prices))
  if(length(l)==4)return(l)
  return(NULL)
}


pdf_read_fruits<-function(link)
{
    date_str<-stringr::str_extract(link,"[0-9]{8}")
    date2<-as.Date(date_str,"%Y%m%d")
    
    
    text1<-try(pdftools::pdf_text(pdf=link))
    if ("try-error" %in% class(text1)){
      message("Error reading PDF") 
      return(NULL) }
    
    
    date_str<-stringr::str_extract(text1,"[0-9]{2}/[0-9]{2}/[0-9]{4}") 
    date1 <-as.Date(date_str,"%d/%m/%Y")
    
    stringr::str_split(text1,"\n") ->text2 #split text with new lines
    text2[[1]]->text3
    
    if(is.na(date1)){
      message("DATE ERROR")
      return(NULL)}
    if( date1!=date2){
      message("Dates different in file content - file name")
      return(NULL)
      }
    
    
    #f1<-function(x){grepl("ΛΑΧΑΝΙΚΑ",x)} #helper functions to test for strings on pdf files
    f1<-function(x){grepl("\u039b\u0391\u03a7\u0391\u039d\u0399\u039a\u0391",x)} #helper functions to test for strings on pdf files
    
    #f2<-function(x){grepl("ΦΡΟΥΤΑ",x)}
    f2<-function(x){grepl("\u03a6\u03a1\u039f\u03a5\u03a4\u0391",x)}
    
    
    
    dRow<-which(f1(text3))
    pRow<-which(f2(text3))
    if(!is.numeric(dRow)| !is.numeric(pRow)) {
      print(dRow)
      print(pRow)
      message("DID NOT FIND TEXT")
      return(NULL)}
    if(length(pRow)==0) {
      message("PROW O")
      return(NULL)}
    if(length(dRow)==0) 
    {message ("DROW O")
      return(NULL)}
    
    if(dRow==0) {
      message("Error. did not find text marker")
      return(NULL)}
    if(pRow==0) {
      message("Error. did not find text marker")
      return(NULL)}
    
    if((pRow-dRow)<2)  return(NULL)
    #better error handling is necessary. SPecifically, error message should be up-propagated
    
    text3[(dRow+2):(pRow-1)] -> text4 #keep part of text between two markees
    vegs <- text4[grepl("[0-9]{2}", text4)]
    
    text3[pRow:length(text3)]->text4
    fruits<-text4[grepl("[0-9]{2}",text4)]
 
    
    
    vegs1<-lapply(vegs,dissect_str)
    fruits<-lapply(fruits,dissect_str)
   
    
    #here checks have to be implemented
    df<-data.frame(col1=character(),col2=character(),col3=character(),col4=character(),stringsAsFactors = FALSE)
   capture.output(names(df)<-c("eidos","dominant","dom_1Y","dom_1W"),file=NULL)
    dfrow=1
    for (t in vegs1){   
       if(length(t)>2) { #some rows are nearly empty, drop them
          df[dfrow,]<- t   #populate a dataframe
          dfrow<-dfrow+1}
    }
  
    
    
    df1<-data.frame(col1=character(),col2=character(),col3=character(),col4=character(),stringsAsFactors = FALSE)
    capture.output(names(df1)<-c("eidos","dominant","dom_1Y","dom_1W"),file=NULL)
    dfrow=1
    for (t in fruits){   
      if(length(t)>2) { #some rows are nearly empty, drop them
        df1[dfrow,]<- t   #populate a dataframe
        dfrow<-dfrow+1}
    }
    df$dominant<-as.double(stringr::str_replace(df$dominant,",","."))
    df$dom_1Y<-as.double(stringr::str_replace(df$dom_1Y,",","."))
    df$dom_1W<-as.double(stringr::str_replace(df$dom_1W,",","."))
    df1$dominant<-as.double(stringr::str_replace(df1$dominant,",","."))
    df1$dom_1Y<-as.double(stringr::str_replace(df1$dom_1Y,",","."))
    df1$dom_1W<-as.double(stringr::str_replace(df1$dom_1W,",","."))
    utils::capture.output(names(df)<-c("CAT","DOMINANT","DOMINANT_1Y","DOMINANT_1W"),file=NULL)
    
    reshape(df,idvar=c("CAT"),varying=list(2:4),direction="long",new.row.names = 1:1000) -> tmp
    tmp$time<-names(df)[tmp$time+1]
    names(tmp)<-c("CAT","PRICE","value")
    tmp$date<-date1
    utils::capture.output(names(df1)<-c("CAT","DOMINANT","DOMINANT_1Y","DOMINANT_1W"),file=NULL)
    
    reshape(df1,idvar=c("CAT"),varying=list(2:4),direction="long",new.row.names = 1:1000) -> tmp1
    tmp1$time<-names(df)[tmp1$time+1]
    names(tmp1)<-c("CAT","PRICE","value")
    tmp1$date<-date1
    
    tmp1$BCAT="FRUITS"
    tmp$BCAT="VEGS"
  
    df<-rbind(tmp,tmp1)
    
    return(df)

}


