import MetaTrader5 as mt5
import pandas as pd
import ta.momentum as momentum
from datetime import datetime
import time

def get_historical_data(symbol, timeframe, number_of_data=1000):
    
    """
    Fetches historical OHLCV (Open, High, Low, Close, Volume) data for a specific trading symbol.

    Parameters:
        symbol (str): The trading symbol to retrieve historical data.
        timeframe (int): The timeframe for historical data, e.g., mt5.TIMEFRAME_M1 for 1-minute data.
        number_of_data (int, optional): The number of historical data points to fetch. Default is 1000.

    Returns:
        pd.DataFrame: DataFrame containing historical OHLCV data. The DataFrame has columns:
                      'time', 'open', 'high', 'low', 'close', and 'tick_volume'.
    """
    
    if not mt5.initialize():
        print("initialize() failed ☢️")
        mt5.shutdown()
        return None

    rates = mt5.copy_rates_from_pos(symbol, timeframe, 0, number_of_data)

    if rates is None:
        print("Failed to retrieve historical data. ☢️")
        mt5.shutdown()
        return None

    df = pd.DataFrame(rates)
    df["time"] = pd.to_datetime(df["time"], unit="s")
    df = df.set_index("time")

    mt5.shutdown()

    return df

def calculate_rsi(df, period=14):

     """
    Calculates the Relative Strength Index (RSI) for a given DataFrame.

    Parameters:
        df (pd.DataFrame): DataFrame containing the 'close' price column.
        period (int, optional): The period for RSI calculation. Default is 14.

    Returns:
        None
    """
    
    try:
        rsi_indicator = momentum.RSIIndicator(df["close"], window=period)
        df["rsi"] = rsi_indicator.rsi()
    except Exception as e:
        print(f"Error calculating RSI: {e}")

def find_filling_mode(symbol):

    for i in range(2):

        request = {
            "action": mt5.TRADE_ACTION_DEAL,
            "symbol": symbol,
            "volume": mt5.symbol_info(symbol).volume_min,
            "type": mt5.ORDER_TYPE_BUY,
            "price": mt5.symbol_info_tick(symbol).ask,
            "type_filling": i,
            "type_time": mt5.ORDER_TIME_GTC
        }

        result = mt5.order_check(request)

        if result.comment == "Done":
            print("Trade was closed")
            break

    return i

def execute_sell_trade(df, symbol, lot_size=0.2):

    """
    Executes the RSI sell trade based on the given strategy conditions.

    Parameters:
        df (pd.DataFrame): DataFrame containing historical data, including RSI values.
        symbol (str): The trading symbol to execute the sell trade.
        lot_size (float, optional): The lot size for the sell trade. Default is 0.2.

    Returns:
        None
    """
    
    current_bar = df.iloc[-1]
    previous_bar = df.iloc[-2]
    confirmation_bar = df.iloc[-3]

    # Check for sell conditions
    if current_bar["rsi"] > 70 and confirmation_bar["close"] > confirmation_bar["open"] \
            and previous_bar["close"] < previous_bar["open"] \
            and current_bar["close"] < current_bar["open"]:

        if not mt5.initialize():
            print("initialize() failed ☢️")
            mt5.shutdown()
            return

        # Execute the trade on the next red candle (Candle 3 in the description)
        request = {
            "action": mt5.TRADE_ACTION_DEAL,
            "symbol": symbol,
            "volume": lot_size,
            "type": mt5.ORDER_TYPE_SELL,
            "price": mt5.symbol_info_tick(symbol).bid,
            "deviation": 10,
            "magic": 0,
            "comment": "RSI Sell Strategy",
            "type_filling": find_filling_mode(symbol),
            "type_time": mt5.ORDER_TIME_GTC
        }

        result = mt5.order_send(request)

        mt5.shutdown()

        if result.comment == "Accepted":
            print("Sell executed")
            # Wait for the trade to close (at the close of the second red candle)
            while True:
                new_bar = get_historical_data(symbol, mt5.TIMEFRAME_M1, 1)
                if new_bar is not None:
                    if new_bar.iloc[0]["close"] < new_bar.iloc[0]["open"]:
                        break
                    time.sleep(1)
            print("Trade closed")
        else:
            print("Error executing the trade")


def run_strategy(symbol, timeframe, lot_size=0.2, data_length=1000, period=14):
    
    """
    Runs the RSI sell strategy on historical data for the specified symbol.

    Parameters:
        symbol (str): The trading symbol to be used.
        timeframe (int): The timeframe for historical data, e.g., mt5.TIMEFRAME_M1 for 1-minute data.
        lot_size (float, optional): The lot size for the sell trades. Default is 0.2.
        data_length (int, optional): The number of historical data points to fetch. Default is 1000.
        period (int, optional): The period for RSI calculation. Default is 14.

    Returns:
        None
    """
    
    while True:

        try:
            df = get_historical_data(symbol, timeframe, data_length)

            if df is not None:
                calculate_rsi(df, period)

                execute_sell_trade(df, symbol, lot_size)

        except Exception as e:
            print(f"Error executing the strategy: {e}")

        sleep_duration = 60
        print("Waiting for a new opportunity")
        time.sleep(sleep_duration)

if __name__ == "__main__":

    symbol = "Boom 1000 Index"
    timeframe = mt5.TIMEFRAME_M1

    lot_size = 0.5

    data_length = 1000
    period = 14

    run_strategy(symbol, timeframe, lot_size, data_length, period)
