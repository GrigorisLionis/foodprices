extract_links<-function(link){ #simple parser of links of pdf and xls files
  p<-rvest::read_html(link) #reads link
  #p %>% rvest::html_elements("div") %>% rvest::html_elements("a") %>% rvest::html_attr("href") %>% as_tibble() ->links; 
  rvest::html_elements(p,"div")->tmp1
  rvest::html_elements(tmp1,"a")->tmp1
  rvest::html_attr(tmp1,"href")->tmp1

  #links<-data.frame(value=tmp1,stringsAsFactors = FALSE)
  links<- tmp1[grepl(".pdf",tmp1) | grepl(".xls",tmp1)]
  #print(links)
  return(links)
  #use filter to fidn pdf and xls files
}

number_of_pages<-function(){
  link<-"https://www.okaa.gr/gr/nea-kai-anakoinoseis/statistika-deltia-timon/"
  p<-rvest::read_html(link)
   
  rvest::html_nodes(p,xpath = "//div[@class='page_numbers']")->tmp1
  rvest::html_nodes(tmp1,xpath = "//a[@class='number']") ->tmp1 
  rvest::html_text(tmp1)->pg
  return(as.integer(unlist(pg[[length(pg)]])))
}
