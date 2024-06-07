//+------------------------------------------------------------------+
//|                                                      GoldADX.mq5 |
//|                                    Copyright 2024, DOSSEH Shalom |
//|                                   https://github.com/AnalyticAce |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
CTrade trade;

input group "====== Trade Setings ======"
input ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT;
input int ADXPeriod = 100; // This is the ADX Period
input ulong Magic = 8888; // Choose a Magic Number for the EA
input double lot_size = 0.02; // Choose the Volume per Trade

input group "====== BreakEven Settings ======"
input double ProfitEvenTrigers = 1000; // After how Many Points in Profit we Triger BreakEven

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

string BoolToString(bool b) {
    return b ? "true" : "false";
}

void OnTick()
{
    bool sell_adx = false;
    bool buy_adx = false;
    int ADXhandle;
    double ADX_di_plus[], ADX_di_minus[], ADX_arr[];
    
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
         "Sell (ADX_min > ADX_plus): " + BoolToString(sell_adx), "\n" +
         "Buy (ADX_min < ADX_plus): " + BoolToString(buy_adx), "\n"
      );
   
    double AskPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    double BidPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    
    double Close1 = iClose(_Symbol, Timeframe, 1);
    double Close2 = iClose(_Symbol, Timeframe, 2);

    /*int value = CopyBuffer(em50handle, 0, 0, 2, em50buffer);
    if (value != 2) {
        Alert("Not enough data for the EMA 50");
        return;
    }*/
    
    // strategy
    if (buy_adx) {
        // Close sell trade if open
        if (PositionSelect(_Symbol)
            && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
            trade.PositionClose(_Symbol);
        }
        
        if (!PositionSelect(_Symbol)) {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, lot_size, ask, 0, 0, "Buy :)");
        }
    }

    else if (sell_adx) {
        if (PositionSelect(_Symbol)
            && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
            trade.PositionClose(_Symbol);
        }

        if (!PositionSelect(_Symbol)) {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, lot_size, bid, 0, 0, "Sell :)");
        }
    }
    //BreakEven(AskPrice, BidPrice);
}
