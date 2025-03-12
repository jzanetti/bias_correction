# Simple Bias Correction

This repository contains APIs for bias correction, facilitating the development of models that reduce systematic errors in predictions and simulations relative to observations.

Both `R` and `Python` interfaces are provided.

## Install:

For `Python`, the package can be installed via `pip install simple_bc`

## Usage

### Python
After the installation, the bias correction can be run as:

```
from simple_bc import bc
data = {
    "obs": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    "fcst": [3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
}
bc.run_bc(data=data, create_plot=True, show_metrics=True, test_size=0.2, method="linear_regression", output_dir="test")
```

If the `data` argument is not provided, some random data will be created and the function will be run for a demostration purpose. The default values will be assigned to other arguments as well.
```
from simple_bc import bc
bc.run_bc()
```

## For developers:
The development working environment can be set up by:

### Python:

For a local working environment, run `conda env create -f env.yml` (given `conda` is installed)

If `Pypi` is needed, a source distribution (`.tar.gz`), and a wheel file (`.whl`) can be created in the directory `dist` using
```
python setup.py sdist bdist_wheel
```
The `whl` file then can be tested as below: `pip install dist/simple_bc-0.1.0-py3-none-any.whl`

After this, the package can be uploaded as: 
```
twine upload dist/*
```

### R:

Install the following packages:

- `devtools`: Install this package to simplify package creation:
    ```
    install.packages("devtools")
    library(devtools)
    ```

- `roxygen2`: For generating documentation:
    ```
    install.packages("roxygen2")
    library(roxygen2)
    ```


- Initialize a Package Structure: Use `devtools` to create a basic package structure. Replace `myPackage` with your desired package name, for example,
    ```
    devtools::create("../simpleBC")
    ```

    This creates a directory (`myPackage/`) with: 
    - `DESCRIPTION`: Metadata about your package (name, version, author, etc.).
    - `NAMESPACE`: Defines exported functions (auto-generated later).
    - `R/`: Directory for your R scripts.

- Copy R script to `../simpleBC/R`, e.g.,
    - `cp -rf simple_bc/bc.R ../simpleBC/R`
    - `mkdir -p ../simpleBC/R/process/r`
    - `cp -rf process/r/*.R ../simpleBC/R/process/r`
  
- Generate documentation and update NAMESPACE: `devtools::document(pkg = "../simpleBC/R")` ~ This creates .Rd files in the man/ directory and updates NAMESPACE to export my_function.

- Fill Out the `DESCRIPTION` File: Edit the `DESCRIPTION` file in myPackage/ to include

- devtools::check(pkg = "../simpleBC")

- devtools::install(pkg = "../simpleBC")

- devtools::build(pkg = "../simpleBC")

- Test on Multiple Platforms: Use R-hub to test your package: devtools::check_rhub(pkg = "../simpleBC")

- Submit via `https://cran.r-project.org/submit.html`
