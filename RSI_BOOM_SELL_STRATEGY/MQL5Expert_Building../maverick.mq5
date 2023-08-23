// Import the CTrade class
#include <Trade\Trade.mqh>

// Define input parameters
input double lotSize = 0.2; // Lot size for the sell trade
input int rsiPeriod = 14;   // Period for RSI indicator
input double overboughtLevel = 70; // RSI overbought level

CTrade trade;

void OnTick() {

   double   open_1  = iOpen(Symbol(),Period(),2);
   double   close_1 = iClose(Symbol(),Period(),2);
   double   open_2  = iOpen(Symbol(),Period(),1);
   double   close_2 = iClose(Symbol(),Period(),1);
   double   open_3  = iOpen(Symbol(),Period(),0);
   double   close_3 = iClose(Symbol(),Period(),0);
   
   double RSIArray[];
    
   int RSIDef = iRSI(_Symbol, 0, rsiPeriod, PRICE_CLOSE);
   ArraySetAsSeries(RSIArray, true);
    
   CopyBuffer(RSIDef, 0, 0, 1, RSIArray);
   double RSIValue = NormalizeDouble(RSIArray[0], 2);
   
   if (RSIValue > overboughtLevel) {
        // Check candle conditions
       bool condition1 = (close_1 < open_1); // Condition 1: Confirmation candle is green
       bool condition2 = (close_2 > open_2); // Condition 2: Previous candle is red
       bool condition3 = (close_3 < open_3);  // Condition 3: Current candle is red

        // Check all conditions
       if (condition1 && condition2 && condition3)
       Comment("Hello");
   }
}
