import streamlit as st
from streamlit_option_menu import option_menu
from arbitrage import *
import datetime
from src.data.fetch_data import *
from src.mectrics.fx_mectrics import *
from introduction import *
from contact import *

# Main Streamlit app
def main():

    forex_pairs = [
        "EUR/USD", "USD/JPY", "GBP/USD", "AUD/USD", "USD/CAD",
        "NZD/USD", "USD/CHF", "EUR/GBP", "EUR/JPY", "GBP/JPY"
    ]

    crypto_pairs = [
        "BTC/USD", "ETH/USD", "XRP/USD", "LTC/USD", "BCH/USD",
        "ADA/USD", "XLM/USD", "EOS/USD", "TRX/USD", "LINK/USD"
    ]

    st.set_page_config(page_title="Arbitrage", layout="wide")

    # Use the option_menu for navigation
    selected_page = option_menu(
        menu_title=None,
        options=["Introduction 📖", "Arbitrage 📈", "Contact ☎️"],
        default_index=0,
        orientation="horizontal",
    )

    # Render the selected page based on user choice
    if selected_page == "Introduction 📖":
        introduction_page()
    elif selected_page == "Arbitrage 📈":
        arbitrage_opportunities_page()
        sidebar(forex_pairs, crypto_pairs)
    else:
        contact_page()

# Execute the main function
if __name__ == "__main__":
    main()