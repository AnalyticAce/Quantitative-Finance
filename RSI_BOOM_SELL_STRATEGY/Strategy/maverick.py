import MetaTrader5 as mt5
import pandas as pd
import ta.momentum as momentum
from datetime import datetime, timedelta
import time 

def get_historical_data(symbol, timeframe, number_of_data = 1000):
    # Initialize the MetaTrader 5 terminal
    if not mt5.initialize():
        print("initialize() failed")
        mt5.shutdown()
        return None

    # Retrieve historical data from MetaTrader 5
    rates = mt5.copy_rates_from_pos(symbol, timeframe, 0, number_of_data)

    # Check if data is retrieved successfully
    if rates is None:
        print("Failed to retrieve historical data.")
        mt5.shutdown()
        return None

    # Transform tuples into a DataFrame
    df = pd.DataFrame(rates)
    df["time"] = pd.to_datetime(df["time"], unit= "s")
    df = df.set_index("time")

    # Shutdown the MetaTrader 5 terminal
    mt5.shutdown()

    return df

def calculate_rsi(df, period = 14):
    try:
        # Use 'window' instead of 'n'
        rsi_indicator = momentum.RSIIndicator(df["close"], window = period)
        df["rsi"] = rsi_indicator.rsi()
    except Exception as e:
        print("Error calculating RSI:", str(e))

def execute_sell_trade(df, symbol, lot_size = 0.2):
    # Get the last row (most recent bar) from the historical data
    current_bar = df.iloc[-1]
    previous_bar = df.iloc[-2]
    
    # Check if RSI is greater than 70 (overbought) and the current close 
    # is lower than the open of the current bar, and the previous close
    # was higher than the open of the previous bar
    if current_bar["rsi"] > 70 and current_bar["close"] < current_bar["open"] \
    and previous_bar["close"] > previous_bar["open"]:
        # Initialize the MetaTrader 5 terminal
        if not mt5.initialize():
            print("initialize() failed")
            mt5.shutdown()
            return

        # Execute a sell trade
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
        print("Sell Trade Executed:", result.comment)

        # Shutdown the MetaTrader 5 terminal
        mt5.shutdown()

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
            break
    return i

def run_strategy(symbol, timeframe, lot_size=0.1, data_length = 1000, period = 14):
    while True:
        try:
            # Retrieve historical data
            df = get_historical_data(symbol, timeframe, data_length)

            # Check if the historical data is retrieved successfully
            if df is not None:
                # Calculate RSI
                calculate_rsi(df, period)
                
                # Execute sell trade if conditions are met
                execute_sell_trade(df, symbol, lot_size)

        except Exception as e:
            print("Error executing the strategy:", str(e))

        # Wait for some time before checking for opportunities again
        # Adjust the sleep duration as per your preference (in seconds)
        sleep_duration = 60  # Wait for 1 minute
        print(f"Waiting for {sleep_duration} seconds before checking again...")
        time.sleep(sleep_duration)

# Example usage:
if __name__ == "__main__":
    symbol = "Boom 1000 Index" # Replace with your desired symbol
    timeframe = mt5.TIMEFRAME_M1  # Replace with your desired timeframe
    lot_size = 0.2  # Replace with your desired lot size
    data_length = 1000  # Replace with the number of data points to retrieve
    period = 14  # Replace with the RSI period

    run_strategy(symbol, timeframe, lot_size, data_length, period)