import streamlit as st

st.title("Simple Trade sizing Calculator")
st.write("This tool helps you size your position and make informed trading decisions.")

st.sidebar.header("Input Parameters")
current_balance = st.sidebar.number_input("Current Balance ($)", min_value=0.0, step=1.0)
number_of_open_positions = st.sidebar.number_input("Number of Open Positions", min_value=1, step=1)
entry_price = st.sidebar.number_input("Entry Price ($)", min_value=0.0, step=0.01)
take_profit = st.sidebar.number_input("Take Profit Price ($)", min_value=0.0, step=0.01)
stop_loss = st.sidebar.number_input("Stop Loss Price ($)", min_value=0.0, step=0.01)
lot_size = st.sidebar.number_input("What is your lot size/trade", min_value=0.0, step=0.01)

estimated_profit = 0.0
estimated_loss = 0.0

estimated_profit = lot_size * abs(entry_price - take_profit) * number_of_open_positions
estimated_loss = lot_size * abs(entry_price - stop_loss) * number_of_open_positions

positive_total = estimated_profit + current_balance
negative_total = current_balance - estimated_loss

st.header("Estimated Profit and Loss")
st.write(f"Estimated Profit: {estimated_profit:.2f}, After Trade:({positive_total:.2f})$")
st.write(f"Estimated Loss: {estimated_loss:.2f}, After Trade:({negative_total:.2f})$")

st.header("Trading Advice")
risk_reward_ratio = estimated_profit / estimated_loss

st.write("Trading Advice:", round(risk_reward_ratio, 2))

if take_profit > 0.0 and stop_loss > 0.0:
    if risk_reward_ratio >= 2.0:
        st.write("Trading Advice: Favorable Risk-Reward Ratio (>= 2)")
    else:
        st.write("Trading Advice: Consider adjusting Take Profit to improve Risk-Reward Ratio")
else:
    st.write("Trading Advice: Please provide Take Profit and Stop Loss values for risk analysis.")