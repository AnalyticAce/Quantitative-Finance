import requests
from bs4 import BeautifulSoup
import pandas as pd

def get_stock_data(ticker):
    url = f'https://finance.yahoo.com/quote/{ticker}/history?p={ticker}'
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    table = soup.find('table', {'data-test': 'historical-prices'})
    df = pd.read_html(str(table))[0]
    df.columns = ['Date', 'Open', 'High', 'Low', 'Close', 'Adj Close', 'Volume']
    df['Date'] = pd.to_datetime(df['Date'])
    df = df.set_index('Date')
    return df

ticker = 'AAPL' # Change this to the ticker symbol you want to scrape data for
df = get_stock_data(ticker)
print(df.head())
