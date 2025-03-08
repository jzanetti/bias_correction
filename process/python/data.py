from numpy.random import normal as numpy_normal
from os.path import join, exists
from os import makedirs
from numpy import array as numpy_array
from numpy import min as numpy_min
from numpy import max as numpy_max
from sklearn.model_selection import train_test_split
from pickle import dump as pickle_dump
from pandas import read_csv



def combine_covariants_and_fcst(covariants: dict, fcst: list) -> numpy_array:
    """
    Combine covariant vectors and a forecast vector into a transposed NumPy array.
    
    This function takes a dictionary of covariant vectors and a forecast vector, checks
    that all vectors have the same length, and combines them into a NumPy array where
    rows represent observations and columns represent features (covariants plus forecast).
    
    Parameters:
    -----------
    covariants : dict
        A dictionary where keys are covariant names (str) and values are lists or arrays
        of numeric values representing the covariants.
    fcst : list
        A list of numeric values representing the forecast.
    
    Returns:
    --------
    numpy.ndarray
        A 2D NumPy array with shape (n, k+1), where n is the length of the vectors and
        k is the number of covariants. The array is transposed so that rows are observations
        and columns are features (covariants followed by forecast).
    
    Raises:
    -------
    Exception
        If any covariant vector’s length does not match the length of `fcst`.
    
    Examples:
    ---------
    >>> covariants = {'x1': [1, 2, 3], 'x2': [4, 5, 6]}
    >>> fcst = [7, 8, 9]
    >>> combine_covariants_and_fcst(covariants, fcst)
    array([[1, 4, 7],
           [2, 5, 8],
           [3, 6, 9]])
    
    >>> covariants = {'x1': [1, 2]}
    >>> fcst = [7, 8, 9]
    >>> combine_covariants_and_fcst(covariants, fcst)
    Exception: Covariant x1 does not have the same length as fcst
    """
    fcst_length = len(fcst)
    x_values = []
    cov_names = list(covariants.keys())

    for cov_name in cov_names:

        cov_value = covariants[cov_name]
        if not len(cov_value) == fcst_length:
            raise Exception(f"Covariant {cov_name} does not have the same length as fcst")
        x_values.append(covariants[cov_name])
    x_values.append(fcst)

    # return num * features
    return {"names": cov_names + ["fcst"], "value": numpy_array(x_values).T}


def apply_saved_scaler(x_values, scaler, names: None or list = None):
    """
    Apply a saved min-max scaler to new data.
    
    Parameters:
        x_values : array-like
            Input data as a matrix with rows as observations and columns as features.
            Must have the same number of columns as the scaler was trained on.
        scaler : dict
            A dictionary containing 'min' and 'max' arrays from a previous scaling operation
            (e.g., from init_scaler), representing the minimum and maximum values per column.
    
    Returns: numpy.ndarray
        A scaled matrix with the same dimensions as x_values, transformed to [0, 1]
        using the formula (x - min) / (max - min).
    
    Notes: Ensures input is a NumPy array, applies the saved min and max values to scale the data.
    If a column's range (max - min) is zero, it is set to 1 to avoid division by zero.
    
    Examples:
        >>> x_train = np.array([[1, 4], [2, 5], [3, 6]])
        >>> result = init_scaler(x_train)
        >>> x_test = np.array([[2, 5], [3, 6]])
        >>> scaled_test = apply_saved_scaler(x_test, result['scaler'])
        >>> print(scaled_test)
        [[0.5 0.5]
        [1.  1. ]]
    """
    if names is not None:
        if not scaler["names"] == names:
            raise Exception("Scaler does not have consistent names")
    
    # Calculate range (max - min) from scaler
    range_vals = scaler['max'] - scaler['min']
    
    # Handle case where range is 0 (to avoid division by zero)
    range_vals[range_vals == 0] = 1
    
    # Apply min-max scaling: (x - min) / (max - min)
    scaled_value = (x_values - scaler['min']) / range_vals
    
    return scaled_value


def init_scaler(x_values: numpy_array, covariants_names: list):
    """
    Initialize a min-max scaler and apply it to the input data.
    
    Parameters:
        x_values : array-like
            Input data as a matrix with rows as observations and columns as features.
            Can be a list, NumPy array, or similar structure.
    
    Returns:
        dict: A dictionary containing:
            - 'scaler': dict with 'min' and 'max' arrays for each column.
            - 'value': scaled NumPy array with values in [0, 1].
    
    Notes:
        Ensures input is a NumPy array, computes min and max per column, and applies
        min-max scaling: (x - min) / (max - min). If a column's range is zero, it is
        set to 1 to avoid division by zero.
    
    Examples:
        >>> x = np.array([[1, 4], [2, 5], [3, 6]])
        >>> result = init_scaler(x)
        >>> print(result['value'])
        [[0.  0. ]
        [0.5 0.5]
        [1.  1. ]]
    """
    # Get min and max for each column (axis=0 means column-wise)
    min_vals = numpy_min(x_values, axis=0)
    max_vals = numpy_max(x_values, axis=0)
    
    # Calculate range (max - min) for each column
    range_vals = max_vals - min_vals
    
    # Handle case where range is 0 (to avoid division by zero)
    range_vals[range_vals == 0] = 1
    
    # Apply min-max scaling: (x - min) / (max - min)
    scaled_value = (x_values - min_vals) / range_vals
    
    # Return a dictionary with scaler and scaled values
    return {
        'scaler': {"min": min_vals, "max": max_vals, "names": covariants_names},
        'value': scaled_value
    }


def prep_data(
    fcst: list, obs: list, covariants: dict, test_size: float = 0.2, random_state: int or None = None
):
    x_info = combine_covariants_and_fcst(covariants, fcst)
    y = numpy_array(obs)  # Target (obs) as a 1D array

    x_train, x_test, y_train, y_test = train_test_split(
        x_info["value"], y, test_size=test_size, random_state=random_state
    )

    scaled_x_train_results = init_scaler(x_train, x_info["names"])
    x_train = scaled_x_train_results["value"]

    scaler = scaled_x_train_results["scaler"]
    x_test = apply_saved_scaler(x_test, scaler, names = x_info["names"])

    return {"x_train": x_train, "x_test": x_test, "y_train": y_train, "y_test": y_test, "scaler": scaler}


def makeup_data():

    test_data = read_csv("examples/etc/test_data.csv")

    data = {
        "obs": list(test_data["y"]),
        "fcst": list(test_data["x1"]),
        "covariants": {
            "var1": list(test_data["x2"]),
            "var2": list(test_data["x3"]),
            "var3": list(test_data["x4"])
        },
    }

    return data


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
