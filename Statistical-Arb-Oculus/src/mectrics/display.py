import pandas as pd
import numpy as np
from math import log
from scipy.stats import pearsonr
from matplotlib import pyplot
from statsmodels.tsa.stattools import adfuller
import statsmodels.api as sm

def calculate_spread(closing_prices_asset_1, closing_prices_asset_2):
    if len(closing_prices_asset_1) != len(closing_prices_asset_2):
        raise ValueError("Input lists must have the same length")
    
    returns_asset_1 = np.diff(closing_prices_asset_1) / closing_prices_asset_1[:-1]
    returns_asset_2 = np.diff(closing_prices_asset_2) / closing_prices_asset_2[:-1]

    spread = [a - b for a, b in zip(returns_asset_1, returns_asset_2)]

    return spread

def calculate_zscore(spread):
    mean_spread = np.mean(spread)
    std_dev_spread = np.std(spread)
    z_scores = [(x - mean_spread) / std_dev_spread for x in spread]
    
    return z_scores

df_1 = pd.read_csv("../../data/btc_usd.csv")
df_2 = pd.read_csv("../../data/eth_usd.csv")
asset_1 = pd.DataFrame(df_1)
asset_2 = pd.DataFrame(df_2)

closing_prices_asset_1 = asset_1["close"]
closing_prices_asset_2 = asset_2["close"]

spread = calculate_spread(closing_prices_asset_1, closing_prices_asset_2)

zscore = calculate_zscore(spread)

import streamlit as st

def show_graph(closing_prices_asset_1, closing_prices_asset_2):

    spread = calculate_spread(closing_prices_asset_1, closing_prices_asset_2)
    spread_chart = pd.DataFrame(spread)
    st.title("Spread Chart")
    st.line_chart(spread_chart, color=["#0000FF"])

def show_zcore(spread):

    zscore = calculate_zscore(spread)
    zscore_chart = pd.DataFrame(zscore)
    st.title("Zscore Chart")
    st.line_chart(zscore_chart, color=["#0000FF"])

show_graph(closing_prices_asset_1, closing_prices_asset_2)
show_zcore(spread)