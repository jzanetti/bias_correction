#' Run bias correction on meteorological data.
#'
#' This function performs bias correction on forecast data using observed data,
#' with options to generate plots, show metrics, and specify the correction method.
#'
#' @param data A list with 'obs' and 'fcst' elements, or NULL to generate synthetic data. Defaults to NULL.
#' @param create_plot Logical, whether to generate visualization plots. Defaults to FALSE.
#' @param show_metrics Logical, whether to display performance metrics. Defaults to FALSE.
#' @param test_size Numeric, proportion of the dataset for the test split (0 to 1). Defaults to 0.2.
#' @param method Character, bias correction method to use. Currently supports "linear_regression". Defaults to "linear_regression".
#' @param output_dir Character, directory path to save the model output. Defaults to TMP_DIR.
#' @return None, saves output to the specified directory and prints a confirmation message.
#' @export
run_bc <- function(data = NULL, create_plot = FALSE, show_metrics = FALSE, 
                   test_size = 0.2, method = "linear_regression", output_dir = TMP_DIR) {
  
  library(ggplot2)
  library(xgboost)
  library(caret)  # for train_test_split equivalent
  source("process/r/constants.R")
  source("process/r/data.R")
  source("process/r/bc.R")
  source("process/r/method.R")
  source("process/r/eval.R")
  source("process/r/vis.R")
  
  # Generate synthetic data if none provided
  if (is.null(data)) {
    data <- makeup_data()
  }
  
  # Create plot if requested
  if (create_plot) {
    plot_data(data, output_dir = output_dir)
  }
  
  # Run bias correction
  output <- start_bc(
    obs = data$obs,
    fcst = data$fcst,
    test_size = test_size,
    show_metrics = show_metrics,
    method = method
  )
  
  # Export results
  cat(sprintf("The model is saved to %s ...\n", output_dir))
  export(output, output_dir = output_dir)
}