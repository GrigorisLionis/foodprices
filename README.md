# foodprices
Price data for the central furit market of Athens is released four times per week. The price data are released in xls and pdf files
Goal of this project is to parse the data and provied a easy to use data source.

## description
Main function is in file get_data.R. 
It reads the data pages, extracts the links,  composes a list of all the xls and pdf links for downloading. For downloading, we use system wget, to avoid messing with utf8 on the url.
Also contains code to parse the xls files.

## usage

get_data(start_date,end_data,cache_path,use_cache,food)

* start_date : "dd-mm-yyyy" 
* end_date : "dd-mm-yyyy"
* food : "ALL,MEAT,FRUITS,VEGETABLES"

return value is a data.frame with the requested info

### ToDo
* have to check
* dates from html files
* incorporate more correctness tests (date from xls file, date from link, date from file name should match)
* retain all data of xls-pdf files.
* translate to english
* include price from fish market
* include prices from Thessaloniki food market

 ## Discusion
 ![lamb price evolution](https://github.com/GrigorisLionis/laxanagora/blob/main/output/res.jpeg?raw=true) 
 The evolution of the meat prices over time  is extremely interesting. While the volatile nature of this commodity is apparent ( relatively "thin" market and seasonal), a significant price increase is also apparent. 
 More analysis of the subcategories of the commodities would be usefull.  A sharp increase of the prices over the last three years is also apparnet 
