import MetaTrader5 as mt5
import pandas as pd
import ta.momentum as momentum
from Strategy.tools.print_utils import printer, print_status
from datetime import datetime
import telebot
import time
from secret import credentials

telegram_token = credentials.YOUR_TELEGRAM_TOKEN
bot = telebot.TeleBot(telegram_token)

def get_historical_data(symbol, timeframe, number_of_data = 1000):

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
    df["time"] = pd.to_datetime(df["time"], unit = "s")
    df = df.set_index("time")

    mt5.shutdown()

    return df

def calculate_rsi(df, period=14):
    try:
        rsi_indicator = momentum.RSIIndicator(df["close"], window = period)
        df["rsi"] = rsi_indicator.rsi()
    except Exception as e:
        print_status(f"Error calculating RSI: {e}", color = "red")

def execute_sell_trade(df, symbol, lot_size = 0.2, initial_balance = 10.0):
    current_bar = df.iloc[-1]
    previous_bar = df.iloc[-2]

    if current_bar["rsi"] > 70 and current_bar["close"] < current_bar["open"] \
        and previous_bar["close"] > previous_bar["open"]:

        if not mt5.initialize():
            print_status("initialize() failed ☢️", color = "red")
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

            telegram_message = (
                f'<b><font color="#00FF00">Trade Executed 🚀</font></b>\n'
                f'<b><font color="#FF0000">SELL {symbol} 📈</font></b>\n'
                f'<i><font color="#FFFF00">Date/Time: {datetime.now()} ⏰</font></i>\n'
                f'<b>Symbol: {symbol} 💱</b>\n'
                f'<b>Price: {result.price}  💵</b>\n'
                f'<b>Current Account Balance: ${current_balance} 💰</b>\n'
                f'<b>ROI since Initial Capital:</b> <font color="{roi_color}"><b>{roi_percentage:.2f}%</b></font>\n'
            )

            bot.send_message(credentials.CHAT_ID, telegram_message, parse_mode="HTML")

        else:
            printer.print_trade_closed()

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

def run_strategy(symbol, timeframe, lot_size = 0.2, data_length = 1000, period = 14):
    while True:
        try:
            df = get_historical_data(symbol, timeframe, data_length)

            if df is not None:
                calculate_rsi(df, period)
                
                execute_sell_trade(df, symbol, lot_size)

        except Exception as e:
            print_status(f"Error executing the strategy: {e}", color="red")

        sleep_duration = 60
        printer.print_waiting_message(sleep_duration)
        time.sleep(sleep_duration)


if __name__ == "__main__":
    symbol = "Boom 1000 Index"
    timeframe = mt5.TIMEFRAME_M1

    lot_size = 0.2

    initial_capital = 10.0
    account_info = mt5.account_info()
    current_balance = account_info.balance

    multiplier = current_balance // initial_capital
    lot_size += multiplier * 0.2

    data_length = 1000
    period = 14

    printer.print_ascii_art()
    run_strategy(symbol, timeframe, lot_size, data_length, period)
