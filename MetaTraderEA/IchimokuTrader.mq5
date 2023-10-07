#property copyright "Copyright 2023, Dosseh Shalom."
#property version   "1.00"

#include <Trade\Trade.mqh>
CTrade trade;

#include <Indicators\Trend.mqh>
CiIchimoku ichimoku;

input int Tenkansen = 9;
input int Kijunsen = 26;
input int Senkouspan = 52;

input ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT;
input ulong Magic = 8888;
input double RiskPercent = 10;

bool FutureCloudGreen = false,  FutureCloudRed = false;
bool PriceAboveCloud = false, PriceBelowCloud = false;
bool TenkenAboveKijun = false, TenkenBelowKijun = false;
bool ChikouAboveCloud = false, ChikouBelowCloud = false;


int OnInit() {
   trade.SetExpertMagicNumber(Magic);
   
   ichimoku = new CiIchimoku();
   ichimoku.Create(_Symbol, Timeframe, Tenkansen, Kijunsen, Senkouspan);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   
}


void SetAllConditionstofalse() {
   FutureCloudGreen = false;  FutureCloudRed = false;
   PriceAboveCloud = false; PriceBelowCloud = false;
   TenkenAboveKijun = false; TenkenBelowKijun = false;
   ChikouAboveCloud = false; ChikouBelowCloud = false;   
}

bool IsNewBar() {
   static datetime previousTime = 0;
   datetime currentTime = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(previousTime != currentTime) {
      return true;
   }
   return false;
}

double calclots(double slPoints) {
   double risk = AccountInfoDouble(ACCOUNT_BALANCE) * RiskPercent / 100;
   
   double ticksize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickvalue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE); 
   double lotstep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   double moneyPerLotstep = slPoints / ticksize * tickvalue * lotstep; 
   double lots = MathFloor(risk/ moneyPerLotstep) * lotstep;
   
   double minvolume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN); 
   double maxvolume = SymbolInfoDouble (Symbol(), SYMBOL_VOLUME_MAX); 
   
   if(maxvolume != 0) lots = MathMin(lots, maxvolume);
   if(minvolume != 0) lots = MathMax(lots,minvolume);
   
   lots = NormalizeDouble(lots, 2);
   return lots;
}

void OnTick() {
   if(!IsNewBar()) return;
   
   ichimoku.Refresh(-1);
   
   double SpanAx1 = ichimoku.SenkouSpanA(1); 
   double SpanAx2 = ichimoku.SenkouSpanA(2); 
   double SpanAx26 = ichimoku.SenkouSpanA(26); 
   double SpanAf26 = ichimoku.SenkouSpanA(-26);
   
   double SpanBx1 = ichimoku.SenkouSpanB(1); 
   double SpanBx2 = ichimoku.SenkouSpanB(2); 
   double SpanBx26 = ichimoku.SenkouSpanB(26); 
   double SpanBf26 = ichimoku. SenkouSpanB(-26);
   
   double Tenkan = ichimoku.TenkanSen(1);
   double Kijun = ichimoku.KijunSen(1);
   double Chikou = ichimoku.ChinkouSpan(26);
   
   double Closex1 = iClose (_Symbol, Timeframe, 1); 
   double Closex2 = iClose(_Symbol, Timeframe, 2);
   
   if(SpanBf26 > SpanAf26) { 
      FutureCloudGreen = false; 
      FutureCloudRed = true;
   }
   
   if(PriceAboveCloud == false && (Closex2 < SpanAx2 || Closex2 < SpanBx2) 
      && Closex1 > SpanAx1 && Closex1>SpanBx1) { 
      PriceAboveCloud = true;
      PriceBelowCloud = false;   
   } 
   
   if(PriceBelowCloud == false && (Closex2>SpanAx2 || Closex2>SpanBx2) 
      && Closex1<SpanAx1 && Closex1<SpanBx1) { 
      PriceAboveCloud = false;
      PriceBelowCloud = true;
   }

   if(Tenkan > Kijun) {
      TenkenAboveKijun = true; 
      TenkenBelowKijun = false;
   }
   
   if(Tenkan < Kijun) {
      TenkenAboveKijun = false; 
      TenkenBelowKijun = true;
   }

   if(Chikou < SpanAx26 && Chikou < SpanBx26){
      ChikouAboveCloud = false; 
      ChikouBelowCloud = true;
   }
   
   if(SpanAx1 > SpanBx1 && Closex1 > SpanBx1 && Closex1 < SpanAx1){
      PriceAboveCloud = false;
      PriceBelowCloud = false;
   }
   
   if(SpanBx1 > SpanAx1 && Closex1 > SpanAx1 && Closex1 < SpanBx1){
      PriceAboveCloud = false; 
      PriceBelowCloud = false;
   }
   
   if(SpanAx26 > SpanBx26 && Chikou > SpanBx26 && Chikou < SpanAx26){
      ChikouAboveCloud = false; 
      ChikouBelowCloud = false;
   }
   
   if(SpanBx26 > SpanAx26 && Chikou > SpanAx26 && Chikou < SpanBx26){
      ChikouAboveCloud = false; 
      ChikouBelowCloud = false;
   }

   Comment("\n PriceaboveCloud: " + PriceAboveCloud +
            "\n Tenkan > Kijun: " + TenkenAboveKijun +
            "\n ChikouaboveCloud: " + ChikouAboveCloud + 
            "\n FutureCloudGreen: " + FutureCloudGreen +
            "\n PricebelowCloud: " + PriceBelowCloud + 
            "\n Tenkan < Kijun:" + TenkenBelowKijun + 
            "\n ChikoubelowCloud: " + ChikouBelowCloud + 
            "\n FutureCloudRed: "+ FutureCloudRed 
   );
   
   if(FutureCloudGreen == true && PriceAboveCloud == true
      && TenkenAboveKijun == true && ChikouAboveCloud == true) { 
      double entry = Closex1;
      double sl = Kijun + 50 * _Point;
      double tp = entry + (entry - sl) * 2;
      double lots = /*0.2;*/calclots(entry - sl);
      trade.Buy(lots, _Symbol, entry, sl, tp, "Buy It");
      SetAllConditionstofalse();
   }
   if(FutureCloudRed == true && PriceBelowCloud == true
      && TenkenBelowKijun == true && ChikouBelowCloud == true) { 
      double entry = Closex1;
      double sl = Kijun + 50 * _Point;
      double tp = entry - (sl - entry) * 2;
      double lots = /*0.2;*/calclots(sl - entry);
      trade.Sell(lots, _Symbol, entry, sl, tp, "Buy It");
      SetAllConditionstofalse();
   }
}
