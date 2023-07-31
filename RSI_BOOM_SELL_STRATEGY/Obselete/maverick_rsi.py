import MetaTrader5 as mt5
import os
import pandas as pd
import time
import ta
from secret import credentials

class TextColors:
    RESET = "\033[0m"
    GREEN = "\033[32m"
    RED = "\033[31m"
    YELLOW = "\033[33m"
    BLINK = "\033[5m"

def print_status(message, color=TextColors.RESET):
    print(f"{color}{message}{TextColors.RESET}")

def print_ascii_art():
    try:
        with open("ascii.txt", "r") as file:
            ascii_art = file.read()
            print(f"{TextColors.BLINK}{TextColors.GREEN}{ascii_art}{TextColors.RESET}")
    except FileNotFoundError:
        print_status("ASCII art file not found.", TextColors.RED)

# RSI sell strategy function
def rsi_sell_strategy(symbol, timeframe, lot_size):
    if not mt5.initialize():
        print_status("Failed to connect to MetaTrader 5!", TextColors.RED)
        return

    login_result = mt5.login(
        credentials.ACCOUNT_NUMBER,
        password = credentials.ACCOUNT_PASSWORD,
        server = credentials.SERVER_NAME
    )

    if login_result:
        print_status("Connected to MetaTrader 5 account", TextColors.GREEN)

    else:
        print_status("Failed to login. Check your credentials and server.", TextColors.RED)
        mt5.shutdown()
        return

    rates = mt5.copy_rates_from(symbol, timeframe, 0, 1000)
    df = pd.DataFrame(rates)
    df['time'] = pd.to_datetime(df['time'], unit='s')
    df.set_index('time', inplace=True)
    df['rsi'] = ta.momentum.RSIIndicator(df['close']).rsi()

    sell_position = None
    trade_count = 0

    for i in range(2, len(df)):

        if df['rsi'][i] > 70 and df['close'][i - 1] < df['open'][i - 1] and df['close'][i - 2] > df['open'][i - 2]:

            if not sell_position:
                # Open a sell trade
                stop_loss_price = df['open'][i - 1]  # Stop loss at the open price of the previous candle
                take_profit_price = df['close'][i]  # Take profit at the close price of the current candle

                sell_position = mt5.OrderSend(
                    symbol = symbol,
                    action = mt5.ORDER_SELL,
                    volume = lot_size, price=df['close'][i],
                    stoploss = stop_loss_price,
                    takeprofit = take_profit_price,
                    type = mt5.ORDER_MARKET
                )

                if sell_position:
                    print_status("Sell trade opened.", TextColors.GREEN)
                    trade_count += 1

                else:
                    print_status("Failed to open sell trade.", TextColors.RED)

                time.sleep(1)

        elif sell_position:
            result = mt5.OrderClose(sell_position)

            if result:
                print_status("Sell trade closed.", TextColors.RED)

            else:
                print_status("Failed to close sell trade.", TextColors.RED)
            sell_position = None

            time.sleep(1)

    mt5.shutdown()
    print_status(f"Strategy execution completed. Total trades executed: {trade_count}", TextColors.YELLOW)

# Main program
if __name__ == "__main__":
    symbol = ["BOOM300", "BOOM500", "BOOM1000"]
    timeframe = mt5.TIMEFRAME_M1
    lot_size = 1
    print_ascii_art()
    rsi_sell_strategy(symbol, timeframe, lot_size)