//+------------------------------------------------------------------+
//|                                                     MASlope.mq5  |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade trade;

input group "1. General Setting"
input ulong expertMagic = 8888;

input group "2. Indicator Setting"
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT;
input int maPeriod = 50;
input ENUM_MA_METHOD maMethod = MODE_SMA;
input int maShift = 25;
input double threeShold = 60.0;
input double rangingRange = 50.0; 

input group "3. Money Management"
input double positionSize = 0.2;

bool isShortSignal = false;
bool isLongSignal = false;
int maHandle1, maHandle2;
double maBuffer1[], maBuffer2[];

int OnInit() {
    trade.SetExpertMagicNumber(expertMagic);
    
    maHandle1 = iMA(_Symbol, PERIOD_CURRENT, maPeriod, 0, maMethod, PRICE_CLOSE);
    maHandle2 = iMA(_Symbol, PERIOD_CURRENT, maPeriod, maShift, maMethod, PRICE_CLOSE);
    
    ArraySetAsSeries(maBuffer1, true);
    ArraySetAsSeries(maBuffer2, true);
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
}

void closeWhen(bool condition) {
    if (condition) {
        for (int i = PositionsTotal() - 1; i >= 0; i--) {
            ulong ticket = PositionGetTicket(i);
            if (PositionSelectByTicket(ticket)) {
                if (trade.PositionClose(ticket)) {
                    Print("Close Position ticket #", ticket, " because condition is met");
                }
            }
        }
    }
}

void OnTick() {
    
    double currentAsk = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    double currentBid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    
    int value = CopyBuffer(maHandle1, 0, 0, 2, maBuffer1);
    if (value != 2) {
        Alert("Not enough data for the maBuffer 1");
        return;
    }
    value = CopyBuffer(maHandle2, 0, 0, 2, maBuffer2);
    if (value != 2) {
        Alert("Not enough data for the maBuffer 2");
        return;
    }

    double maValue1 = NormalizeDouble(maBuffer1[0], _Digits);
    double maValue2 = NormalizeDouble(maBuffer2[0], _Digits);

    double slopeValue = (maValue2 - maValue1) / maShift;
    double maAngle = MathArctan(slopeValue) * 180 / M_PI;

    Comment("MA Angle: ", maAngle,
            "\nMA Value 1: ", maValue1,
            "\nMA Value 2: ", maValue2);

    double closeLastCandle2 = iClose(_Symbol, timeframe, 2);

    isLongSignal = maAngle < -threeShold;
    isShortSignal = maAngle > threeShold;
    
    bool isRanging = (maAngle > -rangingRange && maAngle < rangingRange);

    closeWhen(isRanging);

    if (!isRanging) {
        if (isLongSignal) {
            if (PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
                trade.PositionClose(_Symbol);
            }
            if (!PositionSelect(_Symbol)) {
                trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, positionSize, currentAsk, 0, 0, "Long");
            }
        }
        else if (isShortSignal) {
            if (PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
                trade.PositionClose(_Symbol);
            }
            if (!PositionSelect(_Symbol)) {
                trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, positionSize, currentBid, 0, 0, "Short");
            }
        }
    }
}

