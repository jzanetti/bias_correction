#' Run XGBoost regression model and return predictions.
#'
#' @param x_train Matrix or data.frame of training features
#' @param y_train Numeric vector of training target values
#' @param x_test Matrix or data.frame of test features
#' @param cfg Named list containing XGBoost parameters:
#'   objective (character), n_estimators (integer), 
#'   learning_rate (numeric), max_depth (integer)
#' @param random_state Integer seed for reproducibility, or NULL (default)
#'
#' @return Numeric vector of predictions for x_test
#' 
#' @note Requires xgboost package

# Ensure xgboost is loaded
run_xgboost <- function(
    x_train,
    y_train,
    x_test,
    cfg
) {
  require(xgboost)
  
  xgb_model <- xgboost::xgboost(
    data = x_train,
    label = y_train,
    objective = cfg$objective,
    nrounds = cfg$nrounds,          # equivalent to n_estimators
    eta = cfg$eta,             # equivalent to learning_rate
    max_depth = cfg$max_depth,
    verbose = 0            # suppress output
  )
  # Make predictions
  y_pred <- predict(xgb_model, x_test)
  return(list(model=xgb_model, y_pred=as.data.frame(y_pred)))
}

#' Train and predict using a linear regression model.
#'
#' This function trains a linear regression model using the provided training data
#' and makes predictions on the test data.
#'
#' @param x_train Numeric matrix of training features.
#' @param y_train Numeric vector of training target values.
#' @param x_test Numeric matrix of test features.
#' @param cfg List containing configuration parameters for the linear regression model.
#'            Must include:
#'              - control_method: Method for controlling model fitting (e.g., "cv" for cross-validation).
#'              - cv_folds: Number of folds if using cross-validation.
#'
#' @return A list containing:
#'   - model: The trained linear regression model object (from `caret::train`).
#'   - y_pred: Data frame of predicted values on the test set.
#'
#' @examples
#' x_train <- matrix(rnorm(100), ncol = 1)
#' y_train <- 2 * x_train + rnorm(100, sd = 0.5)
#' x_test <- matrix(rnorm(50), ncol = 1)
#' cfg <- list(control_method = "cv", cv_folds = 5)
#' results <- run_linear_regression(x_train, y_train, x_test, cfg)
#' print(head(results$y_pred))
#'
#' \dontrun{
#' # Example with more complex training data
#' x_train_complex <- matrix(rnorm(200), ncol = 2)
#' y_train_complex <- 3 * x_train_complex[, 1] + 2 * x_train_complex[, 2] + rnorm(100, sd = 0.5)
#' x_test_complex <- matrix(rnorm(100), ncol = 2)
#' cfg_complex <- list(control_method = "cv", cv_folds = 10)
#' results_complex <- run_linear_regression(x_train_complex, y_train_complex, x_test_complex, cfg_complex)
#' print(head(results_complex$y_pred))
#' }
#'
#' @importFrom caret train trainControl
#'
#' @export
run_linear_regression <- function(
    x_train,
    y_train,
    x_test,
    cfg
) {
  require(caret)
  
  # Combine training data into a data frame
  train_data <- data.frame(x_train, y = y_train)
  
  # Train linear regression model
  lm_model <- caret::train(
    y ~ .,                    # Formula: predict y using all features
    data = train_data,        # Training data
    method = "lm",            # Linear regression method
    trControl = trainControl(
      method = cfg$control_method,  # e.g., "cv" for cross-validation
      number = cfg$cv_folds        # Number of folds if using CV
    )
  )
  
  # Make predictions
  colnames(x_test) <- colnames(train_data)[[
    1:(length(colnames(train_data)) - 1)]]
  y_pred <- predict(lm_model, newdata = x_test)

  return(list(model = lm_model, y_pred = as.data.frame(y_pred)))
}
