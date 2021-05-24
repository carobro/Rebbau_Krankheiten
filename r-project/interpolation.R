setwd("C:/Users/caro1/Documents/MobiGi/Rebbau_Krankheiten")
rm(list=ls())

kobo <- read.csv("KoboData.csv")
border <- readOGR(dsn = "shapefile/swissBOUNDARIES3D_1_3_TLM_LANDESGEBIET.shp", stringsAsFactors = F)
points <- cbind(kobo$lon, kobo$lat)



P2 <- kobo
coordinates(P2) <- ~lon+lat
P2$befallBlatt[is.na(P2$befallBlatt)] <- 0
crs(P2) <- "+init=epsg:4326"

W <- spTransform(border, "+init=epsg:4326")

# Replace point boundary extent with that of Texas
P2@bbox <-W@bbox
#P2$befallBlatt

tm_shape(W) + tm_polygons() +
  tm_shape(P2) +
  tm_dots(col= "befallBlatt", palette = "RdBu", auto.palette.mapping = FALSE,title="Sampled precipitation \n(in inches)", size=0.5) +
  tm_legend(legend.outside=TRUE)

# Create an empty grid where n is the total number of cells
grd              <- as.data.frame(spsample(P2, "regular", n=50000), pch=0)
names(grd)       <- c("X", "Y")
coordinates(grd) <- c("X", "Y")
gridded(grd)     <- TRUE  # Create SpatialPixel object
fullgrid(grd)    <- TRUE  # Create SpatialGrid object

# Add P's projection information to the empty grid
proj4string(P2) <- proj4string(P2) # Temp fix until new proj env is adopted
proj4string(grd) <- proj4string(P2)

# Interpolate the grid cells using a power value of 2 (idp=2.0)
P2.idw <- gstat::idw(befallBlatt ~ 1, P2, newdata=grd, idp=2.0)

# Convert to raster object then clip to Switzerland
r       <- raster(P2.idw)
r.m     <- mask(r, W)

plot(r.m)

colors = c("white", "yellow", "orange","red")
# Plot
tm_shape(r.m) + 
  tm_raster(n=5,palette = colors, title="Predicted precipitation \n(in mm)",colorNA = "transparent")+tm_legend(legend.outside=TRUE)




# install.packages("leaflet")
library(leaflet)
library(raster)


writeRaster(r.m,'data.tif', overwrite=TRUE)

raster <- raster('data.tif')

pal <- colorNumeric(c("white","blue","red"), values(raster),
                    na.color = "transparent")

m <- leaflet() %>%
  addTiles(group="OSM(default)") %>%  # Add default OpenStreetMap map tiles
  setView(lng=8.3093072, lat= 47.0501682,  zoom = 7)%>%
  addProviderTiles("OpenStreetMap.Mapnik", options=providerTileOptions(noWrap=TRUE))%>%
  addProviderTiles("Esri.WorldImagery")%>%
  addRasterImage(raster, colors = pal, opacity = 0.5, project = FALSE) %>%
  addLegend(pal = pal, values = values(raster),
            title = "Befallsmenge") %>%
  addLayersControl(baseGroups = c("OSM(default)", "ESRI", "OpenStreetMap.Mapnik")) %>%
  addMarkers(data=points,
            popup = paste0("<strong> Kranheit: </strong>", kobo$krankheit,
                      "<br><strong> Foto: </strong>", kobo$foto_rebe,
                      "<br><strong> Weintyp: </strong>", kobo$weintyp,
                      "<br><strong> Datum: </strong>", kobo$newdate,
                      "<br><strong> Blattbefall: </strong>", kobo$befallBlatt,
                      "<br><strong> Befallmenge: </strong>", kobo$befallmenge,
                      "<br><strong> Betrieb & Parzelle: </strong>", kobo$betrieb, ", ", kobo$parzelle,
                      "<br><strong> BefallProzent: </strong>", kobo$befall_prozent),
                              clusterOptions = markerClusterOptions())

m  # Print the map



