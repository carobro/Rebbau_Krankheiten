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
https://kc.kobotoolbox.org/media/medium?media_file=caro_bro%2Fattachments%2Fe53b4f668c93419f86921b7af6c54b14%2F39ae8d7c-b5f5-4556-9dfc-402b8598edc8%2F1620580545574.jpg
https://kc.kobotoolbox.org/media/original?media_file=caro_bro%2Fattachments%2Fe53b4f668c93419f86921b7af6c54b14%2F39ae8d7c-b5f5-4556-9dfc-402b8598edc8%2F1620580545574.jpg
https://kc.kobotoolbox.org/media/medium?media_file=caro_bro%2Fattachments%2Fe53b4f668c93419f86921b7af6c54b14%2Fa7124581-0c44-437c-b555-20b6dd715280%2F1620639585936.jpg
https://kc.kobotoolbox.org/media/original?media_file=caro_bro%2Fattachments%2Fe53b4f668c93419f86921b7af6c54b14%2F1cb490e8-e950-41d7-bcbe-db8f1f252aaa%2F1619863414166.jpg

library(leaflet)

pts <- data.frame(Latitude = 30, Longitude = 30, file = "thing")

file <- 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Rlogo.png/274px-Rlogo.png'

leaflet() %>%
  addTiles %>%
  addCircleMarkers(data = pts, lng =~Longitude, lat = ~Latitude,
                   popup = paste0("<img src = ", file, ">"))