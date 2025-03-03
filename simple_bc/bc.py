from process.python.data import makeup_data
from process.python.bc import start_bc
from process.python.data import export
from process.python.vis import plot_data
from process.python import TMP_DIR


def run_bc(
    data: dict or None = None,
    create_plot: bool = False,
    show_metrics: bool = False,
    test_size: float = 0.2,
    method: str = "linear_regression",
    output_dir: str = TMP_DIR,
):
    """Run bias correction on meteorological data.

    This function performs bias correction on forecast data using observed data,
    with options to generate plots, show metrics, and specify the correction method.

    Args:
        data (dict or None, optional): Input data containing 'obs' and 'fcst' keys.
            If None, synthetic data will be generated. Defaults to None.
        create_plot (bool, optional): Whether to generate visualization plots.
            Defaults to False.
        test_size : float, optional (default=0.2)
            Proportion of the dataset to include in the test split (0 to 1)
        show_metrics (bool, optional): Whether to display performance metrics.
            Defaults to False.
        method (str, optional): Bias correction method to use. Current supported
            method is "linear_regression". Defaults to "linear_regression".
        output_dir (str, optional): Directory path to save the model output.
            Defaults to empty string (current directory).

    Returns:
        None: The function saves the output to the specified directory and prints
            a confirmation message.

    Notes:
        - If data is not provided (None), the function calls makeup_data() to
          generate synthetic data.
        - The actual bias correction is performed by the start_bc() function.
        - Output is exported using the export() function.
    """
    if data is None:
        data = makeup_data()

    if create_plot:
        plot_data(data, output_dir=output_dir)

    output = start_bc(
        data["obs"],
        data["fcst"],
        test_size=test_size,
        show_metrics=show_metrics,
        method=method,
    )

    print(f"The model is saved to {output_dir} ...")
    export(output, output_dir=output_dir)
