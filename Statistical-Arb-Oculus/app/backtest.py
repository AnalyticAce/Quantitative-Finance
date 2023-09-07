import streamlit as st
import datetime

# Define the Back Test section
def back_test_section():
    # Create a container for the inputs
    with st.container():
        # Set the container width to 80%
        st.write(
            '<style>div[data-testid="stBlock"][data-st-id="1"] > div{max-width: 30%;}</style>',
            unsafe_allow_html=True,
        )

        # Create a row for the inputs
        cols1, cols2, cols3, cols4, cols5, cols6, cols7, cols8, cols9 = st.columns(9)

        # Signal dropdown list
        with cols1:
            signal = st.selectbox("Signal", ["Sell", "Buy", "Both"], key="signal")

        # Long ticker option dropdown list
        with cols2:
            long_ticker = st.selectbox("Long Ticker", ["Pair 1", "Pair 2"], key="long_ticker")

        # Window input box
        with cols3:
            window = st.text_input("Window", key="window")

        # Open trade at input box
        with cols4:
            open_trade_at = st.text_input("Open Trade At", key="open_trade_at")

        # Close trade at input box
        with cols5:
            close_trade_at = st.text_input("Close Trade At", key="close_trade_at")

        # Volume input box
        with cols6:
            volume = st.text_input("Volume", key="volume")

        # Initial Capital input box (in $)
        with cols7:
            initial_capital = st.text_input("Initial Capital", key="initial_capital")

        # Commission input box with default value 0
        with cols8:
            commission = st.text_input("Commission", value="0", key="commission")

        # Backtest button
        with cols9:
            st.write("")  # Spacer
            #st.write("")  # Spacer
            if st.button("Backtest"):
                # Implement backtesting logic here
                st.write("Backtesting in progress...")