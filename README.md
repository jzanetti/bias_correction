# Simple Bias Correction

This repository contains APIs for bias correction, facilitating the development of models that reduce systematic errors in predictions and simulations relative to observations.

Both `R` and `Python` interfaces are provided.

## Install:


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

A source distribution (`.tar.gz`), and a wheel file (`.whl`) can be created in the directory `dist` using
```
python setup.py sdist bdist_wheel
```
The `whl` file then can be tested as below:
- `pip install dist/simple_bc-0.1.0-py3-none-any.whl`

- `Python`: 
  
- run `conda env create -f env.yml` (given `conda` is installed)


- `R`: This R version of this package is under development, the following shows the steps for testing the package with R:
    - Start a new R env: Run `renv::init()` to initialize renv for your project
    - Record R env: `renv::snapshot()`
    - Reload R env: Run `renv::restore()` to load the renv environment for your project
    - Install R packages: `renv::install(c("x", "y", "z"))`
