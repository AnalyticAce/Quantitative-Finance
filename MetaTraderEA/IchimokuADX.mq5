//+------------------------------------------------------------------+
//|                                                     ADXULTIM.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
CTrade trade;
#include <Indicators\Trend.mqh>
CiIchimoku ichimoku;

input group "Indicators Settings"
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT;
input int adxPeriod = 100; // This is the ADX Period

input int tenkansen = 9; // Choose Tenken-sen Value
input int kijunsen = 26; // Choose Kijun-sen Value
input int senkouspan = 52; // Choose SenkouSpan Value

input group "Money Management"
input double lotSize = 0.05; // Choose the Volume per Trade

input group "EA Settings"
input ulong Magic = 8888; // Choose a Magic Number for the EA

bool tenkenAboveKijun = false, tenkenBelowKijun = false;

int OnInit() {

   ichimoku = new CiIchimoku();
   ichimoku.Create(_Symbol, timeframe, tenkansen, kijunsen, senkouspan);
   
   trade.SetExpertMagicNumber(Magic);
   return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
}

void setAllConditionsToFalse() {
   tenkenAboveKijun = false; 
   tenkenBelowKijun = false;  
}

bool isNewBar() {
   static datetime previousTime = 0;
   datetime currentTime = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(previousTime != currentTime) {
      return true;
   }
   return false;
}

void closeWhen(bool condition)
{
   if(condition) {
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket)) {
            if(trade.PositionClose(ticket)) {
               Print("Close Position ticket #", ticket,
               " because condition is met");
            }
         }
      }
   }
}

void OnTick() {

    if(!isNewBar()) return;
   
    ichimoku.Refresh(-1);

    double tenkan = ichimoku.TenkanSen(1);
    double kijun = ichimoku.KijunSen(1);
    double chikou = ichimoku.ChinkouSpan(26);

   if(tenkan > kijun) {
      tenkenAboveKijun = true; 
      tenkenBelowKijun = false;
   }
   
   if(tenkan < kijun) {
      tenkenAboveKijun = false; 
      tenkenBelowKijun = true;
   }
   
    bool sellAdx = false;
    bool buyAdx = false;
    int adxHandle;
    double adxDiPlus[], adxDiMinus[], adxArr[];
    
    adxHandle = iADX(_Symbol, PERIOD_CURRENT, adxPeriod);
    if(adxHandle == INVALID_HANDLE) {
        Print("Error creating ADX indicator handle");
        return;
    }
    
    if(CopyBuffer(adxHandle, 0, 0, 1, adxArr) <= 0 || 
       CopyBuffer(adxHandle, 1, 0, 1, adxDiPlus) <= 0 ||
       CopyBuffer(adxHandle, 2, 0, 1, adxDiMinus) <= 0) {
        Print("Error copying ADX indicator buffer");
        return;
    }
    
    double adxVal = NormalizeDouble(adxArr[0], _Digits);
    double adxPlus = NormalizeDouble(adxDiPlus[0], _Digits);
    double adxMinus = NormalizeDouble(adxDiMinus[0], _Digits);

    if (adxMinus < adxPlus && tenkenAboveKijun) {
        buyAdx = true;
    } else if (adxMinus > adxPlus && tenkenBelowKijun) {
        sellAdx = true;
    }
      
    Comment(
        "ADX value : " + DoubleToString(adxVal, 2), "\n" +
        "DI Plus : " + DoubleToString(adxPlus, 2), "\n" +
        "DI Minus : " + DoubleToString(adxMinus, 2), "\n" +
        "Tenkan > Kijun: " + (string)tenkenAboveKijun, "\n" +
        "Tenkan < Kijun:" + (string)tenkenBelowKijun, "\n" +
        "Sell (adxMinus > adxPlus && tenkenAboveKijun): " + (string)sellAdx, "\n" +
        "Buy (adxMinus < adxPlus && tenkenBelowKijun): " + (string)buyAdx, "\n",
        "\nServer Time : ", (string)TimeCurrent()
    );

    if (buyAdx) {
        if(PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
            trade.PositionClose(_Symbol);
        }
        if (!PositionSelect(_Symbol)) {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, lotSize, ask, 0, 0, "Buy :)");
        }
    } else if (sellAdx) {
        if(PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
            trade.PositionClose(_Symbol);
        }
        if (!PositionSelect(_Symbol)) {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, lotSize, bid, 0, 0, "Sell :)");
        }
    }
}
