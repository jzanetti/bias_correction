import xgboost as xgb
from numpy import array as numpy_array
from sklearn.metrics import mean_squared_error
from process.python.data import prep_data_for_training
from process.python.method import run_xgboost
from process.python.method import run_linear_regression
from process.python.eval import run_eval, run_feature_importance, run_plot
from process.python.vis import plot_data


def train_bc_model(
    obs: list,
    fcst: list,
    covariants: dict,
    test_size: float = 0.2,
    method: str = "xgboost",
    cfg={
        "xgboost": {
            "objective": "reg:squarederror",
            "n_estimators": 100,
            "learning_rate": 0.1,
            "max_depth": 3,
        }
    }
):
    """
    Perform bias correction using specified machine learning method.

    Parameters
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

    Returns: dict
        Results containing the trained model and predictions

    Notes
        This function assumes the existence of helper functions:
        - prep_data(): Prepares and splits the data
        - run_xgboost(): Runs XGBoost model
        - run_linear_regression(): Runs linear regression model
        - run_eval(): Evaluates model predictions

    Examples
        >>> obs = [1, 2, 3, 4, 5]
        >>> fcst = [1.1, 2.2, 3.1, 4.2, 5.1]
        >>> results = start_bc(obs, fcst, method="xgboost", show_metrics=True)
    """

    training_data = prep_data_for_training(fcst, covariants, obs, test_size=test_size)

    if method == "xgboost":
        results = run_xgboost(
            training_data["x_train"], training_data["y_train"], training_data["x_test"], cfg["xgboost"]
        )
    if method == "linear_regression":
        results = run_linear_regression(
            training_data["x_train"], training_data["y_train"], training_data["x_test"]
        )

    metrics = run_eval(results["y_pred"], training_data["y_test"])
    run_plot(fcst, obs, training_data, results)
    feature_importance = run_feature_importance(
        training_data["x_train"], training_data["y_train"], training_data["x_names"])

    print("<><><><><><><><><><><><>")
    print("Training evaluation (Metrics):")
    print(metrics)
    print("Training evaluation (Feature importance):")
    print(feature_importance)
    print("<><><><><><><><><><><><>")

    return {
        "model": results["model"], 
        "metrics": metrics, 
        "scaler": training_data["scaler"], 
        "feature_importance": feature_importance}
