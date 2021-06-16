## DATEI WIRD NICHT VERWENDET
rm(list = ls())
setwd("C:/Users/caro1/Documents/MobiGi/Rebbau_Krankheiten")

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
library(leaflet)

pts <- data.frame(Latitude = 30, Longitude = 30, file = "thing")

file <- 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Rlogo.png/274px-Rlogo.png'

leaflet() %>%
  addTiles %>%
  addCircleMarkers(data = pts, lng =~Longitude, lat = ~Latitude,
                   popup = paste0("<img src = ", file, ">"))
