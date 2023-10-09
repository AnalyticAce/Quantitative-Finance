import pandas as pd
import numpy as np
from math import log
from scipy.stats import pearsonr
import matplotlib.pyplot as plt
from statsmodels.tsa.stattools import adfuller
import statsmodels.tsa.stattools as ts
from typing import Tuple
import statsmodels.api as sm
import hurst

def calculate_correlation(closing_prices_asset_1: pd.Series, closing_prices_asset_2: pd.Series) -> float:
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

def calculate_cointegration(closing_prices_asset_1, closing_prices_asset_2) -> Tuple[bool, float]:
    """
    Perform the Engle-Granger cointegration test between two time series.

    Args:
        closing_prices_asset_1 (numpy.ndarray or pandas.Series): The first time series.
        closing_prices_asset_2 (numpy.ndarray or pandas.Series): The second time series.

    Returns:
        Tuple[bool, float]: (Cointegration result, p-value of the test).
    """
    if isinstance(closing_prices_asset_1, pd.Series):
        closing_prices_asset_1 = closing_prices_asset_1.values
    if isinstance(closing_prices_asset_2, pd.Series):
        closing_prices_asset_2 = closing_prices_asset_2.values

    result = sm.OLS(closing_prices_asset_1, sm.add_constant(closing_prices_asset_2)).fit()

    p_value = sm.tsa.adfuller(result.resid)[1]

    # Return True if cointegrated (p-value < 0.05)
    return p_value < 0.05, p_value

def calculate_spread(closing_prices_asset_1: pd.Series, closing_prices_asset_2: pd.Series) -> list:
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

def calculate_zscore(spread: list) -> list:
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

def hedge_ratio(closing_prices_asset_2: pd.Series, closing_prices_asset_1: pd.Series) -> float:
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

def is_stationary(spread: list, significance_level: float = 0.05) -> bool:
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

def calculate_half_life(time_series: np.ndarray or pd.Series) -> float:
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

def calculate_hurst_exponent(time_series: np.ndarray or pd.Series) -> float:
    """
    Calculate the Hurst exponent of a time series using the "hurst" library.

    Args:
        time_series (numpy.ndarray or pandas.Series): The time series data.

    Returns:
        float: The estimated Hurst exponent.
    """

    if not isinstance(time_series, np.ndarray):
        time_series = np.array(time_series)

    H, _, _ = hurst.compute_Hc(time_series, kind='change', simplified=True)

    return H
