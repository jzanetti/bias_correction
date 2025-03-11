#' Combine Covariants and Forecast into a Matrix
#'
#' This function combines a list of covariant vectors and a forecast vector into a single matrix.
#' Each covariant and the forecast must have the same length. The resulting matrix has columns
#' corresponding to each covariant and the forecast.
#'
#' @param covariants A named list where each element is a numeric vector representing a covariant.
#' @param fcst A numeric vector representing the forecast values.
#' @return A matrix where each column is a covariant or the forecast, with rows corresponding to observations.
#' @details The function checks that all covariants have the same length as the forecast. If any
#' covariant length does not match, it stops with an error message. The output matrix has dimensions
#' n x (k + 1), where n is the length of the vectors and k is the number of covariants.
#' @examples
#' covariants <- list(x1 = 1:3, x2 = 4:6)
#' fcst <- 7:9
#' combine_covariants_and_fcst(covariants, fcst)
#' # Returns a 3x3 matrix with columns x1, x2, and fcst
#' @export
combine_covariants_and_fcst <- function(covariants, fcst) {
  # Get length of fcst
  fcst_length <- length(fcst)
  
  # Initialize an empty list to store x_values
  x_values <- list()
  
  covariants_names <- as.list(names(covariants))
  # Loop over covariant names
  for (cov_name in covariants_names) {
    cov_value <- covariants[[cov_name]]  # Double brackets to extract vector from list
    
    # Check if lengths match
    if (length(cov_value) != fcst_length) {
      stop(sprintf("Covariant %s does not have the same length as fcst", cov_name))
    }
    
    # Append covariant values to the list
    x_values[[cov_name]] <- cov_value
  }
  
  # Append fcst to the list
  x_values[["fcst"]] <- fcst
  x <- as.matrix(do.call(cbind, x_values))
  
  covariants_names[[length(covariants_names) + 1]] <- "fcst"
  
  return (list(names = covariants_names, value = x))
}


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
  test_data <- read.csv(TEST_DATA)
  
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


' Prepare data for modeling by combining, splitting, and scaling
#'
#' This function prepares forecasting data by combining forecast values with covariates,
#' splitting the data into training and test sets, and applying scaling to the features.
#'
#' @param fcst Numeric vector. Forecast values to be used as a feature.
#' @param obs Numeric vector. Observed values to be used as the target variable.
#' @param covariants Data frame or matrix. Covariate features to be combined with forecast.
#' @param test_size Numeric, default = 0.2. Proportion of data to use for testing (0 to 1).
#'
#' @return A list containing:
#'   \item{x_train}{Scaled training features (matrix)}
#'   \item{x_test}{Scaled test features (matrix)}
#'   \item{y_train}{Training target values (vector)}
#'   \item{y_test}{Test target values (vector)}
#'   \item{scaler}{Scaler object/function used for scaling}
#'   \item{x_names}{Character vector of feature names}
#'
#' @details
#' The function assumes the existence of helper functions:
#' - combine_covariants_and_fcst(): Combines covariates and forecast
#' - createDataPartition(): Creates train/test split indices (from caret package)
#' - init_scaler(): Initializes and applies scaling to training data
#' - apply_saved_scaler(): Applies saved scaling to test data
#'
#' @examples
#' \dontrun{
#' fcst <- rnorm(100)
#' obs <- rnorm(100)
#' cov <- matrix(rnorm(100 * 3), ncol = 3)
#' result <- prep_data(fcst, obs, cov, test_size = 0.2)
#' str(result)
#' }
#'
#' @export
prep_data <- function(fcst, obs, covariants, test_size = 0.2) {
  x_info <- combine_covariants_and_fcst(covariants, fcst)
  y <- obs

  train_index <- createDataPartition(y, p = 1 - test_size, list = FALSE)
  x_train <- x_info$value[train_index, , drop = FALSE]
  x_test <- x_info$value[-train_index, , drop = FALSE]
  y_train <- y[train_index]
  y_test <- y[-train_index]
  
  scaled_x_train_results <- init_scaler(x_train, x_info$names)
  
  x_train = scaled_x_train_results$value
  scaler = scaled_x_train_results$scaler
  x_test <- apply_saved_scaler(x_test, scaler, names = x_info$names)
  
  return (list(
    x_train=x_train,
    x_test=x_test,
    y_train=y_train,
    y_test=y_test,
    scaler=scaler,
    x_names=x_info$names
  ))
  
}