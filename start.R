library(ggplot2)
library(xgboost)
library(caret)  # for train_test_split equivalent
source("process/r/constants.R")
source("process/r/data.R")
source("process/r/bc.R")
source("process/r/method.R")
source("process/r/eval.R")
data <- makeup_data(create_plot=TRUE)

start_bc(data$obs, data$fcst, method="xgboost", show_metrics=TRUE)
