//+------------------------------------------------------------------+
//|                                                  orderhelper.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+


int OrderBuy(string symbol, double vol, int slippage, int stoploss_point, int takeprofit_point, 
   string   comment=NULL,        // comment 
   int      magic=0,             // magic number 
   datetime expiration=0,        // pending order expiration 
   color    arrow_color=clrNONE  // color )
{
   double stoploss = NormalizeDouble(Bid - stoploss_point * Point, Digits);
   double takeprofit = NormalizeDouble(Bid + takeprofit_point * Point, Digits);
   int ret = OrderSend(symbol, OP_BUY, vol, Ask, slippage, stoploss, takeprofit, comment, magic, expiration, arrow_color);
   if(ret < 0){
      Print("OrderBuy failed with error #",GetLastError());
   }

   return ret;
}

int OrderSell(string symbol, double vol, int slippage, int stoploss_point, int takeprofit_point, 
   string   comment=NULL,        // comment 
   int      magic=0,             // magic number 
   datetime expiration=0,        // pending order expiration 
   color    arrow_color=clrNONE  // color )
{
   double stoploss = NormalizeDouble(Ask + stoploss_point * Point, Digits);
   double takeprofit = NormalizeDouble(Ask - takeprofit_point * Point, Digits);
   int ret = OrderSend(symbol, OP_SELL, vol, Bid, slippage, stoploss, takeprofit, comment, magic, expiration, arrow_color);
   if(ret < 0){
      Print("OrderSell failed with error #",GetLastError());
   }

   return ret;
}

int OrderCloseSell()
{

   return 0;
}

int OrderCloseBuy()
{

   return 0;
}

int OrderClosePendingBuy()
{

   return 0;
}

int OrderClosePendingSell()
{
   return 0;
}

int OrderCloseAll()
{
   int total = OrdersTotal();
   if(total < 0){
      return 0;
   }

   for(int pos = total - 1; pos >= 0; pos++){
      if(OrderSelect(pos, SELECT_BY_POS) == false){
         Print("OrderSelect failed with error #",GetLastError());
         return (total - pos);
      }
   
      int type = OrderType(pos);
      switch(type){
         case OP_BUY:
            OrderClose(pos, OrderLots(pos), Bid, 10);
            break;
         case OP_SELL:
            OrderClose(pos, OrderLots(pos), Ask, 10);
            break;
         case OP_BUYLIMIT:
         case OP_BUYSTOP:
         case OP_SELLLIMIT:
         case OP_SELLSTOP:
            OrderDelete(pos);
            break;
         default:
            break;
      
      }
   }
   
   return total;
}