import xgboost as xgb
from numpy import array as numpy_array
from sklearn.metrics import mean_squared_error
from process.python.data import prep_data
from process.python.method import run_xgboost
from process.python.method import run_linear_regression
from process.python.eval import run_eval


def start_bc(
    obs: list,
    fcst: list,
    test_size: float = 0.2,
    random_state: int or None = None,
    method: str = "xgboost",
    cfg={
        "xgboost": {
            "objective": "reg:squarederror",
            "n_estimators": 100,
            "learning_rate": 0.1,
            "max_depth": 3,
        }
    },
    show_metrics=False,
):
    """
    Perform bias correction using specified machine learning method.

    Parameters
    ----------
    obs : list
        List of observed values
    fcst : list
        List of forecast values to be corrected
    test_size : float, optional (default=0.2)
        Proportion of the dataset to include in the test split (0 to 1)
    random_state : int or None, optional (default=None)
        Random seed for reproducibility of the train-test split
    method : str, optional (default="xgboost")
        Machine learning method to use for bias correction
        Options: "xgboost", "linear_regression"
    cfg : dict, optional
        Configuration dictionary for the selected method
        Default contains XGBoost parameters:
            - objective: "reg:squarederror"
            - n_estimators: 100
            - learning_rate: 0.1
            - max_depth: 3
    show_metrics : bool, optional (default=False)
        If True, print evaluation metrics

    Returns
    -------
    dict
        Results containing the trained model and predictions

    Notes
    -----
    This function assumes the existence of helper functions:
    - prep_data(): Prepares and splits the data
    - run_xgboost(): Runs XGBoost model
    - run_linear_regression(): Runs linear regression model
    - run_eval(): Evaluates model predictions

    Examples
    --------
    >>> obs = [1, 2, 3, 4, 5]
    >>> fcst = [1.1, 2.2, 3.1, 4.2, 5.1]
    >>> results = start_bc(obs, fcst, method="xgboost", show_metrics=True)
    """

    data = prep_data(fcst, obs, test_size, random_state)

    if method == "xgboost":
        results = run_xgboost(
            data["x_train"], data["y_train"], data["x_test"], cfg["xgboost"]
        )
    if method == "linear_regression":
        results = run_linear_regression(
            data["x_train"], data["y_train"], data["x_test"]
        )

    metrics = run_eval(results["y_pred"], data["y_test"])

    if show_metrics:
        print("<><><><><><><><><><><><>")
        print("Training evaluation:")
        print(metrics)
        print("<><><><><><><><><><><><>")

    return {"model": results["model"], "metrics": metrics}
