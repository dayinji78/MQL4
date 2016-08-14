//+------------------------------------------------------------------+
//|                                                 SimpleVector.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

struct OrderInfo
{
 	   int type;
 	   
 	   int cmd;
};

#import "SimpleVector.dll"
int CreateManager();

int getOrder(OrderInfo &outOrder, int index);
int getCount();

#import