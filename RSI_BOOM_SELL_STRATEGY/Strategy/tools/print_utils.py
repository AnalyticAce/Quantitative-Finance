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
        command = "./maverick_v3"
        command_tel = "./maverick_v3 --telegram"

        message = (
            "Hey 🫠 Welcome to Mavery RSI Version 3.0.1\n"
            f"1. Run {command} to execute the program !\n"
            f"2. Run {command_tel} to receive telegram message when a trade is taken \n"
            "If you have any other questions or need further assistance, feel free to ask! Happy trading! 📈 \n"
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