import ccxt
import pandas as pd
import matplotlib.pyplot as plt
import pandas as pd
import tradermade as tm

def fetch_crypto_data(symbol, timeframe, limit):
    
    binance = ccxt.binance({
        "enabledRateLimit": True,
        "apiKey": "0phrfi8fe83w2IRtumAvYaTWzh43MiGwGyePDxZx9HCWloEUUpuMzTLOWlclxK9y",
        "secret": "2uY1G46lIg8abkslJsOrVLYOIqFSv1OP0PSKkuRm05e6HALefCpZGhXBQZuyYQIz"
    })

    bars = binance.fetch_ohlcv(symbol, timeframe=timeframe, limit=limit)

    df = pd.DataFrame(bars, columns=["timestamp", "open", "high", "low", "close", "volume"])

    df["timestamp"] = pd.to_datetime(df["timestamp"], unit="ms")

    return df

def fetch_fx_data(symbol, start_date, end_date, timeframe):
    
    tm.set_rest_api_key("PQgteXR13COKO54qQXdH")
    
    data = tm.timeseries(
        currency = symbol,  # 'symbol' appears to be a DataFrame object
        start = start_date, 
        end = end_date, 
        interval = timeframe,
        fields=["open", "high", "low", "close"]
    )
    df = pd.DataFrame(data)
    return df


#forex_symbol = "EURUSD"
#forex_start_date = "2023-01-01"
#forex_end_date = "2023-09-01"
#forex_timeframe = "daily"
#forex_data = fetch_fx_data(forex_symbol, forex_start_date, forex_end_date, forex_timeframe)
#print(forex_data.head())