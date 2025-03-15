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

train_bc_model <- function(
    obs,              
    fcst,
    covariants,
    test_size = 0.2,
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
    )
) {
  
  training_data <- prep_data_for_training(fcst, covariants, obs, test_size=test_size)

  if (method == "xgboost") {
    results <- run_xgboost(
      training_data$x_train,
      training_data$y_train,
      training_data$x_test,
      cfg$xgboost
    )
  }
  
  if (method == "linear_regression") {
    results <- run_linear_regression(
      training_data$x_train,
      training_data$y_train,
      training_data$x_test,
      cfg$linear_regression
    )
  }
  
  metrics <- run_eval(results$y_pred, training_data$y_test)
  run_plot(fcst, obs, training_data, results)
  feature_importance = run_feature_importance(
    training_data$x_train, training_data$y_train, training_data$x_names)
  
  cat("<><><><><><><><><><><><>\n")
  cat("Training evaluation (Metrics):\n")
  print(metrics)
  cat("Training evaluation (Feature importance):\n")
  print(feature_importance)
  cat("<><><><><><><><><><><><>\n")

  
  return(
    list(
      model=results$model,
      metrics=metrics,
      scaler=training_data$scaler
    )
  )
  
}