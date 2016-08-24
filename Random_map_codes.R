library(maptools)
library(RColorBrewer)
library(classInt)


colors <- brewer.pal(9, "YlOrRd") #set breaks for the 9 colors 
brks<-classIntervals(zip$INCOME, n=9, style="quantile")
brks<- brks$brks #plot the map
plot(zip, col=colors[findInterval(zip$INCOME, brks,all.inside=TRUE)], axes=F)

#add a title
title(paste ("SF Bay Area Median Household Income"))

#add a legend
legend(x=6298809, y=2350000, legend=leglabs(round(brks)), fill=colors, bty="n",x.intersp = .5, y.intersp = .5)





####################################################


library(ggplot2)
library(maps)

Prison <- read.csv("http://www.oberlin.edu/faculty/cdesante/assets/downloads/prison.csv")
head(Prison)

all_states <- map_data("state")
all_states
head(all_states)
Prison$region <- Prison$stateName

all_states$order <- NULL 

Total <- merge(all_states, Count_by_State, by.x="region", by.y = "State")


Total<- Total[!duplicated(Total, incomparables = F),]

Count_by_State$State <- tolower(Count_by_State$State)

df2<-sqldf("select a.*, b.long,b.lat from Count_by_State a join all_states b on a.State = b.region ")

head(Total)
Total <- Total[Total$region!="district of columbia",]



p <- ggplot()
p <- p + geom_polygon(data=Total, aes(x=long, y=lat, group = group, fill=Total$bwRatio),colour="white"
) + scale_fill_continuous(low = "thistle2", high = "darkred", guide="colorbar")
P1 <- p + theme_bw()  + labs(fill = "Black to White Incarceration Rates \n Weighted by Relative Population" 
                             ,title = "State Incarceration Rates by Race, 2010", x="", y="")
P1 + scale_y_continuous(breaks=c()) + scale_x_continuous(breaks=c()) + theme(panel.border =  element_blank())


g = ggplot(data=fm) + geom_point(aes(x=longitude, y=latitude, size=factor(count) ))

g
# simplify display and limit to the "lower 48"
g = g + theme_bw() + scale_x_continuous(limits = c(-125,-66), breaks = NULL)

g
g = g + scale_y_continuous(limits = c(25,50), breaks = NULL)

g

# don't need axis labels
g = g + labs(x=NULL, y=NULL)

g
