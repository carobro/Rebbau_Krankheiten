## Kranheiten im Rebbau
# install.packages("jsonlite")

library("jsonlite")
# install.packages("gstat")
library(gstat) # Use gstat's idw routine
library(sp)    # Used for the spsample function
library(spatstat)  # Used for the dirichlet tessellation function
library(maptools)  # Used for conversion from SPDF to ppp
library(raster)  
library(rgdal)
# install.packages("e1071")
library(tmap)
# install.packages("tmap", lib = "C:\\Program Files\\R\\R-3.6.0\\library")

#1 Load all needed data
kobodata <- jsonlite::fromJSON("https://caro_bro:VP1_2021@kf.kobotoolbox.org/api/v2/assets/a4TGhiJNRfASUqYXknMQnk/data/?format=json")
head(kobodata)
names(kobodata$results)
kobo_loc <- kobodata$results$`_geolocation`

##  Namen üerarbeiten
data_copy <- kobodata$results[c(3,10,13,15, 18,19,26,27,28,29,30,32,33)]
names(data_copy)<- c("befallBlatt","krankheit","befallmenge","date", "befallTraube", 
        "weintyp","foto_oben", "foto_unten", "foto_rebe", "betieb","befall_prozent", "xx", "cc")
names(data_copy)
## Prozent befall mergen


length(kobo_loc)
index = 0
lat= array(1:length(kobo_loc))
lon= array(1:length(kobo_loc))
for (i in 1:length(kobo_loc)){
  lon[i] = kobo_loc[[i]][1]
  lat[i] = kobo_loc[[i]][2]
}
plot(lat, lon)
data_copy["lat"]<- lat
data_copy["lon"]<- lon

# -----------------------------------------------------------------------
temp_data <- read.csv('https://data.geo.admin.ch/ch.meteoschweiz.messwerte-lufttemperatur-10min/ch.meteoschweiz.messwerte-lufttemperatur-10min_de.csv', sep=";")
head(temp_data)
  
temp_data_temp <- temp_data[c(1,2,4,5,10,11,12)]
temperature <- temp_data_temp[-c(273,272,271),]
names(temperature) <- c("Station", "Abk", "Temperatur", "Datum", "lat", "lon", "Kanton")
  
# --------------------------------------------------------------------------
nieder_data <-   read.csv('https://data.geo.admin.ch/ch.meteoschweiz.messwerte-niederschlag-10min/ch.meteoschweiz.messwerte-niederschlag-10min_de.csv', sep=";")
tail(nieder_data)
length(nieder_data$Station)

nieder_data_temp <- nieder_data[c(1,2,4,5,10,11,12)]
niederschlag <- nieder_data_temp[-c(273,272,271),]
names(niederschlag) <- c("Station", "Abk", "Niederschlag", "Datum", "lat", "lon", "Kanton")

# --------------------------------------------------------------------------------
border <- readOGR(dsn = "C:/Users/caro1/Downloads/swissBOUNDARIES3D/BOUNDARIES_2021_04/DATEN/swissBOUNDARIES3D/SHAPEFILE_LV95_LN02/swissBOUNDARIES3D_1_3_TLM_LANDESGEBIET.shp", stringsAsFactors = F)
#temp <- tempfile()
#download.file("https://cms.geo.admin.ch/ogd/topography/swissBOUNDARIES3D.zip",temp)
# data <- read.table(unz(temp, "file2f50559d39aa.dat"))
# unlink(temp)
# ---------------------------------------------------------------------------------
P <- niederschlag
coordinates(P) <- ~lon+lat
P$Niederschlag[is.na(P$Niederschlag)] <- 0
crs(P) <- "+init=epsg:4326"
W <- spTransform(border, "+init=epsg:4326")

# Replace point boundary extent with that of Texas
P@bbox <-W@bbox

tm_shape(W) + tm_polygons() +
  tm_shape(P) +
  tm_dots(col= "Niederschlag", palette = "RdBu", auto.palette.mapping = FALSE,title="Sampled precipitation \n(in inches)", size=0.5) +
  tm_legend(legend.outside=TRUE)

# Create an empty grid where n is the total number of cells
grd              <- as.data.frame(spsample(P, "regular", n=50000))
names(grd)       <- c("X", "Y")
coordinates(grd) <- c("X", "Y")
gridded(grd)     <- TRUE  # Create SpatialPixel object
fullgrid(grd)    <- TRUE  # Create SpatialGrid object

# Add P's projection information to the empty grid
proj4string(P) <- proj4string(P) # Temp fix until new proj env is adopted
proj4string(grd) <- proj4string(P)

# Interpolate the grid cells using a power value of 2 (idp=2.0)
P.idw <- gstat::idw(P$Niederschlag ~ 1, P, newdata=grd, idp=2.0)

# Convert to raster object then clip to Switzerland
r       <- raster(P.idw)
r.m     <- mask(r, W)

plot(r.m)
# Plot
tm_shape(r.m) + 
  tm_raster(n=5,palette = "RdBu", auto.palette.mapping = FALSE,
            title="Predicted precipitation \n(in mm)")+tm_legend(legend.outside=TRUE)


writeRaster(r.m,'C:/Users/caro1/Documents/MobiGi/Rebbau_Krankheiten/niederschlag.tif', overwrite=TRUE)
