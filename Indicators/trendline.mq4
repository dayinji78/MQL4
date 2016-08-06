
//----------------------------------
#property indicator_chart_window

#define TRENDNAME "trendline:"
//----------------------------------
extern int TrendPeriod=2;
extern color col=SkyBlue;


bool hasLine = false;
string trendname;
int TrendLineCreate(datetime time1, double price1, datetime time2, double price2)
{
   string tmp = TRENDNAME;
   tmp += TimeToString(time1);
   if(hasLine == false){
      trendname = tmp;
   }
   if(ObjectFind(trendname) < 0){
      // create trend line
      hasLine = true;
      ObjectCreate(trendname, OBJ_TREND, 0, time1, price1, time2, price2);
      ObjectSetInteger(0, trendname, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, trendname, OBJPROP_BACK, true);
   }else{
      if(tmp == trendname){
      ObjectSet(trendname, OBJPROP_TIME1, time1);
      ObjectSet(trendname, OBJPROP_PRICE1, price1);
      ObjectSet(trendname, OBJPROP_TIME2, time2);
      ObjectSet(trendname, OBJPROP_PRICE2, price2);
      ObjectSetInteger(0, trendname, OBJPROP_RAY_RIGHT, false); 
      ObjectSetInteger(0, trendname, OBJPROP_BACK, true);
      WindowRedraw();
      }
      // modify trend line
   }
   return 0;
}

//////
class TRENDLINE
{
public:
#define NON_TREND 0
#define UP_TREND 1
#define DOWN_TREND 2
   TRENDLINE()
   {
      _init();
   }

   int calTrendLine(double low, datetime time)
   {
      if(trend_stat == NON_TREND){
         pre_low = low;
         pre_time = time;
         cur_low = low;
         cur_time = time;
         trend_stat = UP_TREND;
      }else if(trend_stat == UP_TREND){
         if(low >= cur_low){
            cur_low = low;
            cur_time = time;
            if(cur_low > pre_low){
               TrendLineCreate(pre_time, pre_low, cur_time, cur_low);
            }
         }else{
            cur_low = 0;
            trend_stat = NON_TREND;
         }
      }
   }
private:
   double pre_low;
   datetime pre_time;
   double cur_low;
   datetime cur_time;
   int trend_stat;
   int _init(){
      trend_stat = NON_TREND;
      pre_low = 0;
      cur_low = 0;
      pre_time = __DATETIME__;
      cur_time = __DATETIME__;
   }   
};

//////
//*****************************************
int minBarCount;
int init()
{
   ObjectsDeleteAll(0, OBJ_TREND);
   minBarCount = TrendPeriod * 24 * 60 / Period();
   return 0;
}
//*******************************
int deinit()
{
   //ObjectsDeleteAll(0, OBJ_TREND);
   return 0;
}
//*******************************


double upTrendHigh = 0;
double upTrendLow = 0;
double upTrendHigh_sec = 0;
double upTrendLow_sec = 0;
datetime upTrendPos = __DATETIME__;

double downTrendHigh = 0;
double downTrendLow = 0;
double downTrendHigh_sec = 10;
double downTrendLow_sec = 10;
datetime downTrendPos = __DATETIME__;

int start()
{
   if(Period() > PERIOD_H1){
      // too small chart
      Sleep(1000);
      return 0;
   }

   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if(counted_bars < 0)
      return -1;
   if(counted_bars > 0)
      counted_bars--;
   //---- last counted bar will be recounted

   int limit = Bars - counted_bars;
   if(limit < minBarCount){
      // need more bars
      //Sleep(PeriodSeconds() * 1000);
      Sleep(1000);
      return limit;
   }
   
   if(hasLine == true)
      return 0;
   TRENDLINE TrendLine;
   for(int i = limit - 1; i >= 0; i--){
      int y = iBarShift(NULL, PERIOD_D1, Time[i]);
      double cur_high = iHigh(NULL, PERIOD_D1, y);
      double cur_low = iLow(NULL, PERIOD_D1, y);

      TrendLine.calTrendLine(cur_low, Time[i]);
      /*
      // calculation up/down trend high/low price
      if(cur_high > upTrendHigh_sec){
         upTrendHigh_sec = cur_high;
         downTrendHigh = cur_high;
         downTrendPos = Time[i];
      }
      if(cur_low > upTrendLow_sec){
         upTrendLow_sec = cur_low;
         downTrendLow = cur_low;
      }
 
      if(cur_high < downTrendHigh_sec){
         downTrendHigh_sec = cur_high;
         upTrendHigh = cur_high;
      }
      if(cur_low < downTrendLow_sec){
         downTrendLow_sec = cur_low;
         upTrendLow =    cur_low;
         upTrendPos = Time[i];
      }

      if(upTrendLow_sec > upTrendLow && upTrendLow_sec > 0 && upTrendLow > 0){
         TrendLineCreate(upTrendPos, upTrendLow, Time[i], upTrendLow_sec);
      }
      
      if(downTrendHigh > downTrendHigh_sec && downTrendHigh_sec > 0 && downTrendLow > 0){
         TrendLineCreate(downTrendPos, downTrendLow, Time[i], downTrendHigh_sec);
      }
      */
   }

   return 0;
}
