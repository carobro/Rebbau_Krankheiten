library(tidyverse)
library(rvest)
library("jsonlite")
library(leaflet)
library(raster)

setwd("C:/Users/caro1/Documents/MobiGi/Rebbau_Krankheiten")

## load geometrie file from Agroscope
stations <- read.csv("agrometeo_stations.csv")
points <- cbind(stations$long_dec, stations$lat_dec)

## make list of stations ids for the url
ids <- paste(stations$id, collapse = ",")

## generate dynamicaly the url to retrieve the  data from Agroscopes website
url <-
  paste0(
    "https://www.agrometeo.ch/de/meteorologie/data?stations=",
    ids,
    "&sensors=6%3Asum&from=2021-04-29&to=2021-05-06&scale=day&groupBy=station"
  )

## since we cant download the data directly in a file format we retrieve the content of
## the website and save them into a table
df <- url %>%
  read_html() %>%
  html_nodes("table") %>%
  html_table(fill = T)

tables <- data.frame()

for (i in length(df)) {
  temp <- df[[i]]
  tables <- bind_rows(tables, temp)
}
tables <- tables[-c(1), ]

#part_one <- tables
#data <- cbind(part_one, tables)
write.csv(tables, "niederschlag_7_Tage.csv")


m <- leaflet() %>%
  addTiles(group = "OSM(default)") %>%  # Add default OpenStreetMap map tiles
  setView(lng = 8.3093072, lat = 47.0501682,  zoom = 7) %>%
  addProviderTiles("OpenStreetMap.Mapnik", options = providerTileOptions(noWrap =
                                                                           TRUE)) %>%
  addProviderTiles("Esri.WorldImagery") %>%
  #addRasterImage(raster, colors = pal, opacity = 0.5, project = FALSE) %>%
  #addLegend(pal = pal, values = values(raster),
  #          title = "Niederschlag in mm") %>%
  addLayersControl(baseGroups = c("OSM(default)", "ESRI", "OpenStreetMap.Mapnik")) %>%
  addMarkers(data = points,
             popup = paste0("<strong> Name: </strong>", stations$name))
m  # Print the map


nieder_sieben <- read.csv("niederschlag_7_Tage_x.csv")
nieder_temp <- subset (nieder_sieben, select = -c(1, 2))
nieder_temp <- nieder_temp[1:7, ]

station_name <- names(nieder_temp)
dauerregen <- data.frame(matrix(ncol = 186, nrow = 1))

index = 0
lauf = 1
for (j in 1:length(nieder_temp)) {
  # print("##")
  #  print(j)
  for (i in 1:7) {
    if (is.numeric(nieder_temp[i, j]) == TRUE) {
      print(index)
      if (as.numeric(nieder_temp[i, j]) > 0) {
        index = index + 1
      }
      else{
        index = 0
      }
    }
    else
      index = 0
  }
  dauerregen[1, j] = index
}

names(dauerregen) <- station_name
# y <- rownames(dauerregen)
x <- colnames(dauerregen)

transformed <- as.data.frame(t(dauerregen))

df <- data.frame(x, transformed$V1)
names(df) <- c("name", "values")

station_data <- merge(df, stations, by = "name")
names(station_data) <- c("name", "values", "x", "ID", "lat", "lon")

library(rgdal)
library(tmap)

P <- station_data
coordinates(P) <- ~ lon + lat
P$values[is.na(P$values)] <- 0
crs(P) <- "+init=epsg:4326"
border <-
  readOGR(dsn = "shapefile/swissBOUNDARIES3D_1_3_TLM_LANDESGEBIET.shp", stringsAsFactors = F)
W <- spTransform(border, "+init=epsg:4326")

# Replace point boundary extent with that of Texas
P@bbox <- W@bbox

tm_shape(W) + tm_polygons() +
  tm_shape(P) +
  tm_dots(
    col = "Niederschlag",
    palette = "RdBu",
    auto.palette.mapping = FALSE,
    title = "Sampled precipitation \n(in inches)",
    size = 0.5
  ) +
  tm_legend(legend.outside = TRUE)

# Create an empty grid where n is the total number of cells
grd              <- as.data.frame(spsample(P, "regular", n = 50000))
names(grd)       <- c("X", "Y")
coordinates(grd) <- c("X", "Y")
gridded(grd)     <- TRUE  # Create SpatialPixel object
fullgrid(grd)    <- TRUE  # Create SpatialGrid object

# Add P's projection information to the empty grid
proj4string(P) <-
  proj4string(P) # Temp fix until new proj env is adopted
proj4string(grd) <- proj4string(P)

# Interpolate the grid cells using a power value of 2 (idp=2.0)
P.idw <- gstat::idw(P$values ~ 1, P, newdata = grd, idp = 2.0)

# Convert to raster object then clip to Switzerland
r       <- raster(P.idw)
r.m     <- mask(r, W)

plot(r.m)
# Plot
tm_shape(r.m) +
  tm_raster(
    n = 5,
    palette = "RdBu",
    auto.palette.mapping = FALSE,
    title = "Predicted precipitation \n(in mm)"
  ) + tm_legend(legend.outside = TRUE)


writeRaster(r.m, 'precipitation.tif', overwrite = TRUE)
