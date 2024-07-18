//+------------------------------------------------------------------+
//|                                                  IchimokuADX.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
#include <Indicators\Trend.mqh>

CTrade trade;
CiIchimoku ichimoku;

input group "==== General Settings ===="
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT; // Trading Timeframe
input ulong Magic = 8888; // EA Magic Number

input group "==== Indicators Settings ===="
input group "=== ADX Indicator ==="
input int adxPeriod = 100; // ADX Period
/*
input group "=== RSI Indicator ==="
input int rsiPeriod = 14; // RSI Period
input int overBought = 70; // OverBought Level
input int overSold = 30; // OverSold Level
*/
input group "=== Ichimoku Indicator ==="
input int tenkansen = 9; // Tenken-sen Value
input int kijunsen = 26; // Kijun-sen Value
input int senkouspan = 52; // SenkouSpan Value

input group "=== Moving Average Indicator ==="
input int maPeriod = 200; // Moving Average Period
input ENUM_MA_METHOD maMethod = MODE_EMA; // Moving Average Method
input ENUM_TIMEFRAMES maTimeframe = PERIOD_CURRENT; // Moving Average Timeframe

input group "==== Money Management ===="
input group "=== Volume Sizing ==="
enum SIZINGMETHOD {
   DYNAMIC, // Dynamic Volume Sizing (Lot Size Based on Risk Per Trade)
   FIXED // Fixed Volume Sizing
};

input SIZINGMETHOD sizingMethod = FIXED; // Choose a Sizing Method
input double lotSize = 0.05; // Volume per Trade
input double RiskPercent = 10; // If Sizing Method is Dynamic Choose a Risk %

input group "=== Trade Management ==="
enum CLOSINGMETHOD {
    OPPOSITE, // Close Trade When Opposite signal is met
    STOPLOSSTAKEPROFIT // Set Take Profit and Stop Loss
};

input CLOSINGMETHOD closingMethod = OPPOSITE; // Trade Closing Method
input double SL = 50; // Set a Stop Loss
input double TP = 150; // Set a Take Profit

enum TOOGLEIT {
   YES, // Enable
   NO  // Disable
};

input group "== BreakEven =="
input TOOGLEIT ToogleBreakeven = NO; // Do you Want to Trigger Breakeven ?
input double ProfitEvenTrigers = 1000; // Trigger BreakEven After

input group "== Trailing Stop =="
input TOOGLEIT ToogleTrailingStop = NO; // Do you Want to Trigger Trailing Stop ?
input int InpTrallingPoints = 200;
input int InpMinProfit = 10;
input int InpTraillingStep = 20;

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
    
    if (ToogleTrailingStop == YES && ToogleBreakeven == YES) {
      Alert("Please you can't Toogle TrailingStop and Breakeven Mechanism At the same time");
      return INIT_PARAMETERS_INCORRECT;
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
               trade.PositionModify(ticket, OpenPrice + 3, 0);                  
            }
         } else if (positionType == POSITION_TYPE_SELL) {
            if (BidPrice < (OpenPrice - ProfitEvenTrigers * _Point)) {
               trade.PositionModify(ticket, OpenPrice - 3, 0);                  
            }
         }
      }
   }
}

void TrailingStop()
{
    for (int i = 0; i < PositionsTotal(); i++) {
        // Get ticket number
        ulong ticket = PositionGetTicket(i);
        if (ticket == 0)
            continue;

        if (PositionSelectByTicket(ticket)) {
            if (PositionGetInteger(POSITION_MAGIC) == Magic) {
                // Modify trailing stop
                double TrailingStopPrice;
                double currentProfit;

                long positionType = PositionGetInteger(POSITION_TYPE);
                double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);

                // Input to point
                double MinimumProfit = InpMinProfit * _Point;
                double TrailingStep = InpTraillingStep * _Point;
                double TrailingPoint = InpTrallingPoints * _Point;

                // Get current SL & TP
                double CurrentSL = PositionGetDouble(POSITION_SL);
                CurrentSL = NormalizeDouble(CurrentSL, _Digits);

                // Get current ask and bid
                double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
                double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

                if (positionType == POSITION_TYPE_BUY) {
                    TrailingStopPrice = bid - TrailingPoint;
                    TrailingStopPrice = NormalizeDouble(TrailingStopPrice, _Digits);
                    currentProfit = bid - openPrice;
                    // Check if we need to move the trailing stop
                    if (TrailingStopPrice > CurrentSL &&
                        currentProfit >= MinimumProfit &&
                        (TrailingStopPrice - CurrentSL) >= TrailingStep) {
                        if (!trade.PositionModify(ticket, TrailingStopPrice, 0)) {
                            Print("Failed to modify buy position: ", trade.ResultRetcode());
                        } else {
                            Print("Trailing stop updated for buy position: ", ticket);
                        }
                    }
                } else if (positionType == POSITION_TYPE_SELL) {
                    TrailingStopPrice = ask + TrailingPoint;
                    TrailingStopPrice = NormalizeDouble(TrailingStopPrice, _Digits);
                    currentProfit = openPrice - ask;
                    if (TrailingStopPrice < CurrentSL &&
                        currentProfit >= MinimumProfit &&
                        (CurrentSL - TrailingStopPrice) >= TrailingStep) {
                        if (!trade.PositionModify(ticket, TrailingStopPrice, 0)) {
                            Print("Failed to modify sell position: ", trade.ResultRetcode());
                        } else {
                            Print("Trailing stop updated for sell position: ", ticket);
                        }
                    }
                }
            }
        }
    } 
}

double calclots(double slPoints) {
    double risk = AccountInfoDouble(ACCOUNT_BALANCE) * RiskPercent / 100;
    double ticksize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    double tickvalue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double lotstep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

    double moneyPerLotstep = slPoints / ticksize * tickvalue * lotstep;
    double lots = MathFloor(risk / moneyPerLotstep) * lotstep;

    double minvolume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
    double maxvolume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);

    if (maxvolume != 0)
        lots = MathMin(lots, maxvolume);
    if (minvolume != 0)
        lots = MathMax(lots, minvolume);

    lots = NormalizeDouble(lots, 2);
 
    return lots;
}

void ClosePosition(bool isBuy)
{
    if (PositionSelect(_Symbol) && 
        PositionGetInteger(POSITION_TYPE) == (isBuy ? POSITION_TYPE_SELL : POSITION_TYPE_BUY)) {
        trade.PositionClose(_Symbol);
    }
}

void OpenPosition(bool isBuy)
{
    double price = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double stoploss = isBuy ? (price - SL * _Point) : (price + SL * _Point);
    double takeprofit = isBuy ? (price + TP * _Point) : (price - TP * _Point);
    double calculatedLot = calclots(stoploss);
    ENUM_ORDER_TYPE orderType = isBuy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
    string orderTypeStr = isBuy ? "Buy :)" : "Sell :)";
    
    Print(orderTypeStr, " Order: ", isBuy ? "Ask=" : "Bid=", price, ", StopLoss=", stoploss, ", TakeProfit=", takeprofit);

    if (closingMethod == STOPLOSSTAKEPROFIT && sizingMethod == FIXED) {
        trade.PositionOpen(_Symbol, orderType, lotSize, price, stoploss, takeprofit, orderTypeStr);
    } else if (closingMethod == OPPOSITE && sizingMethod == FIXED) {
        trade.PositionOpen(_Symbol, orderType, lotSize, price, 0, 0, orderTypeStr);
    } else if (closingMethod == STOPLOSSTAKEPROFIT && sizingMethod == DYNAMIC) {
        trade.PositionOpen(_Symbol, orderType, calculatedLot, price, stoploss, takeprofit, orderTypeStr);
    } else if (closingMethod == OPPOSITE && sizingMethod == DYNAMIC) {
        trade.PositionOpen(_Symbol, orderType, calculatedLot, price, 0, 0, orderTypeStr);
    }
}

void HandlePosition(bool isBuy) {
    ClosePosition(isBuy);
    if (!PositionSelect(_Symbol)) {
        OpenPosition(isBuy);
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
    
    FutureCloudGreen = SpanBf26 <= SpanAf26;
    FutureCloudRed = !FutureCloudGreen;

    PriceAboveCloud = !PriceBelowCloud && (Closex2 < SpanAx2 || Closex2 < SpanBx2) && Closex1 > SpanAx1 && Closex1 > SpanBx1;
    PriceBelowCloud = !PriceAboveCloud && (Closex2 > SpanAx2 || Closex2 > SpanBx2) && Closex1 < SpanAx1 && Closex1 < SpanBx1;

    tenkenAboveKijun = Tenkan > Kijun;
    tenkenBelowKijun = !tenkenAboveKijun;

    bool isSpanAx1AboveSpanBx1 = SpanAx1 > SpanBx1;
    bool isSpanBx1AboveSpanAx1 = SpanBx1 > SpanAx1;

    PriceAboveCloud = !isSpanAx1AboveSpanBx1 && !isSpanBx1AboveSpanAx1 && Closex1 > SpanBx1 && Closex1 < SpanAx1;
    PriceBelowCloud = !isSpanAx1AboveSpanBx1 && !isSpanBx1AboveSpanAx1 && Closex1 > SpanAx1 && Closex1 < SpanBx1;

    ChikouAboveCloud = Chikou > SpanAx26 && Chikou > SpanBx26;
    ChikouBelowCloud = !ChikouAboveCloud;

    double adxDiPlus[], adxDiMinus[], adxArr[], maArr[];

    if (CopyBuffer(adxHandle, 0, 0, 1, adxArr) <= 0 || 
        CopyBuffer(adxHandle, 1, 0, 1, adxDiPlus) <= 0 ||
        CopyBuffer(adxHandle, 2, 0, 1, adxDiMinus) <= 0) {
        Print("Error copying indicators buffer");
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

    double AskPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    double BidPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);

    bool BuyCond = maVal < Closex1 && adxMinus < adxPlus
        && tenkenAboveKijun && PriceAboveCloud && ChikouAboveCloud;

    bool SellCond = maVal > Closex1 && adxMinus > adxPlus
        && tenkenBelowKijun && PriceBelowCloud && ChikouBelowCloud;
        
    Comment(
        "\nServer Time : " + (string)TimeCurrent()
    );

    if (PositionsTotal() > 0 && ToogleTrailingStop == YES) {
        TrailingStop();
    }

    if (BuyCond) {
        HandlePosition(true);
    } else if (SellCond) {
        HandlePosition(false);
    }
    
    if (ToogleBreakeven == YES) {
         BreakEven(AskPrice, BidPrice);
    }
}
