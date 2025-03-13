from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
from sklearn.ensemble import RandomForestRegressor
from numpy import sqrt, array
from pandas import DataFrame
from process.python.vis import plot_data
from process.python.data import reverse_scaler

def run_plot(fcst: list, obs: list, data: dict, results: dict):
    """Generates plots comparing forecast vs observation and data before/after bias correction.

    Args:
        fcst (list): List of forecast values.
        obs (list): List of observed values.
        data (dict): Dictionary with test data, including 'x_test' (array), 'x_names' (list), and 'y_test' (list).
        results (dict): Dictionary with prediction results, including 'y_pred' (list or array).

    Behavior:
        Iterates over use_scatter = True and False to produce two sets of plots:
        - Forecast vs observation plot ('fcst_vs_obs[_scatter].png').
        - Data comparison plot with before and after bias correction ('fcst_vs_obs[_scatter].png').
        Both sets are saved as scatter and line plots in the 'test' directory using plot_data().
        Note: The second plot_data call overwrites the filename from the first; this may be unintended.

    Returns:
        None: Saves plots to files as a side effect.
        
    Examples:
        >>> fcst = [1.1, 2.2, 3.3]
        >>> obs = [1, 2, 3]
        >>> data = {'x_test': [[1, 1.2], [2, 2.3], [3, 3.4]], 'x_names': ['other', 'fcst'], 'y_test': [1, 2, 3]}
        >>> results = {'y_pred': [1.1, 2.2, 3.3]}
        >>> run_plot(fcst, obs, data, results)
    """
    for use_scatter in [True, False]:
        filename = f"fcst_vs_obs{'_scatter' if use_scatter else ''}.png"
        plot_data({"fcst": fcst, "obs": obs}, use_scatter=use_scatter, filename=filename, output_dir="test")
        plot_data(
            {
                "after_bc": results["y_pred"],
                "before_bc_scaled": data["x_test"][:,data["x_names"].index("fcst")],
                "before_bc_raw": reverse_scaler(data["x_test"], data["scaler"], selected_name="fcst"),
                "obs": data["y_test"]
            }, 
            use_scatter=use_scatter, 
            x_name = "obs", 
            y_names = ["after_bc", "before_bc_scaled", "before_bc_raw"],
            title_str = "Data comparison",
            filename = f"bc{'_scatter' if use_scatter else ''}.png",
            output_dir="test"
        )


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
