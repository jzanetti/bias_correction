from matplotlib.pyplot import plot, savefig, close, title, legend, scatter, xlabel, xlim, ylim, ylabel
from process.python import TMP_DIR
from os.path import join, exists
from os import makedirs
from numpy import concatenate as numpy_concatenate
from numpy import min as numpy_min
from numpy import max as numpy_max


def plot_data(
        data_dict: dict, 
        use_scatter: bool = True, 
        output_dir: str = TMP_DIR, 
        x_name: str = "obs", 
        y_names: list = ["fcst"],
        title_str: str = "Data comparison",
        filename: str = "data_comparison.png"):
    """Plots data from a dictionary as either a scatter or line plot and saves it to a file.

    Args:
        data_dict (dict): Dictionary containing data series, with keys matching x_name and y_names.
        use_scatter (bool, optional): If True, creates a scatter plot; if False, a line plot. Defaults to True.
        output_dir (str, optional): Directory to save the plot. Defaults to TMP_DIR.
        x_name (str, optional): Key in data_dict for the x-axis data. Defaults to "obs".
        y_names (list, optional): List of keys in data_dict for y-axis data. Defaults to ["fcst"].
        title (str, optional): Title of the plot. Defaults to "Data comparison".
        filename (str, optional): Name of the output file. Defaults to "data_comparison.png".

    Behavior:
        - If use_scatter is True, plots each y_name against x_name as a scatter plot.
        - If use_scatter is False, plots x_name and all y_names as lines against an implicit index.
        - Adds a legend and saves the plot to output_dir/filename.
    """

    if use_scatter:
        # Calculate global min and max across x and all y values
        x_vals = data_dict[x_name]
        all_vals = numpy_concatenate([x_vals] + [data_dict[y] for y in y_names])
        min_val, max_val = numpy_min(all_vals), numpy_max(all_vals)
        
        for i, proc_y_name in enumerate(y_names):
            scatter(x=data_dict[x_name], y=data_dict[proc_y_name], label=proc_y_name, alpha=0.5)
        
        plot([min_val, max_val], [min_val, max_val], 'k--', alpha=1.0)
        xlim(min_val, max_val)
        ylim(min_val, max_val)
        xlabel(x_name)
        ylabel("Value")
    else:
        for data_type in [x_name] + y_names:
            plot(data_dict[data_type], label=data_type, alpha=0.5)
    legend()

    title(title_str)

    if not exists(output_dir) and len(output_dir) > 0:
        makedirs(output_dir)

    output_path = join(output_dir, filename)
    print(f"The makeup data figure is saved in {output_path}")
    savefig(output_path, bbox_inches="tight")
    close()
