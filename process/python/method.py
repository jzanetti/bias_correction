from xgboost import XGBRegressor
from numpy import array
from pandas import DataFrame
from sklearn.linear_model import LinearRegression


def run_xgboost(
    x_train: array,
    y_train: array,
    x_test: array,
    cfg: dict,
    random_state: int or None = None,
):
    """
    Train and predict using an XGBoost regression model.

    This function trains an XGBoost regression model using the provided training data
    and makes predictions on the test data.

    Args:
        x_train (array): Numeric array of training features.
        y_train (array): Numeric array of training target values.
        x_test (array): Numeric array of test features.
        cfg (dict): Dictionary containing configuration parameters for the XGBoost model.
            Must include:
                - objective (str): The objective function (e.g., "reg:squarederror").
                - n_estimators (int): The number of boosting rounds (trees).
                - learning_rate (float): The learning rate (eta).
                - max_depth (int): The maximum tree depth.
        random_state (int or None, optional): Seed for random number generation. Defaults to None.

    Returns:
        dict: A dictionary containing:
            - model (XGBRegressor): The trained XGBoost model object.
            - y_pred (array): Array of predicted values on the test set.
    """
    xgb_model = XGBRegressor(
        objective=cfg["objective"],  # For regression
        n_estimators=cfg["n_estimators"],  # Number of trees
        learning_rate=cfg["learning_rate"],  # Step size
        max_depth=cfg["max_depth"],  # Maximum tree depth
        random_state=random_state,  # For reproducibility
    )

    # Train the model
    xgb_model.fit(x_train, y_train)

    # Make predictions
    y_pred = xgb_model.predict(x_test)

    return {"model": xgb_model, "y_pred": y_pred}


def run_linear_regression(x_train: array, y_train: array, x_test: array):
    """
    Run linear regression using sklearn

    Parameters:
        x_train : array-like of shape (n_samples, n_features)
            Training data features
        y_train : array-like of shape (n_samples,)
            Training data target
        x_test : array-like of shape (n_samples, n_features)
            Test data features
        cfg : dict
            Configuration dictionary containing 'control_method' and 'cv_folds'

    Returns:
        dict : Contains the trained model and predictions
    """

    # Create and train the linear regression model
    lm_model = LinearRegression()

    # Fit the model
    lm_model.fit(x_train, y_train)

    # Make predictions
    y_pred = lm_model.predict(x_test)

    # Return results as a dictionary
    return {"model": lm_model, "y_pred": y_pred}
