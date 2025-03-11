

#' Evaluate regression model performance
#'
#' This function calculates performance metrics for a regression model by comparing
#' predicted values to actual test values using the caret package's postResample function.
#'
#' @param y_pred Numeric vector of predicted values from the model
#' @param y_test Numeric vector of actual observed values (ground truth)
#' @return A named numeric vector containing RMSE, Rsquared, and MAE metrics
#' @details The function uses caret::postResample to compute:
#'   - RMSE: Root Mean Squared Error
#'   - Rsquared: R-squared (coefficient of determination)
#'   - MAE: Mean Absolute Error
#' @examples
#' y_pred <- c(1.1, 2.2, 3.3)
#' y_test <- c(1.0, 2.0, 3.0)
#' run_eval(y_pred, y_test)
#' @importFrom caret postResample
#' @export
run_eval <- function(y_pred, y_test) {
  metrics <- postResample(pred = y_pred, obs = y_test)
  return(metrics)
}

#' Calculate feature importance using Random Forest regression
#'
#' This function trains a Random Forest Regressor on the input features and target,
#' then computes and returns the feature importance scores sorted in descending order.
#'
#' @param x Matrix or data frame of shape (n_samples, n_features). The input samples (feature matrix).
#' @param y Numeric vector of length n_samples. The target values.
#' @param x_names Character vector. Names of the features corresponding to columns in x.
#' @param n_estimators Integer, default = 100. The number of trees in the Random Forest.
#'
#' @return A data frame containing two columns:
#'   \item{feature}{Feature names}
#'   \item{importance}{Feature importance scores}
#'   Sorted by importance in descending order.
#'
#' @examples
#' set.seed(123)
#' X <- matrix(runif(100 * 3), nrow = 100, ncol = 3)
#' y <- runif(100)
#' names <- c("feat1", "feat2", "feat3")
#' feat_imp <- run_feature_importance(X, y, names)
#' print(feat_imp)
#'
#' @export
run_feature_importance <- function(x, y, x_names, n_estimators = 100) {
  # Load required package
  require(randomForest)
  
  # Train Random Forest model
  model <- randomForest::randomForest(
    x = x,
    y = y,
    ntree = n_estimators,
    importance = TRUE
  )
  feature_importance <- model$importance[, "%IncMSE"]
  return(feature_importance)
}

