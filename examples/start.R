library(ggplot2)
library(xgboost)
library(caret)
library(randomForest)
source("process/r/constants.R")
source("process/r/data.R")
source("process/r/bc.R")
source("process/r/method.R")
source("process/r/eval.R")
source("process/r/vis.R")

data <- makeup_data()

plot_data(data, output_dir = "test_r")

output <- start_bc(
  data$obs, 
  data$fcst, 
  data$covariants, 
  test_size=0.2, 
  method="xgboost", 
  show_metrics=TRUE)

export(
  output, 
  output_dir="test_r")