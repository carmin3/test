//+------------------------------------------------------------------+
//|                                        TestComparatore_v2.12.mq5 |
//|                                      Test per EA Comparatore V2.12 |
//+------------------------------------------------------------------+
#property copyright "Test"
#property version   "1.00"
#property script_show_inputs

// Test delle funzionalità del leverage
void OnStart()
{
    Print("=== TEST COMPARATORE V2.12 - LEVERAGE ===");
    
    // Test 1: Verifica default (leva 1.0) - comportamento identico a V2.11
    Print("Test 1: Comportamento default con leva 1.0");
    TestLeverageCalculation("EURUSD", 1.0, 1000.0);
    
    // Test 2: Verifica con leva superiore
    Print("Test 2: Comportamento con leva 10.0");
    TestLeverageCalculation("EURUSD", 10.0, 1000.0);
    
    // Test 3: Verifica con leva molto alta
    Print("Test 3: Comportamento con leva 100.0");
    TestLeverageCalculation("EURUSD", 100.0, 1000.0);
    
    Print("=== FINE TEST ===");
}

void TestLeverageCalculation(string symbol, double leverage, double maxMoney)
{
    // Simula il calcolo della leva effettiva
    double accountLeverage = 100.0; // Simula leva account
    double symbolLeverage = 50.0;   // Simula leva simbolo
    
    double effectiveLeverage = leverage;
    
    // Controllo limiti come nel codice originale
    if(symbolLeverage > 0 && symbolLeverage < leverage) {
        effectiveLeverage = symbolLeverage;
        Print("  ATTENZIONE: Leva ridotta da ", leverage, " a ", symbolLeverage, " per ", symbol);
    }
    
    if(accountLeverage < effectiveLeverage) {
        effectiveLeverage = accountLeverage;
        Print("  ATTENZIONE: Leva ridotta da ", leverage, " a ", accountLeverage, " (limite account)");
    }
    
    // Calcolo simulato del margine
    double symbolPrice = 1.1000; // Prezzo simulato EURUSD
    double contractSize = 100000.0;
    
    double marginPerLot = (symbolPrice * contractSize) / effectiveLeverage;
    double calculatedLots = NormalizeDouble(maxMoney / marginPerLot, 2);
    
    Print("  Leva richiesta: ", leverage, " | Leva effettiva: ", effectiveLeverage);
    Print("  Margine per lotto: ", marginPerLot, " | Volume calcolato: ", calculatedLots);
    Print("  ---");
}