//+------------------------------------------------------------------+
//|                                             Comparatore_v2.12.mq5 |
//|                        Copyright 2025, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "2.12"
#property description "EA con gestione lag-aware e Citadel Exit Strategy migliorata + Market Close + indici aggiornati + Leva Finanziaria"
#property strict

//--- Input parameters
input group "=== Parametri Base ==="
input double maxMoneyForTrade = 1000.0;     // Capitale massimo per trade
input double riskPercent = 2.0;             // Percentuale di rischio per trade

input group "=== Parametri Leva Finanziaria ==="
input double leverage_multiplier = 1.0;     // Leva finanziaria (1.0 = nessuna leva, 100.0 = leva 1:100)

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("Comparatore V2.12 inizializzato con leva finanziaria: ", leverage_multiplier);
    
    // Verifica validità parametro leva
    if(leverage_multiplier < 1.0)
    {
        Print("ERRORE: Leva finanziaria deve essere >= 1.0. Valore impostato: ", leverage_multiplier);
        return(INIT_PARAMETERS_INCORRECT);
    }
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("Comparatore V2.12 disattivato");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Logica principale del trading
    // Implementazione base per il funzionamento dell'EA
}

//+------------------------------------------------------------------+
//| Calculate optimal volume for a symbol                            |
//+------------------------------------------------------------------+
double CalculateOptimalVolume(string symbol)
{
    // Verifica se il simbolo è valido
    if(!SymbolSelect(symbol, true))
    {
        Print("Errore: Simbolo ", symbol, " non valido");
        return 0.0;
    }
    
    // Ottieni informazioni sul simbolo
    double symbolPrice = SymbolInfoDouble(symbol, SYMBOL_ASK);
    if(symbolPrice <= 0)
    {
        Print("Errore: Impossibile ottenere il prezzo per ", symbol);
        return 0.0;
    }
    
    // Calcola la dimensione del contratto
    double contractSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
    if(contractSize <= 0)
        contractSize = 100000.0; // Default per forex
    
    // NUOVO: Controllo leva effettiva
    double accountLeverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
    double symbolLeverage = SymbolInfoDouble(symbol, SYMBOL_LEVERAGE);
    
    double effectiveLeverage = leverage_multiplier;
    
    // Se il simbolo ha una leva limitata, usala
    if(symbolLeverage > 0 && symbolLeverage < leverage_multiplier) {
        effectiveLeverage = symbolLeverage;
        Print("ATTENZIONE: Leva ridotta da ", leverage_multiplier, " a ", symbolLeverage, " per ", symbol);
    }
    
    // Se l'account ha una leva limitata, usala
    if(accountLeverage < effectiveLeverage) {
        effectiveLeverage = accountLeverage;
        Print("ATTENZIONE: Leva ridotta da ", leverage_multiplier, " a ", accountLeverage, " (limite account)");
    }
    
    // NUOVO: Calcolo margine con leva
    double marginPerLot = (symbolPrice * contractSize) / effectiveLeverage;
    double calculatedLots = NormalizeDouble(maxMoneyForTrade / marginPerLot, 2);
    
    // Verifica limiti minimi e massimi del simbolo
    double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
    double stepLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
    
    // Normalizza secondo i limiti del simbolo
    if(calculatedLots < minLot)
        calculatedLots = minLot;
    else if(calculatedLots > maxLot)
        calculatedLots = maxLot;
    
    // Normalizza secondo lo step del lotto
    if(stepLot > 0)
        calculatedLots = NormalizeDouble(MathRound(calculatedLots / stepLot) * stepLot, 2);
    
    Print("Volume calcolato per ", symbol, " con leva ", effectiveLeverage, ": ", calculatedLots);
    return calculatedLots;
}