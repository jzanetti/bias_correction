from process.python.data import makeup_data
from process.python.bc import train_bc_model
from process.python.data import export
from process.python.vis import plot_data

data = makeup_data()

output = train_bc_model(
    data["obs"], 
    data["fcst"], 
    data["covariants"], 
    test_size=0.2, 
    method="xgboost"
)

export(output, output_dir="test")
