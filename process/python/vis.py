from matplotlib.pyplot import plot, savefig, close, title, legend, scatter, xlabel, ylabel
from process.python import TMP_DIR
from os.path import join, exists
from os import makedirs


def plot_data(data_dict: dict, use_scatter: bool = True, output_dir: str = TMP_DIR):
    """Generate and save plots for observed and forecast data.

    This function creates visualization plots for both observed ('obs') and
    forecast ('fcst') data from the input dictionary and saves them to the
    specified output directory.

    Args:
        data_dict (dict): Dictionary containing data to plot with keys 'obs' and
            'fcst' representing observed and forecast data respectively.
        output_dir (str, optional): Directory path where plots will be saved.
            Defaults to TMP_DIR (temporary directory).

    Returns:
        None: The function saves plot files to disk and prints their locations.
    """

    if use_scatter:
        scatter(x=data_dict["obs"], y=data_dict["fcst"])
        xlabel("obs")
        ylabel("fcst")
    else:
        for data_type in ["obs", "fcst"]:
            plot(data_dict[data_type], label=data_type)
            legend()

    title("Obs and Fcst")

    if not exists(output_dir) and len(output_dir) > 0:
        makedirs(output_dir)

    output_path = join(output_dir, "bc_data.png")
    print(f"The makeup data figure is saved in {output_path}")
    savefig(output_path, bbox_inches="tight")
    close()
