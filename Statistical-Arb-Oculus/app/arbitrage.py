import streamlit as st
from streamlit_option_menu import option_menu
from arbitrage import *
import datetime
from backtest import *


# Define the sidebar content
def sidebar():

    forex_pairs = [
        "EUR/USD", "USD/JPY", "GBP/USD", "AUD/USD", "USD/CAD",
        "NZD/USD", "USD/CHF", "EUR/GBP", "EUR/JPY", "GBP/JPY"
    ]

    crypto_pairs = [
        "BTC/USD", "ETH/USD", "XRP/USD", "LTC/USD", "BCH/USD",
        "ADA/USD", "XLM/USD", "EOS/USD", "TRX/USD", "LINK/USD"
    ]

    # Sidebar title
    st.sidebar.title("Options")

    # Get Pair button
    get_pair_button = st.sidebar.button("Get Pair", key="get_pair_button", help="Click to get the pair")

    # Center align the button
    st.sidebar.markdown("<style>div[data-testid='stButton']>button {text-align: center;}</style>", unsafe_allow_html=True)

    # Style the button on hover with blue color
    st.sidebar.markdown(
        "<style>div[data-testid='stButton']:hover button {background-color: blue;}</style>", unsafe_allow_html=True
    )

    # Market option list
    market = st.sidebar.selectbox("Market", ["Forex", "Crypto"])

    # Define the interval options based on the selected market
    if market == "Crypto":
        limit_range = (0, 1000)
        interval = st.sidebar.slider("Limit", min_value=limit_range[0], max_value=limit_range[1], step=1, value=(0, 500))
    else:
        interval_options = ["1m", "5m", "15m", "1h", "4h", "1d", "1w", "1month"]
        interval = st.sidebar.selectbox("Interval/Timeframe", interval_options)

    # Asset 1 and Asset 2 dropdown lists
    assets = []
    if market == "Crypto":
        assets = st.sidebar.selectbox("Asset 1", crypto_pairs), st.sidebar.selectbox("Asset 2", crypto_pairs)
    else:
        assets = st.sidebar.selectbox("Asset 1", forex_pairs), st.sidebar.selectbox("Asset 2", forex_pairs)

    # Start and End Date options
    current_date = datetime.date.today()
    two_months_ago = current_date - datetime.timedelta(days=60)

    start_date = st.sidebar.date_input("Start Date", current_date - datetime.timedelta(days=1), min_value=two_months_ago, max_value=current_date)
    end_date = st.sidebar.date_input("End Date", current_date, min_value=two_months_ago, max_value=current_date)

    # Conditional rendering for interval options based on the selected market
    if market == "Crypto":
        st.sidebar.markdown("**Crypto Limit Range:**")
        st.sidebar.write(f"Selected Limit Range: {interval[0]} to {interval[1]}")

    # Display the selected options
    st.sidebar.write("Selected Market:", market)
    if market != "Crypto":
        st.sidebar.write("Selected Interval/Timeframe:", interval)
    st.sidebar.write("Selected Asset 1:", assets[0])
    st.sidebar.write("Selected Asset 2:", assets[1])
    st.sidebar.write("Selected Start Date:", start_date)
    st.sidebar.write("Selected End Date:", end_date)

    # Back Test section
    back_test_section()


# Define the Arbitrage Opportunities page content
def arbitrage_opportunities_page():
    st.title("Arbitrage Opportunities")
    # Add content for the Arbitrage Opportunities page here.
    # ...

def metrics():
    st.title("Metrics")