import MetaTrader5 as mt5
import pandas as pd
import ta.momentum as momentum
import time

#close trade 59 sec later

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
            print("Trade is closed")
            break
    return i

def execute_sell_trade(df, symbol, lot_size):
    current_bar = df.iloc[-1]
    previous_bar = df.iloc[-2]
    confirmation_bar = df.iloc[-3]

    # Check for sell conditions
    if current_bar["rsi"] > 70 and confirmation_bar["close"] > confirmation_bar["open"] \
            and previous_bar["close"] < previous_bar["open"] \
            and current_bar["close"] < current_bar["open"]:

        print("We are inside the condition")
        
        print("initializing mt5")

        if not mt5.initialize():
            print("initialize() failed ☢️")
            mt5.shutdown()
            return

        print("end of mt5 initialization")

        print("This is before the request")

        # Execute the trade
        request = {
            "action": mt5.TRADE_ACTION_DEAL,
            "symbol": symbol,
            "volume": lot_size,
            "type": mt5.ORDER_TYPE_SELL,
            "price": mt5.symbol_info_tick(symbol).bid,
            "deviation": 0,
            "magic": 0,
            "comment": "RSI Sell Strategy",
            "type_filling": find_filling_mode(symbol),
            "type_time": mt5.ORDER_TIME_GTC
        }

        print("This is after the request")

        result = mt5.order_send(request)
        
        print("This is after the request as been sent the request")

        if result.comment == "Accepted":

            print("We are inside the close condition")
            
            print("Sell executed") 
            
            time.sleep(59)  # Close the trade after 59 seconds

            print("After sleep time")

            # Close the trade
            close_price = mt5.symbol_info_tick(symbol).ask
            
            print("This is before the close trade request")

            request_close = {
                "action": mt5.TRADE_ACTION_DEAL,
                "symbol": symbol,
                "volume": lot_size,
                "type": mt5.ORDER_TYPE_BUY,
                "price": close_price,
                "deviation": 0,
                "magic": 0,
                "comment": "Close Trade",
                "type_filling": find_filling_mode(symbol),
                "type_time": mt5.ORDER_TIME_GTC
            }

            print("This is after the close trade request")

            result_close = mt5.order_send(request_close)

            print("This is after the close trade request as been sent")

            if result_close.comment == "Accepted":
                print("Trade closed after 59 seconds")
            else:
                print("Error closing the trade")
            
        else:
            print("Error executing the trade")

        mt5.shutdown()

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
