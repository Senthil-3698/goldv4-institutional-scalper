# Source Files

This directory contains the two Expert Advisor source files.

## Files

- **`GoldV4_MT5.mq5`** — v4.21 Asia bot
  - Trading window: broker hours 00:00-03:00
  - Magic: 202600400
  - Audit CSV: `GoldV4_audit.csv`
  - Production config: "Path H"

- **`GoldV5_LNY.mq5`** — v5.2 London bot
  - Trading window: broker hours 08:00-10:00
  - Magic: 202600500
  - Audit CSV: `GoldV5_LNY_audit.csv`
  - Production config: "Path D"

## Compiling

1. Copy both files to your MT5 installation:
   ```
   <MT5 data folder>\MQL5\Experts\
   ```

2. Open MetaEditor (F4 from MT5, or launch separately)

3. Open each `.mq5` file

4. Press **F7** to compile

5. Verify "0 errors, 0 warnings" in the output pane

6. The compiled `.ex5` files appear next to the source

## Deploying

1. Open MT5

2. Open two XAUUSD M1 charts (`File → New Chart → XAUUSD → M1`, twice)

3. From Navigator (Ctrl+N) → Expert Advisors:
   - Drag `GoldV4_MT5` onto one chart
   - Drag `GoldV5_LNY` onto the other chart

4. In each attach dialog:
   - **Common tab:** Enable "Algo Trading"
   - **Inputs tab:** Click **"Reset"** to load production defaults
   - Click OK

5. Verify both dashboards appear with:
   - `SYSTEM: ACTIVE`
   - `AUDIT: LOGGING`

6. Enable "Algo Trading" in the main MT5 toolbar (top ribbon)

## Important: Hedge mode required

The bots open multiple simultaneous positions on the same symbol. This requires your trading account to be in **Hedge mode**, not **Netting mode**.

- **MetaQuotes-Demo** defaults to Hedge mode (unless you create a Netting demo explicitly)
- Many broker accounts default to Netting — check with your broker
- Netting mode will cause positions to close/offset incorrectly

Check your mode: Title bar of MT5 shows either "Hedge" or "Netting".

## Backtesting

1. Open Strategy Tester (Ctrl+R)
2. Settings:
   - Expert: `GoldV4_MT5` or `GoldV5_LNY`
   - Symbol: XAUUSD
   - Period: M1
   - Date: Choose 6+ months
   - Model: **Every tick based on real ticks** (critical for scalping backtests)
   - Deposit: $100,000
   - Leverage: 1:100
3. Inputs tab → **Reset** to load production defaults
4. Click Start

Results appear in Journal with format `GV4.XX TESTER REPORT` or `GV5.X TESTER REPORT`.

## Code Overview

Each `.mq5` file is self-contained (~3,000 lines). Key sections (in order):

1. **Properties & includes** (lines 1-220)
2. **Input parameters** (lines 220-550) — organized into groups
3. **Global variables** (lines 550-700)
4. **Dashboard rendering** (lines 2500-2650)
5. **Signal detection** (lines 1500-2300)
6. **Risk & sizing** (lines 2100-2300)
7. **Execution** (lines 2300-2450)
8. **Position management** (lines 2450-2600)
9. **Audit CSV + MAE/MFE** (lines 1000-1200)
10. **OnInit / OnTick / OnDeinit / OnTester** (lines 2700-3100)

## Modification safety

Before modifying any strategy parameter:

1. Backtest the current configuration to establish baseline
2. Change **ONE input only**
3. Re-backtest with same date range
4. Compare metrics — PF, Net, DD, Win Rate
5. Keep if improved, revert if not
6. Document your hypothesis + result (future-you will thank you)

Beyond the defaults, nearly every tweak I tried made things worse. The provided defaults represent many iterations of tuning. Start there.
