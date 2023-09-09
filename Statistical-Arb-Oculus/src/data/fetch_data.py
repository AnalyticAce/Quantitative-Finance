import ccxt
import pandas as pd
import matplotlib.pyplot as plt
import pandas as pd
import tradermade as tm

def fetch_crypto_data(symbol, timeframe, limit):
    # Create a Binance instance
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
    
    # print the type of symbol
    print(type(symbol))
    
    # pass symbol as it is
    data = tm.timeseries(
        currency = symbol,
        start = start_date, 
        end = end_date, 
        interval = timeframe,
        fields=["open", "high", "low", "close"]
    )
    #df = pd.DataFrame(data)
    
    # assign a value to currency
    currency = symbol
    
    # print the type of currency
    print(type(currency))
    
    # use str.split() method on currency
    data = currency.str.split(",")
    
    return data

#fetch_crypto_data("BTC/USD", "1d", 200)
fetch_crypto_data("ETH/USD", "1d", 200)
#forex_symbol = "EURUSD"
#forex_start_date = "2023-01-01"
#forex_end_date = "2023-09-01"
#forex_timeframe = "daily"
#forex_data = fetch_fx_data(forex_symbol, forex_start_date, forex_end_date, forex_timeframe)
#print(forex_data.head())