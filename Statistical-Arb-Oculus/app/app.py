import streamlit as st
from streamlit_option_menu import option_menu
from arbitrage import *
import datetime
from introduction import *
from contact import *

# Main Streamlit app
def main():
    st.set_page_config(page_title="Arbitrage", layout="wide")

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
        sidebar()

# Execute the main function
if __name__ == "__main__":
    main()