from pickle import load as pickle_load
from xgboost.sklearn import XGBRegressor
from process.python.data import prep_data_for_predicting

def predict_bc_model(fcst: list, covariants: dict, model: XGBRegressor, scaler: dict):
    data = prep_data_for_predicting(fcst, covariants, scaler)

