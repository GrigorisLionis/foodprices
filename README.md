# foodprices
Price data for the central furit market of Athens is released four times per week. The price data are released in xls and pdf files
Goal of this project is to parse the data and provied a easy to use data source.

## description
Main function is in file get_data.R. 
It reads the data pages, extracts the links,  composes a list of all the xls and pdf links for downloading,downloads the files, and parses to a data.frame. 

## usage

get_data(start_date,end_data,cache_path,use_cache,food)

* start_date : "dd-mm-yyyy" 
* end_date : "dd-mm-yyyy"
* food : "ALL,MEAT,FRUITS,VEGETABLES"
* use_caceh : TRUE|FALSE indicates whether to use a cache directory for reading/storing files
* cache_path : path to cache directory

return value is a data.frame with the requested info

### ToDo
* incorporate more correctness tests 
* retain all data of xls-pdf files.
* translate food elements to english. difficulty as food market specific terms are used, that are difficult to translate
* include price from fish market
* include prices from Thessaloniki food market

## Discusion
 ![lamb price evolution](https://github.com/GrigorisLionis/laxanagora/blob/main/output/res.jpeg?raw=true) 
  The graph depicts the evolution of some meat prices over time.
  From the complete data set, food elements that appear more steadily have been choosen.
  * Αρνιά -> Lamb 
  * Αρνιά Ρουμανίας -> imported lamb from Romania
  * Γιδοπρόβατα -> sheep&goat
  * Κατσίκια -> goat
  * Μοσχάρια εγχώρια -> greek beef
  * Μοσχάρια εξωτερικού -> imported beef
  * Χοιρινά εγχώρια -> greek pork (two graphs, with different cuts)
  * Χοιρινά εξωτερικού -> imported pork (two graphs, with different cuts)
  The data are depicted using a typical ggplot panel graph
### Analysis of the results     
The evolution of the meat prices over time  is extremely interesting. While the volatile nature of this commodity is apparent ( relatively "thin" market, speciallity meats not widely produced, seasonal), a significant price increase during the last years is also apparent. The dominant price seems to have increased over 40% during the last 2-3 years. Obviously, a  thourouhg analysis of the subcategories of the commodities would be usefull. The imported prices  seem to be  slightly lower than the domestic prices, but a causality analysis would be usefull to understand wheter the prices of the domestic produced follow the imported. Unfortunatelly, the market data do not contain quantities, to understand how the market is structued.  
