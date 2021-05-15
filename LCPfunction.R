calc.conductance <- function(raster, filename=NULL){
  # get library
  library(gdistance)
  
  # calculate difference in elevation
  heightDiff <- function(x){x[2] - x[1]}
  
  # the difference is non-symetrical (going up is harder than going down)
  hd <- transition(raster,heightDiff,8,symm=FALSE)
  hd
  # calculate slope
  slope <- geoCorrection(hd, type = "r", scl=FALSE)
  slope
  
  # calculate adjacent cells
  adj <- adjacent(r, cells=1:ncell(r), pairs=TRUE, directions=8)
  # create a speed raster with Hiking function in meters per hour (meters are what the grids come in)
  speed <- slope
  speed[adj] <- 6 * 1000*  exp(-3.5 * abs(slope[adj] + 0.05)) # meters per hour as all rasters are in m units
  
  # Rectify the raster values on the basis of cell center distances
  conductance <- geoCorrection(speed, type="r", scl = FALSE)
  
  # Print result to pdf
  ifelse(!dir.exists(file.path(".", "outputs")), dir.create(file.path(".", "outputs")), FALSE)
  
  if(is.null(filename)){
    pdf(paste0("outputs/",names(srtm),"conductance.pdf"))
    plot(raster(conductance), main = paste0("Conductivity of", names(srtm), "surface in hours"))
    dev.off()} else {
      pdf(paste0("outputs/",filename,"conductance.pdf"))
      plot(raster(conductance), main = paste0("Conductivity of", filename, "surface in hours"))
      dev.off()
    }
  
  #Save the result
  ifelse(!dir.exists(file.path(".", "output_data")), dir.create(file.path(".", "output_data")), FALSE)
  if(is.null(filename)){
  saveRDS(conductance, paste0("output_data/",names(srtm),"conductance.rds"))
  }else{
    saveRDS(conductance, paste0("output_data/",filename,"conductance.rds"))
  }
}


x = c(-2, 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 40)
y = c(36, 38, 40, 42, 44) # first batch

for(i in x){
  for(e in y){
    #Download a tile
    cat("Longitude",i, "and Latitude",e)
    srtm <- getData('SRTM', lon = i, lat=e) 
    ## Aggregate just to test the behavior
    srtm <- aggregate(srtm, fact = 10)
    ## Reclassify subzero values
    rcl <- cbind(-9999, 1, NA)
    r <- reclassify(srtm, rcl = rcl)
    ## Save the raster for future record ?
    # saveRDS(r, paste0("output_data/",names(r),".rds"))
    calc.conductance(r)
  }
  
}


plot(raster(readRDS("output_data/srtm_45_05conductance.rds"))) 

pop=5000
travelcost.totown(cities, 5000)
travelcost.totown <- function(cities, pop){
  library(sf)
  library(gdistance)
  local_citiesXk <- cities %>% 
    filter(pop_est > pop) %>% 
    st_as_sf(coords = c("Longitude (X)", "Latitude (Y)"), 
             crs = 4326) %>%
    st_transform(crs = crs(r)) %>% 
    st_crop(r) 
  cost <- accCost(conductance, fromCoords = as(local_citiesXk, "Spatial"))
  plot(y, main = paste0("cost of travel in hours in ",names(srtm)," between towns of population >",pop)); contour(y, add =TRUE) # should be in hours?
  ifelse(!dir.exists(file.path(".", "output_data")), dir.create(file.path(".", "output_data")), FALSE)
  saveRDS(cost, paste0("output_data/",names(srtm),"costtotown",pop,".rds"))
}

# Check the cities came through well
plot(raster(conductance)); plot(local_cities5k$geometry, add = TRUE)

crs(conductance)
