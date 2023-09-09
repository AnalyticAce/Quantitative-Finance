import pandas as pd
import numpy as np
from math import log
from scipy.stats import pearsonr
import matplotlib.pyplot as plt
from statsmodels.tsa.stattools import adfuller
import statsmodels.api as sm

def calculate_correlation(symbol_1, symbol_2):
    """
    Calculate the correlation coefficient between two assets.
    
    Args:
        symbol_1 (str): CSV file path for the first asset's data.
        symbol_2 (str): CSV file path for the second asset's data.
    
    Returns:
        float: The correlation coefficient between the closing prices of the two assets.
    """
    asset_1 = pd.DataFrame(pd.read_csv(symbol_1))
    asset_2 = pd.DataFrame(pd.read_csv(symbol_2))

    closing_prices_asset_1 = asset_1["close"]
    closing_prices_asset_2 = asset_2["close"]

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


df_1 = pd.read_csv("../../data/btc_usd.csv")
df_2 = pd.read_csv("../../data/eth_usd.csv")
asset_1 = pd.DataFrame(df_1)
asset_2 = pd.DataFrame(df_2)

closing_prices_asset_1 = asset_1["close"]
closing_prices_asset_2 = asset_2["close"]

spread = calculate_spread(closing_prices_asset_1, closing_prices_asset_2)

is_stationary_result = is_stationary(spread)

if is_stationary_result:
    print("The spread is stationary.")
else:
    print("The spread is not stationary.")

z_scores = calculate_zscore(spread)
print("Z-Scores:", z_scores)

hedge_r = hedge_ratio(closing_prices_asset_2, closing_prices_asset_1)
print(f"Hedge Ratio: {hedge_r:.2f}")
