cb_2015_us_state_5m

library("tmap")
library("leaflet")













# Read in the shapefile for US states :
usshapefile_zip<- "E:/Projects/Coeur/Map_tutorial/data/cb_2015_us_state_5m/cb_2015_us_state_5m.shp"

#usshapefile <- "E:/Projects/Coeur/Map_tutorial/data/cb_2014_us_county_5m/cb_2014_us_county_5m.shp"

us_zip <- read_shape(file=usshapefile_zip)

# Do a quick plot of the shapefile and check its structure:
qtm(us_zip)
# (pause to wait for map to render, may take a few seconds)

str(us_zip)

str(us_zip@data)

df <- us_zip@data



# Subset just the NH data from the US shapefile
nhgeo <- us_zip[us_zip@data$NAME %in% Count_by_State$State,]

# tmap test plot of the New Hampshire data
qtm(nhgeo)

# structure of the data slot within nhgeo
str(nhgeo@data)

df <- nhgeo@data




# Check if county names are in the same format in both files
str(nhgeo@data$NAME)
str(Count_by_State$State)

# They're not. Change the county names to plain characters in nhgeo:
nhgeo@data$NAME <- as.character(nhgeo@data$NAME)
Count_by_State$State<- as.character(Count_by_State$State)

zipInfo<-Count_by_State[Count_by_State$State %in% nhgeo$NAME,] 

# Order each data set by county name
nhgeo <- nhgeo[order(nhgeo@data$NAME),]
zipInfo <- zipInfo[order(zipInfo$State),]

# Are the two county columns identical now? They should be:
identical(nhgeo@data$ZCTA5CE10,zipInfo$Updated_zip_code )

# Merge data with tmap's append_data function
nhmap <- append_data(nhgeo, zipInfo, key.shp = "NAME", key.data="State")

# See the new data structure with
str(nhmap@data)

# Quick and easy maps as static images with tmap's qtm() function:
qtm(nhmap, "count")
qtm(nhmap, "SandersMarginPctgPoints")



# For more control over look and feel, use the tm_shape() function:
nhstaticmap <- tm_shape(nhmap) +
  tm_fill("count", title="Customer Count", palette = "PRGn") +
  tm_borders(alpha=.5) +
  tm_text("State", size=0.2) + 
  tm_style_classic()





# View the map
nhstaticmap

# save the map to a jpg file with tmap's save_tmap():
save_tmap(nhstaticmap, filename="nhdemprimary.jpg")

# Next up: Code for a basic interactive map, this time for Clinton percentages in NH

# Create a palette
clintonPalette <- colorNumeric(palette = "Blues", domain=nhmap$count)

# and a pop-up window
library(scales)
nhpopup <- paste0("<b>State: ", nhmap@data$State, "</b><br />count ", (nhmap@data$count))

# Now the interactive map:
leaflet(nhmap) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(stroke=FALSE, 
              smoothFactor = 0.2, 
              fillOpacity = .8, 
              popup=nhpopup, 
              color= ~clintonPalette(nhmap@data$count)
  )

