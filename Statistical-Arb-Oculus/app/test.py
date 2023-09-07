from streamlit_option_menu import option_menu
from arbitrage import *
from backtest import *
import streamlit as st
import datetime
from introduction import *
from contact import *


# Define the sidebar content
def sidebar():
    st.sidebar.title("Options")

    forex_pairs = [
        "EUR/USD", "USD/JPY", "GBP/USD", "AUD/USD", "USD/CAD",
        "NZD/USD", "USD/CHF", "EUR/GBP", "EUR/JPY", "GBP/JPY"
    ]

    crypto_pairs = [
        "BTC/USD", "ETH/USD", "XRP/USD", "LTC/USD", "BCH/USD",
        "ADA/USD", "XLM/USD", "EOS/USD", "TRX/USD", "LINK/USD"
    ]

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

    # Conditional rendering for Start and End Date based on the selected market
    if market != "Crypto":
        current_date = datetime.date.today()
        two_months_ago = current_date - datetime.timedelta(days=60)
        start_date = st.sidebar.date_input("Start Date", current_date - datetime.timedelta(days=1), min_value=two_months_ago, max_value=current_date)
        end_date = st.sidebar.date_input("End Date", current_date, min_value=two_months_ago, max_value=current_date)
    else:
        # Remove the Start and End Date inputs if Crypto is selected
        st.sidebar.empty()
        start_date = None
        end_date = None

# Define the Back Test section
def back_test_section():
    st.title("Back Test")
    st.markdown("---")  # Add a horizontal line to separate the sections

    # Create a row for the inputs
    cols1, cols2, cols3, cols4 = st.columns(4)

    # Long ticker option (Asset 1 or Asset 2)
    with cols1:
        long_ticker = st.radio("Long Ticker", ["Asset 1", "Asset 2"])

    # Window input box
    with cols2:
        window = st.text_input("Window", key="window")

    # Open trade at input box
    with cols3:
        open_trade_at = st.text_input("Open Trade At", key="open_trade_at")

    # Close trade at input box
    with cols4:
        close_trade_at = st.text_input("Close Trade At", key="close_trade_at")

    # Create a row for the remaining inputs
    cols5, cols6, cols7, cols8 = st.columns(4)

    # Volume input box
    with cols5:
        volume = st.text_input("Volume", key="volume")

    # Initial Capital input box (in $)
    with cols6:
        initial_capital = st.text_input("Initial Capital ($)", key="initial_capital")

    # Commission input box with default value 0
    with cols7:
        commission = st.text_input("Commission", value="0", key="commission")

    # Backtest button
    with cols8:
        st.write("")  # Spacer
        if st.button("Backtest"):
            # Implement backtesting logic here
            st.write("Backtesting in progress...")

def arbitrage_opportunities_page():
    st.title("Arbitrage Opportunities")

    sidebar()  # Include the sidebar here for the "Arbitrage Opportunities" page

    back_test_section()  # Call the back_test_section without passing arguments

# Define the Introduction page content (example)
def introduction_page():
    st.title("Introduction")
    st.write("This is the Introduction page.")

# Main Streamlit app
def main():
    st.set_page_config(page_title="Your App Name", layout="wide")

    # Use the option_menu for navigation
    selected_page = option_menu(
        menu_title=None,
        options=["Introduction", "Arbitrage Opportunities", "Contact"],
        default_index=0,
        orientation="horizontal",
    )

    # Render the selected page based on user choice
    if selected_page == "Introduction":
        introduction_page()
    elif selected_page == "Arbitrage Opportunities":
        arbitrage_opportunities_page()

# Execute the main function
if __name__ == "__main__":
    main()
