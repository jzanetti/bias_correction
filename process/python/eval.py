from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
from sklearn.ensemble import RandomForestRegressor
from numpy import sqrt, array
from pandas import DataFrame


def run_feature_importance(x: array, y: array, x_names: list, n_estimators: int = 100) -> DataFrame:
    """Calculate feature importance using Random Forest regression.

    This function trains a Random Forest Regressor on the input features and target,
    then computes and returns the feature importance scores sorted in descending order.

    Parameters
    ----------
    x : array-like of shape (n_samples, n_features)
        The input samples (feature matrix).
    y : array-like of shape (n_samples,)
        The target values.
    x_names : list of str
        Names of the features corresponding to columns in x.
    n_estimators : int, default=100
        The number of trees in the Random Forest.

    Returns
    -------
    feature_importance : pandas.DataFrame
        DataFrame containing two columns:
        - 'feature': feature names
        - 'importance': feature importance scores
        Sorted by importance in descending order.

    Examples
    --------
    >>> import numpy as np
    >>> from pandas import DataFrame
    >>> X = np.random.rand(100, 3)
    >>> y = np.random.rand(100)
    >>> names = ['feat1', 'feat2', 'feat3']
    >>> feat_imp = run_feature_importance(X, y, names)
    >>> print(feat_imp)
    """
    model = RandomForestRegressor(n_estimators=n_estimators)
    model.fit(x, y)

    # Get feature importance
    feature_importance = DataFrame({
        'feature': x_names,
        'importance': model.feature_importances_
    })
    feature_importance = feature_importance.sort_values('importance', ascending=False)

    return feature_importance


def run_eval(y_pred: array, y_test: array) -> DataFrame:
    """
    Calculate regression evaluation metrics for predicted vs actual values.

    Parameters
    ----------
    y_pred : array-like
        Predicted values from the model
    y_test : array-like
        Actual target values to compare against
        Must have the same shape as y_pred

    Returns
    -------
    dict
        Dictionary containing three evaluation metrics:
            - 'RMSE': Root Mean Squared Error (float)
            - 'Rsquared': R-squared coefficient of determination (float)
            - 'MAE': Mean Absolute Error (float)

    Examples
    --------
    >>> y_pred = [2.5, 0.0, 2, 8]
    >>> y_test = [3, -0.5, 2, 7]
    >>> run_eval(y_pred, y_test)
    {'RMSE': 0.612..., 'Rsquared': 0.948..., 'MAE': 0.5}

    Notes
    -----
    - RMSE: Lower values indicate better fit (0 is perfect)
    - R-squared: Values closer to 1 indicate better fit
    - MAE: Lower values indicate better fit (0 is perfect)
    """
    RMSE = sqrt(mean_squared_error(y_test, y_pred))
    Rsquared = r2_score(y_test, y_pred)
    MAE = mean_absolute_error(y_test, y_pred)

    metrics = DataFrame.from_dict({"metrics": ["RMSE", "RSquared", "MAE"], "value": [RMSE, Rsquared, MAE]})

    return metrics
