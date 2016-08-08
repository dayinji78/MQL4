//+------------------------------------------------------------------+
//|                                                 SimpleVector.mqh |
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

#define _CAPACITY_RATE_ 1.2
template<typename T>
class SimpleVector 
{
private:
   T m_list[];

   int m_maxSize;
   int m_size;

   T invalid_index;

   bool reSize(int extendSize)
   {
      if(extendSize < 0)
         extendSize = 0;

      ArrayResize(m_list, extendSize, extendSize);
      m_maxSize = extendSize;
      return true;
   }

public:
   SimpleVector(){
      ArrayResize(m_list, 0);
      m_size = 0;
      m_maxSize = 0;
   }

   ~SimpleVector(){
      m_size = 0;
      m_maxSize = 0;
   }
   
   bool init(int initSize)
   {
      if(m_size == 0)
         return false;
      if(m_size != 0 || ArraySize(m_list) != 0)
         return false;
         
      ArrayResize(m_list, initSize, initSize);
      m_maxSize = initSize;
      m_size = 0;
      return true;
   }
   bool push(int &t)
   {
      if (m_size == m_maxSize) 
      {
			int newsize =
					((int) (m_maxSize * _CAPACITY_RATE_) + 1) > m_size + 1 ?
							((int) (m_maxSize * _CAPACITY_RATE_) + 1) : m_size + 1;
			if (!reSize(newsize)) {
				return false;
			}
		}
      m_list[m_size] = t;
      m_size++;
      return true;
   }

   T operator[](int index)
   {
      if(index < 0 || index >= ArraySize(m_list))
         return invalid_index;

      return m_list[index];
   }
   
   int size()
   {
      return m_size;
   }
   
   int capacity()
   {
      return m_maxSize;
   }
   
   bool relocal(int toSize)
   {
      if(toSize < m_size)
         return false;
      if(m_maxSize > toSize)
         return true;
      return reSize(toSize);
   }
   
   bool empty()
   {
      return reSize(0);
   }
};

template<typename T>
class TArray
  {
private:
   T               m_data[];
public:

   bool              Append(T item)
     {
      int new_size=ArraySize(m_data)+1;
      int reserve =(new_size/2+15)&~15;
      //---
      if(ArrayResize(m_data,new_size,reserve)!=new_size)
         return(false);
      //---
      m_data[new_size-1]=item;
      return(true);
     }
   T                 operator[](int index)
     {
      static T invalid_index;
      //---
      if(index<0 || index>=ArraySize(m_data))
         return(invalid_index);
      //---
      
      return(m_data[index]);
     }   
  };
  