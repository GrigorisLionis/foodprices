#' function to read and clean pdf files with meat prices
#' function reads the pdf as text
#' and reads the data into a data.frame
#' the function is simple enough and does not proceeds into many checks
#' the function returns a data.frame with 5 columns if it succeeds, NULL otherwise

pdf_read<-function(link)
{
    
    date_str<-stringr::str_extract(link,"[0-9]{8}")
    date2<-as.Date(date_str,"%Y%m%d")
    
    text1<-try(pdftools::pdf_text(pdf=link))
    if ("try-error" %in% class(text1)) {
      message("Pdf Error")
      return(NULL)
    }
    
    date_str<-stringr::str_extract(text1,"[0-9]{2}/[0-9]{2}/[0-9]{4}") 
    date1 <-as.Date(date_str,"%d/%m/%Y")
    stringr::str_split(text1,"\n") ->text2 #split text with new lines
    text2[[1]]->text3
    if(is.na(date1)){
      message("Date error")
      return(NULL)}
    if( date1!=date2){
      messase("Different dates in file name and file content")
      return(NULL)
      }
    
    f1<-function(x){grepl("\u0391\u002f\u0391",x)} #helper functions to test for strings on pdf files
    
    #f2<-function(x){grepl("Παρατηρήσεις",x)}
    f2<-function(x){grepl("\u03a0\u03b1\u03c1\u03b1\u03c4\u03b7\u03c1\u03ae\u03c3\u03b5\u03b9\u03c2",x)}
    
    dRow<-which(f1(text3))
    pRow<-which(f2(text3))
    if(!is.numeric(dRow)| !is.numeric(pRow)) {
      print(dRow)
      print(pRow)
      message("Error. Did not fine text markers to extract data")
      return(NULL)}
    if(length(pRow)==0) {message ("Error. PROW O")
      return(NULL)}
    if(length(dRow)==0) {message ("DROW O")
      return(NULL)}
    
    if(dRow==0) {return(NULL)}
    if(pRow==0) {return(NULL)}
    
    if((pRow-dRow)<2)  return(NULL)
    #better error handling is necessary. SPecifically, error message should be up-propagated
    text3[(dRow+2):(pRow-1)] -> text4 #keep part of text between two markees
    stringr::str_split(text4,"\\s{2,}") -> text5 #splt on 2+ spaces, to keep texts with spaces
                                             
    #here checks have to be implemented
    df<-data.frame(col1=character(),col2=character(),col3=character(),col4=character(),col5=character(),col6=character(),col7=character(),stringsAsFactors = FALSE)
    names(df)<-c("idx","eidos","kat","an","epik","evros1","evros2")
    dfrow=1
    #text5 contains list (rows) of lists (columbs) of char
    #each element of text5 is a row
    for (t in text5){   
       if(length(t)>2) { #some rows are nearly empty, drop them
          t1<-c(t,rep(NA,7-length(t)))   #some do not have all the prices, fill with NA
          df[dfrow,]<- t1   #populate a dataframe
          dfrow<-dfrow+1}
       }
  
    #change strings of df to nums
    df$kat<-stringr::str_replace(df$kat,",",".")
    df$an<-stringr::str_replace(df$an,",",".")
    df$epik<-stringr::str_replace(df$epik,",",".")
    df$evros1<-stringr::str_replace_all(df$evros1,",",".")
    df$evros2<-stringr::str_replace_all(df$evros2,",",".")
    df[1]<-NULL    #drop first column
    
    capture.output(names(df)<-c("CAT","LOWER","HIGHER","DOMINANT","EVR1","EVR2"),file=NULL)
  
    reshape(df,idvar="CAT",varying=list(2:6),direction="long",new.row.names = 1:1000) -> tmp1
    tmp1$time<-names(df)[tmp1$time+1]
    names(tmp1)<-c("CAT","PRICE","value")
    tmp1$date<-date1
    tmp1$BCAT<-"MEAT"
    return(tmp1)

}

