//+------------------------------------------------------------------+
//|                                                       StdDev.mq5 |
//|                        Copyright 2009, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "© GM, 2020, 2021, 2022, 2023"
#property description "EMA Bbands"
#include <MovingAverages.mqh>

#property indicator_chart_window
#property indicator_buffers 98
#property indicator_plots   98

enum enMaTypes {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
};

//--- input parametrs
input int                                    inpPeriods = 240; // Period
input int                                    InpStdDevShift = 0;   // Shift
input ENUM_MA_METHOD                         InpMAMethod = MODE_EMA; // Method
input ENUM_TIMEFRAMES                        Timeframe = PERIOD_CURRENT;                           // Timeframe
input double                                 inpDeviations = 0.25;          // Bollinger bands deviations
input int                                    offset = 0;
input double                                 margin = 0.05;
input bool                                   showMargins = true;
input bool                                   showBands = true;
input int                                    limitBars = 500;

input color                                  colorMid = clrWhite;
input double                                 larguraBandas = 1;
input bool                                   useTimer = true;
input int                                    WaitMilliseconds                    = 1000;           // Timer (milliseconds) for recalculation
bool                                         debug = false;

double               ExtStdDevBuffer[];
double bufferUp1[], bufferUp2[], bufferUp3[], bufferUp4[], bufferUp5[], bufferUp6[];
double bufferUp7[], bufferUp8[], bufferUp9[], bufferUp10[], bufferUp11[], bufferUp12[];
double bufferUp13[], bufferUp14[], bufferUp15[], bufferUp16[], bufferUp17[], bufferUp18[];
double bufferUp19[], bufferUp20[], bufferUp21[], bufferUp22[], bufferUp23[], bufferUp24[];
double bufferUp25[], bufferUp26[], bufferUp27[], bufferUp28[], bufferUp29[], bufferUp30[];
double bufferUp31[], bufferUp32[], bufferUp33[], bufferUp34[], bufferUp35[], bufferUp36[];
double bufferUp37[], bufferUp38[], bufferUp39[], bufferUp40[], bufferUp41[], bufferUp42[];
double bufferUp43[], bufferUp44[], bufferUp45[], bufferUp46[], bufferUp47[], bufferUp48[];

double bufferDn1[], bufferDn2[], bufferDn3[], bufferDn4[], bufferDn5[], bufferDn6[];
double bufferDn7[], bufferDn8[], bufferDn9[], bufferDn10[], bufferDn11[], bufferDn12[];
double bufferDn13[], bufferDn14[], bufferDn15[], bufferDn16[], bufferDn17[], bufferDn18[];
double bufferDn19[], bufferDn20[], bufferDn21[], bufferDn22[], bufferDn23[], bufferDn24[];
double bufferDn25[], bufferDn26[], bufferDn27[], bufferDn28[], bufferDn29[], bufferDn30[];
double bufferDn31[], bufferDn32[], bufferDn33[], bufferDn34[], bufferDn35[], bufferDn36[];
double bufferDn37[], bufferDn38[], bufferDn39[], bufferDn40[], bufferDn41[], bufferDn42[];
double bufferDn43[], bufferDn44[], bufferDn45[], bufferDn46[], bufferDn47[], bufferDn48[];

double bufferMe[];

int ExtStdDevPeriod, ExtStdDevShift;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit() {

   if(inpPeriods <= 1) {
      ExtStdDevPeriod = 20;
      printf("Incorrect value for input variable inpPeriods=%d. Indicator will use value=%d for calculations.", inpPeriods, ExtStdDevPeriod);
   } else ExtStdDevPeriod = inpPeriods;
   if(InpStdDevShift < 0) {
      ExtStdDevShift = 0;
      printf("Incorrect value for input variable InpStdDevShift=%d. Indicator will use value=%d for calculations.", InpStdDevShift, ExtStdDevShift);
   } else ExtStdDevShift = InpStdDevShift;

   int n_bands = 48;
   int index_buf_up = 0;
   SetIndexBuffer(index_buf_up, bufferUp1, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 1, bufferUp2, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 2, bufferUp3, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_up, PLOT_LINE_COLOR, clrDimGray);
   PlotIndexSetInteger(index_buf_up + 1, PLOT_LINE_COLOR, clrDimGray);
   PlotIndexSetInteger(index_buf_up + 2, PLOT_LINE_COLOR, clrDimGray);

   SetIndexBuffer(index_buf_up + 3, bufferUp4, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 4, bufferUp5, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 5, bufferUp6, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_up + 3, PLOT_LINE_COLOR, clrDimGray);
   PlotIndexSetInteger(index_buf_up + 4, PLOT_LINE_COLOR, clrDimGray);
   PlotIndexSetInteger(index_buf_up + 5, PLOT_LINE_COLOR, clrDimGray);

   SetIndexBuffer(index_buf_up + 6, bufferUp7, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 7, bufferUp8, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 8, bufferUp9, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_up + 6, PLOT_LINE_COLOR, clrAqua);
   PlotIndexSetInteger(index_buf_up + 7, PLOT_LINE_COLOR, clrAqua);
   PlotIndexSetInteger(index_buf_up + 8, PLOT_LINE_COLOR, clrAqua);

   SetIndexBuffer(index_buf_up + 9, bufferUp10, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 10, bufferUp11, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 11, bufferUp12, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_up + 9, PLOT_LINE_COLOR, clrAqua);
   PlotIndexSetInteger(index_buf_up + 10, PLOT_LINE_COLOR, clrAqua);
   PlotIndexSetInteger(index_buf_up + 11, PLOT_LINE_COLOR, clrAqua);

   SetIndexBuffer(index_buf_up + 12, bufferUp13, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 13, bufferUp14, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 14, bufferUp15, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_up + 12, PLOT_LINE_COLOR, clrGreen);
   PlotIndexSetInteger(index_buf_up + 13, PLOT_LINE_COLOR, clrGreen);
   PlotIndexSetInteger(index_buf_up + 14, PLOT_LINE_COLOR, clrGreen);

   SetIndexBuffer(index_buf_up + 15, bufferUp16, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 16, bufferUp17, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 17, bufferUp18, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_up + 15, PLOT_LINE_COLOR, clrGreen);
   PlotIndexSetInteger(index_buf_up + 16, PLOT_LINE_COLOR, clrGreen);
   PlotIndexSetInteger(index_buf_up + 17, PLOT_LINE_COLOR, clrGreen);

   SetIndexBuffer(index_buf_up + 18, bufferUp19, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 19, bufferUp20, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 20, bufferUp21, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_up + 18, PLOT_LINE_COLOR, clrOrange);
   PlotIndexSetInteger(index_buf_up + 19, PLOT_LINE_COLOR, clrOrange);
   PlotIndexSetInteger(index_buf_up + 20, PLOT_LINE_COLOR, clrOrange);

   SetIndexBuffer(index_buf_up + 21, bufferUp22, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 22, bufferUp23, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 23, bufferUp24, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_up + 21, PLOT_LINE_COLOR, clrOrange);
   PlotIndexSetInteger(index_buf_up + 22, PLOT_LINE_COLOR, clrOrange);
   PlotIndexSetInteger(index_buf_up + 23, PLOT_LINE_COLOR, clrOrange);

   SetIndexBuffer(index_buf_up + 24, bufferUp25, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 25, bufferUp26, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 26, bufferUp27, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_up + 24, PLOT_LINE_COLOR, clrLightCoral);
   PlotIndexSetInteger(index_buf_up + 25, PLOT_LINE_COLOR, clrLightCoral);
   PlotIndexSetInteger(index_buf_up + 26, PLOT_LINE_COLOR, clrLightCoral);

   SetIndexBuffer(index_buf_up + 27, bufferUp28, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 28, bufferUp29, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 29, bufferUp30, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_up + 27, PLOT_LINE_COLOR, clrLightCoral);
   PlotIndexSetInteger(index_buf_up + 28, PLOT_LINE_COLOR, clrLightCoral);
   PlotIndexSetInteger(index_buf_up + 29, PLOT_LINE_COLOR, clrLightCoral);

   SetIndexBuffer(index_buf_up + 30, bufferUp31, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 31, bufferUp32, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 32, bufferUp33, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_up + 30, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetInteger(index_buf_up + 31, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetInteger(index_buf_up + 32, PLOT_LINE_COLOR, clrRed);

   SetIndexBuffer(index_buf_up + 33, bufferUp34, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 34, bufferUp35, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 35, bufferUp36, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_up + 33, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetInteger(index_buf_up + 34, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetInteger(index_buf_up + 35, PLOT_LINE_COLOR, clrRed);

   SetIndexBuffer(index_buf_up + 36, bufferUp37, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 37, bufferUp38, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 38, bufferUp39, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_up + 36, PLOT_LINE_COLOR, clrPurple);
   PlotIndexSetInteger(index_buf_up + 37, PLOT_LINE_COLOR, clrPurple);
   PlotIndexSetInteger(index_buf_up + 38, PLOT_LINE_COLOR, clrPurple);

   SetIndexBuffer(index_buf_up + 39, bufferUp40, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 40, bufferUp41, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 41, bufferUp42, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_up + 39, PLOT_LINE_COLOR, clrPurple);
   PlotIndexSetInteger(index_buf_up + 40, PLOT_LINE_COLOR, clrPurple);
   PlotIndexSetInteger(index_buf_up + 41, PLOT_LINE_COLOR, clrPurple);

   SetIndexBuffer(index_buf_up + 42, bufferUp43, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 43, bufferUp44, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 44, bufferUp45, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_up + 42, PLOT_LINE_COLOR, clrFuchsia);
   PlotIndexSetInteger(index_buf_up + 43, PLOT_LINE_COLOR, clrFuchsia);
   PlotIndexSetInteger(index_buf_up + 44, PLOT_LINE_COLOR, clrFuchsia);

   SetIndexBuffer(index_buf_up + 45, bufferUp46, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 46, bufferUp47, INDICATOR_DATA);
   SetIndexBuffer(index_buf_up + 47, bufferUp48, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_up + 45, PLOT_LINE_COLOR, clrFuchsia);
   PlotIndexSetInteger(index_buf_up + 46, PLOT_LINE_COLOR, clrFuchsia);
   PlotIndexSetInteger(index_buf_up + 47, PLOT_LINE_COLOR, clrFuchsia);








   int index_buf_dn = n_bands;
   SetIndexBuffer(index_buf_dn, bufferDn1, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 1, bufferDn2, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 2, bufferDn3, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn, PLOT_LINE_COLOR, clrDimGray);
   PlotIndexSetInteger(index_buf_dn + 1, PLOT_LINE_COLOR, clrDimGray);
   PlotIndexSetInteger(index_buf_dn + 2, PLOT_LINE_COLOR, clrDimGray);

   SetIndexBuffer(index_buf_dn + 3, bufferDn4, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 4, bufferDn5, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 5, bufferDn6, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn + 3, PLOT_LINE_COLOR, clrDimGray);
   PlotIndexSetInteger(index_buf_dn + 4, PLOT_LINE_COLOR, clrDimGray);
   PlotIndexSetInteger(index_buf_dn + 5, PLOT_LINE_COLOR, clrDimGray);

   SetIndexBuffer(index_buf_dn + 6, bufferDn7, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 7, bufferDn8, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 8, bufferDn9, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn + 6, PLOT_LINE_COLOR, clrAqua);
   PlotIndexSetInteger(index_buf_dn + 7, PLOT_LINE_COLOR, clrAqua);
   PlotIndexSetInteger(index_buf_dn + 8, PLOT_LINE_COLOR, clrAqua);

   SetIndexBuffer(index_buf_dn + 9, bufferDn10, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 10, bufferDn11, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 11, bufferDn12, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn + 9, PLOT_LINE_COLOR, clrAqua);
   PlotIndexSetInteger(index_buf_dn + 10, PLOT_LINE_COLOR, clrAqua);
   PlotIndexSetInteger(index_buf_dn + 11, PLOT_LINE_COLOR, clrAqua);

   SetIndexBuffer(index_buf_dn + 12, bufferDn13, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 13, bufferDn14, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 14, bufferDn15, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn + 12, PLOT_LINE_COLOR, clrGreen);
   PlotIndexSetInteger(index_buf_dn + 13, PLOT_LINE_COLOR, clrGreen);
   PlotIndexSetInteger(index_buf_dn + 14, PLOT_LINE_COLOR, clrGreen);

   SetIndexBuffer(index_buf_dn + 15, bufferDn16, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 16, bufferDn17, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 17, bufferDn18, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn + 15, PLOT_LINE_COLOR, clrGreen);
   PlotIndexSetInteger(index_buf_dn + 16, PLOT_LINE_COLOR, clrGreen);
   PlotIndexSetInteger(index_buf_dn + 17, PLOT_LINE_COLOR, clrGreen);

   SetIndexBuffer(index_buf_dn + 18, bufferDn19, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 19, bufferDn20, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 20, bufferDn21, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn + 18, PLOT_LINE_COLOR, clrOrange);
   PlotIndexSetInteger(index_buf_dn + 19, PLOT_LINE_COLOR, clrOrange);
   PlotIndexSetInteger(index_buf_dn + 20, PLOT_LINE_COLOR, clrOrange);

   SetIndexBuffer(index_buf_dn + 21, bufferDn22, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 22, bufferDn23, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 23, bufferDn24, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn + 21, PLOT_LINE_COLOR, clrOrange);
   PlotIndexSetInteger(index_buf_dn + 22, PLOT_LINE_COLOR, clrOrange);
   PlotIndexSetInteger(index_buf_dn + 23, PLOT_LINE_COLOR, clrOrange);

   SetIndexBuffer(index_buf_dn + 24, bufferDn25, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 25, bufferDn26, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 26, bufferDn27, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn + 24, PLOT_LINE_COLOR, clrLightCoral);
   PlotIndexSetInteger(index_buf_dn + 25, PLOT_LINE_COLOR, clrLightCoral);
   PlotIndexSetInteger(index_buf_dn + 26, PLOT_LINE_COLOR, clrLightCoral);

   SetIndexBuffer(index_buf_dn + 27, bufferDn28, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 28, bufferDn29, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 29, bufferDn30, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn + 27, PLOT_LINE_COLOR, clrLightCoral);
   PlotIndexSetInteger(index_buf_dn + 28, PLOT_LINE_COLOR, clrLightCoral);
   PlotIndexSetInteger(index_buf_dn + 29, PLOT_LINE_COLOR, clrLightCoral);

   SetIndexBuffer(index_buf_dn + 30, bufferDn31, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 31, bufferDn32, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 32, bufferDn33, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn + 30, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetInteger(index_buf_dn + 31, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetInteger(index_buf_dn + 32, PLOT_LINE_COLOR, clrRed);

   SetIndexBuffer(index_buf_dn + 33, bufferDn34, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 34, bufferDn35, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 35, bufferDn36, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn + 33, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetInteger(index_buf_dn + 34, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetInteger(index_buf_dn + 35, PLOT_LINE_COLOR, clrRed);

   SetIndexBuffer(index_buf_dn + 36, bufferDn37, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 37, bufferDn38, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 38, bufferDn39, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn + 36, PLOT_LINE_COLOR, clrPurple);
   PlotIndexSetInteger(index_buf_dn + 37, PLOT_LINE_COLOR, clrPurple);
   PlotIndexSetInteger(index_buf_dn + 38, PLOT_LINE_COLOR, clrPurple);

   SetIndexBuffer(index_buf_dn + 39, bufferDn40, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 40, bufferDn41, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 41, bufferDn42, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn + 39, PLOT_LINE_COLOR, clrPurple);
   PlotIndexSetInteger(index_buf_dn + 40, PLOT_LINE_COLOR, clrPurple);
   PlotIndexSetInteger(index_buf_dn + 41, PLOT_LINE_COLOR, clrPurple);

   SetIndexBuffer(index_buf_dn + 42, bufferDn43, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 43, bufferDn44, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 44, bufferDn45, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn + 42, PLOT_LINE_COLOR, clrFuchsia);
   PlotIndexSetInteger(index_buf_dn + 43, PLOT_LINE_COLOR, clrFuchsia);
   PlotIndexSetInteger(index_buf_dn + 44, PLOT_LINE_COLOR, clrFuchsia);

   SetIndexBuffer(index_buf_dn + 45, bufferDn46, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 46, bufferDn47, INDICATOR_DATA);
   SetIndexBuffer(index_buf_dn + 47, bufferDn48, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn + 45, PLOT_LINE_COLOR, clrFuchsia);
   PlotIndexSetInteger(index_buf_dn + 46, PLOT_LINE_COLOR, clrFuchsia);
   PlotIndexSetInteger(index_buf_dn + 47, PLOT_LINE_COLOR, clrFuchsia);





   SetIndexBuffer(index_buf_dn + n_bands, bufferMe, INDICATOR_DATA);
   PlotIndexSetInteger(index_buf_dn + n_bands, PLOT_LINE_COLOR, clrWhite);
   PlotIndexSetDouble(index_buf_dn + n_bands, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(index_buf_dn + n_bands, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(index_buf_dn + n_bands, PLOT_LABEL, "Média " + inpPeriods);
   PlotIndexSetInteger(index_buf_dn + n_bands, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(index_buf_dn + n_bands, PLOT_LINE_COLOR, colorMid);

   SetIndexBuffer(index_buf_dn + n_bands + 1, ExtStdDevBuffer, INDICATOR_CALCULATIONS);

   for (int i = index_buf_up; i <= n_bands - 1; i++) {
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(i, PLOT_LABEL, "Banda superior");
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, larguraBandas);
      PlotIndexSetInteger(i, PLOT_LINE_STYLE, STYLE_DOT);
      //PlotIndexSetInteger(i, PLOT_LINE_COLOR, colorUp);
   }

   for (int i = index_buf_dn; i <= index_buf_dn + n_bands; i++) {
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0);
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(i, PLOT_LABEL, "Banda inferior");
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, larguraBandas);
      PlotIndexSetInteger(i, PLOT_LINE_STYLE, STYLE_DOT);
      //PlotIndexSetInteger(i, PLOT_LINE_COLOR, colorDown);
   }

//--- set index label
//PlotIndexSetString(1, PLOT_LABEL, "EMA");
//PlotIndexSetString(2, PLOT_LABEL, "StdDev(" + string(ExtStdDevPeriod) + ")");
//--- set index shift
//PlotIndexSetInteger(0, PLOT_SHIFT, ExtStdDevShift);

}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
   int pos;
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, ExtStdDevPeriod - 1 + begin);
   if(rates_total < ExtStdDevPeriod)
      return(0);

   pos = prev_calculated - 1;

   if(pos < ExtStdDevPeriod) {
      pos = ExtStdDevPeriod - 1;
      ArrayInitialize(bufferMe, 0);
      ArrayInitialize(bufferUp1, 0);
      ArrayInitialize(bufferUp2, 0);
      ArrayInitialize(bufferUp3, 0);
      ArrayInitialize(bufferUp4, 0);
      ArrayInitialize(bufferUp5, 0);
      ArrayInitialize(bufferUp6, 0);
      ArrayInitialize(bufferUp7, 0);
      ArrayInitialize(bufferUp8, 0);
      ArrayInitialize(bufferUp9, 0);
      ArrayInitialize(bufferUp10, 0);
      ArrayInitialize(bufferUp11, 0);
      ArrayInitialize(bufferUp12, 0);
      ArrayInitialize(bufferUp13, 0);
      ArrayInitialize(bufferUp14, 0);
      ArrayInitialize(bufferUp15, 0);
      ArrayInitialize(bufferUp16, 0);
      ArrayInitialize(bufferUp17, 0);
      ArrayInitialize(bufferUp18, 0);
      ArrayInitialize(bufferUp19, 0);
      ArrayInitialize(bufferUp20, 0);
      ArrayInitialize(bufferUp21, 0);
      ArrayInitialize(bufferUp22, 0);
      ArrayInitialize(bufferUp23, 0);
      ArrayInitialize(bufferUp24, 0);
      ArrayInitialize(bufferUp25, 0);
      ArrayInitialize(bufferUp26, 0);
      ArrayInitialize(bufferUp27, 0);
      ArrayInitialize(bufferUp28, 0);
      ArrayInitialize(bufferUp29, 0);
      ArrayInitialize(bufferUp30, 0);
      ArrayInitialize(bufferUp31, 0);
      ArrayInitialize(bufferUp32, 0);
      ArrayInitialize(bufferUp33, 0);
      ArrayInitialize(bufferUp34, 0);
      ArrayInitialize(bufferUp35, 0);
      ArrayInitialize(bufferUp36, 0);
      ArrayInitialize(bufferUp37, 0);
      ArrayInitialize(bufferUp38, 0);
      ArrayInitialize(bufferUp39, 0);
      ArrayInitialize(bufferUp40, 0);
      ArrayInitialize(bufferUp41, 0);
      ArrayInitialize(bufferUp42, 0);
      ArrayInitialize(bufferUp43, 0);
      ArrayInitialize(bufferUp44, 0);
      ArrayInitialize(bufferUp45, 0);
      ArrayInitialize(bufferUp46, 0);
      ArrayInitialize(bufferUp47, 0);
      ArrayInitialize(bufferUp48, 0);


      ArrayInitialize(bufferDn1, 0);
      ArrayInitialize(bufferDn2, 0);
      ArrayInitialize(bufferDn3, 0);
      ArrayInitialize(bufferDn4, 0);
      ArrayInitialize(bufferDn5, 0);
      ArrayInitialize(bufferDn6, 0);
      ArrayInitialize(bufferDn7, 0);
      ArrayInitialize(bufferDn8, 0);
      ArrayInitialize(bufferDn9, 0);
      ArrayInitialize(bufferDn10, 0);
      ArrayInitialize(bufferDn11, 0);
      ArrayInitialize(bufferDn12, 0);
      ArrayInitialize(bufferDn13, 0);
      ArrayInitialize(bufferDn14, 0);
      ArrayInitialize(bufferDn15, 0);
      ArrayInitialize(bufferDn16, 0);
      ArrayInitialize(bufferDn17, 0);
      ArrayInitialize(bufferDn18, 0);
      ArrayInitialize(bufferDn19, 0);
      ArrayInitialize(bufferDn20, 0);
      ArrayInitialize(bufferDn21, 0);
      ArrayInitialize(bufferDn22, 0);
      ArrayInitialize(bufferDn23, 0);
      ArrayInitialize(bufferDn24, 0);
      ArrayInitialize(bufferDn25, 0);
      ArrayInitialize(bufferDn26, 0);
      ArrayInitialize(bufferDn27, 0);
      ArrayInitialize(bufferDn28, 0);
      ArrayInitialize(bufferDn29, 0);
      ArrayInitialize(bufferDn30, 0);
      ArrayInitialize(bufferDn31, 0);
      ArrayInitialize(bufferDn32, 0);
      ArrayInitialize(bufferDn33, 0);
      ArrayInitialize(bufferDn34, 0);
      ArrayInitialize(bufferDn35, 0);
      ArrayInitialize(bufferDn36, 0);
      ArrayInitialize(bufferDn37, 0);
      ArrayInitialize(bufferDn38, 0);
      ArrayInitialize(bufferDn39, 0);
      ArrayInitialize(bufferDn40, 0);
      ArrayInitialize(bufferDn41, 0);
      ArrayInitialize(bufferDn42, 0);
      ArrayInitialize(bufferDn43, 0);
      ArrayInitialize(bufferDn44, 0);
      ArrayInitialize(bufferDn45, 0);
      ArrayInitialize(bufferDn46, 0);
      ArrayInitialize(bufferDn47, 0);
      ArrayInitialize(bufferDn48, 0);
   }
//--- main cycle
   switch(InpMAMethod) {
   case  MODE_EMA :
      for(int i = pos; i < rates_total && !IsStopped(); i++) {
         if(i == inpPeriods - 1)
            bufferMe[i] = SimpleMA(i, inpPeriods, price);
         else
            bufferMe[i] = ExponentialMA(i, inpPeriods, bufferMe[i - 1], price);
         //--- Calculate StdDev

         double deviation = StdDevFunc(price, bufferMe, i);
         ExtStdDevBuffer[i] = deviation;

         if (showMargins) bufferUp1[i] = bufferMe[i] + deviation * ((inpDeviations * 1) - margin + offset * inpDeviations);
         bufferUp2[i] = bufferMe[i] + deviation * ((inpDeviations * 1) + offset * inpDeviations);
         if (showMargins) bufferUp3[i] = bufferMe[i] + deviation * ((inpDeviations * 1) + margin + offset * inpDeviations);

         if (showBands) {
            if (showMargins) bufferUp4[i] = bufferMe[i] + deviation * ((inpDeviations * 2) - margin + offset * inpDeviations);
            bufferUp5[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + offset * inpDeviations);
            if (showMargins) bufferUp6[i] = bufferMe[i] + deviation * ((inpDeviations * 2) + margin + offset * inpDeviations);

            if (showMargins) bufferUp7[i] = bufferMe[i] + deviation * ((inpDeviations * 3) - margin + offset * inpDeviations);
            bufferUp8[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + offset * inpDeviations);
            if (showMargins) bufferUp9[i] = bufferMe[i] + deviation * ((inpDeviations * 3) + margin + offset * inpDeviations);

            if (showMargins) bufferUp10[i] = bufferMe[i] + deviation * ((inpDeviations * 4) - margin + offset * inpDeviations);
            bufferUp11[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + offset * inpDeviations);
            if (showMargins) bufferUp12[i] = bufferMe[i] + deviation * ((inpDeviations * 4) + margin + offset * inpDeviations);

            if (showMargins) bufferUp13[i] = bufferMe[i] + deviation * ((inpDeviations * 5) - margin + offset * inpDeviations);
            bufferUp14[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + offset * inpDeviations);
            if (showMargins) bufferUp15[i] = bufferMe[i] + deviation * ((inpDeviations * 5) + margin + offset * inpDeviations);

            if (showMargins) bufferUp16[i] = bufferMe[i] + deviation * ((inpDeviations * 6) - margin + offset * inpDeviations);
            bufferUp17[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + offset * inpDeviations);
            if (showMargins) bufferUp18[i] = bufferMe[i] + deviation * ((inpDeviations * 6) + margin + offset * inpDeviations);

            if (showMargins) bufferUp19[i] = bufferMe[i] + deviation * ((inpDeviations * 7) - margin + offset * inpDeviations);
            bufferUp20[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + offset * inpDeviations);
            if (showMargins) bufferUp21[i] = bufferMe[i] + deviation * ((inpDeviations * 7) + margin + offset * inpDeviations);

            if (showMargins) bufferUp22[i] = bufferMe[i] + deviation * ((inpDeviations * 8) - margin + offset * inpDeviations);
            bufferUp23[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + offset * inpDeviations);
            if (showMargins) bufferUp24[i] = bufferMe[i] + deviation * ((inpDeviations * 8) + margin + offset * inpDeviations);

            if (showMargins) bufferUp25[i] = bufferMe[i] + deviation * ((inpDeviations * 9) - margin + offset * inpDeviations);
            bufferUp26[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + offset * inpDeviations);
            if (showMargins) bufferUp27[i] = bufferMe[i] + deviation * ((inpDeviations * 9) + margin + offset * inpDeviations);

            if (showMargins) bufferUp28[i] = bufferMe[i] + deviation * ((inpDeviations * 10) - margin + offset * inpDeviations);
            bufferUp29[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + offset * inpDeviations);
            if (showMargins) bufferUp30[i] = bufferMe[i] + deviation * ((inpDeviations * 10) + margin + offset * inpDeviations);

            if (showMargins) bufferUp31[i] = bufferMe[i] + deviation * ((inpDeviations * 11) - margin + offset * inpDeviations);
            bufferUp32[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + offset * inpDeviations);
            if (showMargins) bufferUp33[i] = bufferMe[i] + deviation * ((inpDeviations * 11) + margin + offset * inpDeviations);

            if (showMargins) bufferUp34[i] = bufferMe[i] + deviation * ((inpDeviations * 12) - margin + offset * inpDeviations);
            bufferUp35[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + offset * inpDeviations);
            if (showMargins) bufferUp36[i] = bufferMe[i] + deviation * ((inpDeviations * 12) + margin + offset * inpDeviations);

            if (showMargins) bufferUp37[i] = bufferMe[i] + deviation * ((inpDeviations * 13) - margin + offset * inpDeviations);
            bufferUp38[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + offset * inpDeviations);
            if (showMargins) bufferUp39[i] = bufferMe[i] + deviation * ((inpDeviations * 13) + margin + offset * inpDeviations);

            if (showMargins) bufferUp40[i] = bufferMe[i] + deviation * ((inpDeviations * 14) - margin + offset * inpDeviations);
            bufferUp41[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + offset * inpDeviations);
            if (showMargins) bufferUp42[i] = bufferMe[i] + deviation * ((inpDeviations * 14) + margin + offset * inpDeviations);

            if (showMargins) bufferUp43[i] = bufferMe[i] + deviation * ((inpDeviations * 15) - margin + offset * inpDeviations);
            bufferUp44[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + offset * inpDeviations);
            if (showMargins) bufferUp45[i] = bufferMe[i] + deviation * ((inpDeviations * 15) + margin + offset * inpDeviations);

            if (showMargins) bufferUp46[i] = bufferMe[i] + deviation * ((inpDeviations * 16) - margin + offset * inpDeviations);
            bufferUp47[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + offset * inpDeviations);
            if (showMargins) bufferUp48[i] = bufferMe[i] + deviation * ((inpDeviations * 16) + margin + offset * inpDeviations);
         }




         if (showMargins) bufferDn1[i] = bufferMe[i] - deviation * ((inpDeviations * 1) - margin + offset * inpDeviations);
         bufferDn2[i] = bufferMe[i] - deviation * ((inpDeviations * 1) + offset * inpDeviations);
         if (showMargins) bufferDn3[i] = bufferMe[i] - deviation * ((inpDeviations * 1) + margin + offset * inpDeviations);

         if (showBands) {
            if (showMargins) bufferDn4[i] = bufferMe[i] - deviation * ((inpDeviations * 2) - margin + offset * inpDeviations);
            bufferDn5[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + offset * inpDeviations);
            if (showMargins) bufferDn6[i] = bufferMe[i] - deviation * ((inpDeviations * 2) + margin + offset * inpDeviations);

            if (showMargins) bufferDn7[i] = bufferMe[i] - deviation * ((inpDeviations * 3) - margin + offset * inpDeviations);
            bufferDn8[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + offset * inpDeviations);
            if (showMargins) bufferDn9[i] = bufferMe[i] - deviation * ((inpDeviations * 3) + margin + offset * inpDeviations);

            if (showMargins) bufferDn10[i] = bufferMe[i] - deviation * ((inpDeviations * 4) - margin + offset * inpDeviations);
            bufferDn11[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + offset * inpDeviations);
            if (showMargins) bufferDn12[i] = bufferMe[i] - deviation * ((inpDeviations * 4) + margin + offset * inpDeviations);

            if (showMargins) bufferDn13[i] = bufferMe[i] - deviation * ((inpDeviations * 5) - margin + offset * inpDeviations);
            bufferDn14[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + offset * inpDeviations);
            if (showMargins) bufferDn15[i] = bufferMe[i] - deviation * ((inpDeviations * 5) + margin + offset * inpDeviations);

            if (showMargins) bufferDn16[i] = bufferMe[i] - deviation * ((inpDeviations * 6) - margin + offset * inpDeviations);
            bufferDn17[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + offset * inpDeviations);
            if (showMargins) bufferDn18[i] = bufferMe[i] - deviation * ((inpDeviations * 6) + margin + offset * inpDeviations);

            if (showMargins) bufferDn19[i] = bufferMe[i] - deviation * ((inpDeviations * 7) - margin + offset * inpDeviations);
            bufferDn20[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + offset * inpDeviations);
            if (showMargins) bufferDn21[i] = bufferMe[i] - deviation * ((inpDeviations * 7) + margin + offset * inpDeviations);

            if (showMargins) bufferDn22[i] = bufferMe[i] - deviation * ((inpDeviations * 8) - margin + offset * inpDeviations);
            bufferDn23[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + offset * inpDeviations);
            if (showMargins) bufferDn24[i] = bufferMe[i] - deviation * ((inpDeviations * 8) + margin + offset * inpDeviations);

            if (showMargins) bufferDn25[i] = bufferMe[i] - deviation * ((inpDeviations * 9) - margin + offset * inpDeviations);
            bufferDn26[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + offset * inpDeviations);
            if (showMargins) bufferDn27[i] = bufferMe[i] - deviation * ((inpDeviations * 9) + margin + offset * inpDeviations);

            if (showMargins) bufferDn28[i] = bufferMe[i] - deviation * ((inpDeviations * 10) - margin + offset * inpDeviations);
            bufferDn29[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + offset * inpDeviations);
            if (showMargins) bufferDn30[i] = bufferMe[i] - deviation * ((inpDeviations * 10) + margin + offset * inpDeviations);

            if (showMargins) bufferDn31[i] = bufferMe[i] - deviation * ((inpDeviations * 11) - margin + offset * inpDeviations);
            bufferDn32[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + offset * inpDeviations);
            if (showMargins) bufferDn33[i] = bufferMe[i] - deviation * ((inpDeviations * 11) + margin + offset * inpDeviations);

            if (showMargins) bufferDn34[i] = bufferMe[i] - deviation * ((inpDeviations * 12) - margin + offset * inpDeviations);
            bufferDn35[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + offset * inpDeviations);
            if (showMargins) bufferDn36[i] = bufferMe[i] - deviation * ((inpDeviations * 12) + margin + offset * inpDeviations);

            if (showMargins) bufferDn37[i] = bufferMe[i] - deviation * ((inpDeviations * 13) - margin + offset * inpDeviations);
            bufferDn38[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + offset * inpDeviations);
            if (showMargins) bufferDn39[i] = bufferMe[i] - deviation * ((inpDeviations * 13) + margin + offset * inpDeviations);

            if (showMargins) bufferDn40[i] = bufferMe[i] - deviation * ((inpDeviations * 14) - margin + offset * inpDeviations);
            bufferDn41[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + offset * inpDeviations);
            if (showMargins) bufferDn42[i] = bufferMe[i] - deviation * ((inpDeviations * 14) + margin + offset * inpDeviations);

            if (showMargins) bufferDn43[i] = bufferMe[i] - deviation * ((inpDeviations * 15) - margin + offset * inpDeviations);
            bufferDn44[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + offset * inpDeviations);
            if (showMargins) bufferDn45[i] = bufferMe[i] - deviation * ((inpDeviations * 15) + margin + offset * inpDeviations);

            if (showMargins) bufferDn46[i] = bufferMe[i] - deviation * ((inpDeviations * 16) - margin + offset * inpDeviations);
            bufferDn47[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + offset * inpDeviations);
            if (showMargins) bufferDn48[i] = bufferMe[i] - deviation * ((inpDeviations * 16) + margin + offset * inpDeviations);
         }

      }
      break;
   case MODE_SMMA :
      for(int i = pos; i < rates_total && !IsStopped(); i++) {
         if(i == inpPeriods - 1)
            bufferMe[i] = SimpleMA(i, inpPeriods, price);
         else
            bufferMe[i] = SmoothedMA(i, inpPeriods, bufferMe[i - 1], price);
         //--- Calculate StdDev
         ExtStdDevBuffer[i] = StdDevFunc(price, bufferMe, i);
      }
      break;
   case MODE_LWMA :
      for(int i = pos; i < rates_total && !IsStopped(); i++) {
         bufferMe[i] = LinearWeightedMA(i, inpPeriods, price);
         ExtStdDevBuffer[i] = StdDevFunc(price, bufferMe, i);
      }
      break;
   default   :
      for(int i = pos; i < rates_total && !IsStopped(); i++) {
         bufferMe[i] = SimpleMA(i, inpPeriods, price);
         //--- Calculate StdDev
         ExtStdDevBuffer[i] = StdDevFunc(price, bufferMe, i);
      }
   }
//---- OnCalculate done. Return new prev_calculated.
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
double StdDevFunc(const double &price[], const double &MAprice[], int position) {
   double dTmp = 0.0;
   for(int i = 0; i < ExtStdDevPeriod; i++)
      dTmp += MathPow(price[position - i] - MAprice[position], 2);

   dTmp = MathSqrt(dTmp / ExtStdDevPeriod);
   return(dTmp);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
