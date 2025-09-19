# download at https://figshare.com/ndownloader/articles/19336346/versions/2
files <- list.files("data/raw_data/sif/2020/", 
                    full.names = T, recursive = T, pattern = ".tif")
area <- tibble(lon = c(-53, -52), lat = c(4.0, 5.0)) %>% 
  st_as_sf(coords = c("lon", "lat"), crs = 4326) %>% 
  st_bbox() %>% 
  st_as_sfc()
rast(files) %>% 
  crop(area) %>%
  as.data.frame(xy = TRUE) %>% 
  gather(date, sif, -x, -y) %>% 
  mutate(date = gsub("RTSIF_", "", date)) %>% 
  mutate(date = as_date(date)) %>% 
  mutate(gpp = sif*15.343*365/10^3) %>% 
  write_tsv("data/raw_data/sif/sif.tsv")
