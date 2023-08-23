// create a simple expert advisors that sell when RSI is above 70 and buy when RSI is below 30, close buy trade when rsi is 70 close sell trade when rsi is 30

//+------------------------------------------------------------------+
//|                                                                  |
//|                  Simple RSI Expert Advisor                       |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //---
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   double rsi;
   int ticket;
   
   //--- get RSI
   rsi=iRSI(NULL,0,14,PRICE_CLOSE,0);
   
   //--- check RSI
   if(rsi>70)
   {
      //--- close buy trades
      while(OrderSelect(ticket,SELECT_BY_POS,MODE_TRADES))
         if(OrderType()==OP_BUY)
            OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,Violet);
   }
   else
   {
      if(rsi<30)
      {
         //--- close sell trades
         while(OrderSelect(ticket,SELECT_BY_POS,MODE_TRADES))
            if(OrderType()==OP_SELL)
               OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,Violet);
      }
   }
}
//+------------------------------------------------------------------+
