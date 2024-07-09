//+------------------------------------------------------------------+
//|                                                          BOS.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade obj_Trade;

input int CandlePeriod = 14; // Number of Candles
input double Lots = 0.05; // Choose the volume per trade
input double takep = 500; // Take Profit in points
input double stopl = 500; // Stop Loss in points

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
static double swing_H = -1.0, swing_L = -1.0;
void OnTick() {
    static bool isNewBar = false;
    int currBars = iBars(_Symbol, _Period);
    static int prevBars = currBars;

    if (prevBars == currBars) {
        isNewBar = false;
    } else {
        isNewBar = true;
        prevBars = currBars;
    }

    const int length = CandlePeriod;
    const int limit = CandlePeriod;

    int right_index, left_index;
    bool isSwingHigh = true, isSwingLow = true;
    int curr_bar = limit;

    if (isNewBar) {
        for (int j = 1; j <= length; j++) {
            right_index = curr_bar - j;
            left_index = curr_bar + j;

            if (high(curr_bar) <= high(right_index) || high(curr_bar) < high(left_index)) {
                isSwingHigh = false;
            }
            if (low(curr_bar) >= low(right_index) || low(curr_bar) > low(left_index)) {
                isSwingLow = false;
            }
        }

        if (isSwingHigh) {
            swing_H = high(curr_bar);
            Print("UP @ BAR INDEX ", curr_bar, " of High: ", high(curr_bar));
            drawSwingPoint(TimeToString(time(curr_bar)), time(curr_bar), high(curr_bar), 77, clrBlue, -1);
        }
        if (isSwingLow) {
            swing_L = low(curr_bar);
            Print("DOWN @ BAR INDEX ", curr_bar, " of Low: ", low(curr_bar));
            drawSwingPoint(TimeToString(time(curr_bar)), time(curr_bar), low(curr_bar), 77, clrRed, 1);
        }
    }

    double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);

    if (swing_H > 0 && Bid > swing_H && close(1) > swing_H) {
        handleBreakUp();
    } else if (swing_L > 0 && Ask < swing_L && close(1) < swing_L) {
        handleBreakDown();
    }
}

//+------------------------------------------------------------------+
//| Handle Break Up                                                  |
//+------------------------------------------------------------------+
void handleBreakUp() {
    Print("BREAK UP NOW");
    int swing_H_index = findSwingIndex(swing_H, true);
    drawBreakLevel(TimeToString(time(0)), time(swing_H_index), high(swing_H_index),
                   time(1), high(swing_H_index), clrBlue, -1);
    swing_H = -1.0;
    double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    obj_Trade.Buy(Lots, _Symbol, Ask, Bid - stopl * _Point, Bid + takep * _Point, "BoS Break Up BUY");
}

//+------------------------------------------------------------------+
//| Handle Break Down                                                |
//+------------------------------------------------------------------+
void handleBreakDown() {
    Print("BREAK DOWN NOW");
    int swing_L_index = findSwingIndex(swing_L, false);
    drawBreakLevel(TimeToString(time(0)), time(swing_L_index), low(swing_L_index),
                   time(1), low(swing_L_index), clrRed, 1);
    swing_L = -1.0;
    double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    obj_Trade.Sell(Lots, _Symbol, Bid, Ask + stopl * _Point, Ask - takep * _Point, "BoS Break Down SELL");
}

//+------------------------------------------------------------------+
//| Find Swing Index                                                 |
//+------------------------------------------------------------------+
int findSwingIndex(double swing, bool isHigh) {
    for (int i = 0; i <= 2 * 5 + 1000; i++) {
        if ((isHigh && high(i) == swing) || (!isHigh && low(i) == swing)) {
            Print("BREAK ", (isHigh ? "HIGH" : "LOW"), " @ BAR ", i);
            return i;
        }
    }
    return 0;
}

//+------------------------------------------------------------------+
//| Helper functions                                                 |
//+------------------------------------------------------------------+
double high(int index) { return iHigh(_Symbol, _Period, index); }
double low(int index) { return iLow(_Symbol, _Period, index); }
double close(int index) { return iClose(_Symbol, _Period, index); }
datetime time(int index) { return iTime(_Symbol, _Period, index); }

void drawSwingPoint(string objName, datetime time, double price, int arrCode, color clr, int direction) {
    if (ObjectFind(0, objName) < 0) {
        ObjectCreate(0, objName, OBJ_ARROW, 0, time, price);
        ObjectSetInteger(0, objName, OBJPROP_ARROWCODE, arrCode);
        ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 10);
        ObjectSetInteger(0, objName, OBJPROP_ANCHOR, direction > 0 ? ANCHOR_TOP : ANCHOR_BOTTOM);

        string txt = " BoS";
        string objNameDescr = objName + txt;
        ObjectCreate(0, objNameDescr, OBJ_TEXT, 0, time, price);
        ObjectSetInteger(0, objNameDescr, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, objNameDescr, OBJPROP_FONTSIZE, 10);
        ObjectSetInteger(0, objNameDescr, OBJPROP_ANCHOR, direction > 0 ? ANCHOR_LEFT_UPPER : ANCHOR_LEFT_LOWER);
        ObjectSetString(0, objNameDescr, OBJPROP_TEXT, " " + txt);
    }
    ChartRedraw(0);
}

void drawBreakLevel(string objName, datetime time1, double price1, datetime time2, double price2, color clr, int direction) {
    if (ObjectFind(0, objName) < 0) {
        ObjectCreate(0, objName, OBJ_ARROWED_LINE, 0, time1, price1, time2, price2);
        ObjectSetInteger(0, objName, OBJPROP_TIME, 0, time1);
        ObjectSetDouble(0, objName, OBJPROP_PRICE, 0, price1);
        ObjectSetInteger(0, objName, OBJPROP_TIME, 1, time2);
        ObjectSetDouble(0, objName, OBJPROP_PRICE, 1, price2);
        ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);

        string txt = " Break   ";
        string objNameDescr = objName + txt;
        ObjectCreate(0, objNameDescr, OBJ_TEXT, 0, time2, price2);
        ObjectSetInteger(0, objNameDescr, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, objNameDescr, OBJPROP_FONTSIZE, 10);
        ObjectSetInteger(0, objNameDescr, OBJPROP_ANCHOR, direction > 0 ? ANCHOR_RIGHT_UPPER : ANCHOR_RIGHT_LOWER);
        ObjectSetString(0, objNameDescr, OBJPROP_TEXT, " " + txt);
    }
    ChartRedraw(0);
}
