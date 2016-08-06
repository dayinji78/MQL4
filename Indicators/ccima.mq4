//+------------------------------------------------------------------+
//|                                                        ccima.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
double buff_up[];
double buff_down[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexStyle(0, DRAW_LINE, 0, 2, clrRed);
   SetIndexBuffer(0, buff_up);
   SetIndexEmptyValue(0, 0.0);
   
   SetIndexStyle(1, DRAW_LINE, 0, 2, clrDeepSkyBlue);
   SetIndexBuffer(1, buff_down);
   SetIndexEmptyValue(1, 0.0);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int TREND=0;
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int limit = rates_total - prev_calculated;
   if(limit == 0){
      return rates_total;
   }
//---
   for(int i = 0; i < limit; i++){
      int y = iBarShift(NULL, PERIOD_H4, time[i], false);
      double cci = iCCI(NULL, PERIOD_H4, 14, PRICE_CLOSE, y);
      double rate = (high[i] - low[i]) / 5;
   
      if(cci > 100){
         TREND = 1;
      }else if(cci < -100){
         TREND = 2;
      }
      if(TREND == 1){
         buff_up[i] = low[i] - rate;
      }else if(TREND == 2){
         buff_down[i] = high[i] + rate;
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
