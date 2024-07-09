//+------------------------------------------------------------------+
//|                                                   IchiokuADX.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
#include <Indicators\Trend.mqh>

CTrade trade;
CiIchimoku ichimoku;

input group "---- General Settings ----"
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT; // Trading Timeframe
input ulong Magic = 8888; // EA Magic Number

input group "---- Indicators Settings ----"
input group "ADX Indicator"
input int adxPeriod = 100; // ADX Period

input group "Ichimoku Indicator"
input int tenkansen = 9; // Tenken-sen Value
input int kijunsen = 26; // Kijun-sen Value
input int senkouspan = 52; // SenkouSpan Value

input group "Moving Average Indicator"
input int maPeriod = 200; // Moving Average Period
input ENUM_MA_METHOD maMethod = MODE_EMA; // Moving Average Method
input ENUM_TIMEFRAMES maTimeframe = PERIOD_CURRENT; // Moving Average Timeframe

input group "---- Money Management ----"
input double lotSize = 0.05; // Volume per Trade

enum CLOSINGMETHOD {
    OPPOSITE, // Close Trade When Opposite signal is met
    STOPLOSSTAKEPROFIT // Set Take Profit and Stop Loss
};

input CLOSINGMETHOD closingMethod = OPPOSITE; // Trade Closing Method
input double SL = 50; // Set a Stop Loss
input double TP = 100; // Set a Take Profit

enum TOOGLEIT {
   YES, // Breakeven Toogled
   NO // Breakeven is not Active
};

input TOOGLEIT ToogleBreakeven = NO; // Do you Want to Trigger Breakeven ?
input double ProfitEvenTrigers = 1000; // Trigger BreakEven After

bool tenkenAboveKijun = false, tenkenBelowKijun = false;
bool FutureCloudGreen = false,  FutureCloudRed = false;
bool PriceAboveCloud = false, PriceBelowCloud = false;
bool ChikouAboveCloud = false, ChikouBelowCloud = false;

int maHandle, adxHandle;

int OnInit() {
    maHandle = iMA(_Symbol, maTimeframe, maPeriod, 0, maMethod, PRICE_CLOSE);
    adxHandle = iADX(_Symbol, timeframe, adxPeriod);

    if (maHandle == INVALID_HANDLE || adxHandle == INVALID_HANDLE) {
      Alert("Initialization failed");
      return INIT_FAILED;
    }

    ichimoku.Create(_Symbol, timeframe, tenkansen, kijunsen, senkouspan);
    trade.SetExpertMagicNumber(Magic);

    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
   if (maHandle != INVALID_HANDLE) {
      IndicatorRelease(maHandle);
   }
   if (adxHandle != INVALID_HANDLE) {
      IndicatorRelease(adxHandle);
   }
}

void setAllConditionsToFalse() {
    tenkenAboveKijun = false; 
    tenkenBelowKijun = false;
    FutureCloudGreen = false;  
    FutureCloudRed = false;
    PriceAboveCloud = false; 
    PriceBelowCloud = false;
    ChikouAboveCloud = false; 
    ChikouBelowCloud = false;
}

bool isNewBar() {
    static datetime previousTime = 0;
    datetime currentTime = iTime(_Symbol, PERIOD_CURRENT, 0);
    if (previousTime != currentTime) {
        previousTime = currentTime;
        return true;
    }
    return false;
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

void BreakEven(double AskPrice, double BidPrice)
{
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      string symbol = PositionGetSymbol(i);
      long positionType = PositionGetInteger(POSITION_TYPE);

      if (_Symbol == symbol) {
         ulong ticket = PositionGetInteger(POSITION_TICKET);
         double OpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         if (positionType == POSITION_TYPE_BUY) {
            if (AskPrice > (OpenPrice + ProfitEvenTrigers * _Point)) {
               trade.PositionModify(ticket, OpenPrice + 1, 0);                  
            }
         } else if (positionType == POSITION_TYPE_SELL) {
            if (BidPrice < (OpenPrice - ProfitEvenTrigers * _Point)) {
               trade.PositionModify(ticket, OpenPrice - 1, 0);                  
            }
         }
      }
   }
}

void OnTick() {
    if (!isNewBar()) return;

    ichimoku.Refresh(-1);
    double SpanAx1 = ichimoku.SenkouSpanA(1); 
    double SpanAx2 = ichimoku.SenkouSpanA(2); 
    double SpanAx26 = ichimoku.SenkouSpanA(26); 
    double SpanAf26 = ichimoku.SenkouSpanA(-26);
    
    double SpanBx1 = ichimoku.SenkouSpanB(1); 
    double SpanBx2 = ichimoku.SenkouSpanB(2); 
    double SpanBx26 = ichimoku.SenkouSpanB(26); 
    double SpanBf26 = ichimoku.SenkouSpanB(-26);
    
    double Tenkan = ichimoku.TenkanSen(1);
    double Kijun = ichimoku.KijunSen(1);
    double Chikou = ichimoku.ChinkouSpan(26);
    
    double Closex1 = iClose(_Symbol, timeframe, 1); 
    double Closex2 = iClose(_Symbol, timeframe, 2);
    
    if (SpanBf26 > SpanAf26) { 
        FutureCloudGreen = false; 
        FutureCloudRed = true;
    }
    
    if (PriceAboveCloud == false && (Closex2 < SpanAx2 || Closex2 < SpanBx2)
        && Closex1 > SpanAx1 && Closex1 > SpanBx1) { 
        PriceAboveCloud = true;
        PriceBelowCloud = false;   
    }
    
    if (PriceBelowCloud == false && (Closex2 > SpanAx2 || Closex2 > SpanBx2)
        && Closex1 < SpanAx1 && Closex1 < SpanBx1) { 
        PriceAboveCloud = false;
        PriceBelowCloud = true;
    }

    if (Tenkan > Kijun) {
        tenkenAboveKijun = true; 
        tenkenBelowKijun = false;
    }
    
    if (Tenkan < Kijun) {
        tenkenAboveKijun = false; 
        tenkenBelowKijun = true;
    }
    
    if (SpanAx1 > SpanBx1 && Closex1 > SpanBx1 && Closex1 < SpanAx1) {
        PriceAboveCloud = false;
        PriceBelowCloud = false;
    }
    
    if (SpanBx1 > SpanAx1 && Closex1 > SpanAx1 && Closex1 < SpanBx1) {
        PriceAboveCloud = false; 
        PriceBelowCloud = false;
    }
    
    if(Chikou < SpanAx26 && Chikou < SpanBx26) {
      ChikouAboveCloud = false; 
      ChikouBelowCloud = true;
    }
    
    if(SpanAx26 > SpanBx26 && Chikou > SpanBx26 && Chikou < SpanAx26) {
      ChikouAboveCloud = false; 
      ChikouBelowCloud = false;
   }
   
   if(SpanBx26 > SpanAx26 && Chikou > SpanAx26 && Chikou < SpanBx26) {
      ChikouAboveCloud = false; 
      ChikouBelowCloud = false;
   }
      
    bool sellAdx = false;
    bool buyAdx = false;
    double adxDiPlus[], adxDiMinus[], adxArr[], maArr[];
    
    if (CopyBuffer(adxHandle, 0, 0, 1, adxArr) <= 0 || 
        CopyBuffer(adxHandle, 1, 0, 1, adxDiPlus) <= 0 ||
        CopyBuffer(adxHandle, 2, 0, 1, adxDiMinus) <= 0) {
        Print("Error copying ADX indicator buffer");
        return;
    }
    
    if (CopyBuffer(maHandle, 0, 0, 1, maArr) <= 0) {
       Print("Error copying Moving Average indicator buffer");
       return;
    }
    
    double adxVal = NormalizeDouble(adxArr[0], _Digits);
    double adxPlus = NormalizeDouble(adxDiPlus[0], _Digits);
    double adxMinus = NormalizeDouble(adxDiMinus[0], _Digits);
    double maVal = NormalizeDouble(maArr[0], _Digits);

    if (/*maVal < Closex1 &&*/ adxMinus < adxPlus && tenkenAboveKijun /*&& FutureCloudGreen && PriceAboveCloud && ChikouAboveCloud*/) {
        buyAdx = true;
    } else if (/*maVal > Closex1 &&*/ adxMinus > adxPlus && tenkenBelowKijun /*&& FutureCloudRed && PriceBelowCloud && ChikouBelowCloud*/) {
        sellAdx = true;
    }

    Comment(
        "ADX value : " + DoubleToString(adxVal, 2) + "\n" +
        "DI Plus : " + DoubleToString(adxPlus, 2) + "\n" +
        "DI Minus : " + DoubleToString(adxMinus, 2) + "\n" +
        "Tenkan > Kijun: " + (string)tenkenAboveKijun + "\n" +
        "Tenkan < Kijun:" + (string)tenkenBelowKijun + "\n" +
        "Sell (adxMinus > adxPlus && tenkenBelowKijun): " + (string)sellAdx + "\n" +
        "Buy (adxMinus < adxPlus && tenkenAboveKijun): " + (string)buyAdx + "\n" +
        "\nServer Time : " + (string)TimeCurrent()
    );

    if (buyAdx) {
        if (PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
            trade.PositionClose(_Symbol);
        }
        if (!PositionSelect(_Symbol)) {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double entry = Closex1;
            double stoploss = ask - SL * _Point;
            double takeprofit = ask + TP * _Point;
            Print("BUY Order: Ask=", ask, ", StopLoss=", stoploss, ", TakeProfit=", takeprofit);
            if (closingMethod == STOPLOSSTAKEPROFIT) {
               trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, lotSize, ask, stoploss, takeprofit, "Buy :)");
            } else if (closingMethod == OPPOSITE) {
               trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, lotSize, ask, 0, 0, "Buy :)");
            }
        }
    } else if (sellAdx) {
        if (PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
            trade.PositionClose(_Symbol);
        }
        if (!PositionSelect(_Symbol)) {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double entry = Closex1;
            double stoploss = bid + SL * _Point;
            double takeprofit = bid - TP * _Point;
            Print("SELL Order: Bid=", bid, ", StopLoss=", stoploss, ", TakeProfit=", takeprofit);
            if (closingMethod == STOPLOSSTAKEPROFIT) {
               trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, lotSize, bid, stoploss, takeprofit, "Sell :)");
            } else if (closingMethod == OPPOSITE) {
               trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, lotSize, bid, 0, 0, "Sell :)");
            }
         }
    }
}
