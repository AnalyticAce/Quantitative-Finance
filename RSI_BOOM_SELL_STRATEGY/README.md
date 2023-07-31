# Maverick RSI Strategy

Maverick RSI Strategy is a simple automated trading strategy based on the Relative Strength Index (RSI) indicator. It uses the MetaTrader 5 platform to retrieve historical price data, calculate the RSI, and execute sell trades when specific conditions are met.

## Table of Contents
- [Project Structure](#project-structure)
- [Documentation](#documentation)
- [Obsolete](#obsolete)
- [Source](#source)
- [Strategy](#strategy)
- [Usage](#usage)
- [Requirements](#requirements)
- [License](#license)

## Project Structure

The project is organized into several directories:

- `Documentation`: Contains the Jupyter notebook `maverick.ipynb`, which provides detailed documentation and explanations for the Maverick RSI Strategy.
- `Obsolete`: Contains older versions of the strategy script (`maverick_rsi.py` and `maverick_rsi_v2.py`) that are no longer in use.
- `Source`: Contains the `ascii.txt` file and `requirements.txt` file.
- `Strategy`: Contains the main implementation of the Maverick RSI Strategy in the `maverick.py` script.
- `README.md`: The current file, providing an overview of the project.

## Documentation

The `Documentation` directory contains the `maverick.ipynb` Jupyter notebook, which serves as comprehensive documentation for the Maverick RSI Strategy. The notebook includes detailed explanations of the strategy's components, such as data retrieval, RSI calculation, and trade execution. It also provides insights into the trading logic and considerations for the strategy's implementation.

## Obsolete

The `Obsolete` directory houses older versions of the strategy script that are no longer in use or have been superseded by newer versions. These scripts are preserved for historical reference and should not be utilized in the current implementation.

## Source

The `Source` directory contains auxiliary files used in the project:

- `ascii.txt`: ASCII art used for decorative purposes.
- `requirements.txt`: A file listing the required Python packages and their versions to run the Maverick RSI Strategy. You can install these dependencies using `pip` with the command `pip install -r requirements.txt`.

## Strategy

The `Strategy` directory is the core of the Maverick RSI Strategy:

- `maverick.py`: This script contains the main implementation of the strategy. It retrieves historical price data, calculates the RSI indicator, and executes sell trades based on specific conditions.

## Usage

To use the Maverick RSI Strategy, follow these steps:

1. Ensure you have the required Python packages installed. You can install them using the command:
```pyton
pip install -r Source/requirements.txt.
```
2. Open the `maverick.py` script located in the `Strategy` directory and adjust the strategy parameters (e.g., symbol, timeframe, lot size, data length, and RSI period) based on your trading preferences and the financial instrument you want to trade.
3. Run the `maverick.py` script using a Python interpreter.
4. The strategy will continuously monitor the market for sell trade opportunities based on the RSI indicator and execute sell trades when specific conditions are met.

## Requirements

The Maverick RSI Strategy requires the following Python packages:

- MetaTrader5==5.0.40
- pandas==1.3.3
- ta==0.7.0
- termcolor==1.1.0

You can install these dependencies using `pip` with the command 
```python 
pip install -r Source/requirements.txt.
```

## License

This project is licensed under the [MIT License](LICENSE). Feel free to modify and adapt the strategy according to your needs. However, please note that trading in financial markets involves risks, and the strategy's performance may vary depending on various factors. It is recommended to thoroughly test the strategy and exercise caution when using it for real trading. The authors of this project are not responsible for any financial losses incurred while using the strategy.

For detailed information on the implementation and usage of the Maverick RSI Strategy, please refer to the `maverick.ipynb` Jupyter notebook in the `Documentation` directory.

For any issues or suggestions, please feel free to open an [issue](https://github.com/username/repo/issues) on GitHub.