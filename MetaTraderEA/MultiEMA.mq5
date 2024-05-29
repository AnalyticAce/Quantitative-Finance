//+------------------------------------------------------------------+
//|                                                     MultiEMA.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade trade;

input group "====== Trade Setings ======"
input ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT;
input int ADXPeriod = 100; // This the ADX Period
input ulong Magic = 8888;
input double lot_size = 0.2;
input double RiskPercent = 10;
input group "Trailling Stop Loss"
input int InpTrallingPoints = 200;
input int InpMinProfit = 10;
input int InpTraillingStep = 20;

input group "====== BreakEven Settings ======"
input double ProfitEvenTrigers = 1000;

MqlRates bar[];
ulong lastbar;

input group "====== EMA Settings ======"
input ENUM_MA_METHOD ema1 = MODE_EMA;
input int em1p = 4;
input ENUM_MA_METHOD ema2 = MODE_EMA;
input int em2p = 8;
input ENUM_MA_METHOD ema3 = MODE_EMA;
input int em3p = 12;
input ENUM_MA_METHOD ema4 = MODE_EMA;
input int em4p = 16;
input ENUM_MA_METHOD ema5 = MODE_EMA;
input int em5p = 20;
input ENUM_MA_METHOD ema6 = MODE_EMA;
input int em6p = 24;

int em1handle,
    em2handle,
    em3handle,
    em4handle,
    em5handle,
    em6handle;

int TotalBar;

double em1buffer[],
    em2buffer[],
    em3buffer[],
    em4buffer[],
    em5buffer[],
    em6buffer[];

int OnInit() {
    trade.SetExpertMagicNumber(Magic);
    em1handle = iMA(_Symbol, PERIOD_CURRENT, em1p, 0, ema1, PRICE_CLOSE);
    em2handle = iMA(_Symbol, PERIOD_CURRENT, em2p, 0, ema2, PRICE_CLOSE);
    em3handle = iMA(_Symbol, PERIOD_CURRENT, em3p, 0, ema3, PRICE_CLOSE);
    em4handle = iMA(_Symbol, PERIOD_CURRENT, em4p, 0, ema4, PRICE_CLOSE);
    em5handle = iMA(_Symbol, PERIOD_CURRENT, em5p, 0, ema5, PRICE_CLOSE);
    em6handle = iMA(_Symbol, PERIOD_CURRENT, em6p, 0, ema6, PRICE_CLOSE);

    if (em1handle == INVALID_HANDLE) {
        Alert("Slowhandle init failed");
        return INIT_FAILED;
    } if (em2handle == INVALID_HANDLE) {
        Alert("Slowhandle init failed");
        return INIT_FAILED;
    } if (em3handle == INVALID_HANDLE) {
        Alert("Slowhandle init failed");
        return INIT_FAILED;
    } if (em4handle == INVALID_HANDLE) {
        Alert("Slowhandle init failed");
        return INIT_FAILED;
    } if (em5handle == INVALID_HANDLE) {
        Alert("Slowhandle init failed");
        return INIT_FAILED;
    } if (em6handle == INVALID_HANDLE) {
        Alert("Slowhandle init failed");
        return INIT_FAILED;
    }
    ArraySetAsSeries(em1buffer, true);
    ArraySetAsSeries(em2buffer, true);
    ArraySetAsSeries(em3buffer, true);
    ArraySetAsSeries(em4buffer, true);
    ArraySetAsSeries(em5buffer, true);
    ArraySetAsSeries(em6buffer, true);
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
    if (em1handle != INVALID_HANDLE) {
        IndicatorRelease(em1handle);
    } if (em2handle != INVALID_HANDLE) {
        IndicatorRelease(em2handle);
    } if (em3handle != INVALID_HANDLE) {
        IndicatorRelease(em3handle);
    } if (em4handle != INVALID_HANDLE) {
        IndicatorRelease(em4handle);
    } if (em5handle != INVALID_HANDLE) {
        IndicatorRelease(em5handle);
    } if (em6handle != INVALID_HANDLE) {
        IndicatorRelease(em6handle);
    }
}

bool IsNewBar() {
    static datetime previousTime = 0;
    datetime currentTime = iTime(_Symbol, PERIOD_CURRENT, 0);
    if (previousTime != currentTime) {
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
         "ADX value : " + ADX_val, "\n" +
         "DI Plus : " + ADX_plus, "\n" +
         "DI Minus : " + ADX_min, "\n" +
         "Sell (ADX_min > ADX_plus): " + sell_adx, "\n" +
         "Buy (ADX_min < ADX_plus): " + buy_adx, "\n"
      );
   
    double AskPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    double BidPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
    
    double Close1 = iClose(_Symbol, Timeframe, 1);
    double Close2 = iClose(_Symbol, Timeframe, 2);

    int value = CopyBuffer(em1handle, 0, 0, 2, em1buffer);
    if (value != 2) {
        Alert("Not enough data for the EMA 1");
        return;
    }

    value = CopyBuffer(em2handle, 0, 0, 2, em2buffer);
    if (value != 2) {
        Alert("Not enough data for the EMA 2");
        return;
    }

    value = CopyBuffer(em3handle, 0, 0, 2, em3buffer);
    if (value != 2) {
        Alert("Not enough data for the EMA 3");
        return;
    }

    value = CopyBuffer(em4handle, 0, 0, 2, em4buffer);
    if (value != 2) {
        Alert("Not enough data for the EMA 4");
        return;
    }

    value = CopyBuffer(em5handle, 0, 0, 2, em5buffer);
    if (value != 2) {
        Alert("Not enough data for the EMA 5");
        return;
    }

    value = CopyBuffer(em6handle, 0, 0, 2, em6buffer);
    if (value != 2) {
        Alert("Not enough data for the EMA 6");
        return;
    }

    if (PositionsTotal() > 0) {
        TrailingStop();
    }

    // strategy
    if (em1buffer[0] > em2buffer[0] && em1buffer[0] > em3buffer[0]
        && em1buffer[0] > em4buffer[0] && em1buffer[0] > em5buffer[0]
        && em1buffer[0] > em6buffer[0] && buy_adx) {
        // Close sell trade if open
        if (PositionSelect(_Symbol)
            && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
            trade.PositionClose(_Symbol);
        }
        // double entry = Close1;
        double sl = em1buffer[0] + 10 * _Point;
        // double tp = entry + 200;
        //  Open buy trade if not already open
        if (!PositionSelect(_Symbol)) {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            // trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, lot_size, ask, sl, tp, "Buy :)");
            // trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, lot_size, ask, 0, 0, "Buy :)");
            trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, lot_size, ask, sl, 0, "Buy :)");
        }
    }

    // Sell condition: EMA 4 is below all other EMAs
    else if (em1buffer[0] < em2buffer[0] && em1buffer[0] < em3buffer[0]
         && em1buffer[0] < em4buffer[0] && em1buffer[0] < em5buffer[0]
         && em4buffer[0] < em6buffer[0] && sell_adx) {
        // Close buy trade if open
        if (PositionSelect(_Symbol)
            && PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) {
            trade.PositionClose(_Symbol);
        }
        // double entry = Close1;
        double sl = em1buffer[0] - 10 * _Point;
        // double tp = entry + 200;
        //  Open sell trade if not already open
        if (!PositionSelect(_Symbol)) {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            // trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, lot_size, bid, sl, tp, "Sell :)");
            trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, lot_size, bid, sl, 0, "Sell :)");
            // trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, lot_size, bid, 0, 0, "Sell :)");
        }
    }
    //BreakEven(AskPrice, BidPrice);
}
