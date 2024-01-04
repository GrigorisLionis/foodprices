#' Read price data from website
#' 
#' This function reads the price data from the website, and returns
#' a data frame with the requested data. 
#' @param start_date start date,in %d-%m-%Y, for data retrival
#' @param end_date end date,in  %d-%m-%Y, for data retrival
#' @param use_cache TRUE/FALSE whether to use a cache directory for storing files
#' @param cache_path path to store files
#' @param food string ALL|MEAT|FRUITS|VEGETABLES to choose kind of food to report
#' @export
#' @return A dataframe with the requested data
get_data<-function(start_date="01-01-2010",end_date="01-01-2024",cache_path="./files/",use_cache = FALSE,food="ALL"){
  sdate=as.Date(start_date,"%d-%m-%Y")
  edate=as.Date(end_date,"%d-%m-%Y")
  if( !(food %in% c("ALL","MEAT","FRUITS","VEGETABLES"))){
    message("Error. Optional parameter food shoud be \"ALL\",\"MEAT\",\"FRUITS\",\"VEGETABLES\"")
    return(NULL)}
  if(is.na(sdate)){
    message("Error.Optional argument start Date should be on  on %d-%m-%Y"); return(NULL)}  
  if(is.na(edate)){
    message("Error.Optional argument end date should be on  on %d-%m-%Y"); return(NULL)}
  if(!is.logical(use_cache)){
    message("Error.Optional argument use_cache should be TRUE/FALSE"); return(NULL)}
  if(use_cache){
    if(!file.exists(cache_path)){dir.create(cache_path)}
  }
  file_paths<-c("")
  okaa_path<-"https://www.okaa.gr/"
  base_link="https://www.okaa.gr/gr/nea-kai-anakoinoseis/statistika-deltia-timon/?pg="
  np<-number_of_pages()
  for (i in 1:np){ 
    link=paste(base_link,as.character(i),sep = "");
    links=extract_links(link);
    #print(links)
 
    #print(links)
    #print(file_paths)
    file_paths<-c(file_paths,links); #file links are stored on file_paths data.frame
    #print(file_paths)
    #stop()
    last<-file_paths[length(file_paths)]
    #print(last)

    date_c<-as.Date(stringr::str_extract(last,"[0-9]{8}"),"%Y%m%d")
    #print(date_c)
    if (!is.na(date_c)) {if (sdate>date_c) {break}}
  }
 
  sp_name <-function(name){
    stringr::str_split(name,"/")->tmp1 
    unlist(tmp1)->tmp1 
    utils::tail(tmp1,n=1)->fn 
    return(fn)
  }
  file_paths<-data.frame(value=file_paths,stringsAsFactors = FALSE)
  file_paths$link<-(paste(okaa_path,file_paths$value,sep=""))
  file_paths$name<-unname(sapply(file_paths$value,sp_name))
  file_paths$dates<-as.Date(stringr::str_extract(file_paths$name,"[0-9]{8}"),"%Y%m%d") 
 
  file_paths<-file_paths[file_paths$dates>=sdate & file_paths$dates<=edate,]
  if(food=="MEAT"){
    file_paths<-file_paths[grepl("kreas",file_paths$name),]
  }
  if(food=="VEGETABLES"| food=="FRUITS"){
    file_paths<-file_paths[!grepl("kreas",file_paths$name),]
  }
  file_paths<-file_paths[!is.na(file_paths$name),]
  
  if(!use_cache){
    cache_path<-paste(tempdir(),"/",sep="")
    use_cache=TRUE
  }
  #if cache is not requested, create tmpdir
  #store files in tmpdir
  #use the same alg
  
  if(use_cache){
    for(filename in file_paths$name){
      if (is.na(filename)) next 
      if(!file.exists(paste(cache_path,filename,sep=""))){
        link=file_paths[file_paths$name==filename,]$link
        #system(paste("wget '",link,"' -O '",cache_path,filename,"'",sep=""))
        link<-gsub(" ","%20",link)
        #print(link)
        #print(filename)
        #print(paste(cache_path,filename,sep=""))
        print(paste("downloading...",filename))
        utils::download.file(url=link,destfile=paste(cache_path,filename,sep=""))
        
      }
      
    }
    
  }
  
  kreas<-file_paths[grepl("kreas",file_paths$name),]$name
  laxan<-file_paths[!grepl("kreas",file_paths$name),]$name
  if(food=="MEAT"){laxan<-NULL}
  if(food =="FRUITS" | food=="VEGETABLES") {kreas<-NULL}
  
  RES<-NULL
  
  for (fname in kreas){
    filename=paste(cache_path,fname,sep="")
    
    if(grepl("xls",fname)) {xls_data(filename) -> d1}
    if(grepl("pdf",fname)) {pdf_read(filename) -> d1}
    if(is.data.frame(d1)){ RES<- rbind(RES,d1)}
  }
  
  for (fname in laxan){
    filename=paste(cache_path,fname,sep="")
    #print(filename)
    if(grepl("xls",fname)) {
      d1<- try(xls_data_fruits(filename))
      if ("try-error" %in% class(d1)){
           print("ERROR processing file")
           print(filename)
           next() }
      }
    if(grepl("pdf",fname)){
        d1<- try(pdf_read_fruits(filename))
        if ("try-error" %in% class(d1)){
             print("ERROR processing file")
             print(filename)
             next() }
  } 

    
    if(is.data.frame(d1)){ RES<- rbind(RES,d1)}
  }
  
  if(food=="FRUITS") RES<-RES[RES$BCAT=="FRUITS",]
  if(food=="VEGETABLES") RES<-RES[RES$BCAT=="VEGS",]
  
  return(RES)
}
  

