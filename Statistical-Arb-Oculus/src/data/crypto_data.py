import ccxt
import pandas as pd
from secret import binance

symbol = "BTC/USDT"
timeframe = "15m"
limit = 1000

def fetch_crypto_data(symbol, timeframe, limit):
        
    binance = ccxt.binance({
        "enabledRateLimit" : True,
        "apiKey": "0phrfi8fe83w2IRtumAvYaTWzh43MiGwGyePDxZx9HCWloEUUpuMzTLOWlclxK9y",
        "secret" : "2uY1G46lIg8abkslJsOrVLYOIqFSv1OP0PSKkuRm05e6HALefCpZGhXBQZuyYQIz"
    })

    bars = binance.fetch_ohlcv(symbol, timeframe = timeframe, limit = limit)

    df = pd.DataFrame(bars, columns=["timestamp", "open", "high", "low", "close", "volume"])

    df["timestamp"] = pd.to_datetime(df["timestamp"], unit="ms")

    return df[["timestamp", "close"]]