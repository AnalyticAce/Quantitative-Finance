import streamlit as st
import datetime

# Define the Back Test section
def back_test_section():
    # Create a sepertor for the inputs
    st.markdown("---")
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
            if st.button("Backtest"):
                # Implement backtesting logic here
                st.write("Backtesting in progress...")
        back_test_result()

def back_test_result():
    st.markdown("---")

    net_win_rate = 0.75
    z_score_win_rate_m = 0.85
    z_score_win_rate_p = 0.05
    num_open_trade_p = 10
    num_open_trade_m = 0.5
    total_num_trades = 10
    net_avg_return = 0.5
    net_total_return = 0.6
    net_total_drawdown = -19
    total_profit = 1500

    with st.container():
        st.write(
            '<style>div[data-testid="stBlock"][data-st-id="2"] > div{max-width: 30%;}</style>',
            unsafe_allow_html=True,
        )

        cols1, cols2, cols3, cols4, cols5, cols6, cols7, cols8, cols9, cols10 = st.columns(10)

        # net_win_rate
        with cols1:
            st.write("Net Win Rate")
            if net_win_rate < 0:
                st.markdown(f'<p style="color:red;">{net_win_rate}</p>', unsafe_allow_html=True)
            else:
                st.markdown(f'<p style="color:green;">{net_win_rate}</p>', unsafe_allow_html=True)

        # z_score_win_rate_p
        with cols2:
            st.write("Z-Score Win (-)")
            if z_score_win_rate_p < 0:
                st.markdown(f'<p style="color:red;">{z_score_win_rate_p}</p>', unsafe_allow_html=True)
            else:
                st.markdown(f'<p style="color:green;">{z_score_win_rate_p}</p>', unsafe_allow_html=True)

        # z_score_win_rate_m
        with cols3:
            st.write("Z-Score Win (+)")
            if z_score_win_rate_m < 0:
                st.markdown(f'<p style="color:red;">{z_score_win_rate_m}</p>', unsafe_allow_html=True)
            else:
                st.markdown(f'<p style="color:green;">{z_score_win_rate_m}</p>', unsafe_allow_html=True)

        # num_open_trade_p
        with cols4:
            st.write("Num of Longs")
            if num_open_trade_p != "Yes":
                st.markdown(f'<p style="color:red;">{num_open_trade_p}</p>', unsafe_allow_html=True)
            else:
                st.markdown(f'<p style="color:green;">{num_open_trade_p}</p>', unsafe_allow_html=True)
    
        # num_open_trade_m
        with cols5:
            st.write("Num of Shorts")
            if num_open_trade_m < 0:
                st.markdown(f'<p style="color:red;">{num_open_trade_m}</p>', unsafe_allow_html=True)
            else:
                st.markdown(f'<p style="color:green;">{num_open_trade_m}</p>', unsafe_allow_html=True)

        # total_num_trades
        with cols6:
            st.write("Total Trades")
            if total_num_trades < 0:
                st.markdown(f'<p style="color:red;">{total_num_trades}</p>', unsafe_allow_html=True)
            else:
                st.markdown(f'<p style="color:green;">{total_num_trades}</p>', unsafe_allow_html=True)

        # net_avg_return
        with cols7:
            st.write("Avg Return")
            if total_num_trades < 0:
                st.markdown(f'<p style="color:red;">{net_avg_return}</p>', unsafe_allow_html=True)
            else:
                st.markdown(f'<p style="color:green;">{net_avg_return}</p>', unsafe_allow_html=True)
            
        # net_total_return
        with cols8:
            st.write("Total Return")
            if total_num_trades < 0:
                st.markdown(f'<p style="color:red;">{net_total_return}</p>', unsafe_allow_html=True)
            else:
                st.markdown(f'<p style="color:green;">{net_total_return}</p>', unsafe_allow_html=True)

        # net_total_drawdown
        with cols9:
            st.write("Max Drawdown")
            if total_num_trades < 0:
                st.markdown(f'<p style="color:red;">{net_total_drawdown}</p>', unsafe_allow_html=True)
            else:
                st.markdown(f'<p style="color:green;">{net_total_drawdown}</p>', unsafe_allow_html=True)

        # total_profit
        with cols10:
            st.write("Net Profit")
            if total_num_trades < 0:
                st.markdown(f'<p style="color:red;">{total_profit}</p>', unsafe_allow_html=True)
            else:
                st.markdown(f'<p style="color:green;">{total_profit}</p>', unsafe_allow_html=True)