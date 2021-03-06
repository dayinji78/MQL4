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

#define MAIGC 0075
//
input int channelperiod = 5;//通道周期
// close order param
input OPTIONTYPE option_type = 多空单;//开仓或递增加仓
input OPTIONFRAME timeframe = M30;//周期参数
input ORDERCLOSEMODE orderCloseMode = 平多开空，平空开多;//平仓模式
//input double orderCloseTakeProfit = 10;
input int orderCloseAllTakePips = 100;//多空单总盈利平仓

// open order param
input int maxLots = 1;//最大持仓
input double firstLots = 0.01;//首单下单量
input ORDEROPENMODE orderOpenMode = 单边递增;//下单量模式
input double stepLots = 0.01;//递增下单量
input int timesLots = 1;//翻倍下单量 
input RAISEMODE raiseMode = 直接进场;//加码下单模式
input int maxRaiseCount = 1;
input double raiseLots = 0.01;
input double raiseInterval = 100;//加码间距

// TP SL
input int trailSL_start = 3000;
input int trailSL = 1000;
input int BUY_TakeProfit = 1000;//多单止盈
input int BUY_StopLost = 1000;//多单止损
input int SELL_TakeProfit = 1000;//空单止盈
input int SELL_StopLost = 1000;//空单止盈

// commons
input string comment = "指标递增加码EA";
input bool sendEMail = false;
//
input int slippage = 10;//滑点

double last_lots = 0;
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
      return true;
   else
      return false;
}

int getOrderTask(double buy_arrow, double sell_arrow, OrderConf &orderList[])
{
   //struct OrderConf orderList[];
   ArrayResize(orderList, 10, 10);
   int listSize = 10;
   int listIndex = 0;

   double allLots = 0;
   
   
   int total = OrdersTotal();
   bool closeAllOrder = false;

   double allTakeProfit = 0;
   double lastOrderOpenPrcie = 0;
   
   for(int i = 0; i < total; i++)
   {
      if(OrderSelect(i, SELECT_BY_POS) == false)
         continue;
      if(OrderType() != OP_BUY && OrderType() != OP_SELL)
         continue;
      if(OrderMagicNumber() != MAIGC)
         continue;
      
      allLots += OrderLots();
      allTakeProfit += OrderProfit();
      lastOrderOpenPrcie = OrderOpenPrice();
   }

   
   // close order
   if(orderCloseMode != 手动平仓)
   {
      int total = OrdersTotal();
      bool closeAllOrder = false;
      if(orderCloseMode == 盈利多空平仓)
      {
         if(allTakeProfit >= orderCloseAllTakePips * Point)
         {
            closeAllOrder = true;
         }
      }
         
      for(int i = 0; i < total; i++)
      {
         if(OrderSelect(i, SELECT_BY_POS) == false)
            continue;
         if(OrderType() != OP_BUY && OrderType() != OP_SELL)
            continue;
         if(OrderMagicNumber() != MAIGC)
            continue;
            
         allLots += OrderLots();
         int type = OrderType();
         
         Print("type:", type, ",sella:", sell_arrow, ",buya:", buy_arrow, ",orderCloseMode:", orderCloseMode);


         if((type == OP_BUY && hasArrow(sell_arrow) && orderCloseMode != 单平空) || 
            (type == OP_SELL && hasArrow(buy_arrow) && orderCloseMode != 单平多) ||
            closeAllOrder)
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
               Print("need close ticket:", orderList[listIndex].ticket, ",profit:", OrderProfit());
               allLots -= OrderLots();
               if(OrderProfit() < 0)
                  last_lots = OrderLots();
               else
                  last_lots = 0;
         } else{
            lastOrderOpenPrcie = OrderOpenPrice();
         }
      }
   }
   Print("alllots:", allLots, ",maxRaiseCount:", maxLots);
   if(allLots >= maxLots)
      return 0;

   // open new order
   double lots = getRaiseLots(last_lots);
   Print("has buy Arrow:", hasArrow(buy_arrow));
	if(hasArrow(buy_arrow) && raiseMode == 直接进场)
	{
	   Print("add buy OpenOrder");
	   if(lastOrderOpenPrcie != 0 && (Bid > NormalizeDouble(lastOrderOpenPrcie + raiseInterval * Point, Digits)) ||
	      lastOrderOpenPrcie == 0)
	   {
	   
   	   orderList[listIndex].cmd = OpenOrder;
         orderList[listIndex].ticket = 0;
         orderList[listIndex].type = OP_BUY;
         orderList[listIndex].lots = lots;
         Print("takeprofit:", NormalizeDouble(Bid + BUY_TakeProfit * Point, Digits), ", Point:", Point, ",Digits:", Digits);
         orderList[listIndex].takeprofit = NormalizeDouble(Bid + BUY_TakeProfit * Point, Digits);
         orderList[listIndex].stoploss = NormalizeDouble(Bid - BUY_StopLost * Point, Digits);
         listIndex++;
         if(listIndex >= listSize)
         {
            ArrayResize(orderList, 10 + listIndex, 10);
         }
      }
	}
	
	Print("has sell Arrow:", hasArrow(sell_arrow));
   if(hasArrow(sell_arrow) > 0 && raiseMode == 直接进场)
	{
	   Print("ADD sell order");
		if(lastOrderOpenPrcie != 0 && (Ask < NormalizeDouble(lastOrderOpenPrcie - raiseInterval * Point, Digits)) ||
	      lastOrderOpenPrcie == 0)
	   {
   	   orderList[listIndex].cmd = OpenOrder;
         orderList[listIndex].ticket = 0;
         orderList[listIndex].type = OP_SELL;
         orderList[listIndex].lots = lots;
         orderList[listIndex].takeprofit = NormalizeDouble(Ask - SELL_TakeProfit * Point, Digits);
         orderList[listIndex].stoploss = NormalizeDouble(Ask + SELL_StopLost * Point, Digits);
         listIndex++;
         if(listIndex >= listSize)
         {
            ArrayResize(orderList, 10 + listIndex, 10);
         }
      }
	}
	
	return listIndex;
}


int executionOrderTask(OrderConf &orderTask[])
{
   int taskCount = ArraySize(orderTask);

   for(int i = 0 ;i < taskCount; i++)
   {
            
      if(orderTask[i].cmd == CloseOrder)
      {
         // close ticket
         Print("ticket:", orderTask[i].ticket, ",lots:", orderTask[i].lots, ",cmd:", orderTask[i].cmd);
         if(orderTask[i].cmd == OP_BUY)
            OrderClose(orderTask[i].ticket, orderTask[i].lots, Bid, slippage, clrRed);
         else
            OrderClose(orderTask[i].ticket, orderTask[i].lots, Ask, slippage, clrRed);
      }
      else if(orderTask[i].cmd == OpenOrder)
      {
         Print("ticket:", orderTask[i].ticket, ",lots:", orderTask[i].lots, ",cmd:", orderTask[i].cmd, ",stoploss:", orderTask[i].stoploss, ",takeprofit:", orderTask[i].takeprofit);
         // open new order
         if(orderTask[i].type == OP_BUY)
            OrderSend(NULL, OP_BUY, orderTask[i].lots, Bid, slippage, orderTask[i].stoploss, orderTask[i].takeprofit, comment, MAIGC);
         else
            OrderSend(NULL, OP_SELL, orderTask[i].lots, Ask, slippage, orderTask[i].stoploss, orderTask[i].takeprofit, comment, MAIGC);
      }
   }
   
   return 0;
}

void OnTick()
{
//---
   //////读取指标值
   double buy_s = iCustom(NULL, (int)timeframe, "A3.ex4", channelperiod, 0.1, 1, 1, 1000, 0, 1);//买入信号
	double sell_s = iCustom(NULL, (int)timeframe, "A3.ex4", channelperiod, 0.1, 1, 1, 1000, 1, 1);//卖出信号
	double buy_arrow = iCustom(NULL, (int)timeframe, "A3.ex4", channelperiod, 0.1, 1, 1, 1000, 2, 1);//买入信号
	double sell_arrow = iCustom(NULL, (int)timeframe, "A3.ex4", channelperiod, 0.1, 1, 1, 1000, 3, 1);//卖出信号

	bool arrow = hasArrow(buy_arrow);
	if(arrow || hasArrow(sell_arrow))
	   Print("has sell arrow");
	else
	   return ;
	   
		Print("buys:", buy_s, ",sells:", sell_s, ",buya:", buy_arrow, ",sella:", sell_arrow);
	OrderConf orderTask[];
	int size = getOrderTask(buy_arrow, sell_arrow, orderTask);

	executionOrderTask(orderTask);
} 
//+------------------------------------------------------------------+
