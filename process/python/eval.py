from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
from numpy import sqrt, array


def run_eval(y_pred: array, y_test: array):
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

    return {"RMSE": RMSE, "Rsquared": Rsquared, "MAE": MAE}
