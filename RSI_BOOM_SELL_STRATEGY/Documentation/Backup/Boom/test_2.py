import MetaTrader5 as mt5
import pandas as pd
import ta.momentum as momentum
from datetime import datetime, timedelta
import time

def get_historical_data(symbol, timeframe, number_of_data):
    
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

def calculate_rsi(df, period):

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

import threading

def close_trade_after_duration(symbol, duration):
    # Define a function to close the trade after the specified duration
    def close_trade():
        time.sleep(60)  # Wait for the specified duration
        if not mt5.initialize():
            print("initialize() failed ☢️")
            mt5.shutdown()
            return
        
        # Close the trade (you should implement the logic to close the trade here)
        # For demonstration purposes, let's print a message.
        print("Trade closed after", duration, "seconds")
        
        mt5.shutdown()

    # Create a new thread to handle the trade closure
    close_thread = threading.Thread(target=close_trade)
    close_thread.start()  # Start the thread

def execute_sell_trade(df, symbol, lot_size, duration):

    current_bar = df.iloc[-1]
    previous_bar = df.iloc[-2]
    confirmation_bar = df.iloc[-3]

    if current_bar["rsi"] > 70 and confirmation_bar["close"] > confirmation_bar["open"] \
            and previous_bar["close"] < previous_bar["open"] \
            and current_bar["close"] < current_bar["open"]:

        if not mt5.initialize():
            print("initialize() failed ☢️")
            mt5.shutdown()
            return

        entry_price = mt5.symbol_info_tick(symbol).bid

        request = {
            "action": mt5.TRADE_ACTION_DEAL,
            "symbol": symbol,
            "volume": lot_size,
            "type": mt5.ORDER_TYPE_SELL,
            "price": entry_price,
            "deviation": 0,
            "magic": 0,
            "comment": "RSI Sell Strategy",
            "type_filling": find_filling_mode(symbol),
            "type_time": mt5.ORDER_TIME_GTC,
        }

        result = mt5.order_send(request)

        mt5.shutdown()

        if result.comment == "Accepted":
            print("Sell executed")
            # Close the trade after the specified duration
            close_trade_after_duration(symbol, 60)
        else:
            print("Error executing the trade")


def run_strategy(symbol, timeframe, lot_size, data_length, period):
    
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
    lot_size = 1.0
    data_length = 500
    period = 7

    run_strategy(symbol, timeframe, lot_size, data_length, period)
