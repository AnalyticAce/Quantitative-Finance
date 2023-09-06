import pandas as pd
import matplotlib.pyplot as plt
from src.data.fetch_data import fetch_fx_data

# Define the assets in the pair
asset_symbol_1 = "EURUSD"
asset_symbol_2 = "USDJPY"
start_date = "2023-01-01"
end_date = "2023-09-01"
timeframe = "daily"

# Fetch data for asset 1 and asset 2
asset_1 = fetch_fx_data(asset_symbol_1, start_date, end_date, timeframe)
asset_2 = fetch_fx_data(asset_symbol_2, start_date, end_date, timeframe)

# Extract the closing prices and dates
closing_prices_asset_1 = asset_1["close"]
closing_prices_asset_2 = asset_2["close"]
dates = asset_1["date"]  # Assuming both assets have the same date index

# Create a figure with two y-axes
fig, ax1 = plt.subplots(figsize=(12, 6))
ax2 = ax1.twinx()  # Create a secondary y-axis

# Plot closing prices of asset 1 in blue on the primary y-axis
ax1.plot(dates, closing_prices_asset_1, label=f"{asset_symbol_1} Closing Price", color="blue")

# Plot closing prices of asset 2 in orange on the secondary y-axis
ax2.plot(dates, closing_prices_asset_2, label=f"{asset_symbol_2} Closing Price", color="orange")

# Set labels for the y-axes
ax1.set_ylabel(f"{asset_symbol_1} Price", color="blue")
ax2.set_ylabel(f"{asset_symbol_2} Price", color="orange")

plt.title(f"{asset_symbol_1} vs {asset_symbol_2} Closing Prices")
plt.xlabel("Date")
plt.grid(True)

# Display the plot
plt.tight_layout()
plt.show()
