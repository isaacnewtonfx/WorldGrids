## Processing Equi7 system for the purpose of global soil mapping
## Equi7 (see Fig. 6 in http://www.sciencedirect.com/science/article/pii/S0098300414001629)

library(rgdal)
library(sp)
library(maptools)
#setwd("\\Equi7_Grid_V12_Public_Package\\Grids")
lst <- list.files(pattern="*_PROJ_ZONE.shp$", full.names = TRUE, recursive = TRUE)
equi7 <- list(NULL)
for(i in 1:length(lst)){
  equi7[[i]] <- readOGR(lst[i], layer=strsplit(basename(lst[i]),"\\.")[[1]][1])
}

for(i in 1:length(lst)){
  names(equi7)[i] <- strsplit(strsplit(basename(lst[i]), "\\.")[[1]][1], "_")[[1]][3]
}
save(equi7, file="equi7.rda", compress="xz") 

lst.ll <- list.files(pattern="*_GEOG_ZONE.shp$", full.names = TRUE, recursive = TRUE)
equi7.ll <- list(NULL)
for(i in 1:length(lst.ll)){
  equi7.ll[[i]] <- readOGR(lst.ll[i], layer=strsplit(basename(lst.ll[i]),"\\.")[[1]][1])
}

library(plotKML)
kml_open("equi7.kml")
for(i in 1:length(lst)){
  kml_layer(equi7.ll[[i]], subfolder.name=strsplit(basename(lst.ll[i]),"\\.")[[1]][1], colour=ZONE, colour_scale=rep("#FFFF00", 2), alpha=.4)
}
kml_close("equi7.kml")

## TILING SYSTEMS:
c.lst <- c("AF", "AN", "AS", "EU", "NA", "OC", "SA")
t.lst <- list.files(path="EQUI7_V13_GRIDS", pattern="*_PROJ_TILE_T3.shp$", full.names = TRUE, recursive = TRUE)
equi7t3 <- list(NULL)
for(i in 1:length(t.lst)){
  equi7t3[[i]] <- readOGR(t.lst[i], layer=strsplit(basename(t.lst[i]),"\\.")[[1]][1])
  ## subset to tiles with land:
  equi7t3[[i]] <- equi7t3[[i]][equi7t3[[i]]$COVERSLAND==1,]
}
## land polys:
land.lst <- list.files(path="EQUI7_V13_GRIDS", pattern="*_PROJ_LAND.shp$", full.names = TRUE, recursive = TRUE)
equi7land <- list(NULL)
for(i in 1:length(land.lst)){
  equi7land[[i]] <- readOGR(land.lst[i], layer=strsplit(basename(land.lst[i]),"\\.")[[1]][1])
}
plot(equi7land[[1]])
lines(as(equi7t3[[1]], "SpatialLines"))
names(equi7t3) <- c.lst <- c("AF", "AN", "AS", "EU", "NA", "OC", "SA")
names(equi7land) <- c.lst <- c("AF", "AN", "AS", "EU", "NA", "OC", "SA")
save(equi7land, file="equi7land.rda")
save(equi7t3, file="equi7t3.rda")

## write to Shapefiles:
for(i in 1:length(equi7t3)){
  writeOGR(equi7t3[[i]], paste0(names(equi7t3)[i], "_t3_tiles.shp"), paste0(names(equi7t3)[i], "_t3_tiles"), "ESRI Shapefile")
}
