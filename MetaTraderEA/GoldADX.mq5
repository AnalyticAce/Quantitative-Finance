//+------------------------------------------------------------------+
//|                                                     MultiEMA.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

/*
Todo:
-----
* Add time filter, close all open trades on fridays at 6pm and Open trade every monday at 9
* Close all open trades where a specified profit target is reached.
* Add Range Breakout, set stop loss at the low of the range.
* Breakeven when the price moves once the size of the range. Modify the SL to (OpenPrice + 5points)
* Implement support and resitance confirmation.
* Handling the input errors
* Dynamic Lot Sizing
*/

#include <Trade\Trade.mqh>
CTrade trade;

input group "====== Indicator & EA Setings ======"
input ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT;
input int ADXPeriod = 100; // This is the ADX Period
input ulong Magic = 8888; // Choose a Magic Number for the EA

enum LOTSIZING {
   DYNAMIC,
   FIXED,
};

input group "===== Money Management ====="
input LOTSIZING SizeTechn = FIXED; // Choose Volume Sizing Method
input double RiskPercent = 1; // Choose Percentage of Capital Per Trade
input double LotSize = 0.02; // Choose the Volume per Trade

input group "===== Time Filter ====="
input int StartDayOfWeek = 1; // Choose Trade Start DayOfWeek
input int StartHour = 9; // Choose Trade Start Hour
input int StartMin = 0; // Choose Trade Start Minute

input int EndDayOfWeek = 5; // Choose Trade End DayOfWeek
input int EndHour = 18; // Choose Trade End Hour
input int EndMin = 0; // // // Choose Trade Start Minute

input group "====== Securing Profit ======"
bool TrailingStop = false; // Enable Trailing Stop Mechanism
bool TrailingPoints = 50; // Trail Stop Loss Every Specified Points
input double ProfitEvenTrigers = 1000; // After how Many Points in Profit we Triger BreakEven
input double TargetProfit = 200; // All Open Trade Will be Closed When Target Profit is Reached

int OnInit() {
    trade.SetExpertMagicNumber(Magic);
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
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

void OnTick()
{
    bool sell_adx = false;
    bool buy_adx = false;
    int ADXhandle;
    double ADX_di_plus[], ADX_di_minus[], ADX_arr[];
    
    // time filtering
    MqlDateTime structTime;
    TimeCurrent(structTime);

    structTime.day_of_week = StartDayOfWeek;
    structTime.hour        = StartHour;
    structTime.min         = StartMin;
    structTime.sec         = 0;
    datetime timeStart     = StructToTime(structTime);

    structTime.day_of_week = EndDayOfWeek;
    structTime.hour        = EndHour;
    structTime.min         = EndMin;
    structTime.sec         = 0;
    datetime timeEnd     = StructToTime(structTime);
    
    bool TimeFilter = TimeCurrent() >= timeStart && TimeCurrent() < timeEnd;
    
    ADXhandle = iADX(_Symbol, PERIOD_CURRENT, ADXPeriod);
    CopyBuffer(ADXhandle, 0, 0, 1, ADX_arr);
    CopyBuffer(ADXhandle, 1, 0, 1, ADX_di_plus);
    CopyBuffer(ADXhandle, 2, 0, 1, ADX_di_minus);
   
    double ADX_min = NormalizeDouble(ADX_di_plus[0], _Digits);
    double ADX_plus = NormalizeDouble(ADX_di_minus[0], _Digits);
    double ADX_val = NormalizeDouble(ADX_arr[0], _Digits);
      
      if (ADX_min < ADX_plus) {
         sell_adx = true;
      } else if (ADX_min > ADX_plus) {
         buy_adx = true;
      }
      
      Comment(
         "ADX value : " + DoubleToString(ADX_val, 2), "\n" +
         "DI Plus : " + DoubleToString(ADX_plus, 2), "\n" +
         "DI Minus : " + DoubleToString(ADX_min, 2), "\n" +
         "Sell (ADX_min > ADX_plus): " + (string)sell_adx, "\n" +
         "Buy (ADX_min < ADX_plus): " + (string)buy_adx, "\n",
         "\nSever Time : ", TimeCurrent(),
         "\nTrades can Only be Opened : ", timeStart,
         "\nAll Open Trades will be Closed On: ", timeEnd
      );
   
    double AskPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    double BidPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    double isProfit = (AccountInfoDouble(ACCOUNT_EQUITY) - AccountInfoDouble(ACCOUNT_BALANCE)) > TargetProfit;
    
    double Close1 = iClose(_Symbol, Timeframe, 1);
    double Close2 = iClose(_Symbol, Timeframe, 2);
    
    // strategy
    if (buy_adx) {
        // Close sell trade if open
        if (PositionSelect(_Symbol)
            && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
            trade.PositionClose(_Symbol);
        }
        
        if (!PositionSelect(_Symbol)) {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, LotSize, ask, 0, 0, "Buy :)");
        }
    }

    else if (sell_adx) {
        if (PositionSelect(_Symbol)
            && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
            trade.PositionClose(_Symbol);
        }

        if (!PositionSelect(_Symbol)) {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, LotSize, bid, 0, 0, "Sell :)");
        }
    }
    //BreakEven(AskPrice, BidPrice);
}
