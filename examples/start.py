from process.python.data import makeup_data
from process.python.bc import start_bc
from process.python.data import export
from process.python.vis import plot_data

# data = makeup_data(create_plot=True)

data = {
    "obs": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    "fcst": [3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
}


plot_data(data, output_dir="test")

output = start_bc(
    data["obs"], data["fcst"], show_metrics=True, method="linear_regression"
)

export(output, output_dir="test")
