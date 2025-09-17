# Simulations
Sep 17, 2025

- [`singularity`](#singularity)
- [`snakemake`](#snakemake)
- [content](#content)

`snakemake` and `singularity` workflow to run all simulations

## `singularity`

The singularity image is used by the `snakemake` workflow. It contains
`TROLL 4.0`, corresponding `rcontroll` version and associated R
packages.

To build:

``` bash
sudo singularity build rcontroll.sif rcontroll.def
```

To use:

``` bash
singularity shell -e troll4.sif 
```

> `-e` to avoid conflict with local environment

## `snakemake`

Bla

``` bash
snakemake -np
```

## content

- `...`:

``` r
fs::dir_tree()
```

    .
    ├── README.md
    ├── README.qmd
    ├── README.rmarkdown
    ├── config.yml
    ├── job.sh
    ├── rcontroll.def
    ├── ressources.yaml
    ├── scripts
    │   └── spinup.R
    └── snakefile
