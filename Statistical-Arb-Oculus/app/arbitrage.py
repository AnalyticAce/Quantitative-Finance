import streamlit as st
from streamlit_option_menu import option_menu
from arbitrage import *
import datetime
#from src.data.fetch_data import *
#from src.mectrics.fx_mectrics import *
from backtest import *

def sidebar(forex_pairs, crypto_pairs):
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
        interval_options = ["4h", "1d", "1w", "1month"]
        interval = st.sidebar.selectbox("Interval/Timeframe", interval_options)
    else:
        interval_options = ["daily", "weekly", "montly"]
        interval = st.sidebar.selectbox("Interval/Timeframe", interval_options)

    # Pair 1 and Pair 2 dropdown lists
    Pairs = []
    if market == "Crypto":
        Pairs = st.sidebar.selectbox("Pair 1", crypto_pairs), st.sidebar.selectbox("Pair 2", crypto_pairs)
    else:
        Pairs = st.sidebar.selectbox("Pair 1", forex_pairs), st.sidebar.selectbox("Pair 2", forex_pairs)

    # Conditional rendering for Start and End Date based on the selected market
    if market != "Crypto":
        current_date = datetime.date.today()
        two_months_ago = current_date - datetime.timedelta(days=60)
        start_date = st.sidebar.date_input("Start Date", current_date - datetime.timedelta(days=1), min_value=two_months_ago, max_value=current_date)
        end_date = st.sidebar.date_input("End Date", current_date, min_value=two_months_ago, max_value=current_date)
    else:
        limit_range = (0, 1000)
        interval = st.sidebar.slider("Limit", min_value=limit_range[0], max_value=limit_range[1], step=1, value=(0, 500))

def metrics_section(correlation, hedge_ratio, p_value, is_stationary, half_life, hurst_exponent):

    st.title("Metrics")

    # Create a container for the metrics
    with st.container():
        # Set the container width to 80%
        st.write(
            '<style>div[data-testid="stBlock"][data-st-id="2"] > div{max-width: 30%;}</style>',
            unsafe_allow_html=True,
        )

        # Create a row for the metrics cards
        cols1, cols2, cols3, cols4, cols5, cols6 = st.columns(6)

        # Correlation metric card
        with cols1:
            st.write("Correlation")
            if correlation < 0:
                st.markdown(f'<p style="color:red;">{correlation}</p>', unsafe_allow_html=True)
            else:
                st.markdown(f'<p style="color:green;">{correlation}</p>', unsafe_allow_html=True)

        # P-Value metric card
        with cols2:
            st.write("P-Value")
            if p_value < 0:
                st.markdown(f'<p style="color:red;">{p_value}</p>', unsafe_allow_html=True)
            else:
                st.markdown(f'<p style="color:green;">{p_value}</p>', unsafe_allow_html=True)

        # Is Stationary metric card
        with cols3:
            st.write("Is Stationary")
            if is_stationary != "Yes":
                st.markdown(f'<p style="color:red;">{is_stationary}</p>', unsafe_allow_html=True)
            else:
                st.markdown(f'<p style="color:green;">{is_stationary}</p>', unsafe_allow_html=True)

        # Half-Life metric card
        with cols4:
            st.write("Half-Life")
            if half_life < 0:
                st.markdown(f'<p style="color:red;">{half_life}</p>', unsafe_allow_html=True)
            else:
                st.markdown(f'<p style="color:green;">{half_life}</p>', unsafe_allow_html=True)

        # Hurst Exponent metric card
        with cols5:
            st.write("Hurst Exponent")
            if hurst_exponent < 0:
                st.markdown(f'<p style="color:red;">{hurst_exponent}</p>', unsafe_allow_html=True)
            else:
                st.markdown(f'<p style="color:green;">{hurst_exponent}</p>', unsafe_allow_html=True)

        # Hedge Ratio metric card
        with cols6:
            st.write("Hedge Ratio")
            if hedge_ratio < 0:
                st.markdown(f'<p style="color:red;">{hedge_ratio}</p>', unsafe_allow_html=True)
            else:
                st.markdown(f'<p style="color:green;">{hedge_ratio}</p>', unsafe_allow_html=True)

# Define the Arbitrage Opportunities page content
def arbitrage_opportunities_page():
    
    metrics_section(
    correlation = 0.75,
    hedge_ratio = 0.85,
    p_value = 0.05,
    is_stationary = "Yes",
    half_life = 10,
    hurst_exponent = 0.5
    )
    
    back_test_section()
