
from os.path import join, exists
from os import makedirs
from numpy import array as numpy_array
from numpy import min as numpy_min
from numpy import max as numpy_max
from sklearn.model_selection import train_test_split
from pickle import dump as pickle_dump
from pandas import read_csv
from process.python import TEST_DATA, TRAINING_OUTPUT_FILENAME


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


def reverse_scaler(
    scaled_values: numpy_array, 
    scaler: dict, 
    selected_name: str or None = None) -> numpy_array:
    """
    Reverse min-max scaling using the provided scaler parameters.

    Parameters:
        scaled_values : np.ndarray
            Scaled data as a NumPy array with values in [0, 1], matching the shape of the original data.
        scaler : dict
            Dictionary containing 'min' and 'max' arrays from the original scaling (output of init_scaler).

    Returns:
        np.ndarray
            Unscaled (original) values as a NumPy array.

    Notes:
        Reverses the transformation (x - min) / (max - min) to x = scaled * (max - min) + min.
        Assumes the scaler dictionary has 'min' and 'max' keys with arrays matching the columns of scaled_values.

    Examples:
        >>> x = np.array([[1, 4], [2, 5], [3, 6]])
        >>> scaled = init_scaler(x)
        >>> unscaled = reverse_scaler(scaled['value'], scaled['scaler'])
        >>> print(unscaled)
        [[1. 4.]
         [2. 5.]
         [3. 6.]]
    """
    # Extract min and max from scaler
    min_vals = scaler["min"]
    max_vals = scaler["max"]

    # Calculate range (max - min)
    range_vals = max_vals - min_vals

    # Handle zero-range case (though not strictly necessary for reversal, included for consistency)
    range_vals[range_vals == 0] = 1

    # Reverse the scaling: scaled * (max - min) + min
    unscaled_values = scaled_values * range_vals + min_vals

    if selected_name is None:
        return unscaled_values
    
    return unscaled_values[:, scaler["names"].index(selected_name)]


def prep_data_for_training(
    fcst: list, covariants: dict, obs: list, test_size: float = 0.2, random_state: int or None = None
) -> dict:
    x_info = combine_covariants_and_fcst(covariants, fcst)
    y = numpy_array(obs)  # Target (obs) as a 1D array

    x_train, x_test, y_train, y_test = train_test_split(
        x_info["value"], y, test_size=test_size, random_state=random_state
    )

    scaled_x_train_results = init_scaler(x_train, x_info["names"])
    x_train = scaled_x_train_results["value"]

    scaler = scaled_x_train_results["scaler"]
    x_test = apply_saved_scaler(x_test, scaler, names = x_info["names"])

    return {
        "x_train": x_train, 
        "x_test": x_test, 
        "y_train": y_train, 
        "y_test": y_test, 
        "scaler": scaler, 
        "x_names": x_info["names"]}


def prep_data_for_predicting(fcst: list, covariants: dict, scaler: dict) -> numpy_array:
    """
    Prepares data for prediction by combining forecasts and covariants, and applying a saved scaler.

    Args:
        fcst (list): A list representing the forecast values.
        covariants (dict): A dictionary containing covariant data. The structure is assumed to be
            compatible with the `combine_covariants_and_fcst` function.
        scaler (dict): A dictionary containing the saved scaler parameters, as expected by
            the `apply_saved_scaler` function.

    Returns:
        numpy.ndarray: A numpy array containing the scaled, combined forecast and covariant data.

    Example:
        Assuming `combine_covariants_and_fcst` returns a dictionary like:
        {'value': numpy_array, 'names': list_of_names}
        and `apply_saved_scaler` applies the scaling and returns a numpy array,
        this function will combine the forecasts and covariants, scale the resulting values,
        and return the scaled numpy array.
    """
    x_info = combine_covariants_and_fcst(covariants, fcst)
    return apply_saved_scaler(x_info["value"], scaler, names = x_info["names"])


def makeup_data():
    """Make up some test datasets

    Returns:
        _type_: _description_
    """
    test_data = read_csv(TEST_DATA)

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
        open(join(output_dir, TRAINING_OUTPUT_FILENAME), "wb"),
    )
