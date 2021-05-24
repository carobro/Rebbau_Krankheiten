# install.packages("leaflet")
library(leaflet)
library(raster)
install.packages("rlang")

setwd("C:/Users/caro1/Documents/MobiGi/Rebbau_Krankheiten")
data <- read.csv("KoboData.csv")
points <- cbind(data$lon, data$lat)

raster <- raster('niederschlag.tif')

pal <- colorNumeric(c("white", "blue", "red"), values(raster),
                    na.color = "transparent")


crs <-  "L.CRS.EPSG2056"
format <- "jpeg"
layer <- "ch.swisstopo.swissimage"
swiss <-
  "//{s}.geo.admin.ch/1.0.0/ch.swisstopo.swissimage/default/current/2056/{z}/{x}/{y}.jpeg"

m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  setView(lng = 8.3093072, lat = 47.0501682,  zoom = 7) %>%
  addProviderTiles(providers$CartoDB.Positron, group = "Basemap") %>%
  addProviderTiles("Esri.WorldImagery", group = "Satellite") %>%
  addRasterImage(
    raster,
    colors = pal,
    opacity = 0.5,
    project = FALSE,
    group = "raster"
  ) %>%
  addLegend(pal = pal,
            values = values(raster),
            title = "Niederschlag in mm") %>%
  addLayersControl(
    baseGroups = c("OpenStreetMap", "ESRI", "Basemap"),
    overlayGroups = "raster"
  ) %>%
  addMarkers(
    data = points,
    popup = paste0(
      "<strong> Kranheit: </strong>",
      data$krankheit,
      "<br><strong> Foto: </strong>",
      data$foto_rebe,
      "<br><strong> Weintyp: </strong>",
      data$weintyp,
      "<br><strong> Datum: </strong>",
      data$newdate,
      "<br><strong> Blattbefall: </strong>",
      data$befallBlatt,
      "<br><strong> Befallmenge: </strong>",
      data$befallmenge,
      "<br><strong> Betrieb & Parzelle: </strong>",
      data$betrieb,
      ", ",
      data$parzelle,
      "<br><strong> BefallProzent: </strong>",
      data$befall_prozent
    ),
    clusterOptions = markerClusterOptions()
  ) %>%
  addEasyButton(easyButton(
    icon = "fa-crosshairs",
    title = "Locate Me",
    onClick = JS("function(btn, map){ map.locate({setView: true}); }")
  ))

m  # Print the map
