import pandas as pd
import numpy as np
from math import log
from scipy.stats import pearsonr
import matplotlib.pyplot as plt
from statsmodels.tsa.stattools import adfuller
import statsmodels.api as sm

def calculate_correlation(closing_prices_asset_1, closing_prices_asset_2):
    """
    Calculate the correlation coefficient between two assets based on their closing prices.
    
    Args:
        closing_prices_asset_1 (pandas.Series): Closing prices of the first asset.
        closing_prices_asset_2 (pandas.Series): Closing prices of the second asset.
    
    Returns:
        float: The correlation coefficient between the closing prices of the two assets.
    """
    correlation_coefficient, _ = pearsonr(closing_prices_asset_1, closing_prices_asset_2)
    
    return correlation_coefficient


def calculate_spread(closing_prices_asset_1, closing_prices_asset_2):
    """
    Calculate the spread between two assets based on their returns.
    
    Args:
        closing_prices_asset_1 (pandas.Series): Closing prices of the first asset.
        closing_prices_asset_2 (pandas.Series): Closing prices of the second asset.
    
    Returns:
        list: A list representing the spread between the two assets based on returns.
    """
    if len(closing_prices_asset_1) != len(closing_prices_asset_2):
        raise ValueError("Input lists must have the same length")
    
    returns_asset_1 = np.diff(closing_prices_asset_1) / closing_prices_asset_1[:-1]
    returns_asset_2 = np.diff(closing_prices_asset_2) / closing_prices_asset_2[:-1]

    spread = [a - b for a, b in zip(returns_asset_1, returns_asset_2)]

    return spread

def calculate_zscore(spread):
    """
    Calculate the Z-score of a spread.
    
    Args:
        spread (list): A list representing the spread between two assets.
    
    Returns:
        list: Z-scores for the spread data.
    """
    mean_spread = np.mean(spread)
    std_dev_spread = np.std(spread)
    z_scores = [(x - mean_spread) / std_dev_spread for x in spread]
    
    return z_scores

def hedge_ratio(closing_prices_asset_2, closing_prices_asset_1):
    """
    Calculate the hedge ratio for two assets.
    
    Args:
        closing_prices_asset_2 (pandas.Series): Closing prices of the second asset.
        closing_prices_asset_1 (pandas.Series): Closing prices of the first asset.
    
    Returns:
        float: The hedge ratio.
    """
    closing_prices_asset_1 = sm.add_constant(closing_prices_asset_1)
    model = sm.OLS(closing_prices_asset_2, closing_prices_asset_1).fit()

    return model.params[1]

def is_stationary(spread, significance_level=0.05):
    """
    Check the stationarity of a spread using the Augmented Dickey-Fuller (ADF) test.
    
    Args:
        spread (list): A list representing the spread between two assets.
        significance_level (float): The significance level for the ADF test.
    
    Returns:
        bool: True if the spread is stationary, False otherwise.
    """
    result = adfuller(spread)
    p_value = result[1]

    if p_value <= significance_level:
        return True
    else:
        return False

def calculate_half_life(time_series):
    """
    Calculate the half-life of a mean-reverting time series.

    Args:
        time_series (numpy.ndarray or pandas.Series): The time series data.

    Returns:
        float: The estimated half-life.
    """

    if not isinstance(time_series, np.ndarray):
        time_series = np.array(time_series)

    delta_y = np.diff(time_series)

    X = sm.add_constant(time_series[:-1])

    model = sm.OLS(delta_y, X).fit()

    half_life = -np.log(2) / model.params[1]

    return half_life
