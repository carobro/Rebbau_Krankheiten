library(rgdal)
library(leaflet)
library(sp)
library(dplyr)
library(gt)
setwd("C:/Users/caro1/Documents/MobiGi/Rebbau_Krankheiten")
rm(list=ls())
layer <- readOGR("C:/Users/caro1/Downloads/Haegglingen/Gebiet_Haegglingen.shp")
layer$PolyID <- c(1:length(layer$id))

coords <- coordinates(layer)
layer$lat <- as.numeric(coords[,2])
layer$lng <- as.numeric(coords[,1])
projection(layer)="+init=epsg:4326"
# spTransform(layer, "+init=epsg:4326")

data <- read.csv("KoboData_Parzelle.csv")
#kobo <- data[c(17,16, 2,3,4,7,12,13,14, 15)]
kobo <- data[c(17,16, 13, 1)]
coordinates(kobo) <- ~ lon + lat
proj4string(kobo) <- proj4string(layer)


base <- data[c(17,16, 13, 1)]
inarea <- over(layer,kobo, returnList = FALSE)
inarea$PolyID <- c(1:length(inarea$X))

# area <- merge(x= inarea, y=base, by="X", all.x=FALSE)
# test <- inarea %>% left_join(base, by="kommentar")
#inarea$polyID <- c(1:length(inarea$id))
#area <-na.omit(inarea) 
points <- cbind(kobo$lon, kobo$lat)


test <- merge(x=layer, y=inarea, by="PolyID", all.x=FALSE)

pal <- colorFactor(palette = c("red", "blue", "green"), na.color = "transparent", levels =
                     levels(test$kommentar))

leaflet() %>%
  addTiles(group = "OSM(default)") %>%  # Add default OpenStreetMap map tiles
  setView(lng = 8.25016, lat = 47.392155,  zoom = 15) %>%
  addProviderTiles("OpenStreetMap.Mapnik", options = providerTileOptions(noWrap =
                                                                           TRUE)) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addProviderTiles("OpenStreetMap.Mapnik", options = providerTileOptions(noWrap =
                                                                           TRUE)) %>%
  addPolygons(
    data = test,
    color = "black",
    weight = 2,
    opacity = 1.0,
    fillOpacity = 0.8,
    fillColor = ~ pal(test$kommentar),
    highlightOptions = highlightOptions(
      color = "white",
      weight = 2,
      bringToFront = TRUE
    ),
    popup = paste0("<br>", test$kommentar, "<br>", inarea$PolyID),
    group = "Parzellen"
  ) %>%
  addMarkers(data = points,
             popup = kobo$kommentar,
             group = "Marker") %>%
  addLayersControl(
    baseGroups = c("OSM(default)", "ESRI", "OpenStreetMap.Mapnik"),
    overlayGroups = c("Marker", "Parzellen")
  )


#m  # Print the map

writeOGR(obj=test, dsn="Haegglingen", layer="Haegglingen", driver = "ESRI Shapefile")
