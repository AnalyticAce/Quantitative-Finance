import streamlit as st
from streamlit_option_menu import option_menu
from arbitrage import *
import datetime

# Define the Back Test section
def back_test_section():
    st.sidebar.title("Back Test")

    # Long ticker option (Asset 1 or Asset 2)
    #long_ticker = st.sidebar.radio("Long Ticker", ["Asset 1", "Asset 2"])

    # Window input box
    window = st.sidebar.number_input("Window", min_value=1, step=1)

    # Open trade at input box
    open_trade_at = st.sidebar.number_input("Open Trade At", min_value=0.0)

    # Close trade at input box
    close_trade_at = st.sidebar.number_input("Close Trade At", min_value=0.0)

    # Volume input box
    volume = st.sidebar.number_input("Volume", min_value=0.0)

    # Initial Capital input box (in $)
    initial_capital = st.sidebar.number_input("Initial Capital ($)", min_value=0.0)

    # Commission input box with default value 0
    commission = st.sidebar.number_input("Commission", min_value=0.0, value=0.0)

    # Backtest button
    if st.sidebar.button("Backtest", key="backtest_button"):
        # Implement backtesting logic here
        st.write("Backtesting in progress...")