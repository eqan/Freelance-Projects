//+------------------------------------------------------------------+
//|                                                                  |
//|                                     Copyright © 2022, Eqan Ahmad |
//|                                     https://fiverr.com/eqanahmad |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Eqan Ahmad"
#property link      "https://fiverr.com/eqanahmad"
#property version   "1.00"
#property strict
/*
   ✅I'm looking for a very basic ea that compares sma to wma with input available for each period.
   ✅Other inputs needed are lot size, Max open trades, trading hours. TP, SL, and TSL with option to turn off ( if it =0)

   ✅Logic- buy/ sell when WMA crosses SMA.
   ✅Close the buy/sell position when it crosses again

   ✅option to add multiple timeframes-- only enter position if 15min, 60min and 420min candles align
*/

enum settings
  {
   settings = 0,                                  //======= Settings =======
  };
// Definition of an hour. This is necessary for a drop down menu for hours input.
enum ENUM_HOUR
{
   h00 = 00, // 00:00
   h01 = 01, // 01:00
   h02 = 02, // 02:00
   h03 = 03, // 03:00
   h04 = 04, // 04:00
   h05 = 05, // 05:00
   h06 = 06, // 06:00
   h07 = 07, // 07:00
   h08 = 08, // 08:00
   h09 = 09, // 09:00
   h10 = 10, // 10:00
   h11 = 11, // 11:00
   h12 = 12, // 12:00
   h13 = 13, // 13:00
   h14 = 14, // 14:00
   h15 = 15, // 15:00
   h16 = 16, // 16:00
   h17 = 17, // 17:00
   h18 = 18, // 18:00
   h19 = 19, // 19:00
   h20 = 20, // 20:00
   h21 = 21, // 21:00
   h22 = 22, // 22:00
   h23 = 23, // 23:00
};

input settings gs = 0;                                        // ===== General =====
input double LotSize = 0.01;                                  // LotSize
input int slippage = 5;                                       // Slippage
input int magicNumber = 123;                                  // Magic Number
input double takeProfit = 20;                                 // Take Profit (Pips)
input double stopLoss = 30;                                   // Stop Loss (Pips)
input int maxOpenTrades = 5;                                  // Max Open Trades

input settings ths = 0;                                       // ===== Trading Hours Setup =====
input ENUM_HOUR StartHour = 9;                                // Starting Hour
input ENUM_HOUR LastHour = 5;                                 // Ending Hour

input settings tss = 0;                                       // ===== Trailing Stop =====
input bool enableTrailingStop = true;                         // Allow Trailing Stop ?
input int trailingStart = 200;                                // Trailing Start
input int trailingStep = 150;                                 // Trailing Stop

input settings tfs = 0;                                       // ===== Time Frames Setup =====
input bool enableMultipleTimeFrame = true;                    // Enable Multiple Time Frame
input bool enable15MinsTime = true;                           // Enable 15 Mins Time Frame
input bool enable60MinsTime = true;                           // Enable 60 Mins Time Frame
input bool enable240MinsTime = true;                          // Enable 240 Mins Time Frame

input settings smas = 0;                                      // ===== SMA Current Setup =====
input int smaPeriod = 5;                                      // Period
input int smaShift = 0;                                       // Shift

input settings wmas = 0;                                      // ===== WMA Current Setup =====
input int wmaPeriod = 5;                                      // Period
input int wmaShift = 0;                                       // Shift

input settings smas_1 = 0;                                    // ===== SMA 15 Setup =====
input int smaPeriod_1 = 5;                                    // Period
input int smaShift_1 = 0;                                     // Shift

input settings wmas_1 = 0;                                    // ===== WMA 15 Setup =====
input int wmaPeriod_1 = 5;                                    // Period
input int wmaShift_1 = 0;                                     // Shift

input settings smas_2 = 0;                                    // ===== SMA 60 Setup =====
input int smaPeriod_2 = 5;                                    // Period
input int smaShift_2 = 0;                                     // Shift

input settings wmas_2 = 0;                                    // ===== WMA 60 Setup =====
input int wmaPeriod_2 = 5;                                    // Period
input int wmaShift_2 = 0;                                     // Shift

input settings smas_3 = 0;                                    // ===== SMA 240 Setup =====
input int smaPeriod_3 = 5;                                    // Period
input int smaShift_3 = 0;                                     // Shift

input settings wmas_3 = 0;                                    // ===== WMA 240 Setup =====
input int wmaPeriod_3 = 5;                                    // Period
input int wmaShift_3 = 0;                                     // Shift


datetime current;
double pip = Point,stopLevel,lotSize;
int totalBuy = 0,totalSell = 0,step;
string dir="";


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   pip = pip * 10.0;
   stopLevel = MarketInfo(Symbol(),MODE_STOPLEVEL) * pip;
   step = (MarketInfo(Symbol(),MODE_LOTSTEP) == 0.1) + 2 * (MarketInfo(Symbol(),MODE_LOTSTEP) == 0.01);
   lotSize = NormalizeDouble(LotSize,step);
   if(lotSize != LotSize)
     {
      lotSize = lotSize == 0 ? MarketInfo(Symbol(),MODE_MINLOT) : lotSize;
      Print("Wrong Volume " + DoubleToString(LotSize,2) + " for Pair " + Symbol() + ".It should be round off to " + (string)step + " decimal places like " + DoubleToString(lotSize,step));
      Alert("Wrong Volume " + DoubleToString(LotSize,2) + " for Pair " + Symbol() + ".It should be round off to " + (string)step + " decimal places like " + DoubleToString(lotSize,step));
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
//| Check Active Hours                                               |
//+------------------------------------------------------------------+
bool CheckActiveHours()
{
   // Set operations disabled by default.
   bool OperationsAllowed = false;
   // Check if the current hour is between the allowed hours of operations. If so, return true.
   if ((StartHour == LastHour) && (Hour() == StartHour))
      OperationsAllowed = true;
   if ((StartHour < LastHour) && (Hour() >= StartHour) && (Hour() <= LastHour))
      OperationsAllowed = true;
   if ((StartHour > LastHour) && (((Hour() >= LastHour) && (Hour() <= 23)) || ((Hour() <= StartHour) && (Hour() > 0))))
      OperationsAllowed = true;
   return OperationsAllowed;
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   ordersTotal();
   if(current != Time[0])
     {
      current = Time[0];
      order();
     }
   if(enableTrailingStop)
   {
      trailingStop();
   }
  }
//+------------------------------------------------------------------+
//| Function to Check if the Conditions for the Order has met        |
//+------------------------------------------------------------------+
void order()
  {

   if(maxOpenTrades >= OrdersTotal())
     {
      orderCloseBuy("Buy Order Closed on Max Open Trades!");
      orderCloseSell("Sell Order Closed on Max Open Trades!");
     }
   if(CheckActiveHours())
   {
      if(enableMultipleTimeFrame)
     {
      double wma1_1 = EMPTY_VALUE, wma1_2 = EMPTY_VALUE;
      double wma2_1 = EMPTY_VALUE, wma2_2 = EMPTY_VALUE;
      double wma3_1 = EMPTY_VALUE, wma3_2 = EMPTY_VALUE;
      double sma1_1 = EMPTY_VALUE, sma1_2 = EMPTY_VALUE;
      double sma2_1 = EMPTY_VALUE, sma2_2 = EMPTY_VALUE;
      double sma3_1 = EMPTY_VALUE, sma3_2 = EMPTY_VALUE;

      bool mins15BuyAligned = false;
      bool mins60BuyAligned = false;
      bool mins240BuyAligned = false;
      bool mins15SellAligned = false;
      bool mins60SellAligned = false;
      bool mins240SellAligned = false;

      if(enable15MinsTime)
        {
         wma1_1 = iMA(NULL,PERIOD_M15, wmaPeriod_1, wmaShift_1, MODE_LWMA, PRICE_CLOSE, 0);
         wma1_2 = iMA(NULL,PERIOD_M15, wmaPeriod_1, wmaShift_1, MODE_LWMA, PRICE_CLOSE, 1);
         sma1_1 = iMA(NULL,PERIOD_M15, smaPeriod_1, smaShift_1, MODE_SMA,  PRICE_CLOSE, 0);
         sma1_2 = iMA(NULL,PERIOD_M15, smaPeriod_1, smaShift_1, MODE_SMA,  PRICE_CLOSE, 1);
         if(wma1_2 > sma1_2 && wma1_1 < sma1_1)
           {
            mins15BuyAligned = true;
           }
         else
            if(wma1_2 < sma1_2 && wma1_1 > sma1_1)
              {
               mins15SellAligned = true;
              }
        }
      if(enable60MinsTime)
        {
         wma2_1 = iMA(NULL,PERIOD_H1, wmaPeriod_2, wmaShift_2, MODE_LWMA, PRICE_CLOSE, 0);
         wma2_2 = iMA(NULL,PERIOD_H1, wmaPeriod_2, wmaShift_2, MODE_LWMA, PRICE_CLOSE, 1);
         sma2_1 = iMA(NULL,PERIOD_H1, smaPeriod_2, smaShift_2, MODE_SMA,  PRICE_CLOSE, 0);
         sma2_2 = iMA(NULL,PERIOD_H1, smaPeriod_2, smaShift_2, MODE_SMA,  PRICE_CLOSE, 1);
         if(wma2_2 > sma2_2 && wma2_1 < sma2_1)
           {
            mins60BuyAligned = true;
           }
         else
            if(wma2_2 < sma2_2 && wma2_1 > sma2_1)
              {
               mins60SellAligned = true;
              }
        }
      if(enable240MinsTime)
        {
         wma3_1 = iMA(NULL,PERIOD_H4, wmaPeriod_3, wmaShift_3, MODE_LWMA, PRICE_CLOSE, 0);
         wma3_2 = iMA(NULL,PERIOD_H4, wmaPeriod_3, wmaShift_3, MODE_LWMA, PRICE_CLOSE, 1);
         sma3_1 = iMA(NULL,PERIOD_H4, smaPeriod_3, smaShift_3, MODE_SMA,  PRICE_CLOSE, 0);
         sma3_2 = iMA(NULL,PERIOD_H4, smaPeriod_3, smaShift_3, MODE_SMA,  PRICE_CLOSE, 1);
         if(wma3_2 > sma3_2 && wma3_1 < sma3_1)
           {
            mins240BuyAligned = true;
           }
         else
            if(wma3_2 < sma3_2 && wma3_1 > sma3_1)
              {
               mins240SellAligned = true;
              }
        }
      if(enable15MinsTime && enable60MinsTime && enable240MinsTime)
      {
         if(mins15BuyAligned && mins60BuyAligned && mins240BuyAligned)
         {
            orderCloseBuy("Buy order closed all timeframes aligned!");
            orderBuy();
         }
         else if(mins15SellAligned && mins60SellAligned && mins240SellAligned)
         {
            orderCloseSell("Sell order closed all timeframes aligned!");
            orderSell();
         }
      }
      else if(enable15MinsTime && enable60MinsTime)
      {
         if(mins15BuyAligned && mins60BuyAligned)
         {
            orderCloseBuy("Buy order closed all timeframes aligned!");
            orderBuy();
         }
         else if(mins15SellAligned && mins60SellAligned)
         {
            orderCloseSell("Sell order closed all timeframes aligned!");
            orderSell();
         }
      }
      else if(enable15MinsTime && enable240MinsTime)
      {
         if(mins15BuyAligned && mins240BuyAligned)
         {
            orderCloseBuy("Buy order closed all timeframes aligned!");
            orderBuy();
         }
         else if(mins15SellAligned && mins240SellAligned)
         {
            orderCloseSell("Sell order closed all timeframes aligned!");
            orderSell();
         }
      }      
      else if(enable60MinsTime && enable240MinsTime)
      {
         if(mins60BuyAligned && mins240BuyAligned)
         {
            orderCloseBuy("Buy order closed all timeframes aligned!");
            orderBuy();
         }
         else if(mins60SellAligned && mins240SellAligned)
         {
            orderCloseSell("Sell order closed all timeframes aligned!");
            orderSell();
         }
      }
      else if(enable15MinsTime)
      {
         if(mins15BuyAligned)
         {
            orderCloseBuy("Buy order closed all timeframes aligned!");
            orderBuy();
         }
         else if(mins15SellAligned)
         {
            orderCloseSell("Sell order closed all timeframes aligned!");
            orderSell();
         }
      }
      else if(enable60MinsTime)
      {
         if(mins60BuyAligned)
         {
            orderCloseBuy("Buy order closed all timeframes aligned!");
            orderBuy();
         }
         else if(mins60SellAligned)
         {
            orderCloseSell("Sell order closed all timeframes aligned!");
            orderSell();
         }
      }
      else if(enable240MinsTime)
      {
         if(mins240BuyAligned)
         {
            orderCloseBuy("Buy order closed all timeframes aligned!");
            orderBuy();
         }
         else if(mins240SellAligned)
         {
            orderCloseSell("Sell order closed all timeframes aligned!");
            orderSell();
         }
      }
     }
   else
     {
      double wma1_1 = iMA(NULL,0, wmaPeriod, wmaShift, MODE_LWMA, PRICE_CLOSE, 0);
      double wma1_2 = iMA(NULL,0, wmaPeriod, wmaShift, MODE_LWMA, PRICE_CLOSE, 1);
      double sma1_1 = iMA(NULL,0, smaPeriod, smaShift, MODE_SMA,  PRICE_CLOSE, 0);
      double sma1_2 = iMA(NULL,0, smaPeriod, smaShift, MODE_SMA,  PRICE_CLOSE, 1);
      if(wma1_2 > sma1_2 && wma1_1 < sma1_1)
        {
         orderCloseBuy("Buy order closed all timeframes aligned!");
         orderBuy();
        }
      else
         if(wma1_2 < sma1_2 && wma1_1 > sma1_1)
           {
            orderCloseSell("Sell order closed all timeframes aligned!");
            orderSell();
           }
     }

   }
   
  }
//+------------------------------------------------------------------------+
//| Function to return True if the double has some value, false otherwise  |
//+------------------------------------------------------------------------+
bool hasValue(double val)
  {
   return (val && val != EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//| Function to place Buy orders                                     |
//+------------------------------------------------------------------+
void orderBuy()
  {
   double sl = (stopLoss == 0) ? 0 : NormalizeDouble(Ask - stopLoss * pip, Digits);
   double tp = (takeProfit == 0) ? 0 : NormalizeDouble(Ask + takeProfit * pip, Digits);

   int retries = 10;
   while(retries >= 0)
     {
      if(OrderSend(Symbol(),OP_BUY,lotSize,Ask,slippage,sl,tp,"",magicNumber,0,clrBlue) < 0)
        {
         Print("Buy Order failed with error #",GetLastError());
         if(tp != 0 && tp - Bid < stopLevel)
            Print("Wrong Takeprofit " + DoubleToString(tp,Digits) + ", TP should be at " + DoubleToString(Ask + stopLevel,Digits) + " or above");
         if(sl != 0 && Bid - sl < stopLevel)
            Print("Wrong Stoploss " + DoubleToString(sl,Digits) + ", SL should be at " + DoubleToString(Bid - stopLevel,Digits) + " or below");
         if(retries - 1 >= 0)
            Sleep(1000);
        }
      else
        {
         Print("Buy Order placed successfully");
         break;
        }
      --retries;
     }//End While
  }
//+------------------------------------------------------------------+
//| Function to place Sell Orders                                    |
//+------------------------------------------------------------------+
void orderSell()
  {
   double sl = (stopLoss == 0) ? 0 : NormalizeDouble(Bid + stopLoss * pip, Digits);
   double tp = (takeProfit == 0) ? 0 : NormalizeDouble(Bid - takeProfit * pip, Digits);

   int retries = 3;
   while(retries >= 0)
     {
      if(OrderSend(Symbol(),OP_SELL,lotSize,Bid,slippage,sl,tp,"",magicNumber,0,clrRed) < 0)
        {
         Print("Sell Order failed with error #",GetLastError());
         if(tp != 0 && Ask - tp < stopLevel)
            Print("Wrong Takeprofit " + DoubleToString(tp,Digits) + ", TP should be at " + DoubleToString(Bid - stopLevel,Digits) + " or below");
         if(sl != 0 && sl - Ask < stopLevel)
            Print("Wrong Stoploss " + DoubleToString(sl,Digits) + ", SL should be at " + DoubleToString(Ask + stopLevel,Digits) + " or above");
         if(retries - 1 >= 0)
            Sleep(1000);
        }
      else
        {
         Print("Sell Order placed successfully");
         break;
        }
      --retries;
     }//End While
  }

//+------------------------------------------------------------------+
//| Function to count total Buy, Sell Orders                         |
//+------------------------------------------------------------------+
void ordersTotal()
  {
   totalBuy = totalSell = 0;
   for(int i = OrdersTotal() - 1; i >= 0; --i) // Cycle searching in orders
     {
      if(OrderSelect(i,SELECT_BY_POS) == true)
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
           {
            if(OrderType() == OP_BUY)
               ++totalBuy;
            if(OrderType() == OP_SELL)
               ++totalSell;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Function to close buy orders                                     |
//+------------------------------------------------------------------+
void orderCloseBuy(string com)
  {
   for(int i = OrdersTotal() - 1; i >= 0; --i) // Cycle searching in orders
     {
      if(OrderSelect(i,SELECT_BY_POS) == true)
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber && OrderType() == OP_BUY)
           {
            if(OrderClose(OrderTicket(),OrderLots(),Bid,slippage,clrCyan) == true)
               Print("Buy Order closed on " + com);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Function to close sell orders                                    |
//+------------------------------------------------------------------+
void orderCloseSell(string com)
  {
   for(int i = OrdersTotal() - 1; i >= 0; --i) // Cycle searching in orders
     {
      if(OrderSelect(i,SELECT_BY_POS) == true)
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber && OrderType() == OP_SELL)
           {
            if(OrderClose(OrderTicket(),OrderLots(),Ask,slippage,clrCyan) == true)
               Print("Sell Order closed on " + com);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Trailing Stop Function                                           |
//+------------------------------------------------------------------+
void trailingStop()
  {
   for(int i = OrdersTotal() -1; i >= 0; --i)
     {
      if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol())
        {
         if(OrderType() == OP_BUY &&  Bid - OrderOpenPrice() >= trailingStart * pip && OrderStopLoss() < Bid - trailingStep* pip)
           {
            if(OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid - trailingStep * pip, Digits), OrderTakeProfit(), 0))
               Print("Modified buy by trailing stop");
            else
               Print("Not Modified buy by trailing stop");
           }
         else
            if(OrderType() == OP_SELL && OrderOpenPrice() - Ask >= trailingStart * pip && (OrderStopLoss() > Ask + trailingStep * pip || OrderStopLoss() == 0))
              {
               if(OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ask + trailingStep * pip, Digits), OrderTakeProfit(), 0))
                  Print("Modified sell by trailing stop");
               else
                  Print("Not Modified sell by trailing stop");
              }
        }
     }
  }