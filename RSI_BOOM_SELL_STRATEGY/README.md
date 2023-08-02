# Maverick RSI Strategy

Maverick RSI Strategy is a simple automated trading strategy based on the Relative Strength Index (RSI) indicator. It uses the MetaTrader 5 platform to retrieve historical price data, calculate the RSI, and execute sell trades when specific conditions are met.

## Project Structure

The project is organized into several directories:

- `Backtest`: Contains the Jupyter notebook `backtest.ipynb`, which performs backtesting on the Maverick RSI Strategy using historical data and showcases the results in the form of images.
- `Documentation`: Contains the Jupyter notebook `maverick.ipynb`, which provides detailed documentation and explanations for the Maverick RSI Strategy.
- `Obsolete`: Contains older versions of the strategy script (`maverick_rsi_v1.py` and `maverick_rsi_v2.py`) that are no longer in use.
- `Source`: Contains auxiliary files used in the project, including ASCII art, backtest result images, sounds, and the `requirements.txt` file.
- `Strategy`: Contains the main implementation of the Maverick RSI Strategy in the `maverick_v3.py` script, along with a `tools` directory that houses the `print_utils.py` module for improved code readability.

## Documentation

The `Documentation` directory contains the `maverick.ipynb` Jupyter notebook, which serves as comprehensive documentation for the Maverick RSI Strategy. The notebook includes detailed explanations of the strategy's components, such as data retrieval, RSI calculation, and trade execution. It also provides insights into the trading logic and considerations for the strategy's implementation.

## Obsolete

The `Obsolete` directory houses older versions of the strategy script that are no longer in use or have been superseded by newer versions. These scripts are preserved for historical reference and should not be utilized in the current implementation.

## Source

The `Source` directory contains auxiliary files used in the project:

- `image`: Contains backtest result images, including `backtest.png` and `profit.png`.
- `son`: Contains sound files used for notifications, including `error.mp3` and `success.mp3`.
- `text`: Contains ASCII art used for decorative purposes in `ascii.txt` and the `requirements.txt` file listing the required Python packages and their versions to run the Maverick RSI Strategy. You can install these dependencies using `pip` with the command `pip install -r Source/text/requirements.txt`.

## Strategy

The `Strategy` directory is the core of the Maverick RSI Strategy:

- `maverick_v3.py`: This script contains the main implementation of the strategy. It retrieves historical price data, calculates the RSI indicator, and executes sell trades based on specific conditions.

- `tools/print_utils.py`: This module contains printing functions to enhance code readability. It separates all the printing statements from the main script for better organization.

## Backtest

The `Backtest` directory contains the `backtest.ipynb` Jupyter notebook, which performs backtesting on the Maverick RSI Strategy using historical price data stored in the `historical_data.csv` file. The notebook uses the `maverick_v3.py` script to execute the strategy and evaluates its performance based on the historical data. The results are displayed in the form of images, including a performance chart and a profit chart.

### Backtest Results

#### Performance Chart
![Performance Chart](Source/image/backtest.png)

#### Profit Chart (With an Initial Capital of $10)
![Profit Chart](Source/image/profit.png)

## Telegram Signal and Help

To receive Telegram messages when a trade is taken, run the following command:

```python
./Strategy/maverick_v3  --telegram
```

To set up the Telegram bot, follow these steps:

1. Search for the "BotFather" bot in the Telegram app.
2. Start a chat with the BotFather and use the command "/newbot" to create a new bot.
3. Follow the instructions to choose a name and username for your bot.
4. Once the bot is created, the BotFather will provide you with a token. Copy this token; you will need it later.
5. Create a new file named `secret.py` inside the `Strategy` directory.
6. Inside `secret.py`, define a class named `credentials` and add the following lines:

```python
class credentials:
    YOUR_TELEGRAM_TOKEN = "YOUR_TELEGRAM_API_KEY"
    CHAT_ID = "YOUR_CHAT_ID"
```

Replace `"YOUR_TELEGRAM_API_KEY"` with the token you obtained from the BotFather, and `"YOUR_CHAT_ID"` (To find `"YOUR_CHAT_ID"` search for the "userinfobot" bot in the Telegram app and get the necessary informations using "/start") with your Telegram Chat ID.
7. Save the changes to the `secret.py` file.

After setting up the Telegram bot and updating the `secret.py` file with your API key and Chat ID, you can run the Maverick RSI Strategy with Telegram notifications as explained in the "Usage" section.

To get help and see available commands, run:

```python
./Strategy/maverick_v3 --help
```

## Requirements

The Maverick RSI Strategy requires the following Python packages:

- MetaTrader5==5.0.40
- pandas==1.3.3
- ta==0.7.0
- termcolor==1.1.0
- playsound
- telebot
- pyTelegramBotAPI

You can install these dependencies using `pip` with the command:
```python
pip install -r Source/text/requirements.txt
```

## License

This project is licensed under the [MIT License](LICENSE). Feel free to modify and adapt the strategy according to your needs. However, please note that trading in financial markets involves risks, and the strategy's performance may vary depending on various factors. It is recommended to thoroughly test the strategy and exercise caution when using it for real trading. The authors of this project are not responsible for any financial losses incurred while using the strategy.

For detailed information on the implementation and usage of the Maverick RSI Strategy, please refer to the `maverick.ipynb` Jupyter notebook in the `Documentation` directory.

For any issues or suggestions, please feel free to open an [issue](https://github.com/AnalyticAce/Algorithmic-Trading-Projects/issues) on GitHub.

**Note:** Please replace "username/repo" with your actual GitHub repository URL.