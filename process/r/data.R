#' Apply Saved Min-Max Scaler to New Data
#'
#' Applies a previously computed min-max scaler to new data, transforming it to the range [0, 1]
#' using the saved minimum and maximum values from training data.
#'
#' @param x_values A numeric matrix or data frame with rows as observations and columns as features.
#'                 The number of columns must match the number of features in the scaler.
#' @param scaler A list containing `min` and `max` vectors (from a previous call to `apply_scaler`),
#'               representing the minimum and maximum values for each column of the original data.
#' @return A matrix of scaled values, with the same dimensions as `x_values`, where each column
#'         is transformed using the formula `(x - min) / (max - min)`.
#' @details This function assumes the scaler was created with compatible data (same number of columns).
#'          If a column's range (`max - min`) is zero, it is treated as 1 to avoid division by zero.
#'          The input is coerced to a matrix if it isn’t already one.
#' @examples
#' # Training data
#' x_train <- matrix(c(1, 2, 3, 4, 5, 6), ncol = 2)
#' result <- apply_scaler(x_train)
#' 
#' # Test data
#' x_test <- matrix(c(2, 3, 5, 6), ncol = 2)
#' scaled_test <- apply_saved_scaler(x_test, result$scaler)
#' print(scaled_test)
#' @export
apply_saved_scaler <- function(x_values, scaler, names=NULL) {

  if (!is.null(names)){
    if (! identical(scaler$names, names)){
      stop("Scaler does not have consistent names")
    }
  }
  
  if (!is.matrix(x_values)) {
    x_values <- as.matrix(x_values)
  }
  range_vals <- scaler$max - scaler$min
  range_vals[range_vals == 0] <- 1
  scaled_value <- t((t(x_values) - scaler$min) / range_vals)
  return(scaled_value)
}

#' Apply Min-Max Scaling to a Matrix
#'
#' Scales the input matrix using min-max scaling (values between 0 and 1) and returns
#' the scaler parameters and scaled values for later use.
#'
#' @param x_values A numeric matrix with rows as observations and columns as features.
#' @return A list containing the scaler parameters (min and max for each column) and the scaled matrix.
#' @examples
#' x <- matrix(c(1, 2, 3, 4, 5, 6), ncol = 2)
#' result <- init_scaler(x)
#' result$value  # Scaled matrix
#' result$scaler  # Scaler parameters
init_scaler <- function(x_values, covariants_names) {
  
  # Ensure input is a matrix
  if (!is.matrix(x_values)) {
    x_values <- as.matrix(x_values)
  }
  
  # Get min and max for each column
  min_vals <- apply(x_values, 2, min)
  max_vals <- apply(x_values, 2, max)
  
  # Calculate range (max - min) for each column
  range_vals <- max_vals - min_vals
  
  # Handle case where range is 0 (to avoid division by zero)
  range_vals[range_vals == 0] <- 1
  
  # Apply min-max scaling: (x - min) / (max - min)
  scaled_value <- t((t(x_values) - min_vals) / range_vals)
  
  # Return a list with scaler and scaled values
  return(list(
    scaler = list(min = min_vals, max = max_vals, names = covariants_names), 
    value = scaled_value))
}


#' Generate synthetic data following normal distributions for observation and forecast.
#'
#' @param data_size Integer number of data points to generate for each data type. Defaults to 1000.
#' @param normal_cfg Named list containing mean and standard deviation for each data type.
#'   Expected structure: list("obs" = list("mean" = float, "std" = float),
#'                           "fcst" = list("mean" = float, "std" = float)).
#'   Defaults to observation mean=100.0, std=5.0 and forecast mean=105.0, std=6.3.
#' @param create_plot Logical indicating whether to create plots for the data using ggplot2. Defaults to FALSE.
#'
#' @return A named list containing vectors of generated data with names "obs" and "fcst",
#'   where each vector has length equal to data_size.
#' 
#' @note Requires ggplot2 package for plotting functionality when create_plot = TRUE
#' 
#' @export
#' 
makeup_data <- function() {
  test_data <- read.csv("examples/etc/test_data.csv")
  
  output <- list(
    obs = test_data$y,
    fcst = test_data$x1,
    covariants = list(
      var1 = test_data$x2,
      var2 = test_data$x3,
      var3 = test_data$x4
    )
  )
  
  return(output)
}

#' Exports an R object to an RData file.
#'
#' This function saves an R object, typically a list containing models or other data,
#' to an RData file. This is useful for persisting R objects to disk for later use.
#'
#' @param output The R object (e.g., list, data frame, model) to be exported.
#' @param output_dir (character, optional) The directory where the RData file will be saved.
#'                    Defaults to the current working directory.
#'
#' @examples
#' # Assuming 'my_data' is an R object you want to save:
#' # export_r(my_data, "path/to/my/directory")
#' # export_r(my_data) # Saves to the current working directory.
#' 
#' @export
#' 
export <- function(output, output_dir = "") {
  output_file <- "bc_output.RData"
  if (nchar(output_dir) > 0) {
    output_file <- file.path(output_dir, "bc_output.RData")
  }
  save(output, file = output_file)
}