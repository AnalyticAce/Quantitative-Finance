//+------------------------------------------------------------------+
//|                                                 PositiveSwap.mq5 |
//|                                  Copyright 2024, DOSSEH Shalom.  |
//|                                   https://github.com/AnalyticAce |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade trade;

input double Lotsize = 0.02; // Input the Volume Per Trade

int OnInit() {

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   
}

void OnTick() {

   double symbol_long_swap = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_LONG);
   double symbol_short_swap = SymbolInfoDouble(_Symbol, SYMBOL_SWAP_SHORT);

   Comment("Long Swap : ", DoubleToString(symbol_long_swap, _Digits),
         "Short Swap: ", DoubleToString(symbol_short_swap, _Digits));
   
   if(symbol_long_swap > 0) {
      if (PositionSelect(_Symbol)
          && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
          trade.PositionClose(_Symbol);
      }
      if (!PositionSelect(_Symbol)) {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         trade.PositionOpen(_Symbol,ORDER_TYPE_BUY, Lotsize, ask, 0, 0, "Long Swap is Positive");
       }
   }
   
   if (symbol_short_swap > 0) {
       if (PositionSelect(_Symbol)
           && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
           trade.PositionClose(_Symbol);
       }
      if (!PositionSelect(_Symbol)) {
      
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, Lotsize, bid, 0, 0, "Short Swap Is Positive");
       }
   }
   
}
