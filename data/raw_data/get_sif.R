# download at https://figshare.com/ndownloader/articles/19336346/versions/2
folder <- "~/Téléchargements/19336346/"
files <- list.files(folder, full.names = T, recursive = T, pattern = ".tif")
area <- tibble(lon = c(-53, -52), lat = c(4.0, 5.0)) %>% 
  st_as_sf(coords = c("lon", "lat"), crs = 4326) %>% 
  st_bbox() %>% 
  st_as_sfc()
sif <- rast(files) %>% 
  crop(area)
