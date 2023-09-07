import pandas as pd
import numpy as np
from math import log
from scipy.stats import pearsonr
import matplotlib.pyplot as plt
from src.data.fetch_data import fetch_fx_data
#from statsmodels.regression.linear_model import OLS
from statsmodels.tsa.stattools import adfuller
import statsmodels.api as sm


# Function to calculate the correlation coefficient
def calculate_correlation(asset_symbol_1, asset_symbol_2, start_date, end_date, timeframe):
    asset_1 = fetch_fx_data(asset_symbol_1, start_date, end_date, timeframe)
    asset_2 = fetch_fx_data(asset_symbol_2, start_date, end_date, timeframe)

    closing_prices_asset_1 = asset_1["close"]
    closing_prices_asset_2 = asset_2["close"]

    correlation_coefficient, _ = pearsonr(closing_prices_asset_1, closing_prices_asset_2)

    return correlation_coefficient

# Function to calculate the spread between two assets
def calculate_spread(closing_prices_asset_1, closing_prices_asset_2):
    if len(closing_prices_asset_1) != len(closing_prices_asset_2):
        raise ValueError("Input lists must have the same length")

    spread = [log(a) - log(b) for a, b in zip(closing_prices_asset_1, closing_prices_asset_2)]

    return spread

# Function to calculate the Z-score
def calculate_zscore(spread):
    mean_spread = np.mean(spread)
    std_dev_spread = np.std(spread)
    z_scores = [(x - mean_spread) / std_dev_spread for x in spread]
    
    return z_scores

# Function to calculate hedge ratio
def hedge_ratio(closing_prices_asset_2, closing_prices_asset_1):
    
    closing_prices_asset_1 = sm.add_constant(closing_prices_asset_1)
    model = sm.OLS(closing_prices_asset_2, closing_prices_asset_1).fit()

    return model.params[1]

# t-stat value =  -3.3175906010162217
# {'1%': -3.4381962830171444, '5%': -2.8650034233058093, '10%': -2.568614210583549}
# Since the t-stat value is below the critical value at 5%, the spread is considered stationary or cointegrated.

def is_stationary(spread, significance_level = 0.05):

    result = adfuller(spread)
    
    p_value = result[1]
    
    if p_value <= significance_level:
        return True
    else:
        return False 

"""
Half-life indicates how long the spread typically takes to revert back to the mean. 
A half-life of 10 days for example indicates that this pair typically takes 10 days to revert.
"""

def half_life(spread):
    
    spread_lag = spread.shift(1)
    spread_lag.ix[0] = spread_lag.ix[1]

    s_ret = spread - spread_lag
    s_ret.ix[0] = s_ret.ix[1]

    spread_lag2 = sm.add_constant(spread_lag)

    model = sm.OLS(s_ret, spread_lag2)
    res = model.fit()

    halflife = round(-np.log(2) / res.params[1],0)
    
    return halflife

"""
Hurst Exponent:
The Hurst exponent mainly helps us determine whether a time series is mean reverting or not. 
The outputted value H from the Hurst formula is some value between 0 and 1.

H < 0.5 — The time series is mean reverting (Sideways)
H = 0.5 — The time series is a Geometric Brownian Motion (Random Walk)
H > 0.5 — The time series is trending (Trending)
"""

#def hurst_exponent():


asset_symbol_1 = "EURUSD"
asset_symbol_2 = "AUDCAD"
start_date = "2023-01-01"
end_date = "2023-09-01"
timeframe = "daily"

asset_1 = fetch_fx_data(asset_symbol_1, start_date, end_date, timeframe)
asset_2 = fetch_fx_data(asset_symbol_2, start_date, end_date, timeframe)
print(asset_1)
print(asset_2)
closing_prices_asset_1 = asset_1["close"]
closing_prices_asset_2 = asset_2["close"]

correlation = calculate_correlation(asset_1, asset_2, start_date, end_date, timeframe)
print("Correlation Coefficient:", correlation)

spread = calculate_spread(closing_prices_asset_1, closing_prices_asset_2)
print("Spread:", spread)

is_stationary_result = is_stationary(spread)

if is_stationary_result:
    print("The spread is stationary.")
else:
    print("The spread is not stationary.")

#z_scores = calculate_zscore(spread)
#print("Z-Scores:", z_scores)

#hedge_r = hedge_ratio(closing_prices_asset_2, closing_prices_asset_1)
#print("Hedge Ration:", hedge_r)