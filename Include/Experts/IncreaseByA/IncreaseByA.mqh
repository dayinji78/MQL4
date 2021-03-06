//+------------------------------------------------------------------+
//|                                                  IncreaseByA.mqh |
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

enum OPTIONTYPE {多单, 空单, 多空单};
enum OPTIONFRAME {M1 = PERIOD_M1, M5 = PERIOD_M5, M15 = PERIOD_M15, M30 = PERIOD_M30, H1 = PERIOD_H1, H4 = PERIOD_H4};
enum ORDERCLOSEMODE 
{
   手动平仓,
   平多开空，平空开多,
   单平多,
   单平空,
   盈利多空平仓,
};

enum ORDEROPENMODE
{
   单边递增,
   单边翻倍,
};

enum RAISEMODE
{
   直接进场,
   挂单进场,
};

enum ORDERTYPE
{
   UnknowOrder,
   OpenOrder,
   CloseOrder,
   ModifiyOrder,
};

struct OrderConf
{
   ORDERTYPE cmd;

   int ticket;
   int type;

   double lots;
   
   double profit;
   double trailstart;

   double takeprofit;
   double stoploss;
};