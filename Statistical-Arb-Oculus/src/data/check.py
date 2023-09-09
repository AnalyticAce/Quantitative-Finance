import ccxt
import pandas as pd

def fetch_crypto_data(symbol, timeframe, limit):
    # Create a Binance instance
    binance = ccxt.binance({
        "enabledRateLimit": True,
        "apiKey": "YourApiKeyHere",  # Replace with your API key
        "secret": "YourApiSecretHere"  # Replace with your API secret
    })

    try:
        bars = binance.fetch_ohlcv(symbol, timeframe=timeframe, limit=limit)

        if bars is not None:
            df = pd.DataFrame(bars, columns=["timestamp", "open", "high", "low", "close", "volume"])
            df["timestamp"] = pd.to_datetime(df["timestamp"], unit="ms")
            return df
        else:
            print("Failed to fetch data from the Binance API.")
    except ccxt.NetworkError as e:
        print(f"NetworkError: {e}")
    except ccxt.ExchangeError as e:
        print(f"ExchangeError: {e}")
    except Exception as e:
        print(f"Error: {e}")

    return None

# Example usage:
symbol = "BTC/USDT"
timeframe = "1h"
limit = 100
crypto_data = fetch_crypto_data(symbol, timeframe, limit)

if crypto_data is not None:
    closing_prices_asset_1 = crypto_data["close"]
    print(closing_prices_asset_1.head())
else:
    # Handle the case when data retrieval fails
    print("Data retrieval failed. Check your API credentials and network connection.")
