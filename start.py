from process.python.data import makeup_data
from process.python.bc import start_bc

data = makeup_data(create_plot=True)

start_bc(data["obs"], data["fcst"], show_metrics=True, method="linear_regression")
