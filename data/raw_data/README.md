# Raw data
Sylvain Schmitt -
Sep 18, 2025

This folder will contains the raw data for all anlayses. In particular:

- `gadm41_GUF_shp/` : GADM data from
  <https://gadm.org/download_country.html>
- `guyafor.tsv`: Guyafor data from
  <https://paracou.cirad.fr/website/experimental-design/guyafor-network>
- `JRC_TMF_UndisturbedDegradedForest_v1_1982_2024_SAM_ID49_N10_W60.tif`:
  TMF data from <https://forobs.jrc.ec.europa.eu/TMF/data>
- `fayad_2016/`: Biomass map of @fayad2016 from
  <https://entrepot.recherche.data.gouv.fr/dataset.xhtml?persistentId=doi:10.17180/forest-biomass-fr-guiana-map-2016>
- `matradica_soil/`: Soil maps from French Guiana from the METRADICA
  project, I. Maréchaux pers. com.
- `Paracou_species_troll.tsv`: Paracou species data from @schmitt2024
- `era/`: ERA5-Land data \[@muñoz-sabater2021\] downloaded from the
  google earth engine using a python script and mamba environment

``` r
fs::dir_tree()
```

    .
    ├── JRC_TMF_UndisturbedDegradedForest_v1_1982_2024_SAM_ID49_N10_W60.tif
    ├── Paracou_species_troll.tsv
    ├── README.md
    ├── README.qmd
    ├── README.rmarkdown
    ├── era
    │   ├── get_era_ee.py
    │   └── get_era_ee.yml
    ├── fayad_2016
    │   ├── AGB_16122015.tfw
    │   ├── AGB_16122015.tif
    │   ├── AGB_16122015.tif.aux.xml
    │   ├── AGB_16122015.tif.ovr
    │   └── MANIFEST.TXT
    ├── gadm41_GUF_shp
    │   ├── gadm41_GUF_0.cpg
    │   ├── gadm41_GUF_0.dbf
    │   ├── gadm41_GUF_0.prj
    │   ├── gadm41_GUF_0.shp
    │   ├── gadm41_GUF_0.shx
    │   ├── gadm41_GUF_1.cpg
    │   ├── gadm41_GUF_1.dbf
    │   ├── gadm41_GUF_1.prj
    │   ├── gadm41_GUF_1.shp
    │   ├── gadm41_GUF_1.shx
    │   ├── gadm41_GUF_2.cpg
    │   ├── gadm41_GUF_2.dbf
    │   ├── gadm41_GUF_2.prj
    │   ├── gadm41_GUF_2.shp
    │   └── gadm41_GUF_2.shx
    ├── guyafor.tsv
    └── metradica_soil
        ├── clay.tif
        ├── sand.tif
        └── silt.tif
