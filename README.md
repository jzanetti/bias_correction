


## For developers:
The development working environment can be set up by:

- `Python`: run `conda env create -f env.yml` (given `conda` is installed)


- `R`: This R version of this package is under development, the following shows the steps for testing the package with R:
    - Start a new R env: Run `renv::init()` to initialize renv for your project
    - Record R env: `renv::snapshot()`
    - Reload R env: Run `renv::restore()` to load the renv environment for your project
    - Install R packages: `renv::install(c("x", "y", "z"))`
