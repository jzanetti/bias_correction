

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