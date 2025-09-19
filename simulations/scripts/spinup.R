# snakemake log
log_file <- file(snakemake@log[[1]], open = "wt")
sink(log_file, append = TRUE, type = "message")
sink(log_file, append = TRUE)

# snakemake vars
climate_file <- snakemake@input[[1]]
correspondence_file <- snakemake@input[[2]]
species_file <- snakemake@input[[3]]
soil_file <- snakemake@input[[4]]
folderout <- snakemake@output[[1]]
x_pos <- as.numeric(snakemake@params$x)
y_pos <- as.numeric(snakemake@params$y)
cra <- as.numeric(snakemake@params$cra)
crb <- as.numeric(snakemake@params$crb)
m <- as.numeric(snakemake@params$m)
a0 <- as.numeric(snakemake@params$a0)
b0 <- as.numeric(snakemake@params$b0)
delta <- as.numeric(snakemake@params$delta)
test <- snakemake@params$test

# test
# climate_file <- "simulations/data/era.tsv"
# correspondence_file <- "simulations/data/correspondence_era.tsv"
# species_file <- "simulations/data/species.tsv"
# soil_file <- "simulations/data/soil.tsv"
# folderout <- "results/spinup/sim_-52.95_4.05_R1"
# x_pos <- -52.95
# y_pos <- 4.05
# cra <- 1.80
# crb <- 0.3860
# m <- 0.035
# a0 <- 0.2
# b0 <- 0.015
# delta <- 0.1
# test <- TRUE

# libraries
library(tidyverse)
library(rcontroll)

# code
name <- tail(str_split_1(folderout, "/"), 1)

coords_era <- read_tsv(correspondence_file) %>% 
  filter(X == x_pos, Y == y_pos)

climate_raw <- read_tsv(climate_file) %>% 
  filter(near(lon, coords_era$lon)) %>% 
  filter(near(lat, coords_era$lat)) %>% 
  filter(year(time) %in% 1980:2024) %>% 
  arrange(time) %>% 
  select(-lon, -lat)

climate_ds <- tibble(time = seq(min(climate_raw$time),
                                max(climate_raw$time),
                                by = 60 * 60 * 0.5)) %>%
  left_join(climate_raw) %>%
  group_by(day = as_date(time)) %>%
  mutate(across(
    c(tas, vpd, ws),
    ~ zoo::na.spline(., time, na.rm = FALSE)
  )) %>%
  mutate(across(
    c(snet),
    ~ zoo::na.approx(., time, na.rm = FALSE)
  )) %>%
  ungroup() %>%
  select(-day) %>%
  mutate(across(c(snet), ~ ifelse(is.na(.), 0, .))) %>%
  mutate(across(c(snet), ~ ifelse(. < 0, 0, .))) %>% 
  filter(paste0(month(time), "-", day(time)) != "2-29") %>% 
  mutate(snet = ifelse(snet <= 1.1, 1.1, snet)) %>%
  mutate(vpd = ifelse(vpd <= 0.011, 0.011, vpd)) %>%
  mutate(ws = ifelse(ws <= 0.11, 0.11, ws))

sampled_years <- c(sample(1980:2024, 555, replace = TRUE),
                   1980:2024)

year_df <- tibble(orig_year = sampled_years) %>% 
  mutate(sim_year = (max(sampled_years)-600+1):max(sampled_years))

spinup <- year_df %>% 
  left_join(mutate(climate_ds, orig_year = year(time)),
            relationship = "many-to-many",
            by = join_by(orig_year)) %>% 
  mutate(months_diff = (sim_year - orig_year)*12) %>% 
  mutate(time = time %m+% months(months_diff)) %>% 
  select(-months_diff)

clim <- spinup %>%
  rename(date = time) %>% 
  mutate(time = hour(date)) %>%
  mutate(date = date(date)) %>%
  select(date, time, tas, pr) %>%
  mutate(tas = ifelse(time < 6, NA, tas)) %>%
  mutate(tas = ifelse(time >= 18, NA, tas)) %>%
  group_by(date) %>%
  summarise(
    NightTemperature = mean(tas, na.rm = TRUE),
    Rainfall = sum(pr, na.rm = TRUE)
  ) %>%
  select(-date)

ndays <- length(unique(date(spinup$time)))
day <- spinup %>%
  rename(Temp = tas, Snet = snet, VPD = vpd, WS = ws) %>%
  mutate(time_hour = hour(time)) %>%
  filter(time_hour >= 6, time_hour < 18) %>%
  select(-time_hour) %>%
  mutate(time_numeric = hour(time) + minute(time) / 60) %>%
  mutate(DayJulian = rep(1:ndays, each = 24)) %>%
  select(DayJulian, time_numeric, Temp, Snet, VPD, WS)

n <- as.numeric(nrow(clim))
if(test)
  n <- 10

parameters <- generate_parameters(nbiter = n,
                                  klight = 0.5,
                                  phi = 0.10625,
                                  absorptance_leaves = 0.83,
                                  sigma_height = 0.19,
                                  sigma_CR = 0.29,
                                  sigma_CD = 0.0,
                                  sigma_P = 0.24,
                                  sigma_N = 0.12,
                                  sigma_LMA = 0.24,
                                  sigma_wsg = 0.06,
                                  sigma_dbhmax = 0.05,
                                  corr_CR_height = 0.0,
                                  corr_N_P = 0.65,
                                  corr_N_LMA = -0.43,
                                  corr_P_LMA = -0.39,
                                  Cair = 375,
                                  LL_parameterization = 0,
                                  pheno_a0 = a0,
                                  pheno_b0 = b0,
                                  pheno_delta = delta,
                                  CR_a = cra,                                    
                                  CR_b = crb,
                                  m = m,
                                  m1 = m,
                                  WATER_RETENTION_CURVE = 0)

seed <- sample.int(.Machine$integer.max, 1)
parameters <- mutate(parameters, value = ifelse(param == "Rseed", seed, value))

species <- read_tsv(species_file)

soil <- read_tsv(soil_file) %>% 
  filter(x == x_pos, y == y_pos) %>% 
  select(-x, -y)

sim <- troll(
  name = name,
  path = gsub(name, "", folderout),
  global = parameters,
  species = species,
  climate = clim,
  daily = day,
  pedology = soil,
  load = FALSE,
  verbose = TRUE,
  overwrite = TRUE
)
