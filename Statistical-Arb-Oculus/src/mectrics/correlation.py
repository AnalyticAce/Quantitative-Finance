import pandas as pd
import numpy as np
from src.data.fetch_data import fetch_fx_data

asset_1 = fetch_fx_data("EURUSD", "2023-01-01", "2023-09-01", "daily")
asset_2 = fetch_fx_data("GBPUSD", "2023-01-01", "2023-09-01", "daily")

print(asset_2)