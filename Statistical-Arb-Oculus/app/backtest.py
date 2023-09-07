import streamlit as st
import datetime

# Define the Back Test section
def back_test_section():

    # Create a row for the inputs
    cols1, cols2, cols3, cols4 = st.columns(4)

    # Long ticker option (Pair 1 or Pair 2)
    with cols1:
        long_ticker = st.radio("Long Ticker", ["Pair 1", "Pair 2"], key="long_ticker", help="Select the long ticker")

    # Window input box
    with cols2:
        window = st.text_input("Window", key="window", help="Enter the window size")

    # Open trade at input box
    with cols3:
        open_trade_at = st.text_input("Open Trade At", key="open_trade_at", help="Enter the open trade value")

    # Close trade at input box
    with cols4:
        close_trade_at = st.text_input("Close Trade At", key="close_trade_at", help="Enter the close trade value")

    # Create a row for the remaining inputs
    cols5, cols6, cols7, cols8 = st.columns(4)

    # Volume input box
    with cols5:
        volume = st.text_input("Volume", key="volume", help="Enter the volume")

    # Initial Capital input box (in $)
    with cols6:
        initial_capital = st.text_input("Initial Capital ($)", key="initial_capital", help="Enter the initial capital")

    # Commission input box with default value 0
    with cols7:
        commission = st.text_input("Commission", value="0", key="commission", help="Enter the commission")

    # Backtest button
    with cols8:
        st.write("")  # Spacer
        if st.button("Backtest"):
            # Implement backtesting logic here
            st.write("Backtesting in progress...")
