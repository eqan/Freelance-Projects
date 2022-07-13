//+------------------------------------------------------------------+
//|                                                                  |
//|                                     Copyright © 2022, Manan Hfz  |
//|                                     https://fiverr.com/mananhfz  |
//+------------------------------------------------------------------+
/*
   ✅ inputs
   ✅ EMAs
   ✅ 10 pips int
   ✅ SL,TP = 0
   ✅ Trailing stop
   ✅ Profit $$ = 0.01 double
   ✅ Loss $$ = 0.01 double
   ✅ Lotsize = 0.01 double
   ✅ Lot multiplier = 2 double
*/
#property copyright "Copyright © 2022, Mananhfz"
#property link      "https://fiverr.com/mananhfz"
#property version   "1.00"
#property strict
enum settings
   {
   settings = 0,                                  //======= Settings =======
   };
struct TradeInfo
   {
   double            orderPrice;
   int               orderType;
   };

input settings gs = 0;                                       // ===== General =====
input double pipLimit = 10;                                  // Distance to Open Next Trade (pips)
input double LotSize = 0.01;                                 // LotSize
input double lotMultipler = 2;                               // LotSizeMultiplier
input double totalProfitLimit = 10;                          // Max Profit Limit $$
input double totalLossLimit = 20;                            // Max Loss Limit $$
input int slippage = 5;                                      // Slippage
input int magicNumber = 123;                                 // Magic Number


input settings mas1 = 0;                                     // ===== EMA 1 Settings =====
input int ma_period1 = 10;                                    // MA Period
input int ma_shift1 = 0;                                      // MA Shift
input ENUM_MA_METHOD  ma_method1 = MODE_EMA;                  // MA Method
input ENUM_APPLIED_PRICE ma_price1 = PRICE_CLOSE;             // MA Price


input settings mas2 = 0;                                     // ===== EMA 2 Settings =====
input int ma_period2 = 20;                                    // MA Period
input int ma_shift2 = 0;                                      // MA Shift
input ENUM_MA_METHOD  ma_method2 = MODE_EMA;                  // MA Method
input ENUM_APPLIED_PRICE ma_price2 = PRICE_CLOSE;             // MA Price


datetime current;
double pip = Point, stopLevel, lotSize;
int totalBuy = 0, totalSell = 0, step;
bool enableBuyTrade = false, enableSellTrade = false;
bool allowTrailingStop = true;
double takeProfit = 0, stopLoss = 0;
TradeInfo lastTradeInfo;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
   {
//---
   pip = pip * 10.0;
   stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * pip;
   step = (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.1) + 2 * (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.01);
   lotSize = NormalizeDouble(LotSize, step);
   if(lotSize != LotSize)
      {
      lotSize = lotSize == 0 ? MarketInfo(Symbol(), MODE_MINLOT) : lotSize;
      Print("Wrong Volume " + DoubleToString(LotSize, 2) + " for Pair " + Symbol() + ".It should be round off to " + (string)step + " decimal places like " + DoubleToString(lotSize, step));
      Alert("Wrong Volume " + DoubleToString(LotSize, 2) + " for Pair " + Symbol() + ".It should be round off to " + (string)step + " decimal places like " + DoubleToString(lotSize, step));
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
void OnTick()
   {
//---
   ordersTotal();
   continuousTrade();

   if(current != Time[0])
      {
      current = Time[0];
      order();
      }

   closingTrades();
   }
//+------------------------------------------------------------------+
//| Function to Check if the Conditions for the Order has met        |
//+------------------------------------------------------------------+
void order()
   {
   if(totalBuy > 0 || totalSell > 0)
      return;

   double ma1_1 = iMA(NULL, 0, ma_period1, ma_shift1, ma_method1, ma_price1, 1);
   double ma2_1 = iMA(NULL, 0, ma_period2, ma_shift2, ma_method2, ma_price2, 1);
   if(ma1_1 < ma2_1)
      orderBuy(lotSize);
   else
      orderSell(lotSize);
   }
//+------------------------------------------------------------------+
//| Function to open Trades continuously                             |
//+------------------------------------------------------------------+
void continuousTrade()
   {
   setLastTradeInfo();
   if(lastTradeInfo.orderType != -1)
      {
      if(Ask - lastTradeInfo.orderPrice >= pipLimit * pip)
         orderBuy(getLotsize());
      if(lastTradeInfo.orderPrice - Bid >= pipLimit * pip)
         orderSell(getLotsize());
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closingTrades()
   {
   double profit = 0;
   calculateProfitLoss(profit);
   if(profit >= totalProfitLimit && totalProfitLimit != 0)
      {
      orderCloseBuy("$" + DoubleToStr(totalProfitLimit, 2) + " Profit");
      orderCloseSell("$" + DoubleToStr(totalProfitLimit, 2) + " Profit");
      }
   if(profit <= -1 * totalLossLimit && totalLossLimit != 0)
      {
      orderCloseBuy("$" + DoubleToStr(totalLossLimit, 2) + " Loss");
      orderCloseSell("$" + DoubleToStr(totalLossLimit, 2) + " Loss");
      }
   }
//+------------------------------------------------------------------+
//| Calculate Total Profit And Loss                                  |
//+------------------------------------------------------------------+
void calculateProfitLoss(double &profit)
   {
   for(int pos = OrdersTotal() - 1; pos >= 0; --pos)
      if(OrderSelect(pos, SELECT_BY_POS))
         if(OrderType() < 2 && OrderSymbol() == _Symbol && OrderMagicNumber() == magicNumber)
            profit += OrderProfit() + OrderSwap() + OrderCommission();
   }
//+------------------------------------------------------------------+
//| Function to count total Buy, Sell Orders                         |
//+------------------------------------------------------------------+
void setLastTradeInfo()
   {
   for(int i = OrdersTotal() - 1; i >= 0; --i) // Cycle searching in orders
      {
      if(OrderSelect(i, SELECT_BY_POS) == true)
         {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
            {
            if(OrderType() == OP_BUY || OrderType() == OP_SELL)
               {
               lastTradeInfo.orderPrice = OrderOpenPrice();
               lastTradeInfo.orderType = OrderType();
               return;
               }
            }
         }
      }
   lastTradeInfo.orderType = -1;
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
void orderBuy(double l)
   {
   RefreshRates();
   double sl = (stopLoss == 0) ? 0 : NormalizeDouble(Ask - stopLoss * pip, Digits);
   double tp = (takeProfit == 0) ? 0 : NormalizeDouble(Ask + takeProfit * pip, Digits);

   int retries = 3;
   while(retries >= 0)
      {
      if(OrderSend(Symbol(), OP_BUY, l, Ask, slippage, sl, tp, "", magicNumber, 0, clrBlue) < 0)
         {
         Print("Buy Order failed with error #", GetLastError());
         if(tp != 0 && tp - Bid < stopLevel)
            Print("Wrong Takeprofit " + DoubleToString(tp, Digits) + ", TP should be at " + DoubleToString(Ask + stopLevel, Digits) + " or above");
         if(sl != 0 && Bid - sl < stopLevel)
            Print("Wrong Stoploss " + DoubleToString(sl, Digits) + ", SL should be at " + DoubleToString(Bid - stopLevel, Digits) + " or below");
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
void orderSell(double l)
   {
   RefreshRates();
   double sl = (stopLoss == 0) ? 0 : NormalizeDouble(Bid + stopLoss * pip, Digits);
   double tp = (takeProfit == 0) ? 0 : NormalizeDouble(Bid - takeProfit * pip, Digits);

   int retries = 3;
   while(retries >= 0)
      {
      if(OrderSend(Symbol(), OP_SELL, l, Bid, slippage, sl, tp, "", magicNumber, 0, clrRed) < 0)
         {
         Print("Sell Order failed with error #", GetLastError());
         if(tp != 0 && Ask - tp < stopLevel)
            Print("Wrong Takeprofit " + DoubleToString(tp, Digits) + ", TP should be at " + DoubleToString(Bid - stopLevel, Digits) + " or below");
         if(sl != 0 && sl - Ask < stopLevel)
            Print("Wrong Stoploss " + DoubleToString(sl, Digits) + ", SL should be at " + DoubleToString(Ask + stopLevel, Digits) + " or above");
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
//| Compute Necessary Elements Before Every Trade                    |
//+------------------------------------------------------------------+
double getLotsize()
   {
   double l = NormalizeDouble(getPrevLot() * lotMultipler, step);
   l = MathMin(MarketInfo(Symbol(), MODE_MAXLOT), l);
   l = MathMax(MarketInfo(Symbol(), MODE_MINLOT), l);
   return l;
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPrevLot()
   {
   for(int i = OrdersTotal() - 1; i >= 0; --i) // Cycle searching in orders
      {
      if(OrderSelect(i, SELECT_BY_POS) == true)
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
            return OrderLots();
      }
   return lotSize;
   }
//+------------------------------------------------------------------+
//| Function to count total Buy, Sell Orders                         |
//+------------------------------------------------------------------+
void ordersTotal()
   {
   totalBuy = totalSell = 0;
   for(int i = OrdersTotal() - 1; i >= 0; --i) // Cycle searching in orders
      {
      if(OrderSelect(i, SELECT_BY_POS) == true)
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
      if(OrderSelect(i, SELECT_BY_POS) == true)
         {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber && OrderType() == OP_BUY)
            {
            if(OrderClose(OrderTicket(), OrderLots(), Bid, slippage, clrCyan) == true)
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
      if(OrderSelect(i, SELECT_BY_POS) == true)
         {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber && OrderType() == OP_SELL)
            {
            if(OrderClose(OrderTicket(), OrderLots(), Ask, slippage, clrCyan) == true)
               Print("Sell Order closed on " + com);
            }
         }
      }
   }
//+------------------------------------------------------------------+
