//+------------------------------------------------------------------+
//|                                             Comparatore_v2.11.mq5 |
//|                        Copyright 2025, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "2.11"
#property description "EA con gestione lag-aware e Citadel Exit Strategy migliorata + Market Close + indici aggiornati"
#property strict

//--- Input parameters
input group "=== Parametri Base ==="
input double maxMoneyForTrade = 1000.0;     // Capitale massimo per trade
input double riskPercent = 2.0;             // Percentuale di rischio per trade

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("Comparatore V2.11 inizializzato");
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("Comparatore V2.11 disattivato");
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
    
    // Calcolo del margine richiesto (senza leva aggiuntiva in V2.11)
    double marginPerLot = (symbolPrice * contractSize);
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
    
    Print("Volume calcolato per ", symbol, ": ", calculatedLots);
    return calculatedLots;
}