# set directory
getwd()

setwd("E:/Projects/Coeur")



library(xlsx)


Population_Rank<-read.xlsx("E:/Projects/Coeur/RawData/CoeurCustomersforDataAnalysis.xlsx" , sheetIndex = 1)


Population_Rank <- Population_Rank[ ,c(1,2,3,4,5,6)]


Domestic_Customers_Sponsored <-read.xlsx("E:/Projects/Coeur/RawData/CoeurCustomersforDataAnalysis.xlsx" , sheetIndex = 2)





Retail_Shops <-read.xlsx("E:/Projects/Coeur/RawData/CoeurCustomersforDataAnalysis.xlsx" , sheetIndex = 3)



##############****************EDA*********************

str(Domestic_Customers_Sponsored)


##only customer data

Customer_data<-Domestic_Customers_Sponsored[is.na(Domestic_Customers_Sponsored$Ambassador) & is.na(Domestic_Customers_Sponsored$Professional) , ]


##zip code cleaning

Domestic_Customers_Sponsored$Updated_zip_code <- Domestic_Customers_Sponsored$Zip.Code

Domestic_Customers_Sponsored$Updated_zip_code<- gsub("[']" , "" , Domestic_Customers_Sponsored$Updated_zip_code) 

Domestic_Customers_Sponsored$Updated_zip_code<-gsub(".*-","0",Domestic_Customers_Sponsored$Updated_zip_code)


length(unique(Domestic_Customers_Sponsored$Updated_zip_code))


length(unique(Domestic_Customers_Sponsored$Address1))




###

library(sqldf)

Count_by_zip <- sqldf("select Updated_zip_code, count(*) as count  from Domestic_Customers_Sponsored group by Updated_zip_code")

library(RgoogleMaps)
library(ggplot2)
library(ggmap)



##only customer data

Customer_data<-Domestic_Customers_Sponsored[is.na(Domestic_Customers_Sponsored$Ambassador) & is.na(Domestic_Customers_Sponsored$Professional) , ]


table(Domestic_Customers_Sponsored$Ambassador)


table(Domestic_Customers_Sponsored$Professional)


Count_by_zip <- sqldf("select Updated_zip_code, count(*) as count  from Customer_data group by Updated_zip_code")


quantile(Count_by_zip$count)

fm<-Count_by_zip

fm$Range<-ifelse(fm$count > 0 & fm$count<= 3, "1-3",
                 ifelse(fm$count > 3 & fm$count<= 6, "3-6",
                        ifelse(fm$count > 6 & fm$count<=9, "6-9", "9-13")))

table(fm$Range)

 

library(zipcode)
data(zipcode)
Count_by_zip$Updated_zip_code<- clean.zipcodes(Count_by_zip$Updated_zip_code)
fm<- merge(Count_by_zip, zipcode, by.x='Updated_zip_code', by.y='zip')

FM<- fm[1:20,]

map<-get_map(location='united states', zoom=5, maptype='roadmap')

#map

ggmap(map)

ggmap(map) + geom_point(aes(x=longitude, y=latitude, colour = (Range)  ), data=fm, alpha=.4 )   


table(fm$Range) 






devtools::install_github("hrbrmstr/localgeo")

library(localgeo)

geocode("Chicago")

t<-geocode(Count_by_State$State)

State_data<-cbind(Count_by_State , t)


ggmap(map) + geom_point(aes(x=lon, y=lat, size = (count)  ), data=State_data, alpha=.4 )   


t<-geocode()





library(sqldf)


Count_by_city <- sqldf("select City, count(*) as count  from Customer_data group by City")

write.csv(Count_by_city, "Count_by_city.csv" , row.names = F)


#####cities 




str(Count_by_city)

Count_by_city$City<- as.character(Count_by_city$City)

#geocode("Chicago")

t1<-geocode(Count_by_city$City)

City_data<-cbind(Count_by_city , t1)


ggmap(map) + geom_point(aes(x=lon, y=lat, size = (count)  ), data=City_data, alpha=.4 )   
