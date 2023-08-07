import datetime
from sys import *
import telebot

class credentials:
    YOUR_TELEGRAM_TOKEN = "YOUR_TELEGRAM_API_KEY"
    CHAT_ID = "YOUR_CHAT_ID"

telegram_token = credentials.YOUR_TELEGRAM_TOKEN

bot = telebot.TeleBot(telegram_token)

# Global variables to keep track of total trades and profit
total_trades = 0
total_profit = 0

def execute_sell_trade(df, symbol, lot_size=0.2, initial_balance=10.0):
    # ... (existing code)

    if result.comment == "Accepted":
        # ... (existing code)

        # Update total trades and profit
        global total_trades, total_profit
        total_trades += 1
        total_profit += (current_balance - initial_balance)

    # ... (previous code)
    
def calculate_profit_for_date(df, date):
    df_date = df[df.index.date == date]
    profit_for_date = (df_date["open"].iloc[0] - df_date["close"].iloc[-1]) * lot_size
    return profit_for_date

def calculate_profit_for_period(df, start_date, end_date):
    df_period = df[(df.index.date >= start_date) & (df.index.date <= end_date)]
    profit_for_period = sum((df_period["open"].iloc[0] - df_period["close"].iloc[-1]) * lot_size)
    return profit_for_period

def send_total_trades():
    global total_trades
    bot.send_message(credentials.CHAT_ID, f"Total Trades: {total_trades}", parse_mode="HTML")

def send_profit_for_date(date):
    df = get_historical_data(symbol, timeframe, data_length)
    if df is not None:
        profit_for_date = calculate_profit_for_date(df, date)
        bot.send_message(credentials.CHAT_ID, f"Profit for {date}: ${profit_for_date:.2f}", parse_mode="HTML")

def send_profit_for_period(start_date, end_date):
    df = get_historical_data(symbol, timeframe, data_length)
    if df is not None:
        profit_for_period = calculate_profit_for_period(df, start_date, end_date)
        bot.send_message(credentials.CHAT_ID, f"Profit from {start_date} to {end_date}: ${profit_for_period:.2f}", parse_mode="HTML")
        

# Command handler for /total_trades command
@bot.message_handler(commands=['total_trades'])
def handle_total_trades(message):
    send_total_trades()

# Command handler for /profit_for_date command
@bot.message_handler(commands=['profit_for_date'])
def handle_profit_for_date(message):
    try:
        date_string = message.text.split(" ")[1]
        date = datetime.strptime(date_string, '%Y-%m-%d').date()
        send_profit_for_date(date)
    except IndexError:
        bot.reply_to(message, "Please provide a valid date in the format YYYY-MM-DD.")
    except ValueError:
        bot.reply_to(message, "Invalid date format. Please use the format YYYY-MM-DD.")

# Command handler for /profit_for_period command
@bot.message_handler(commands=['profit_for_period'])
def handle_profit_for_period(message):
    try:
        date_strings = message.text.split(" ")[1:]
        start_date = datetime.strptime(date_strings[0], '%Y-%m-%d').date()
        end_date = datetime.strptime(date_strings[1], '%Y-%m-%d').date()
        send_profit_for_period(start_date, end_date)
    except IndexError:
        bot.reply_to(message, "Please provide both start and end dates in the format YYYY-MM-DD.")
    except ValueError:
        bot.reply_to(message, "Invalid date format. Please use the format YYYY-MM-DD.")

if __name__ == "__main__":
    # ... (previous code)

    if len(argv) > 1 and argv[1] == "--telegram":
        telegram_enabled = True
        bot.polling()
    else:
        telegram_enabled = False


######################################################################################################
    """
    
    With the modifications, the script now handles three Telegram commands:

1. `/total_trades`: Sends the total number of trades.
2. `/profit_for_date YYYY-MM-DD`: Sends the profit for the given date (replace `YYYY-MM-DD` with the desired date).
3. `/profit_for_period YYYY-MM-DD YYYY-MM-DD`: Sends the profit for the given period (replace both `YYYY-MM-DD` with the start and end dates of the desired period).

To use these commands, run the script with the `--telegram` argument. For example:

```
python3 testing.py --telegram
```

Then, in your Telegram chat with the bot, you can use the commands to get the desired information. For example:

- `/total_trades`
- `/profit_for_date 2023-08-01`
- `/profit_for_period 2023-08-01 2023-08-15`

    """

