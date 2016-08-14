//+------------------------------------------------------------------+
//|                                                         test.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <commontool/SimpleVector.mqh>
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
   return(INIT_SUCCEEDED);
}

/*
  struct mystr
  {
      int a;
      int b;
  };
  
  
template<typename T>
T ArrayMax(T &arr[])
  {
   uint size=ArraySize(arr);
   if(size==0) return(0);          
   
   T max=arr[0];
   for(uint n=1;n<size;n++)
      if(max<arr[n]) max=arr[n];
//---
   return(max);
  }
  */
  

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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

OrderInfo outOrder;
CreateManager();
Print("Ordercount:", getCount());
getOrder(outOrder, 0);
Print("type:", outOrder.type, ",cmd:", outOrder.cmd);
/*
  SimpleVector<int> vect;
vect.init(10);
   for(int i = 0; i < 10; i++){
   
     vect.push(i);
   }

//---
   int a[5];
   ZeroMemory(a);
   a[0] = 10;
   a[1] = 2;
   a[3] = 4;
   a[4] = 20;
   
   //int c = ArrayMax(a);
   
   for(int i = 1; i < 1000; i++){

      ArrayResize(a, i);
      if(i == 2)
         a[1] = 98;
      if(i == 150)
         a[149] = 88;
   }
   */
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
