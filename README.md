# Simple Bias Correction

This repository contains APIs for bias correction, facilitating the development of models that reduce systematic errors in predictions and simulations relative to observations.

Both `R` and `Python` interfaces are provided.

## Install:

 - For `Python`, the package can be installed via `pip install simple_bc`
 - For `R`, taking the provided _tarball_, and install it locally via:
    ```
    install.packages("SimpleBC.tar.gz", repos = "https://cran.r-project.org", type = "source")
    library(SimpleBC)
    ```
## Usage

### Model training:

To train the model using existing forecasts, covariates, and observations, the data must be organized in a specific format:

<table> <tr> <th>Python</th> <th>R</th> </tr> <tr> <td>

In `Python`, inputs must be organized within a dictionary, as shown in the example below:
```
data = {
    "obs": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    "fcst": [3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    "covariants": {
        "var1": [1, 2, 3, ...],
        "var2": [1.1, 2.2, 3.3, ...],
        ...
    }
}
```

The dictionary must include three required keys: `obs`, `fcst`, and `covariants`.

- The `obs` key stores a list of observed values.
- The `fcst` key stores a list of forecast values.
- The `covariants` key holds a nested dictionary where each key (e.g., `var1`, `var2`) maps to a list of covariate values.

All values associated with obs, fcst, and the entries within `covariants` must be provided as **lists**.

</td> <td>

In `R`, inputs must be organized within a `R list`, as shown in the example below:
```
  output <- list(
    obs = c(1,2,3,...),
    fcst = c(3,5,6,...),
    covariants = list(
      var1 = c(2,4,1,...),
      var2 = c(1,5,6,...),
      ...
    )
  )
```
Similar to the requirement by `python`, three keys `obs`, `fcst` and `covariants` are required for `R`.

</td> </tr> </table>

As an example, some sample data can be obtained by:

<table> <tr> <th>Python</th> <th>R</th> </tr> <tr> <td>

```
from process.python.data import makeup_data
data = makeup_data()
```
</td> <td>

```
source("process/r/data.R")
data <- makeup_data()
```
</td> </tr> </table>

The model can be trained using the function `train_bc_model`. `Python` and `R` can be operated in a similar way. For example:

<table> <tr> <th>Python</th> <th>R</th> </tr> <tr> <td>

For `Python`, the model can be trained using the following code:

```
output = train_bc_model(
    data["obs"], 
    data["fcst"], 
    data["covariants"], 
    test_size=0.2, 
    method="xgboost"
)
```

The `output` is a dictionary containing the following keys:

- `model`: The trained model, including all parameters.
- `metrics`: A DataFrame of training metrics, including `RMSE`, `R²`, and `MAE`.
- `scaler`: The scaler applied to the input data during training.
- `feature_importance`: Feature importance scores for fcst and all variables in covariants.

During the training process, the following figures are generated to aid in understanding the results:

- `fcst_vs_obs.png`: A plot showing the differences between the fcst and obs data.
- `bc.png`: A comparison of the data before and after bias correction.

After the training, the output can be saved via the function `export`, such as:

```
export(output, output_dir="test")
```

where the output will be stored in a direcotry `test`

</td> <td>

In `R`, the model is trained via:
```
output <- train_bc_model(
  data$obs, 
  data$fcst, 
  data$covariants, 
  test_size=0.2, 
  method="xgboost")
```
Similar to `python`, the output can be saved with:

```
export(
  output, 
  output_dir="test_r")
```

where the output will be stored in a direcotry `test_r`

</td> </tr> </table>

### Examples:

The examples for running `bias_correction` can be found in the directory `examples`:

- `python` example: `start.py`
- `R` example: `start.R`


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

For creating a local library for `bias_correction`,

- Document Functions: add `roxygen2` comments above each function in your .R files to document them. For example:
  ```
  #' Add two numbers
  #' @param x First number
  #' @param y Second number
  #' @return Sum of x and y
  #' @export
  add_numbers <- function(x, y) {
    return(x + y)
  }
  ```
  The @export tag makes the function available when the package is loaded.


- Install the `devtools`, `usethis` and `roxygen2` packages:
  ```
  install.packages(c("devtools", "usethis", "roxygen2"), binary = TRUE)
  ```

- Use usethis to set up the package directory:
  ```
  library(usethis)
  create_package("../SimpleBC")
  ```

- Add functions
  - Move R function scripts (e.g., from `process/R`) into the `../SimpleBC/R` folder. For example `cp -rf process/R/*.R ../SimpleBC/R`

- Edit the DESCRIPTION File: Open the DESCRIPTION file in the package directory and fill in details like (within the newly created `../SimpleBC` project):
  ```
  Package: SimepleBC
  Title: Your Package Title
  Version: 0.1.0
  Author: Your Name <your.email@example.com>
  Maintainer: Your Name <your.email@example.com>
  Description: A brief description of what your package does.
  License: MIT (or choose another, e.g., GPL-3)
  Imports: dplyr, tidyr (list dependencies here)
  ```
  Specify any dependencies under Imports if your functions rely on other packages.
  
- Run the following to generate documentation (see Step 1) and update `NAMESPACE` (within the newly created `../SimpleBC` project):
  ```
  library(devtools)
  document()
  ```

- Install and Test the Package Locally (within the newly created `../SimpleBC` project):
  - Build and install the package:
    ```
    devtools::install()
    ```

  - Build a source package for distribution:
    ```
    devtools::build(path = paste(getwd(), "..", "bias_correction", sep = "/"))
    ```
  The above will provide a tarball as `SimpleBC.tar.gz`
  
  - The package then later can be installed as:
    ```
    install.packages("SimpleBC.tar.gz", repos = "https://cran.r-project.org", type = "source")
    library(SimpleBC)
    ```
