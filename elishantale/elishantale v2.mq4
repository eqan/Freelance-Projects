//+------------------------------------------------------------------+
//|                                                                  |
//|                                     Copyright © 2022, MananHfz   |
//|                                     https://fiverr.com/mananhfz  |
//+------------------------------------------------------------------+
/*
  ✅ - Sell/Buy Trade on outer bands + Extra Limit and according to candle types
  ✅ - Closing of trades via opposite color bands whether inner or outer
  ✅ - Trailing Stop Feature
  ✅ - 1 Buy Or 1 Sell Trade at a time
  ✅ - Alerts on trade
*/

#property copyright "Copyright © 2022, MananHfz  "
#property link      "https://fiverr.com/mananhfz "
#property version   "1.00"
#property strict

#define bullish 0
#define bearish 1
enum settings
  {
   settings = 0,                                  //======= Settings =======
  };
input settings gs = 0;                                        // ===== General =====
input double LotSize = 0.01;                                  // LotSize
input double stopLoss = 30;                                   // Stop Loss (Pips)
input int slippage = 5;                                       // Slippage
input int magicNumber = 123;                                  // Magic Number

input settings ds1s = 0;                                      // ===== DS Indicator 1 Settings =====
input int ds1_HalfLength = 63;                                // Half Length
input int ds1_Price = 0;                                      // Price
input double ds1_ATRMultiplier = 3.0;                         // ATR Multiplier
input int ds1_ATRPeriod = 110;                                // ATR Period
input bool ds1_Interpolate = true;                            // ATR Interpolate

input settings ds2s = 0;                                      // ===== DS Indicator2 Settings =====
input int ds2_HalfLength = 63;                                // Half Length
input int ds2_Price = 0;                                      // Price
input double ds2_ATRMultiplier = 2.0;                         // ATR Multiplier
input int ds2_ATRPeriod = 110;                                // ATR Period
input bool ds2_Interpolate = true;                            // ATR Interpolate

input settings tss = 0;                                       // ===== Trailing Stop =====
input bool allowTrailingStop = true;                          // Allow Trailing Stop ?
input int trailingStart = 20;                                 // Trailing Start (Pips)
input int trailingStep = 15;                                  // Trailing Stop  (Pips)

input settings als = 0;                                       // ===== Alerts =====
input bool allowAlerts = false;                               // Desktop Alerts ?
input bool allowMobile = false;                               // Mobile Alerts ?
input bool allowEmail = false;                                // Email Alerts ?


datetime current;
double pip = Point,stopLevel,lotSize;
int totalBuy = 0,totalSell = 0,step;
string dir="";
double takeProfit = 0;

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
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   ordersTotal();
   if(current != iTime(Symbol(), PERIOD_M1, 0))
     {
      current = iTime(Symbol(), PERIOD_M1, 0);
      order();
     }
   if(allowTrailingStop)
      trailingStop();
  }
//+------------------------------------------------------------------+
//| Function to Check if the Conditions for the Order has met        |
//+------------------------------------------------------------------+
void order()
  {
   double dsi1_lineRed = iCustom(Symbol(), 0, dir + "DJ SCALPERWAY","All tf",ds1_HalfLength, ds1_Price, ds1_ATRMultiplier, ds1_ATRPeriod, ds1_Interpolate, 1, 1);
   double dsi1_lineBlue = iCustom(Symbol(), 0, dir + "DJ SCALPERWAY","All tf",ds1_HalfLength, ds1_Price, ds1_ATRMultiplier, ds1_ATRPeriod, ds1_Interpolate, 2, 1);
   double dsi2_lineRed = iCustom(Symbol(), 0, dir + "DJ SCALPERWAY","All tf",ds2_HalfLength, ds2_Price, ds2_ATRMultiplier, ds2_ATRPeriod, ds2_Interpolate, 1, 1);
   double dsi2_lineBlue = iCustom(Symbol(), 0, dir + "DJ SCALPERWAY","All tf",ds2_HalfLength, ds2_Price, ds2_ATRMultiplier, ds2_ATRPeriod, ds2_Interpolate, 2, 1);
   double outerBandRed, outerBandBlue, innerBandRed, innerBandBlue;

   outerBandRed = MathMax(dsi1_lineRed, dsi2_lineRed);
   outerBandBlue = MathMin(dsi1_lineBlue, dsi2_lineBlue);
   innerBandRed = MathMin(dsi1_lineRed, dsi2_lineRed);
   innerBandBlue = MathMax(dsi1_lineBlue, dsi2_lineBlue);

   if(iOpen(Symbol(),PERIOD_M1,1) > outerBandRed && iClose(Symbol(),PERIOD_M1,1) < outerBandRed
      && totalSell == 0)
      orderSell();

   else
      if(iClose(Symbol(),PERIOD_M1,1) > outerBandBlue && iOpen(Symbol(),PERIOD_M1,1) < outerBandBlue
         && totalBuy ==0)
         orderBuy();

   if(totalBuy > 0 && (Ask > outerBandRed || Ask > innerBandRed))
     {
      orderCloseBuy("Buy Order Closed On Red Line!");
     }

   if(totalSell > 0 && (Bid < outerBandBlue || Bid < innerBandBlue))
     {
      orderCloseSell("Sell Order Closed On Blue Line!");
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
         doAlert("Buy Trade", "Buy Trade Placed!");
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
         doAlert("Sell Trade", "Sell Trade Placed!");
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
              {
               Print("Buy Order closed on " + com);
               doAlert("Buy Trade", "Buy Trade Closed!");
              }
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
              {
               Print("Sell Order closed on " + com);
               doAlert("Sell Trade", "Sell Trade Closed!");
              }
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

//+------------------------------------------------------------------+
//| Function to Show Alerts                                          |
//+------------------------------------------------------------------+
void doAlert(string title,string msg)
  {
   if(allowAlerts)
      Alert(msg);
   if(allowEmail)
      SendMail(title,msg);
   if(allowMobile)
      SendNotification(msg);
  }
//+------------------------------------------------------------------+