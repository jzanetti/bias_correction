from process.python.data import makeup_data
from process.python.train import train_bc_model
from process.python.data import export
from process.python.predict import predict
from pickle import load as pickle_load

data = makeup_data()

RUN_TRAIN = False
RUN_PREDICT = True

if RUN_TRAIN:
    output = train_bc_model(
        data["obs"], 
        data["fcst"], 
        data["covariants"], 
        test_size=0.2, 
        method="xgboost"
    )

    export(output, output_dir="test")

if RUN_PREDICT:
    output = pickle_load( open("test/training_output.pickle", "rb" ) )
    predict(
        data["fcst"],
        data["covariants"],
        output["model"],
        output["scaler"]
    )