//+------------------------------------------------------------------+
//|                                                     指标递增加码EA.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Experts\IncreaseByA\IncreaseByA.mqh>

//
input int channelperiod = 5;//通道周期
// close order param
input OPTIONTYPE option_type = 多空单;
input OPTIONFRAME timeframe = M30;
input ORDERCLOSEMODE orderCloseMode = 平多开空，平空开多;
//input double orderCloseTakeProfit = 10;
input int orderCloseTakePips = 100;

// open order param
input int maxLots = 1;
input double firstLots = 0.01;
input ORDEROPENMODE orderOpenMode = 单边递增;
input double stepLots = 0.01;
input int timesLots = 1;
input RAISEMODE raiseMode = 直接进场;
input int maxRaiseCount = 1;
input double raiseLots = 0.01;
input double raiseInterval = 100;

// TP SL
input int trailSL_start = 300;
input int trailSL = 100;
input int BUY_TakeProfit = 100;
input int BUY_StopLost = 100;
input int SELL_TakeProfit = 100;
input int SELL_StopLost = 100;

// commons
input string comment = "指标递增加码EA";
input bool sendEMail = false;
//
input int slippage = 10;

double last_lots = 0;
double total_lots = 0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   iCustom(NULL, 0, "ccima.ex4", 0, 0);
   if(_LastError != 0)
   {
      ExpertRemove();
      return INIT_FAILED;
   }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
/*
int getLastOrderConf(struct OrderConf)
{
   struct OrderConf orderConf;
   ZeroMemory(orderConf);
   int total = OrdersTotal();
   if(total == 0)
      return orderConf;
      
   if(OrderSelect(total - 1, SELECT_BY_POS) == false)
      return orderConf;
      
   orderConf.ticket = OrderTicket();
   orderConf.cmd = OrderType();
   orderConf.lots = OrderLots();
   
   orderConf.takeprofit = OrderTakeProfit();
   orderConf.stoploss = OrderStopLoss();

   return orderConf;
}
*/

double getRaiseLots(double lots)
{
   if(lots == 0)
      return firstLots;

   if(orderOpenMode == 单边递增)
      lots += stepLots;
   else
      lots *= timesLots + 1;
      
   return lots;
}
bool hasArrow(int arrow)
{
   if(arrow != -1 && arrow != EMPTY_VALUE)
      return false;
   else
      return true;
}

int getOrderTask(double buy_arrow, double sell_arrow, OrderConf &orderList[])
{
   //struct OrderConf orderList[];
   ArrayResize(orderList, 10, 10);
   int listSize = 10;
   int listIndex = 0;

   double allLots = 0;
   // close order
   if(orderCloseMode != 手动平仓)
   {
      int total = OrdersTotal();
      for(int i = 0; i < total; i++)
      {
         if(OrderSelect(i, SELECT_BY_POS) == false)
            continue;
         if(OrderType() != OP_BUY || OrderType() != OP_SELL)
            continue;
         
         allLots += OrderLots();
         int type = OrderType();
         if((type == OP_BUY && hasArrow(sell_arrow) && orderCloseMode != 单平空) || 
            (type == OP_SELL && hasArrow(buy_arrow) && orderCloseMode != 单平多))
         {
               orderList[listIndex].cmd = CloseOrder;
               orderList[listIndex].type = OrderType();
               orderList[listIndex].ticket = OrderTicket();
               orderList[listIndex].lots = OrderLots();
               listIndex++;
               if(listIndex >= listSize)
               {
                  ArrayResize(orderList, 10 + listIndex, 10);
               }
               
               if(OrderProfit() < 0)
                  last_lots = OrderLots();
               else
                  total_lots = 0;
         }
      }
   }
   
   if(allLots >= total_lots)
      return 0;

   // open new order
   double lots = getRaiseLots(last_lots);

	if(hasArrow(buy_arrow) && raiseMode == 直接进场)
	{
	   orderList[listIndex].cmd = OpenOrder;
      orderList[listIndex].ticket = 0;
      orderList[listIndex].type = OP_BUY;
      orderList[listIndex].lots = lots;
      orderList[listIndex].takeprofit = BUY_TakeProfit;
      orderList[listIndex].stoploss = BUY_StopLost;
      listIndex++;
      if(listIndex >= listSize)
      {
         ArrayResize(orderList, 10 + listIndex, 10);
      }
	}
	
   if(hasArrow(sell_arrow) > 0 && raiseMode == 直接进场)
	{
	   orderList[listIndex].cmd = OpenOrder;
      orderList[listIndex].ticket = 0;
      orderList[listIndex].type = OP_SELL;
      orderList[listIndex].lots = lots;
      orderList[listIndex].takeprofit = SELL_TakeProfit;
      orderList[listIndex].stoploss = SELL_StopLost;
      listIndex++;
      if(listIndex >= listSize)
      {
         ArrayResize(orderList, 10 + listIndex, 10);
      }
	}
	
	return listIndex;
}


int executionOrderTask(OrderConf &orderTask[])
{
   int taskCount = ArraySize(orderTask);
   
   for(int i = 0 ;i < taskCount; i++)
   {
   
      if(orderTask[i].type != CloseOrder)
      {
         // close ticket
         if(orderTask[i].type == OP_BUY)
            OrderClose(orderTask[i].ticket, orderTask[i].lots, Bid, slippage, clrRed);
         else
            OrderClose(orderTask[i].ticket, orderTask[i].lots, Ask, slippage, clrRed);
      }
      else
      {
         // open new order
         if(orderTask[i].type == OP_BUY)
            OrderSend(NULL, OP_BUY, orderTask[i].lots, Ask, slippage, orderTask[i].stoploss, orderTask[i].takeprofit);
         else
            OrderSend(NULL, OP_SELL, orderTask[i].lots, Bid, slippage, orderTask[i].stoploss, orderTask[i].takeprofit);
      }
   }
   
   return 0;
}

void OnTick()
{
//---
   //////读取指标值
	double buy_arrow = iCustom(NULL, (int)timeframe, "A3.ex4", channelperiod, 0.1, 1, 1, 1000, 2, 1);//买入信号
	double sell_arrow = iCustom(NULL, (int)timeframe, "A3.ex4", channelperiod, 0.1, 1, 1, 1000, 3, 1);//卖出信号
	
	bool arrow = hasArrow(buy_arrow);
	OrderConf orderTask[];
	int size = getOrderTask(buy_arrow, sell_arrow, orderTask);
	
	executionOrderTask(orderTask);
} 
//+------------------------------------------------------------------+
