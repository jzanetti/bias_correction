library(ggplot2)
library(xgboost)
library(caret)
library(randomForest)
library(tidyr)
library(data.table)
source("process/r/constants.R")
source("process/r/data.R")
source("process/r/train.R")
source("process/r/method.R")
source("process/r/eval.R")
source("process/r/vis.R")

data <- makeup_data()

output <- train_bc_model(
  data$obs, 
  data$fcst, 
  data$covariants, 
  test_size=0.2, 
  method="xgboost")

export(
  output, 
  output_dir="test_r")