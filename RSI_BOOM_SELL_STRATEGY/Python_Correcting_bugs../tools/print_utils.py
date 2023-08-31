from termcolor import colored
from playsound import playsound
from datetime import datetime

class TextColors:
    RESET = "\033[0m"
    GREEN = "\033[32m"
    RED = "\033[31m"
    YELLOW = "\033[33m"
    BLINK = "\033[5m"

def print_status(message, color = TextColors.RESET):
    print(f"{color}{message}{TextColors.RESET}")

class printer:

    def help():
        command = " python3 maverick_v3.py run"
        command_ = "python3 maverick_v3.py --telegram"
        command_t = "python3 maverick_v3.py --telecmd" # to be added as arg (Upcomming)
        
        message = (
            "Hey 🫠 Welcome to Mavery RSI Version 3.0.1\n"
            f"1. Run {command} to execute the program !\n"
            f"2. Run {command_} to receive telegram message when a trade is taken \n"
            f"3. Run {command_t} to see available telegram commands \n"
            "If you have any other questions or need further assistance, feel free to ask! Happy trading! 📈 \n"
        )

        playsound("../../Source/son/success.mp3")
        print(message)

    def command_t():
        
        message = (
            # To be completed
            "Hey 🫠 Welcome to Mavery RSI Version 4.0.1\n"
            "This are the available commands with the telegram bot\n"
            "1. `/total_trades`: Sends the total number of trades.\n"
            "2. `/profit_for_date YYYY-MM-DD`: Sends the profit for the given date (replace `YYYY-MM-DD` with the desired date).\n"
            "3. `/profit_for_period YYYY-MM-DD YYYY-MM-DD`: Sends the profit for the given period (replace both `YYYY-MM-DD` with the start and end dates of the desired period)\n"
            "                                     \n"
            "                                     \n"
            "Usage : \n"
            "In your Telegram chat with the bot, you can use the commands to get the desired information. For example:\n"
            "                                     \n"
            "- /total_trades\n"
            "- /profit_for_date 2023-08-01\n"
            "- /profit_for_period 2023-08-01 2023-08-15\n"
            "                                     \n"
            "If you have any other questions or need further assistance, feel free to ask! Happy trading! 📈\n"
        )

        playsound("../../Source/son/success.mp3")
        print(message)
        
    def print_ascii_art():
        try:
            with open("../../Source/text/ascii.txt", "r") as file:
                ascii_art = file.read()
                print(f"{TextColors.BLINK}{TextColors.GREEN}{ascii_art}{TextColors.RESET}")
        except FileNotFoundError:
            playsound("../../Source/son/error.mp3")
            print_status("ASCII art file not found.", color = "red")

    def print_trade_execution_details(symbol, result, current_balance, initial_balance):
        # Calculate return on investment (ROI) percentage
        roi_percentage = ((current_balance - initial_balance) / initial_balance) * 100

        roi_color = "🔴" if roi_percentage < 0 else "🟢"
        # Print trade execution details in a stylized manner
        playsound("../../Source/son/success.mp3")
        print(colored("===== Trade Executed 🚀 =====", "green"))
        print(colored(f"=====  SELL {symbol} 📈 =====", "red", attrs=["blink", "underline"]))
        print(colored(f"Date/Time: {datetime.now()} ⏰", "yellow", attrs=["blink", "underline"]))
        print(colored(f"Symbol: {symbol} 💱", "yellow"))
        print(colored(f"Price: {result.price}  💵", "yellow"))
        print(colored(f"Current Account Balance: ${current_balance} 💰", "yellow"))
        print(f"ROI since Initial Capital: {roi_color} {roi_percentage:.2f}%", color = "red" if roi_percentage < 0 else "green")
        print(colored("=============================", "green"))

    def print_trade_closed():
        playsound("../../Source/son/error.mp3")
        print(colored("===== Trade Closed ❌ =====", "red"))

    def print_waiting_message(sleep_duration):
        print(colored(f"Waiting for {sleep_duration} seconds before checking again...🧘🧘🧘"), "red")



import MetaTrader5 as mt5
import pandas as pd
import ta.momentum as momentum
from datetime import datetime
import time
from Strategy.tools.print_utils import printer, print_status
import telebot
from sys import *
from secret import credentials # add manually you API info

telegram_token = credentials.YOUR_TELEGRAM_TOKEN

bot = telebot.TeleBot(telegram_token)

def get_historical_data(symbol, timeframe, number_of_data=1000):
    if not mt5.initialize():
        print_status("initialize() failed ☢️", color = "red")
        mt5.shutdown()
        return None

    rates = mt5.copy_rates_from_pos(symbol, timeframe, 0, number_of_data)

    if rates is None:
        print_status("Failed to retrieve historical data. ☢️", color = "red")
        mt5.shutdown()
        return None

    df = pd.DataFrame(rates)
    df["time"] = pd.to_datetime(df["time"], unit="s")
    df = df.set_index("time")

    mt5.shutdown()

    return df

def calculate_rsi(df, period=14):
    try:
        rsi_indicator = momentum.RSIIndicator(df["close"], window=period)
        df["rsi"] = rsi_indicator.rsi()
    except Exception as e:
        print_status(f"Error calculating RSI: {e}", color = "red")

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
            printer.print_trade_closed()
            break

    return i

def execute_sell_trade(df, symbol, lot_size=0.2):
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
            account_info = mt5.account_info()
            current_balance = account_info.balance

            roi_percentage = ((current_balance - initial_balance) / initial_balance) * 100
            printer.print_trade_execution_details(symbol, result, current_balance, roi_percentage)
            roi_color = "🔴" if roi_percentage < 0 else "🟢"

            if telegram_enabled:
                telegram_message = (
                    f'<b>Trade Executed 🚀</b>\n\n'
                    f'<b>SELL {symbol} 📈</b>\n\n'
                    f'<i>Date/Time: {datetime.now()} ⏰</i>\n\n'
                    f'<b>Symbol: {symbol} 💱</b>\n'
                    f'<b>Price: {result.price}  💵</b>\n'
                    f'<b>Current Account Balance: ${current_balance} 💰</b>\n\n'
                    f'<b>ROI since Initial Capital:</b> {roi_color}<b>{roi_percentage:.2f}%</b>\n\n'
                )
                bot.send_message(credentials.CHAT_ID, telegram_message, parse_mode="HTML")

            while True:
                new_bar = get_historical_data(symbol, mt5.TIMEFRAME_M1, 1)
                if new_bar is not None:
                    if new_bar.iloc[0]["close"] < new_bar.iloc[0]["open"]:
                        break
                    time.sleep(1)
            printer.print_trade_closed()
        else:
            print_status(f"Error executing the trade", color="red")


def run_strategy(symbol, timeframe, lot_size=0.2, data_length=1000, period=14):
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

    lot_size = 0.2

    initial_capital = 10.0
    account_info = mt5.account_info()
    current_balance = account_info.balance

    data_length = 1000
    period = 14

    telegram_enabled = False
    
    if len(argv) > 1:
        if argv[1] == "--telegram":
            telegram_enabled = True
        elif argv[1] == "--help":
            printer.help()
        elif argv[1] == "--telecmd":
            printer.command_t()
        elif argv[1] == "--run":
            printer.print_ascii_art()
            run_strategy(symbol, timeframe, lot_size, data_length, period)
        else:
            printer.help()
    else:
        printer.help()
