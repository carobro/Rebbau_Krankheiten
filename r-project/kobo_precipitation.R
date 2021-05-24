library(raster)
library(leaflet)
detach("package:tidyr")

setwd("C:/Users/caro1/Documents/MobiGi/Rebbau_Krankheiten")
rm(list = ls())
data <- read.csv("KoboData.csv")
points <- cbind(data$lon, data$lat)

raster <- raster('precipitation.tif')

extraction <- extract(raster, points, method='simple')
extraction <- round(extraction, digits = 0)

data$infektionsGefahr <- extraction

pal <-
  colorBin(
    c("green", "yellow", "orange", "red"),
    domain = values(raster),
    bins = 4,
    na.color = "transparent"
  )

m <- leaflet() %>%
  addTiles(group = "OSM(default)") %>%  # Add default OpenStreetMap map tiles
  setView(lng = 8.3093072, lat = 47.0501682,  zoom = 7) %>%
  addProviderTiles("OpenStreetMap.Mapnik", options = providerTileOptions(noWrap =
                                                                           TRUE)) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addRasterImage(raster,
                 colors = pal,
                 opacity = 0.5,
                 project = FALSE) %>%
  addLegend(
    color = c("green", "yellow", "orange", "red"),
    labels = c("gering", "mittel", "hoch", "sehr hoch"),
    title = "Niederschlagtage <br> (letzte 7 Tage)"
  ) %>%
  addLayersControl(baseGroups = c("OSM(default)", "ESRI", "OpenStreetMap.Mapnik")) %>%
  addMarkers(
    data = points,
    popup = paste0(
      "<strong> Weintyp: </strong>",
      data$weintyp,
      "<br><strong> Datum: </strong>",
      data$newdate,
      "<br><strong> Betrieb & Parzelle: </strong>",
      data$betrieb, ", ",
      data$parzelle,
      "<br><strong> Infektionsgefahr: </strong>",
      data$infektionsGefahr
    ),
    clusterOptions = markerClusterOptions()
  )

m  # Print the map


write.csv(data$infektionsGefahr, "infektion.csv")
