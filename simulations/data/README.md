# Simulations data
Sep 19, 2025

This folder contains the data needed to run the virtual experiment with
a snakemake workflow. They are produced in the analyses (specifically in
the input data chapter). In particular they include:

- `correspondence_era.tsv`: the correspondence table between the grid of
  our simulations and the grid of ERA5-Land
- `era.tsv`: ERA5-Land data
- `grid_era.tsv`: the grid of our simulations after removing cells
  without information in ERA5-Land
- `soil.tsv`: soil data from METRADICA prepared for TROLL 4.0
- `species.tsv`: species data prepared for TROLL 4.0

``` r
fs::dir_tree()
```

    .
    ├── README.md
    ├── README.qmd
    ├── README.rmarkdown
    ├── correspondence_era.tsv
    ├── era.tsv
    ├── grid_era.tsv
    ├── soil.tsv
    └── species.tsv
