#include <Trade\Trade.mqh>

input long MagicNumber = 1234; // Magic number
input double Lots = 0.05; // Lot size
input int StopLoss = 150; // Stop Loss in % of range
input int TakeProfit = 200; // Take Profit in % of range
input int RangeStart = 600; // Range start time
input int RangeDuration = 120; // Range duration
input int RangeClose = 1200; // Range close time

struct RANGE_STRUCT {
    datetime start_time; // Range start time
    datetime end_time; // Range end time
    datetime close_time; // Range close time
    double high; // Range high
    double low; // Range low
    bool f_entry; // Entry flag
    bool f_high_break; // High break flag
    bool f_low_break; // Low break flag

    RANGE_STRUCT() : start_time(0), end_time(0), close_time(0), high(0), low(999999), f_entry(false), f_high_break(false), f_low_break(false) {}
};

RANGE_STRUCT range;
MqlTick last_tick, prev_tick;
CTrade trade;

int OnInit()
{
    if(MagicNumber <= 0) {
        Alert("Magic Number can't be negative");
        return INIT_PARAMETERS_INCORRECT;
    } 
    if (Lots <= 0 || Lots > 1) {
        Alert("Please enter a valid lot size");
        return INIT_PARAMETERS_INCORRECT;
    } 
    if(RangeStart < 0 || RangeStart >= 1400) {
        Alert("Range start < 0 or >= 1400");
        return INIT_PARAMETERS_INCORRECT;
    } 
    if(RangeClose < 0 || RangeClose >= 1400 || RangeClose == (RangeStart + RangeDuration) % 1400) {
        Alert("Range start < 0 or >= 1400 or RangeClose == (RangeStart + RangeDuration) % 1400");
        return INIT_PARAMETERS_INCORRECT;
    }

    // Set magic number
    trade.SetExpertMagicNumber(MagicNumber);
    
    // Calculate new range
    if(_UninitReason == REASON_PARAMETERS) {
        CalculateRange();
    }
    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
    ObjectDelete(NULL, "RangeStart");
    ObjectDelete(NULL, "RangeEnd");
    ObjectDelete(NULL, "RangeClose");
    ObjectDelete(NULL, "RangeHigh");
    ObjectDelete(NULL, "RangeLow");
    ObjectDelete(NULL, "RangeHigh ");
    ObjectDelete(NULL, "RangeLow ");
}

void OnTick()
{
    prev_tick = last_tick;
    if(!SymbolInfoTick(Symbol(), last_tick)) {
        Print("Error getting tick info: ", GetLastError());
        return;
    }

    if(last_tick.time >= range.start_time && last_tick.time < range.end_time) {
        range.f_entry = true;
        if(last_tick.ask > range.high) {
            range.high = last_tick.ask;
            DrawObjects();
        }

        if(last_tick.bid < range.low) {
            range.low = last_tick.bid;
            DrawObjects();
        }
    }

    // Close position if range is closed
    if (last_tick.time >= range.close_time) {
        if (!ClosePositions()) {
            return;
        }
    }

 if((RangeClose >= 0 && last_tick.time >= range.close_time)
        || (range.f_high_break && range.f_low_break)
        || range.end_time == 0
        || (range.end_time != 0 && last_tick.time > range.end_time && !range.f_entry)
        && CountOpenPositions() == 0) {
        CalculateRange();
    }

    
    // Check for breakouts
    CheckBreakout();
}

int CountOpenPositions()
{
    int counter = 0;
    int total = PositionsTotal();

    for (int i = total - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if (ticket <= 0) {
            Print("Error getting ticket number: ", GetLastError());
            return -1;
        }

        if (!PositionSelectByTicket(ticket)) {
            Print("Error selecting position by ticket: ", GetLastError());
            return -1;
        }

        long magicnumber;
        if (!PositionGetInteger(POSITION_MAGIC, magicnumber)) {
            Print("Error getting magic number: ", GetLastError());
            return -1;
        }

        if (magicnumber == MagicNumber) {
            counter++;
        }
    }

    return counter;
}

bool ClosePositions()
{
    int total = PositionsTotal();

    for (int i = total - 1; i >= 0; i--) {
        if (total != PositionsTotal()) {
            total = PositionsTotal();
            i = total;
            continue;
        }
        ulong ticket = PositionGetTicket(i);
        if (ticket <= 0) {
            Print("Error getting ticket number: ", GetLastError());
            return false;
        }

        if (!PositionSelectByTicket(ticket)) {
            Print("Error selecting position by ticket: ", GetLastError());
            return false;
        }

        long magicnumber;
        if (!PositionGetInteger(POSITION_MAGIC, magicnumber)) {
            Print("Error getting magic number: ", GetLastError());
            return false;
        }

        if (magicnumber == MagicNumber) {
            trade.PositionClose(ticket);
            if (trade.ResultRetcode() != TRADE_RETCODE_DONE) {
                Print("Error closing position: ", trade.ResultRetcode());
                return false;
            }
        }
    }
    return true;
}

void CalculateRange()
{
    range.start_time = TimeCurrent();
    range.end_time = 0;
    range.close_time = 0;
    range.high = 0.0;
    range.low = 999999;
    range.f_entry = false;
    range.f_high_break = false;
    range.f_low_break = false;

    int timecycle = 86400;
    range.start_time = (last_tick.time - (last_tick.time % timecycle)) + RangeStart * 60;
    
    for (int i = 0; i < 7; i++) {
        MqlDateTime time;
        TimeToStruct(range.start_time, time);
        int dow = time.day_of_week;

        if(last_tick.time >= range.start_time || dow == 6 || dow == 0) {
            range.start_time += timecycle;
        }
    }

    // Calculate end time
    range.end_time = range.start_time + RangeDuration * 60;

    for (int i = 0; i < 7; i++) {
        MqlDateTime time;
        TimeToStruct(range.end_time, time);
        int dow = time.day_of_week;

        if(dow == 6 || dow == 0) {
            range.end_time += timecycle;
        }
    }

    // Calculate close time
    range.close_time = (range.end_time - (range.end_time % timecycle)) + RangeClose * 60;
    for (int i = 0; i < 7; i++) {
        MqlDateTime time;
        TimeToStruct(range.close_time, time);
        int dow = time.day_of_week;

        if(dow == 6 || dow == 0 || range.close_time <= range.end_time) {
            range.close_time += timecycle;
        }
    }
    DrawObjects();
}

void CheckBreakout()
{
    // Check if we are in the range end
    if(last_tick.time >= range.end_time && range.end_time > 0 && range.f_entry) {
        if(!range.f_high_break && last_tick.ask > range.high) {
            range.f_high_break = true;
            Print("High Breakout");
            // calculate sl and tp
            double sl = NormalizeDouble(last_tick.bid - ((range.high - range.low) * StopLoss * 0.01), _Digits);
            double tp = NormalizeDouble(last_tick.bid + ((range.high - range.low) * TakeProfit * 0.01), _Digits);
           
            // Buy
            trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, Lots, last_tick.ask, sl, tp, "High Breakout");
        }

        if (!range.f_low_break && last_tick.bid < range.low) {
            range.f_low_break = true;
            Print("Low Breakout");
            // calculate sl and tp
            double sl = NormalizeDouble(last_tick.ask + ((range.high - range.low) * StopLoss * 0.01), _Digits);
            double tp = NormalizeDouble(last_tick.ask - ((range.high - range.low) * TakeProfit * 0.01), _Digits);
           
            // Sell
            trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, Lots, last_tick.bid, sl, tp, "Low Breakout");
        }
    }
}

void DrawObjects()
{
    // Draw range start
    ObjectDelete(NULL,"RangeStart");
    if (range.start_time > 0) {
        ObjectCreate(NULL, "RangeStart", OBJ_VLINE, 0, range.start_time, 0);
        ObjectSetString(NULL, "RangeStart", OBJPROP_TOOLTIP, "Range Start\n"+TimeToString(range.start_time, TIME_DATE|TIME_MINUTES));
        ObjectSetInteger(NULL, "RangeStart", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(NULL, "RangeStart", OBJPROP_WIDTH, 2);
        ObjectSetInteger(NULL, "RangeStart", OBJPROP_BACK, true);
    }

    // Draw range end
    ObjectDelete(NULL, "RangeEnd");
    if (range.end_time > 0) {
        ObjectCreate(NULL, "RangeEnd", OBJ_VLINE, 0, range.end_time, 0);
        ObjectSetString(NULL, "RangeEnd", OBJPROP_TOOLTIP, "Range End\n"+TimeToString(range.end_time, TIME_DATE|TIME_MINUTES));
        ObjectSetInteger(NULL, "RangeEnd", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(NULL, "RangeEnd", OBJPROP_WIDTH, 2);
        ObjectSetInteger(NULL, "RangeEnd", OBJPROP_BACK, true);
    }

    // Draw range close
    ObjectDelete(NULL, "RangeClose");
    if (range.close_time > 0) {
        ObjectCreate(NULL, "RangeClose", OBJ_VLINE, 0, range.close_time, 0);
        ObjectSetString(NULL, "RangeClose", OBJPROP_TOOLTIP, "Range Close\n"+TimeToString(range.close_time, TIME_DATE|TIME_MINUTES));
        ObjectSetInteger(NULL, "RangeClose", OBJPROP_COLOR, clrGreen);
        ObjectSetInteger(NULL, "RangeClose", OBJPROP_WIDTH, 2);
        ObjectSetInteger(NULL, "RangeClose", OBJPROP_BACK, true);
    }

    // Draw range high
    ObjectDelete(NULL, "RangeHigh");
    if (range.high > 0) {
        ObjectCreate(NULL, "RangeHigh", OBJ_HLINE, 0, range.start_time, range.high);
        ObjectSetString(NULL, "RangeHigh", OBJPROP_TOOLTIP, "Range High\n"+DoubleToString(range.high, _Digits));
        ObjectSetInteger(NULL, "RangeHigh", OBJPROP_COLOR, clrBlue);
        ObjectSetInteger(NULL, "RangeHigh", OBJPROP_WIDTH, 2);
        ObjectSetInteger(NULL, "RangeHigh", OBJPROP_BACK, true);

        ObjectCreate(NULL, "RangeHigh ", OBJ_TREND, 0, range.end_time, range.high, range.close_time, range.high);
        ObjectSetString(NULL, "RangeHigh ", OBJPROP_TOOLTIP, "High of the range\n"+DoubleToString(range.high, _Digits));
        ObjectSetInteger(NULL, "RangeHigh ", OBJPROP_COLOR, clrBlue);
        ObjectSetInteger(NULL, "RangeHigh ", OBJPROP_BACK, true);
        ObjectSetInteger(NULL, "RangeHigh ", OBJPROP_STYLE, STYLE_DOT);
    }

    // Draw range low
    ObjectDelete(NULL, "RangeLow");
    if (range.low < 999999) {
        ObjectCreate(NULL, "RangeLow", OBJ_HLINE, 0, range.start_time, range.low);
        ObjectSetString(NULL, "RangeLow", OBJPROP_TOOLTIP, "Range Low\n"+DoubleToString(range.low, _Digits));
        ObjectSetInteger(NULL, "RangeLow", OBJPROP_COLOR, clrBlue);
        ObjectSetInteger(NULL, "RangeLow", OBJPROP_WIDTH, 2);
        ObjectSetInteger(NULL, "RangeLow", OBJPROP_BACK, true);

        ObjectCreate(NULL, "RangeLow ", OBJ_TREND, 0, range.end_time, range.low, range.close_time, range.low);
        ObjectSetString(NULL, "RangeLow ", OBJPROP_TOOLTIP, "Low of the range\n"+DoubleToString(range.low, _Digits));
        ObjectSetInteger(NULL, "RangeLow ", OBJPROP_COLOR, clrBlue);
        ObjectSetInteger(NULL, "RangeLow ", OBJPROP_BACK, true);
        ObjectSetInteger(NULL, "RangeLow ", OBJPROP_STYLE, STYLE_DOT);
    }
}
