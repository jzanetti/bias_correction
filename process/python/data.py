from numpy.random import normal as numpy_normal
from os.path import join, exists
from os import makedirs
from numpy import array as numpy_array
from sklearn.model_selection import train_test_split
from pickle import dump as pickle_dump


def prep_data(
    fcst: list, obs: list, test_size: float = 0.2, random_state: int or None = None
):
    """Prepare and split data for model training and testing.

    Args:
        fcst (list): List of forecast values (features).
        obs (list): List of observed values (target).
        test_size (float, optional): Proportion of the dataset to include in the test split.
            Must be between 0.0 and 1.0. Defaults to 0.2.
        random_state (int or None, optional): Random seed for reproducibility.
            If None, the split will be random. Defaults to None.

    Returns:
        dict: Dictionary containing:
            - 'x_train': Training features (2D numpy array)
            - 'x_test': Testing features (2D numpy array)
            - 'y_train': Training targets (1D numpy array)
            - 'y_test': Testing targets (1D numpy array)

    Examples:
        >>> fcst = [1.1, 2.2, 3.3, 4.4]
        >>> obs = [1, 2, 3, 4]
        >>> data = prep_data(fcst, obs, test_size=0.25, random_state=42)
        >>> print(data['x_train'].shape)
    """
    x = numpy_array(fcst).reshape(-1, 1)  # Features (fcst) as a 2D array
    y = numpy_array(obs)  # Target (obs) as a 1D array

    x_train, x_test, y_train, y_test = train_test_split(
        x, y, test_size=test_size, random_state=random_state
    )

    return {"x_train": x_train, "x_test": x_test, "y_train": y_train, "y_test": y_test}


def makeup_data(
    data_size: int = 1000,
    normal_cfg: dict = {
        "obs": {"mean": 100.0, "std": 5.0},
        "fcst": {"mean": 105.0, "std": 6.3},
    },
):
    """Generate synthetic data following normal distributions for observation and forecast.

    Args:
        data_size (int): Number of data points to generate for each data type. Defaults to 1000.
        normal_cfg (dict): Configuration dictionary containing mean and standard deviation
            for each data type. Expected structure:
            {
                "obs": {"mean": float, "std": float},
                "fcst": {"mean": float, "std": float}
            }
            Defaults to observation mean=100.0, std=5.0 and forecast mean=105.0, std=6.3.

    Returns:
        dict: Dictionary containing lists of generated data with keys "obs" and "fcst",
            where each list has length equal to data_size.

    Note:
        This function assumes numpy_normal() is available, which is typically
        numpy.random.normal().
    """
    output = {}
    for data_type in ["obs", "fcst"]:
        output[data_type] = numpy_normal(
            normal_cfg[data_type]["mean"], normal_cfg[data_type]["std"], data_size
        ).tolist()

    return output


def export(output: dict, output_dir: str = ""):
    """
    Exports a dictionary to a pickle file.

    Args:
        output (dict): The dictionary to be exported.
        output_dir (str, optional): The directory where the pickle file will be saved.
                                     Defaults to the current working directory.
    """

    if not exists(output_dir) and len(output_dir) > 0:
        makedirs(output_dir)

    pickle_dump(
        output,
        open(join(output_dir, "bc_output.pickle"), "wb"),
    )
