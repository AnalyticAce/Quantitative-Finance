#include <Trade\Trade.mqh>
CTrade trade;

int handlebb;
int totalbar;

input ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT;
input int Periods = 20;

input double Deviation = 2.0;
input ENUM_APPLIED_PRICE ApplyP = PRICE_CLOSE;

input double lot = 0.2;

int OnInit()
{
   totalbar = iBars(_Symbol, Timeframe);
   handlebb = iBands(_Symbol,Timeframe, Periods, 0, Deviation, ApplyP);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   

}

void OnTick() {
   int bars = iBars(_Symbol, Timeframe);
   if (totalbar < bars) {
      totalbar = bars;
      double bbupper[], bbmiddle[], bblower[];
      CopyBuffer(handlebb,BASE_LINE,1,2,bbmiddle);
      CopyBuffer(handlebb,UPPER_BAND,1,2,bbupper);
      CopyBuffer(handlebb,LOWER_BAND,1,2,bblower);
      double close1 = iClose(_Symbol,Timeframe,1);
      double close2 = iClose(_Symbol,Timeframe,2);
      double distance = bbupper[1] - bblower[1];
      
      for(int i = PositionsTotal() - 1; i >= 0; --i) {
         ulong posTicket = PositionGetTicket(i);
         
         if(PositionSelectByTicket(posTicket)) {
            double posLots = PositionGetDouble(POSITION_VOLUME);
            double posSl = PositionGetDouble(POSITION_SL);
            double posTp = PositionGetDouble(POSITION_TP);
            
            ENUM_POSITION_TYPE posType = ENUM_POSITION_TYPE(PositionGetInteger(POSITION_TYPE));
            
            double lotstoclose = posLots / 2;
            lotstoclose = NormalizeDouble(lotstoclose, 2);
            if(posType == POSITION_TYPE_BUY && close1 > bbmiddle[0] 
               && posLots == lot && trade.PositionClosePartial(posTicket, lotstoclose)) {
               Print("pos # ", posTicket, "was partially closed..");
               posLots = lot - lotstoclose;  
               
               if (posLots < lot) {
                  double sl = bblower[1];
                  sl = NormalizeDouble(sl, _Digits);
                  
                  if(sl > posSl && trade.PositionModify(posTicket, sl, posTp)) {
                     Print("pos # ", posTicket, "was modified by trailing stop..");
                  }
               }
            } else if(posType == POSITION_TYPE_SELL && close1 < bbmiddle[0] 
               && posLots == lot && trade.PositionClosePartial(posTicket, lotstoclose)) {
               Print("pos # ", posTicket, "was partially closed..");
               posLots = lot - lotstoclose;
               
               if (posLots < lot) {
                  double sl = bblower[1];
                  sl = NormalizeDouble(sl, _Digits);
                  if(sl < posSl && trade.PositionModify(posTicket, sl, posTp)) {
                     Print("pos # ", posTicket, "was modified by trailing stop..");
                  }
               }
            }
         }
      }
      
      if(close1 > bbupper[1] && close2 > bbupper[0]) { 
         Print("Close is above bbupper"); 
         
         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         bid = NormalizeDouble(bid, _Digits);
         
         double sl = bid + distance;
         sl = NormalizeDouble(sl, _Digits);
         
         double tp = bid - distance;
         tp = NormalizeDouble(tp, _Digits);
         
         trade.Sell(lot,_Symbol,bid,sl,tp,"Sell");
      } else if (close1 < bblower[1] && close2 < bblower[0]) { 
         Print("Close is below bblower"); 
         
         double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         ask = NormalizeDouble(ask,_Digits);
         
         double sl = ask - distance;
         sl = NormalizeDouble(sl,_Digits);
         
         double tp = ask + distance;
         tp = NormalizeDouble(tp,_Digits);
         
         trade.Buy(lot,_Symbol,ask,sl,tp,"Buy");   
      }
   }
}
