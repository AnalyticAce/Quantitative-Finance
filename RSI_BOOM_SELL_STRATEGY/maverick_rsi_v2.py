import MetaTrader5 as mt5
import pandas as pd
import ta
from datetime import datetime

class RsiSellStrategy:

    def __init__(self, symbol, timeframe, lot_size = 1):
        self.symbol = symbol
        self.timeframe = timeframe
        self.lot_size = lot_size

    def initialize_terminal(self):
        mt5.initialize()

    def shutdown_terminal(self):
        mt5.shutdown()

    def get_historical_data(self, number_of_data = 1000):
        from_date = datetime.now()

        rates = mt5.copy_rates_from_pos(self.symbol, self.timeframe, 0, number_of_data)

        df = pd.DataFrame(rates)

        df["time"] = pd.to_datetime(df["time"], unit="s")
        
        df["time"] = pd.to_datetime(df["time"], format='%Y-%m-%d %H:%M:%S')
        
        df = df.set_index("time")

        return df

    def calculate_rsi(self, df, period = 14):
        rsi_indicator = ta.momentum.RSIIndicator(df["close"], n=period)
        df["rsi"] = rsi_indicator.rsi()

    def execute_sell_trade(self):
        current_bar = self.df.iloc[-1]
        previous_bar = self.df.iloc[-2]

        if current_bar["rsi"] > 70 and current_bar["close"] < current_bar["open"] and previous_bar["close"] > previous_bar["open"]:
            # Check if there is an existing sell trade
            open_positions = mt5.positions_get(symbol = self.symbol)
            sell_trade_exists = any(position.type == mt5.ORDER_SELL for position in open_positions)

            if not sell_trade_exists:
                # Execute a sell trade
                request = {
                    "action": mt5.TRADE_ACTION_DEAL,
                    "symbol": self.symbol,
                    "volume": self.lot_size,
                    "type": mt5.ORDER_SELL,
                    "price": mt5.symbol_info_tick(self.symbol).ask,
                    "deviation": 10,
                    "type_time": mt5.ORDER_TIME_GTC
                }

                result = mt5.order_send(request)
                if result.comment == "Request executed":
                    print("Sell trade executed successfully.")
                else:
                    print("Error executing sell trade:", result.comment)

    def close_sell_trade(self):
        open_positions = mt5.positions_get(symbol = self.symbol)
        for position in open_positions:
            if position.type == mt5.ORDER_SELL:
                request = {
                    "position": position.ticket,
                    "action": mt5.TRADE_ACTION_DEAL,
                    "symbol": self.symbol,
                    "volume": position.volume,
                    "type": mt5.ORDER_BUY,
                    "price": mt5.symbol_info_tick(self.symbol).bid,
                    "deviation": 10,
                    "type_time": mt5.ORDER_TIME_GTC
                }
                result = mt5.order_send(request)
                if result.comment == "Request executed":
                    print("Sell trade closed successfully.")
                else:
                    print("Error closing sell trade:", result.comment)

    def run_strategy(self, data_length=1000):
        try:
            self.initialize_terminal()

            # Retrieve historical data
            self.df = self.get_historical_data(data_length)

            # Calculate RSI
            self.calculate_rsi(self.df)

            # Execute sell trade if conditions are met
            self.execute_sell_trade()

            # Close sell trade if conditions are met
            self.close_sell_trade()

        except Exception as e:
            print("Error executing the strategy:", str(e))

        finally:
            self.shutdown_terminal()

if __name__ == "__main__":
    symbol = ["BOOM1000", "BOOM500", "BOOM300"]  # Replace with your desired symbol
    timeframe = mt5.TIMEFRAME_M1  # Replace with your desired timeframe
    lot_size = 1.0  # Replace with your desired lot size

    strategy = RsiSellStrategy(symbol, timeframe, lot_size)
    strategy.run_strategy()
