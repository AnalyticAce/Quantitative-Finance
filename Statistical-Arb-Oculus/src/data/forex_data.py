import pandas as pd
import tradermade as tm

def fetch_fx_data(symbol, start_date, end_date, timeframe):

    tm.set_rest_api_key("PQgteXR13COKO54qQXdH")

    data = tm.timeseries(currency = symbol, start = start_date, end= end_date, interval = timeframe ,fields=["open", "high", "low","close"])

    df = pd.DataFrame(data)

    return df