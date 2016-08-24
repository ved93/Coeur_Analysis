library("tmap")
library("leaflet")



# Read in the shapefile for US states :
usshapefile_zip<- "E:/Projects/Coeur/Map_tutorial/data/cb_2015_us_zcta510_500k/cb_2015_us_zcta510_500k.shp"


us_zip <- read_shape(file=usshapefile_zip)

# Do a quick plot of the shapefile and check its structure:
qtm(us_zip)
# (pause to wait for map to render, may take a few seconds)

str(us_zip)
str(us_zip@data)

df <- us_zip@data

# Subset just the NH data from the US shapefile
nhgeo <- us_zip[us_zip@data$ZCTA5CE10 %in% Count_by_zip$Updated_zip_code,]

# tmap test plot of the New Hampshire data
qtm(nhgeo)

# structure of the data slot within nhgeo
str(nhgeo@data)

df <- nhgeo@data




# Check if county names are in the same format in both files
str(nhgeo@data$ZCTA5CE10)
str(Count_by_zip$Updated_zip_code)

# They're not. Change the county names to plain characters in nhgeo:
nhgeo@data$ZCTA5CE10 <- as.character(nhgeo@data$ZCTA5CE10)


zipInfo<-Count_by_zip[Count_by_zip$Updated_zip_code %in% nhgeo$ZCTA5CE10,] 

# Order each data set by county name
nhgeo <- nhgeo[order(nhgeo@data$ZCTA5CE10),]
zipInfo <- zipInfo[order(zipInfo$Updated_zip_code),]

# Are the two county columns identical now? They should be:
identical(nhgeo@data$ZCTA5CE10,zipInfo$Updated_zip_code )

# Merge data with tmap's append_data function
nhmap <- append_data(nhgeo, zipInfo, key.shp = "ZCTA5CE10", key.data="Updated_zip_code")

# See the new data structure with
str(nhmap@data)

# Quick and easy maps as static images with tmap's qtm() function:
qtm(nhmap, "count")
qtm(nhmap, "SandersMarginPctgPoints")



# For more control over look and feel, use the tm_shape() function:
nhstaticmap<-tm_shape(nhmap) +
  tm_fill("count", title="Customer Count", palette = "PRGn") +
  tm_borders(alpha=.5) +
  tm_text("Updated_zip_code", size=0.8) + 
  tm_style_classic()



# Create a palette
clintonPalette <- colorNumeric(palette = "Blues", domain=nhmap$count)

# and a pop-up window
library(scales)
nhpopup <- paste0("<b>Zipcode: ", nhmap@data$ZCTA5CE10, "</b><br />count ", (nhmap@data$count))

# Now the interactive map:
leaflet(nhmap) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(stroke=FALSE, 
              smoothFactor = 0.2, 
              fillOpacity = .8, 
              popup=nhpopup, 
              color= ~clintonPalette(nhmap@data$count)
  )%>% setView(-122.36075812146, 47.6759920119894, zoom = 2)





