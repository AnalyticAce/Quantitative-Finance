import pandas as pd
from scipy.stats import pearsonr
from src.data.fetch_data import fetch_fx_data
import matplotlib.pyplot as plt
import numpy as np

def calculate_correlation(asset_symbol_1, asset_symbol_2, start_date, end_date, timeframe):

    asset_1 = fetch_fx_data(asset_symbol_1, start_date, end_date, timeframe)
    asset_2 = fetch_fx_data(asset_symbol_2, start_date, end_date, timeframe)

    closing_prices_asset_1 = asset_1["close"]
    closing_prices_asset_2 = asset_2["close"]

    correlation_coefficient, _ = pearsonr(closing_prices_asset_1, closing_prices_asset_2)

    return correlation_coefficient

def calculate_spread(closing_prices_asset_1, closing_prices_asset_2):

    if len(closing_prices_asset_1) != len(closing_prices_asset_2):
        raise ValueError("Input lists must have the same length")

    spread = [a - b for a, b in zip(closing_prices_asset_1, closing_prices_asset_2)]

    return spread

def calculate_zscore(spread):
    mean_spread = np.mean(spread)
    std_dev_spread = np.std(spread)
    
    z_scores = [(x - mean_spread) / std_dev_spread for x in spread]
    
    return z_scores