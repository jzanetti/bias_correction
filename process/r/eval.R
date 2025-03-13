
' Run plotting for forecast vs observation and data comparison
#'
#' @description
#' This function generates two sets of plots: one comparing forecast and observation data,
#' and another comparing data before and after bias correction against observations.
#' Each set is plotted as both a scatter plot and a line plot, saved to the specified output directory.
#'
#' @param fcst Numeric vector of forecast values.
#' @param obs Numeric vector of observed values.
#' @param data List containing test data with elements `x_test` (matrix), `x_names` (vector), and `y_test` (vector).
#' @param results List containing prediction results with a nested `y_pred` element, itself containing a `y_pred` vector.
#'
#' @details
#' The function iterates over `use_scatter = TRUE` and `FALSE` to produce:
#' - A forecast vs observation plot (`fcst_vs_obs[_scatter].png`).
#' - A data comparison plot with before and after bias correction (`data_comparison_after_bc[_scatter].png`).
#' Both plots are saved in the "test_r" directory.
#'
#' @return None (invisible NULL); the function saves plots to files as a side effect.
#'
#' @examples
#' \dontrun{
#'   fcst <- c(1.1, 2.2, 3.3)
#'   obs <- c(1, 2, 3)
#'   data <- list(x_test = matrix(c(1, 1.2, 2, 2.3, 3, 3.4), ncol = 2),
#'                x_names = c("other", "fcst"), y_test = c(1, 2, 3))
#'   results <- list(y_pred = list(y_pred = c(1.1, 2.2, 3.3)))
#'   run_plot(fcst, obs, data, results)
#' }
#' @export
#' 
run_plot <- function(
    fcst,
    obs,
    data,
    results) {

  for (use_scatter in c(TRUE, FALSE)) {
    
    filename <- paste0(
      "fcst_vs_obs", ifelse(
        use_scatter, "_scatter", ""), ".png")
    
    plot_data(
      list(fcst=fcst, obs=obs), 
      use_scatter=use_scatter, 
      output_dir = "test_r",
      filename = filename)
    
    filename <- paste0(
      "bc", ifelse(
        use_scatter, "_scatter", ""), ".png")

    plot_data(
      data_dict = list(
        after_bc = results[["y_pred"]]$y_pred,
        before_bc_scaled = data[["x_test"]][, which(data[["x_names"]] == "fcst")],
        before_bc_raw = reverse_scaler(data[["x_test"]], data[["scaler"]], selected_name="fcst"),
        obs = data[["y_test"]]
      ),
      use_scatter = use_scatter,
      x_name = "obs",
      y_names = c("after_bc", "before_bc_scaled", "before_bc_raw"),
      title = "Data comparison",
      filename = filename,
      output_dir = "test_r"
    )
  }
}


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

