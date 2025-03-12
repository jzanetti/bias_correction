from process.python.data import makeup_data
from process.python.bc import start_bc
from process.python.data import export
from process.python.vis import plot_data

data = makeup_data()

output = start_bc(
    data["obs"], 
    data["fcst"], 
    data["covariants"], 
    test_size=0.2, 
    method="xgboost"
)

export(output, output_dir="test")
