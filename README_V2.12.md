# EA Comparatore V2.12 - Implementazione Leva Finanziaria

## Aggiornamento dalla V2.11 alla V2.12

### Nuove Funzionalità
- **Parametro Leva Finanziaria**: Nuovo input `leverage_multiplier` per controllare la leva utilizzata
- **Controlli di Sicurezza Automatici**: Riduzione automatica della leva ai limiti broker/simbolo
- **Logging Trasparente**: Warning chiari quando la leva viene ridotta per sicurezza

### Parametri Aggiunti
```mql5
input group "=== Parametri Leva Finanziaria ==="
input double leverage_multiplier = 1.0;        // Leva finanziaria (1.0 = nessuna leva, 100.0 = leva 1:100)
```

### Comportamento

#### Default (leverage_multiplier = 1.0):
- Comportamento identico alla V2.11
- Nessun cambiamento nel calcolo del margine
- Retrocompatibilità garantita al 100%

#### Con Leva Superiore (leverage_multiplier > 1.0):
- Controllo automatico dei limiti del broker
- Controllo automatico dei limiti del simbolo
- Riduzione automatica della leva se necessario
- Warning nel log quando la leva viene ridotta

### Controlli di Sicurezza

1. **Validazione Input**: La leva deve essere >= 1.0
2. **Limite Simbolo**: Se il simbolo ha una leva massima inferiore, viene utilizzata quella
3. **Limite Account**: Se l'account ha una leva massima inferiore, viene utilizzata quella
4. **Logging**: Tutti i cambiamenti vengono registrati nel log per trasparenza

### Esempi di Utilizzo

#### Esempio 1: Nessuna Leva (Default)
```
leverage_multiplier = 1.0
Risultato: Identico alla V2.11
```

#### Esempio 2: Leva 10:1
```
leverage_multiplier = 10.0
Risultato: Margine richiesto = (Prezzo × Contratto) / 10
```

#### Esempio 3: Leva con Limitazioni
```
leverage_multiplier = 100.0
Limite Account = 50.0
Risultato: Usa leva 50.0 + "ATTENZIONE: Leva ridotta da 100 a 50 (limite account)"
```

### Calcolo del Margine

**V2.11 (Senza leva):**
```mql5
double marginPerLot = (symbolPrice * contractSize);
```

**V2.12 (Con leva):**
```mql5
double marginPerLot = (symbolPrice * contractSize) / effectiveLeverage;
```

### Testing
Per testare la funzionalità, utilizzare il file `TestComparatore_v2.12.mq5` incluso.

### Compatibilità
- **Backward Compatible**: Comportamento identico con leverage_multiplier = 1.0
- **Forward Compatible**: Pronto per future modifiche alla gestione della leva
- **Safe**: Controlli automatici prevengono l'uso di leve eccessive

## File Modificati
- `Comparatore_v2.11.mq5` - Versione base di riferimento
- `Comparatore_v2.12.mq5` - Versione aggiornata con leva finanziaria
- `TestComparatore_v2.12.mq5` - Script di test per verificare la funzionalità