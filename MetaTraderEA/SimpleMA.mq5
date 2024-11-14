#include <Trade\Trade.mqh>

CTrade trade;

input ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT;
input ulong Magic = 8888;

input int maPeriod = 50;
input ENUM_MA_METHOD maMethod = MODE_SMA;
input double lot = 0.02;

int maHandle;
double maBuffer[];

datetime lastBuyTime = 0;
datetime lastSellTime = 0;

int OnInit() {
    maHandle = iMA(_Symbol, Timeframe, maPeriod, 0, maMethod, PRICE_CLOSE);
    if (maHandle == INVALID_HANDLE) {
        Alert("Failed to initialize moving average handle.");
        return INIT_FAILED;
    }

    ArraySetAsSeries(maBuffer, true);

    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
    if (maHandle != INVALID_HANDLE) {
        IndicatorRelease(maHandle);
    }
}

void OnTick() {
    if (CopyBuffer(maHandle, 0, 0, 2, maBuffer) != 2) {
        Alert("Not enough data for moving average.");
        return;
    }

    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    bool isBuySignal = maBuffer[0] < currentPrice;
    bool isSellSignal = maBuffer[0] > currentPrice;

    if (PositionSelect(_Symbol)) {
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && isSellSignal) {
            trade.PositionClose(_Symbol);
        }
        if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && isBuySignal) {
            trade.PositionClose(_Symbol);
        }
    }

    if (isBuySignal && !PositionSelect(_Symbol)) {
        double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, lot, ask, 0, 0, "Buy");
    }

    if (isSellSignal && !PositionSelect(_Symbol)) {
        double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, lot, bid, 0, 0, "Sell");
    }
}
