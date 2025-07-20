library(ggplot2)
library(xgboost)
library(caret)
library(randomForest)
library(tidyr)
library(data.table)
source("process/r/constants.R")
source("process/r/data.R")
source("process/r/train.R")
source("process/r/predict.R")
source("process/r/method.R")
source("process/r/eval.R")
source("process/r/vis.R")

data <- makeup_data()

RUN_TRAIN = TRUE
RUN_PREDICT = TRUE

if (RUN_TRAIN) {
  output <- train_bc_model(
    data$obs, 
    data$fcst, 
    data$covariants, 
    test_size=0.2, 
    method="xgboost")
  
  export(
    output, 
    output_dir="test_r")
}

if (RUN_PREDICT) {
  load("test_r/training_output.RData")
  
  predict_bc_model(
    data$fcst,
    data$covariants,
    output$model,
    output$scaler
  )
}