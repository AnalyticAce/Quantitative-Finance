import ccxt
import pandas as pd
import matplotlib.pyplot as plt
import pandas as pd
import tradermade as tm

def fetch_crypto_data(symbol, timeframe, limit):
    binance = ccxt.binance()

    try:
        bars = binance.fetch_ohlcv(symbol, timeframe=timeframe, limit=limit)

        df = pd.DataFrame(bars, columns=["timestamp", "open", "high", "low", "close", "volume"])
        df["timestamp"] = pd.to_datetime(df["timestamp"], unit="ms")

        return df.to_csv('../../data/eth_usd.csv')

    except ccxt.NetworkError as e:
        print(f"NetworkError: {e}")
    except ccxt.ExchangeError as e:
        print(f"ExchangeError: {e}")
    except Exception as e:
        print(f"Error: {e}")

    return None

def fetch_fx_data(symbol, start_date, end_date, timeframe):
    
    tm.set_rest_api_key("PQgteXR13COKO54qQXdH")
    
    print(type(symbol))
    
    data = tm.timeseries(
        currency = symbol,
        start = start_date, 
        end = end_date, 
        interval = timeframe,
        fields=["open", "high", "low", "close"]
    )

    currency = symbol
    
    print(type(currency))

    data = currency.str.split(",")
    
    return data