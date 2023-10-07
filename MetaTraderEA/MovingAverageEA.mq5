#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>

CTrade trade;

input ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT;
input ulong Magic = 8888;
input double RiskPercent = 10;

input int fastperiod = 200;
input int slowperiod = 31;

input int stop_loss = 10;
input int take_profit = 50;

int slowhandle;
int fasthandle;
double fastbuffer[];
double slowbuffer[];

datetime opentimebuy = 0;
datetime opentimesell = 0;

int OnInit() {
   fasthandle = iMA(_Symbol, PERIOD_CURRENT, fastperiod, 0, MODE_EMA, PRICE_CLOSE);
   if (fasthandle == INVALID_HANDLE) {
      Alert("FastHandle init failed");
      return INIT_FAILED;
   }

   slowhandle = iMA(_Symbol, PERIOD_CURRENT, slowperiod, 0, MODE_SMA, PRICE_CLOSE);
   if (slowhandle == INVALID_HANDLE) {
      Alert("Slowhandle init failed");
      return INIT_FAILED;
   }

   ArraySetAsSeries(fastbuffer, true);
   ArraySetAsSeries(slowbuffer, true);
   return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   if (fasthandle != INVALID_HANDLE) {
      IndicatorRelease(fasthandle);
   }
   if (slowhandle != INVALID_HANDLE) {
      IndicatorRelease(slowhandle);
   }
}

void OnTick() {
   int value = CopyBuffer(fasthandle, 0, 0, 2, fastbuffer);
   if (value != 2) {
      Alert("Not enough data for the fast ma");
      return;
   }

   value = CopyBuffer(slowhandle, 0, 0, 2, slowbuffer);
   if (value != 2) {
      Alert("Not enough data for the slow ma");
      return;
   }

   Comment("ema[0]:", fastbuffer[0], "\n",
           "ema[1]:", fastbuffer[1], "\n",
           "ma[0]:", slowbuffer[0], "\n",
           "ma[1]:", slowbuffer[1]);

   if (fastbuffer[1] >= slowbuffer[1] && fastbuffer[0] < slowbuffer[0]) {
      // Close any open sell positions before opening a buy position
      if (PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
         trade.PositionClose(_Symbol);
      }

      if (opentimebuy != iTime(_Symbol,PERIOD_CURRENT,0)) {
         opentimebuy = iTime(_Symbol,PERIOD_CURRENT,0);
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, 0.5, ask, 0, 0, "Buy");
      }
   }

   if (fastbuffer[1] <= slowbuffer[1] && fastbuffer[0] > slowbuffer[0]) {
      // Close any open buy positions before opening a sell position
      if (PositionSelect(_Symbol) && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
         trade.PositionClose(_Symbol);
      }

      if (opentimesell != iTime(_Symbol,PERIOD_CURRENT,0)) {
         opentimesell = iTime(_Symbol,PERIOD_CURRENT,0);
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, 0.5, bid, 0, 0, "Sell");
      }
   }
}
