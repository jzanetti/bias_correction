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

#' Starts a bias correction procedure using either XGBoost or linear regression.
#'
#' This function trains a model to correct the bias between observed and forecasted values.
#' It splits the data into training and testing sets, trains the specified model,
#' evaluates its performance, and returns the trained model, predictions, and metrics.
#'
#' @param obs Numeric vector of observed values.
#' @param fcst Numeric vector of forecasted values.
#' @param test_size Proportion of data to use for testing (default: 0.2).
#' @param random_state Seed for random number generation (default: NULL).
#' @param method Model to use for bias correction ("xgboost" or "linear_regression", default: "xgboost").
#' @param cfg List containing model-specific configurations.
#'            For XGBoost:
#'              - objective: objective function (default: "reg:squarederror").
#'              - nrounds: number of boosting rounds (default: 100).
#'              - eta: learning rate (default: 0.1).
#'              - max_depth: maximum tree depth (default: 3).
#'            For linear regression:
#'              - control_method: method for controlling model fitting (default: "cv").
#'              - cv_folds: number of cross-validation folds (default: 5).
#' @param show_metrics Logical, if TRUE, prints the evaluation metrics (default: FALSE).
#'
#' @return A list containing:
#'   - model: The trained model object.
#'   - prd: Numeric vector of predicted values on the test set.
#'   - metrics: List of evaluation metrics.
#'
#' @examples
#' obs <- rnorm(100)
#' fcst <- obs + rnorm(100, mean = 0.5, sd = 0.2)
#' results <- start_bc(obs, fcst, test_size = 0.3, method = "xgboost")
#' print(results$metrics)
#'
#' results_lm <- start_bc(obs, fcst, test_size = 0.3, method = "linear_regression")
#' print(results_lm$metrics)
#'
#' results_seed <- start_bc(obs, fcst, test_size = 0.3, random_state=123, method = "xgboost")
#' print(results_seed$metrics)
#'
#' results_metrics <- start_bc(obs, fcst, test_size = 0.3, show_metrics = TRUE, method = "xgboost")
#'
#' results_cfg <- start_bc(obs, fcst, test_size = 0.3, method = "xgboost", cfg = list(xgboost = list(objective = "reg:squarederror", nrounds = 50, eta = 0.05, max_depth = 4)))
#' print(results_cfg$metrics)
#'
#' \dontrun{
#' # Example cfg for linear regression
#' results_lm_cfg <- start_bc(obs, fcst, test_size = 0.3, method = "linear_regression", cfg = list(linear_regression = list(control_method = "cv", cv_folds = 10)))
#' print(results_lm_cfg$metrics)
#' }
#'
#' @importFrom caret createDataPartition
#' @importFrom utils head
#'
#' @export

start_bc <- function(
    obs,              
    fcst,
    covariants,
    test_size = 0.2, 
    random_state = NULL,
    method = "xgboost",
    cfg = list(
      xgboost = list(
        objective = "reg:squarederror",
        nrounds = 100,
        eta = 0.1,
        max_depth = 3
      ),
      linear_regression = list(
        control_method = "cv",
        cv_folds = 5  
      )
    ),
    show_metrics = FALSE
) {
  
  # Set seed if provided
  if (!is.null(random_state)) {
    set.seed(random_state)
  }
  
  x_info <- combine_covariants_and_fcst(covariants, fcst)
  # x <- matrix(fcst, ncol = 1)  # Features as a matrix
  y <- obs                     # Target as a vector

  # Split data into train and test sets
  train_index <- createDataPartition(y, p = 1 - test_size, list = FALSE)
  x_train <- x_info$value[train_index, , drop = FALSE]
  x_test <- x_info$value[-train_index, , drop = FALSE]
  y_train <- y[train_index]
  y_test <- y[-train_index]
  
  scaled_x_train_results <- init_scaler(x_train, x_info$names)
  
  x_train = scaled_x_train_results$value
  scaler = scaled_x_train_results$scaler
  x_test <- apply_saved_scaler(x_test, scaler, names = x_info$names)

  if (method == "xgboost") {
    results <- run_xgboost(
      x_train,
      y_train,
      x_test,
      cfg$xgboost
    )
  }
  
  if (method == "linear_regression") {
    results <- run_linear_regression(
      x_train,
      y_train,
      x_test,
      cfg$linear_regression
    )
  }
  
  metrics <- run_eval(results$y_pred, y_test)
  
  if (show_metrics){
    cat("<><><><><><><><><><><><>\n")
    cat("Training evaluation:\n")
    print(metrics)
    cat("<><><><><><><><><><><><>\n")
  }
  
  return(
    list(
      model=results$model,
      metrics=metrics,
      scaler=scaler
    )
  )
  
}