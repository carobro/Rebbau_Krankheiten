library(raster)
library(leaflet)
library(rgdal)
setwd("C:/Users/caro1/Documents/MobiGi/Rebbau_Krankheiten")
rm(list = ls())

data <- read.csv("KoboData.csv")

nied <- raster("niederschlag.tif")
prec <- raster("precipitation.tif")

infektion <- read.csv("infektion.csv")
names(infektion) <- c("X", "Infektion")

haegglingen <- readOGR("Haegglingen/Haegglingen.shp")

klus <- readOGR("Klus/Klus.shp")

data <- merge(data, infektion, by = "X")

points <- cbind(data$lon, data$lat)


pal_prec <-
  colorBin(
    c("green", "yellow", "orange", "red"),
    domain = values(prec),
    bins = 4,
    na.color = "transparent"
  )


pal_nied <- colorNumeric(c("white", "blue", "red"), values(nied),
                         na.color = "transparent")

pal_klus <-
  colorFactor(
    palette = c("red", "blue", "green"),
    na.color = "transparent",
    levels =
      levels(klus$Kommentar)
  )

pal_haeg <-
  colorFactor(
    palette = c("red", "blue", "green"),
    na.color = "transparent",
    levels =
      levels(haegglingen$kommenta_1)
  )


################################################################
library("jsonlite")
library(jpeg)
#1 Load all needed data
kobodata <-
  jsonlite::fromJSON(
    "https://caro_bro:VP1_2021@kf.kobotoolbox.org/api/v2/assets/a4TGhiJNRfASUqYXknMQnk/data/?format=json"
  )
head(kobodata)

pictures <- data.frame(kobodata$results$`group_dx9qs74/Foto_Blatt_krank`, kobodata$results$`group_dx9qs74/Foto_Blatt_krank_unten`, kobodata$results$`group_befallsstaerke/Foto_Rebe`, kobodata$results$`group_befallsstaerke/Foto_Blatt_krank`)

attach <- kobodata$results$`_attachments`

pic1 <- array(1:length(attach))
pic2 <- array(1:length(attach))
pic3 <- array(1:length(attach))
for (i in 1:length(attach)){
  temp <- attach[[i]]$download_small_url
  print(temp)
  temp[is.na(temp)] <- 0
  pic1[i] <- temp[1]
  pic2[i] <- temp[2]
  pic3[i] <- temp[3]
}
#################################


m <- leaflet() %>%
  addTiles(group = "Open Street Map") %>% 
  # Add default OpenStreetMap map tiles
  setView(lng = 8.3093072, lat = 47.0501682,  zoom = 7) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addLayersControl(
    baseGroups = c("Esri.WorldImagery","Open Street Map"),
    overlayGroups = c("Infektionswahrscheinlichkeit", "Niederschlag (10 min)", "Messstandort", "Parzellen"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  addRasterImage(
    prec,
    colors = pal_prec,
    opacity = 0.5,
    project = FALSE,
    group = "Infektionswahrscheinlichkeit"
  ) %>%
  addLegend(
    color = c("green", "yellow", "orange", "red"),
    labels = c("gering", "mittel", "hoch", "sehr hoch"),
    title = "Infektionswahrscheinlichkeit <br> (Niederschlag letzte 7 Tage)",
    group = "Infektionswahrscheinlichkeit"
  ) %>%
  addRasterImage(
    nied,
    colors = pal_nied,
    opacity = 0.5,
    project = FALSE,
    group = "Niederschlag (10 min)"
  ) %>%
  addLegend(
    pal = pal_nied,
    values = values(nied),
    title = "Niederschlag in mm  <br> (letzte 10 min.)",
    group = "Niederschlag (10 min)"
  ) %>%
  addPolygons(
    data = klus,
    color = "black",
    weight = 2,
    opacity = 1.0,
    fillOpacity = 0.8,
    fillColor = ~ pal_klus(klus$Kommentar),
    highlightOptions = highlightOptions(
      color = "white",
      weight = 2,
      bringToFront = TRUE
    ),
    popup = paste0("<br>", klus$Weintyp, "<br>", klus$PolyID),
    group = "Parzellen"
  ) %>%
  addPolygons(
    data = haegglingen,
    color = "black",
    weight = 2,
    opacity = 1.0,
    fillOpacity = 0.8,
    fillColor = ~ pal_haeg(haegglingen$kommenta_1),
    highlightOptions = highlightOptions(
      color = "white",
      weight = 2,
      bringToFront = TRUE
    ),
    popup = paste0("<br>", "<strong> Strategiename: </strong>", haegglingen$kommenta_1, "<br>", 
                   "<strong> Parzellen ID: </strong>", haegglingen$PolyID),
    group = "Parzellen"
  ) %>%
  addMarkers(
    data = points,
    popup = paste0(
      "<strong> Weintyp: </strong>",
      data$weintyp,
      "<br><strong> Datum: </strong>",
      data$newdate,
      "<br><strong> Betrieb & Parzelle: </strong>",
      data$betrieb,
      ", ",
      data$parzelle,
      "<br><strong> Infektionsgefahr: </strong>",
      data$infektionsGefahr,
      "<br><strong> Kommentar: </strong>",
      data$kommentar,
      "<br><img src = ", pic1, ">"
    ),
    clusterOptions = markerClusterOptions(showCoverageOnHover = FALSE),
    group = "Messstandort"
  )%>%
  addEasyButton(easyButton(
    icon = "fa-crosshairs",
    title = "Zeige meinen Standort",
    onClick = JS("function(btn, map){ map.locate({setView: true}); }")
  ))%>%
htmlwidgets::onRender("
    function(el, x) {
      this.on('baselayerchange', function(e) {
        e.layer.bringToBack();
      })
    }
  ")
m %>% hideGroup("Niederschlag (10 min)")

