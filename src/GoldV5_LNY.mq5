//+------------------------------------------------------------------+
//|                    Gold V5 LNY  v5.2                             |
//|       Institutional London/NY XAUUSD Scalper / HFT               |
//|              Forked from Gold V4 MT5 v4.19 (Asia)                |
//|                                                                  |
//|  v5.2-HOTFIX PATH D DEFAULTS HARDCODED (2026-08-05):             |
//|   CRITICAL BUG FOUND: v5.0 source defaults were baseline config, |
//|   NOT Path D. User manually set Path D in Strategy Tester inputs |
//|   but source was never updated. Any EA reset → baseline loaded → |
//|   would trade losing config (PF 0.96 vs Path D PF 1.18).         |
//|                                                                  |
//|   FIXED source defaults now match production Path D:             |
//|     TradeNewYork:  true  → false  (NY hours = -$425/trade)       |
//|     TradeOverlap:  true  → false  (overlap chop, no edge)        |
//|     London_End:    12    → 10     (peak London only)             |
//|                                                                  |
//|   Now compiling v5.2 produces the CORRECT Path D behavior by     |
//|   default — no manual inputs needed on chart re-attach.          |
//|                                                                  |
//|  v5.2 DIRECTION-ASYMMETRIC FILTERS — REVERTED (2026-08-05):      |
//|   ATTEMPTED: add 3 buy-only gates to lift buy WR (was 59.3%      |
//|   in live vs sells 66.7%).                                       |
//|                                                                  |
//|   BACKTEST RESULT: FAILED CATASTROPHICALLY                       |
//|     v5.0 Path D:   +$38,023  PF 1.18  DD 18.65%  WR 53.5%        |
//|     v5.2 v6.1:     -$15,827  PF 0.88  DD 30.38%  WR 49.6%        |
//|     Delta: -$53,850 (-142% worse across every metric)            |
//|                                                                  |
//|   DIAGNOSIS: Direction-asymmetric filters were too restrictive.  |
//|   Real winners occur during NEUTRAL HTF and RANDOM Hurst too.    |
//|   Blocking them left only "perfect setup" buys that turned out   |
//|   to be late-trend whipsaws.                                     |
//|                                                                  |
//|   VERDICT: UseDirectionAsymmetric = false (default).             |
//|   Code preserved but disabled. Can re-enable if future data      |
//|   suggests different thresholds.                                 |
//|                                                                  |
//|   INSTITUTIONAL LESSON: Path D is the optimum. Two consecutive   |
//|   improvement attempts (v6.0 partials, v6.1 dir-filters) both    |
//|   made things worse. STOP TUNING. Deploy Path D as production.   |
//|   Live PF 1.57 already beats backtest PF 1.18 by 33%.            |
//|                                                                  |
//|  --------------------------------------------------------------  |
//|  BELOW: PRESERVED v5.1 HISTORY                                   |
//|  --------------------------------------------------------------  |
//|                                                                  |
//|  v5.1 R:R RESCUE — REVERTED (2026-08-05):                        |
//|   ATTEMPTED: reintroduce partial TPs (30/30/40 structure).       |
//|   BACKTEST RESULT: FAILED.                                       |
//|     v5.0 Path D:  +$38,023  PF 1.18  DD 18.65%  WR 53.5%         |
//|     v5.1 Partial: +$7,440   PF 1.04  DD 22.54%  WR 50.5%         |
//|     Delta: -$30,583  (-40% worse across every metric)            |
//|                                                                  |
//|   DIAGNOSIS: Partial TPs freed position slots faster, allowing   |
//|   121 extra marginal-quality trades. Win rate dropped 3pt.       |
//|   Path C's original conclusion (partials cap winners) was RIGHT. |
//|                                                                  |
//|   REVERTED: UsePartialTP back to false. Trail-only Path D        |
//|   remains the validated production config.                       |
//|                                                                  |
//|   LEARNING: Live R:R = 0.98 is NOT caused by exit structure.     |
//|   It's caused by regime mix. Live data > backtest here.          |
//|                                                                  |
//|   NEXT: v6.1 Direction-Asymmetric Filters (fix long-bias weak).  |
//|   Live shows sells 66.7% WR vs longs 59.3% WR. Filter longs      |
//|   stricter to boost overall WR without breaking exit structure.  |
//|                                                                  |
//|  --------------------------------------------------------------  |
//|  BELOW: PRESERVED v5.0 HISTORY                                   |
//|  --------------------------------------------------------------  |
//|                                                                  |
//|  v5.0 LONDON/NY FORK (2026-07-03):                               |
//|   Forked from proven GoldV4 v4.19 (Asia strategy, PF 1.44 on     |
//|   6-month backtest, Max DD 6.39%). Retunes signal engine,        |
//|   session gates, ATR parameters, and risk model for the London   |
//|   + New York session volatility profile. Same battle-tested      |
//|   safety infrastructure (equity guard, DynamicRisk throttle,     |
//|   direction cooldowns, MAE/MFE audit trail, HARD_LOT_CEILING).   |
//|                                                                  |7
//|  ISOLATION FROM v4.19 — prevents double-trading same positions:  |
//|       Magic          :  202600500  (v4.19 uses 202600400)        |
//|       Audit CSV      :  GoldV5_LNY_audit.csv                     |
//|       Log prefix     :  GV5.2:                                   |
//|       Dashboard tag  :  "GOLD V5 LNY v5.0 | LONDON/NY"           |
//|                                                                  |
//|  BASELINE v5.0 config changes vs v4.19 (Path H):                 |
//|       ADX_MinStrength   25   → 30   (LNY needs stronger trends)  |
//|       ATR_SL_Mult       1.75 → 2.25 (wider stops for volatility) |
//|       Trail_ActivateATR 1.0  → 1.5  (wait longer for confirm)    |
//|       TradeAsian        true → false                             |
//|       TradeLondon       false→ true                              |
//|       TradeNewYork      false→ true                              |
//|       TradeOverlap      false→ true                              |
//|       Asian_End         3    → 8    (irrelevant, Asia disabled)  |
//|                                                                  |
//|  RATIONALE: London/NY gold markets are institutional-flow-driven |
//|  with wider volatility, tighter competition, and faster spread   |
//|  changes. The Asia edge (early-Tokyo microstructure handoff)     |
//|  does not exist in London/NY — but a DIFFERENT edge exists:      |
//|  session-anchor VWAP reversion, DXY correlation flow, and        |
//|  post-open range breakout patterns. v5.0 baseline preserves      |
//|  v4.19's confluence engine as a starting point; iterative tuning |
//|  (Paths A-Z) will progressively add LNY-specific edge features.  |
//|                                                                  |
//|  These are BASELINE defaults. Iterative tuning to follow via     |
//|  Path A → Path Z backtests, same methodology used for v4.19.     |
//|                                                                  |
//|  --------------------------------------------------------------  |
//|  BELOW: PRESERVED v4.19 HISTORY (for lineage / audit reference)  |
//|  --------------------------------------------------------------  |
//|                                                                  |
//|  v4.19 PATH H PRODUCTION DEFAULTS (2026-07-02):                  |
//|   Backtest verified profitable configuration hardcoded as        |
//|   compile-time defaults. Prevents accidental input reset back    |
//|   to losing values in Strategy Tester or on chart attach.        |
//|                                                                  |
//|   Backtest result (Apr-Jun 2026, XAUUSD M1, real ticks):         |
//|       Net PnL:          +$28,110.46 (+28.1%)                     |
//|       Profit Factor:    1.28                                     |
//|       Expectancy:       +$51.11 / trade                          |
//|       Win rate:         44.2%                                    |
//|       R:R (avg):        1.61                                     |
//|       Max Drawdown:     7.39%                                    |
//|       Max Consec Loss:  19                                       |
//|       Recovery Factor:  2.29                                     |
//|                                                                  |
//|   Path H defaults changed vs v4.16:                              |
//|       ADX_MinStrength   20   → 25   (signal quality)             |
//|       UsePartialTP      true → false (kill partial exits)        |
//|       UseBEStop         true → false (kill BE stop)              |
//|       Trail_ActivateATR 0.5  → 1.0  (trail activates at 1 ATR)   |
//|       UseSessionFilter  false→ true (enforce session gate)       |
//|       TradeLondon       true → false (London hours = losers)     |
//|       TradeNewYork      true → false (NY hours = disaster)       |
//|       TradeOverlap      true → false (kill session handoff)      |
//|       Asian_End         8    → 3    (peak-hours only)            |
//|                                                                  |
//|   Result: Only trades XAUUSD M1 during broker hours 0-3 (late-   |
//|   NY / early-Tokyo institutional handoff), with high-ADX         |
//|   confluence and Chandelier trail-only exits. Discovered through |
//|   6 backtest iterations (Path C through Path H).                 |
//|                                                                  |
//|  v4.16 DIAGNOSTICS + REVERT (2026-07-01):                        |
//|     v4.15's TP-widening HURT (avg-win unchanged, fewer TP1 hits, |
//|     PF 0.91→0.89). Reverted TP1/TP2/TP3/Chand to v4.14 values.   |
//|     Kept SL=1.75 (helped) and EC_MinTrades=25 (neutral).         |
//|   + Selectivity nudge: MinScoreTrend 7→8 (high-conviction only)  |
//|   + Exit-reason logging: new "exit_reason" column in audit CSV.  |
//|     Categories: SL_LIKELY / AFTER_TP1 / AFTER_TP2 / BE_STOP /    |
//|     TIME_EXIT / EXHAUST_EXIT. Shows where trades actually die —  |
//|     the diagnostic we've been missing for 3 iterations.          |
//|   + Effective risk % logging: new "eff_risk_pct" column shows    |
//|     the actual risk after Kelly + DynamicRiskMult. Proves        |
//|     whether the throttle from v4.15 is actually firing.          |
//|   + TradeState now carries plannedExit + effRiskPct fields.      |
//|                                                                  |
//|  v4.15 R:R + DYNAMIC RISK (2026-07-01):                          |
//|   + FIX A (R:R rebalance): retuned ATR multipliers based on      |
//|     v4.14 backtest showing avg-win/avg-loss = 0.47 (upside down).|
//|       ATR_SL_Mult     2.0 → 1.75  (tighter stop, smaller losses) |
//|       ATR_TP1_Mult    1.0 → 1.25  (bigger partial win)           |
//|       ATR_TP2_Mult    2.0 → 2.5                                  |
//|       ATR_TP3_Mult    3.5 → 4.5   (let winners run)              |
//|       Chand_ATR_Mult  2.5 → 2.0   (tighter trail locks profit)   |
//|       EC_MinTrades    10  → 25    (less aggressive EC filter)    |
//|     Target R:R at TP1 = 0.71 (up from 0.5), at TP3 = 2.57.       |
//|   + FIX C (dynamic risk throttle): DynamicRiskMult() cuts lot    |
//|     size after consecutive losses (60% at 2 in a row, 35% at 4)  |
//|     AND after intraday drawdown (65% at 3%, 40% at 6%). Dampers  |
//|     multiply, floor at 15% of base. Reduces max drawdown without |
//|     reducing trade frequency.                                    |
//|   + NOTE (Fix B — session bias): investigated. UseSessionFilter  |
//|     is off, so the observed 98%-Asia clustering is real strategy |
//|     behavior, not a gate bug. Left as-is; will revisit after     |
//|     R:R/risk fixes are validated.                                |
//|                                                                  |
//|  v4.14 STUCK-STATE BUG FIXES (2026-07-01):                       |
//|   + FIX #1: g_PauseBars now decrements once per new bar. Was     |
//|     never decremented, so after 3 consecutive losses the bot     |
//|     stayed paused forever unless a winning trade arrived (which  |
//|     it couldn't, because entries were blocked). This is the      |
//|     smoking gun for the "11 trades then 60 days silence"         |
//|     pattern seen in v4.13 backtest.                              |
//|   + FIX #2: CheckReset() day-rollover now ALSO clears the        |
//|     equity-curve filter state (g_ECBlocked, g_ECurveCount,       |
//|     g_ECurveIdx), the direction-cooldown counters, and the       |
//|     consecutive-loss tracker. Previously these persisted across  |
//|     days, causing multi-day stuck states even after the intended |
//|     daily reset. Max stuck duration is now < 24 hours by design. |
//|                                                                  |
//|  v4.13 TUNED DEFAULTS + TESTER (2026-06-05):                     |
//|   + Defaults retuned from observed loss patterns:                |
//|       MaxPyramidLayers     2 → 0    (no layer stacking)          |
//|       MinBarsBetweenEntry  3 → 5    (5-min entry spacing)        |
//|       HFTTickScore        11 → 13   (mid-bar entry stricter)     |
//|       MinScoreTrend        6 → 7    (one notch higher conviction)|
//|   + OnTester() — institutional Strategy Tester report. Computes  |
//|     net PnL, win rate, profit factor, expectancy, max DD, max    |
//|     consecutive losses, per-session breakdown. Returns a single  |
//|     composite optimization criterion for parameter sweeps.       |
//|                                                                  |
//|  v4.12 SAFETY HARDENS (2026-06-03):                              |
//|   + HARD_LOT_CEILING — compile-time const, cannot be raised by   |
//|     user input. Caps lot size in CalcLots AND has a kill-switch  |
//|     check in OpenTrade that REFUSES any trade above the const.   |
//|     Fix for the recurring "MaxLotSize input drift" pattern.      |
//|   + Startup config dump — every safety-critical input printed    |
//|     to Experts log on OnInit as one copy-pasteable block. No     |
//|     more guessing whether the EA reloaded with expected values.  |
//|   + History-derived day baseline — DayPnL and trade count        |
//|     recomputed from MT5 deal history on every OnInit. Reload     |
//|     during drawdown no longer resets DayPnL to zero. Circuit     |
//|     breakers now fire on real intraday drawdown.                 |
//|                                                                  |
//|  v4.11 ADDITIONS (2026-06-01):                                   |
//|   + MAE/MFE tracking per trade — Maximum Adverse Excursion and   |
//|     Maximum Favorable Excursion in R-multiples (1R = ATR_SL_Mult |
//|     * ATR), written to two new audit CSV columns.                |
//|   + Per-trade auto-tuning hints printed to Experts log when      |
//|     excursion ratios are extreme (e.g. winner gave back >2R,     |
//|     loser had MFE >0.6R before SL).                              |
//|   + Dashboard: live rolling MAE/MFE avg over last N closes with  |
//|     colour cue (orange = leaving profit, red = SL too tight).    |
//|                                                                  |
//|  v4.10 INSTITUTIONAL UPGRADES (2026-05-28):                      |
//|   + HTF Bias Master Filter — M15 EMA-slope agreement required    |
//|     before same-direction entry. Prevents counter-HTF trades.    |
//|   + Hurst Exponent regime classifier routes strategies by        |
//|     measured market behaviour (trending vs mean-reverting).      |
//|   + Direction-aware loss cooldown — locks single direction       |
//|     after consecutive same-direction losses.                     |
//|   + Equity curve filter — pauses entries when 20-trade EC dips   |
//|     below its 5-trade SMA.                                       |
//|   + Self-healing position recovery rebuilds g_Trades[] on        |
//|     attach from any pre-existing positions with matching Magic.  |
//|   + Trade audit CSV log to MQL5\Files\GoldV4_audit.csv           |
//|   + Tick velocity gate (refuses entry on illiquid windows).      |
//|   + Pre-trade cost-vs-edge gate (rejects no-edge entries).       |
//|                                                                  |
//|  v4.01 PATCHES (2026-05-28):                                     |
//|   * Day/Week DD baseline persists across reload via GlobalVar.   |
//|   * Safer defaults: MaxLotSize 1.0, ATR_SL_Mult 2.0.             |
//|                                                                  |
//|  NEW IN v4.00 OVER v3.20:                                        |
//|   + Fractional Kelly position sizing (rolling 30-trade window)   |
//|   + Kalman-filtered trend estimator (noise-reduced slope)        |
//|   + Microstructure layer (bid/ask imbalance, cum-delta proxy)    |
//|   + Session-adaptive score thresholds and ATR bands              |
//|   + Volatility regime detection (ATR percentile rank)            |
//|   + Chandelier exit trailing stop                                |
//|   + Portfolio heat manager (cap on total open R%)                |
//|   + Exhaustion-exit module (RSI extreme + price stall)           |
//|   + USD-strength correlation guard via EURUSD                    |
//|   + Adaptive spread quality (median, not absolute)               |
//|   + Microsecond-precision latency tracking                       |
//|   + Anti-cluster filter (min time gap between same-dir entries)  |
//|                                                                  |
//|  RETAINED FROM v3.20:                                            |
//|   * VWAP institutional filter                                    |
//|   * Smart Money Concepts (Order Block, FVG, Liquidity Sweep)     |
//|   * RSI/MACD divergence                                          |
//|   * Dynamic S/R take profit                                      |
//|   * Multi-strategy (Trend / Reversion / Breakout)                |
//|   * Pyramid scale-in                                             |
//|   * Daily + weekly drawdown circuit breakers                     |
//|   * News blackout, spread filter, recovery mode                  |
//|                                                                  |
//|  HONEST NOTE: MT5 cannot deliver true sub-millisecond co-located |
//|  HFT execution. This EA implements institutional-grade *logic*   |
//|  within MT5's broker round-trip ceiling (~30-200 ms typical).    |
//+------------------------------------------------------------------+

#property copyright   "Gold V5 LNY | Institutional London/NY Scalper (fork of GoldV4 v4.19)"
#property link        ""
#property version     "5.20"
#property description "Institutional XAUUSD London/NY Scalper v5.2 (Direction-Asymmetric Filters)"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\SymbolInfo.mqh>

//+------------------------------------------------------------------+
//| INPUTS                                                           |
//+------------------------------------------------------------------+

input group "=== GENERAL ==="
input string   EA_Comment            = "GV5";           // v5.0: unique trade tag, isolates from v4
input ulong    Magic                 = 202600500;     // unique v5 magic (v4 uses 202600400 — DO NOT change)
input bool     EnableLiveTrading     = true;
input int      BaseSlippage          = 30;
input int      MaxRetryAttempts      = 3;
input int      RetryDelayMs          = 250;
input bool     VerboseLogging        = true;

input group "=== RISK (BALANCED PRO) ==="
input double   RiskPercent           = 1.0;           // base risk per trade
input bool     UseDynamicRisk        = true;          // v4.15: throttle down after losses / DD
input double   MaxDailyLossPct       = 3.0;
input double   MaxWeeklyLossPct      = 6.0;
input double   MaxDailyProfitPct     = 6.0;
input int      MaxDailyTrades        = 18;
input int      MaxOpenPositions      = 5;
input double   MaxPortfolioHeatPct   = 3.5;           // cap on sum of open R%
input double   MaxLotSize            = 1.0;            // v4.01: 10.0→1.0
input double   MinLotSize            = 0.01;

// v4.12: HARDCODED ABSOLUTE LOT CEILING — defense-in-depth against config drift.
// This is NOT an input. It cannot be raised by the user. If MaxLotSize is
// accidentally set higher, the final lot size is still capped here. If you need
// to legitimately raise it, edit this const and recompile — a deliberate act.
#define  HARD_LOT_CEILING  2.0

input group "=== KELLY SIZING ==="
input bool     UseKelly              = true;
input int      Kelly_WindowTrades    = 30;            // rolling window
input double   Kelly_Fraction        = 0.25;          // fractional Kelly (0.25 = quarter-Kelly)
input double   Kelly_MinSamples      = 12;            // need this many trades before Kelly kicks in
input double   Kelly_MaxMult         = 1.5;           // hard cap on sizing mult
input double   Kelly_MinMult         = 0.35;          // hard floor

input group "=== CONFLUENCE ENGINE ==="
input int      MinScoreTrend         = 8;             // v4.16: 7→8 (further selectivity — high-conviction only)
input int      MinScoreReversion     = 5;
input int      MinScoreBreakout      = 5;
input int      HFTTickScore          = 13;            // v4.13: 11→13 (mid-bar entry harder)
input int      MinBarsBetweenEntry   = 5;             // v4.13: 3→5 (kills cluster pattern)
input int      MinSecsBetweenSameDir = 90;            // anti-cluster on same direction
input bool     UseEMACross           = true;
input bool     UseRSI                = true;
input bool     UseATRFilter          = true;
input bool     UseBB                 = true;
input bool     UseOrderFlow          = true;
input bool     UseMTF                = true;
input bool     UseVolumeFilter       = true;
input bool     UseADX                = true;
input bool     UseMACD               = true;
input bool     UseStochastic         = true;
input bool     UseVWAP               = true;
input bool     UseSMC                = true;
input bool     UseDivergence         = true;
input bool     UseKalman             = true;          // NEW
input bool     UseMicrostructure     = true;          // NEW
input bool     UseMarketRegime       = true;

input group "=== MULTI-STRATEGY ==="
input bool     UseTrendStrategy      = true;
input bool     UseReversionStrat     = true;
input bool     UseBreakoutStrat      = true;
input int      BreakoutLookback      = 20;
input double   BreakoutVolMult       = 1.5;

input group "=== PYRAMID SCALE-IN ==="
input bool     UsePyramid            = true;
input int      MaxPyramidLayers      = 0;             // v4.13: 2→0 (no pyramid stacking; single-shot)
input double   PyramidLayer1ATR      = 1.0;
input double   PyramidLayer2ATR      = 2.0;
input double   PyramidLotMult        = 0.5;

input group "=== VWAP ==="
input int      VWAP_Bars             = 200;
input double   VWAP_BandMult         = 1.0;

input group "=== SMART MONEY CONCEPTS ==="
input int      OB_LookbackBars       = 10;
input int      FVG_MinPoints         = 5;
input bool     UseOrderBlock         = true;
input bool     UseFVG                = true;
input bool     UseLiquiditySweep     = true;
input int      SweepLookback         = 5;
input double   SweepReverseRatio     = 0.6;

input group "=== DIVERGENCE ==="
input int      Div_Lookback          = 14;
input bool     UseRSI_Div            = true;
input bool     UseMACD_Div           = true;

input group "=== DYNAMIC S/R TP ==="
input bool     UseDynamicTP          = true;
input int      SR_Lookback           = 50;
input int      SR_MinTouches         = 2;
input double   SR_ZonePct            = 0.05;

input group "=== EMA ==="
input int      EMA_Fast              = 8;
input int      EMA_Slow              = 21;
input int      EMA_Trend             = 50;
input int      EMA_HTF_Fast          = 8;
input int      EMA_HTF_Slow          = 21;

input group "=== RSI ==="
input int      RSI_Period            = 14;
input double   RSI_OB                = 68.0;
input double   RSI_OS                = 32.0;
input double   RSI_BuyZone           = 50.0;
input double   RSI_SellZone          = 50.0;
input double   RSI_Extreme_OB        = 78.0;          // exhaustion exit trigger
input double   RSI_Extreme_OS        = 22.0;

input group "=== ADX ==="
input int      ADX_Period            = 14;
input double   ADX_MinStrength       = 30.0;          // v5.0: 25→30 (LNY needs stronger trends to filter noise)
input double   ADX_StrongTrend       = 35.0;

input group "=== MACD ==="
input int      MACD_Fast             = 12;
input int      MACD_Slow             = 26;
input int      MACD_Signal           = 9;

input group "=== STOCHASTIC ==="
input int      Stoch_K               = 5;
input int      Stoch_D               = 3;
input int      Stoch_Slowing         = 3;
input double   Stoch_OB              = 80.0;
input double   Stoch_OS              = 20.0;

input group "=== ATR / VOL REGIME ==="
input int      ATR_Period            = 14;
input double   ATR_SL_Mult           = 2.25;           // v5.0: 1.75→2.25 (wider stops for LNY volatility)
input double   ATR_TP1_Mult          = 1.0;            // v4.16: REVERTED — v4.15 widening hurt wins
input double   ATR_TP2_Mult          = 2.0;            // v4.16: REVERTED
input double   ATR_TP3_Mult          = 3.5;            // v4.16: REVERTED
input double   ATR_Min               = 0.30;
input double   ATR_Max               = 12.0;
input int      VolRegime_Lookback    = 200;           // bars for percentile
input double   VolRegime_LowPct      = 35.0;          // below = LOW vol
input double   VolRegime_HighPct     = 75.0;          // above = HIGH vol

input group "=== BOLLINGER ==="
input int      BB_Period             = 20;
input double   BB_Dev                = 2.0;
input double   BB_ZScore             = 0.8;

input group "=== ORDER FLOW ==="
input int      OF_Bars               = 5;
input double   OF_Ratio              = 1.4;

input group "=== KALMAN FILTER [NEW] ==="
input double   Kalman_Q              = 0.0001;        // process noise
input double   Kalman_R              = 0.01;          // measurement noise
input int      Kalman_SlopeBars      = 5;             // bars for slope calc

input group "=== MICROSTRUCTURE [NEW] ==="
input int      Micro_TickWindow      = 200;           // ticks to look at
input double   Micro_ImbalanceTh     = 0.58;          // 58%+ same-side = signal

input group "=== EXHAUSTION EXIT [NEW] ==="
input bool     UseExhaustionExit     = true;
input int      ExhStallBars          = 3;             // bars without progress = stall
input double   ExhMinProfitATR       = 1.0;           // only exit winners > 1 ATR

input group "=== CORRELATION GUARD [NEW] ==="
input bool     UseCorrelationGuard   = true;
input string   USD_ProxySymbol       = "EURUSD";      // gold ~+correlated with EURUSD
input int      Corr_Bars             = 6;             // bars for proxy momentum
input double   Corr_Threshold        = 0.0008;        // EURUSD move > X = USD spike

input group "=== LOSS PROTECTION ==="
input int      MaxConsecLosses       = 3;
input int      LossCooldown          = 5;
input bool     UseRecoveryMode       = true;
input double   RecoveryRiskPct       = 0.5;
input double   RecoveryTrigger       = 1.5;

input group "=== SPREAD FILTER ==="
input bool     UseSpreadFilter       = true;
input double   MaxSpreadPoints       = 35.0;          // absolute hard cap
input double   AdaptiveSpreadMult    = 2.0;           // reject if > X * median
input int      SpreadMedianBars      = 60;            // rolling window
input bool     WaitForSpread         = true;
input int      SpreadWaitSec         = 10;

input group "=== PARTIAL TP ==="
input bool     UsePartialTP          = false;         // v5.1-REVERT: Path C proved partials cap winners (backtest confirmed)
input double   TP1_ClosePct          = 40.0;          // (unused when UsePartialTP=false)
input double   TP2_ClosePct          = 35.0;          // (unused when UsePartialTP=false)

input group "=== TRAILING STOP ==="
input bool     UseTrailingStop       = true;
input bool     UseChandelierTrail    = true;          // NEW: HH-based trail
input double   Chand_ATR_Mult        = 2.5;           // v4.16: REVERTED — tighter trail didn't help
input double   Trail_ATR_Mult        = 1.0;           // fallback / non-chandelier
input double   Trail_ActivateATR     = 1.5;           // v5.0: 1.0→1.5 (wait longer for LNY confirmation)
input bool     UseBEStop             = false;         // v4.19: OFF — BE stop was locking premature exits
input double   BE_ActivateATR        = 0.8;

input group "=== TIME EXIT ==="
input bool     UseTimeExit           = true;
input int      MaxBarsInTrade        = 30;
input bool     TimeExitOnlyLoss      = true;

input group "=== LATENCY ADAPTIVE ==="
input bool     UseLatencyAdapt       = true;
input int      LatencyWindowSize     = 10;
input double   LatencySlippMult      = 0.02;

input group "=== HTF BIAS MASTER [v4.10] ==="
input bool     UseHTFBias            = true;            // require HTF agreement
input ENUM_TIMEFRAMES HTFBias_TF     = PERIOD_M15;      // master HTF
input int      HTFBias_EMAFast       = 21;
input int      HTFBias_EMASlow       = 50;
input int      HTFBias_SlopeBars     = 3;               // slope confirmation bars
input bool     HTFBias_Strict        = true;            // block opposing entries entirely

input group "=== HURST REGIME [v4.10] ==="
input bool     UseHurst              = true;
input ENUM_TIMEFRAMES Hurst_TF       = PERIOD_M5;
input int      Hurst_Bars            = 100;             // sample size
input double   Hurst_TrendTh         = 0.55;            // >this = trending
input double   Hurst_RevertTh        = 0.45;            // <this = mean-reverting

input group "=== v6.1 DIRECTION-ASYMMETRIC FILTERS (DISABLED — FAILED BACKTEST) ==="
input bool     UseDirectionAsymmetric  = false;  // v6.1-REVERT: backtest PF 0.88 (Path D was 1.18). Disabled.
input double   ADX_MinStrength_Buy     = 32.0;   // (unused when UseDirectionAsymmetric=false)
input bool     Buy_RequireBullHTF      = true;   // (unused when UseDirectionAsymmetric=false)
input bool     Buy_RequireTrendHurst   = true;   // (unused when UseDirectionAsymmetric=false)

input group "=== DIRECTION-AWARE COOLDOWN [v4.10] ==="
input bool     UseDirCooldown        = true;
input int      DirCool_Consec        = 2;               // consec same-dir losses to lock
input int      DirCool_LockBars      = 10;              // bars to lock direction

input group "=== EQUITY CURVE FILTER [v4.10] ==="
input bool     UseECFilter           = true;
input int      EC_Window             = 20;
input int      EC_SMABars            = 5;
input int      EC_MinTrades          = 25;              // v4.15: 10→25 (less aggressive EC filter, fewer false blocks)

input group "=== POSITION RECOVERY [v4.10] ==="
input bool     UseSelfHeal           = true;            // rebuild g_Trades on attach

input group "=== TRADE AUDIT CSV [v4.10] ==="
input bool     UseAuditCSV           = true;
input string   Audit_Filename        = "GoldV5_LNY_audit.csv";  // v5.0: unique filename, does not clash with v4
input bool     Audit_LogSignals      = false;           // verbose; off by default
input bool     Audit_LogTrades       = true;            // open/close events

input group "=== TICK VELOCITY GATE [v4.10] ==="
input bool     UseTickVelocity       = true;
input int      TickVel_WindowSec     = 30;              // rolling window seconds
input double   TickVel_MinPerSec     = 1.5;             // below this = illiquid

input group "=== COST-VS-EDGE GATE [v4.10] ==="
input bool     UseCostEdgeGate       = true;
input double   MaxCostFracOfTP1      = 0.30;            // (spread+est slip)/TP1 < this

input group "=== SESSION ==="
input bool     UseSessionFilter      = true;          // v4.19: ON — enforce Path H session gate
input bool     TradeAsian            = false;         // v5.0: OFF — Asia trades in v4.19, not here
input bool     TradeLondon           = true;          // v5.0: ON — London is our primary window
input bool     TradeNewYork          = false;         // v5.2-CRITICAL FIX: Path D — NY hours were losing -$425/trade
input bool     TradeOverlap          = false;         // v5.2-CRITICAL FIX: Path D — overlap adds chop, no edge
input int      Asian_Start           = 0;
input int      Asian_End             = 8;             // v5.0: RESET to 8 (irrelevant — Asia disabled)
input int      London_Start          = 8;
input int      London_End            = 10;            // v5.2-CRITICAL FIX: Path D — 12→10 (peak London only, edge concentrated here)
input int      NY_Start              = 13;
input int      NY_End                = 17;
input int      GMT_Offset            = 0;
input bool     UseSessionAdaptive    = true;          // NEW: per-session score thresholds

input group "=== NEWS FILTER ==="
input bool     UseNewsFilter         = true;
input int      NewsBefore            = 30;
input int      NewsAfter             = 30;
input bool     FilterHigh            = true;
input bool     FilterMed             = false;

input group "=== TIMEFRAMES ==="
input ENUM_TIMEFRAMES HTF_TF         = PERIOD_M15;
input ENUM_TIMEFRAMES MTF_TF         = PERIOD_M5;
input ENUM_TIMEFRAMES Base_TF        = PERIOD_M1;

input group "=== DASHBOARD ==="
input bool     ShowDashboard         = true;
input bool     ShowArrows            = true;
input int      Dash_X                = 15;
input int      Dash_Y                = 30;
input color    Clr_Bull              = clrLime;
input color    Clr_Bear              = clrRed;
input color    Clr_Neutral           = clrGray;
input color    Clr_Warn              = clrOrange;
input color    Clr_Accent            = clrGold;
input color    Clr_BG                = C'10,14,28';

//+------------------------------------------------------------------+
//| GLOBAL OBJECTS                                                   |
//+------------------------------------------------------------------+

CTrade        Trade;
CPositionInfo PosInfo;
CSymbolInfo   SymInfo;

// Indicator handles
int h_EMA_F, h_EMA_S, h_EMA_T;
int h_EMA_HF, h_EMA_HS;
int h_MTF_F, h_MTF_S;
int h_RSI, h_ATR, h_BB;
int h_ADX, h_MACD, h_Stoch;
int h_ATR_Long;                                       // longer ATR for regime

// Equity / risk state
double   g_DayEquity     = 0;
double   g_WeekEquity    = 0;
double   g_DayPnL        = 0;
int      g_DayTrades     = 0;
datetime g_LastDayReset  = 0;
datetime g_LastWeekReset = 0;
bool     g_CBDay         = false;
bool     g_CBWeek        = false;
bool     g_ProfitLock    = false;
bool     g_Recovery      = false;

// Loss protection
int      g_ConsecLoss    = 0;
int      g_ConsecWin     = 0;
bool     g_LossPause     = false;
int      g_PauseBars     = 0;

// VWAP
double   g_VWAP          = 0;
double   g_VWAPUpperBand = 0;
double   g_VWAPLowerBand = 0;

// Latency
double   g_LatencyArr[];
int      g_LatencyIdx    = 0;
double   g_AvgLatency    = 0;
ulong    g_OrderSentUsec = 0;

// News
datetime g_LastNewsScan  = 0;
bool     g_NewsActive    = false;
string   g_NewsDesc      = "";

// Bar / time tracking
datetime g_LastBar       = 0;
int      g_BarsSinceEntry= 999;
datetime g_LastBuyTime   = 0;
datetime g_LastSellTime  = 0;
string   g_ObjPrefix     = "GV400_";
int      g_ArrowIdx      = 0;

// Kalman state
double   g_KalmanX       = 0;
double   g_KalmanP       = 1.0;
bool     g_KalmanInit    = false;
double   g_KalmanHist[];    // history of filtered values

// Spread quality
double   g_SpreadHist[];
int      g_SpreadIdx     = 0;
double   g_MedianSpread  = 0;

// Kelly stats (rolling)
double   g_TradeResults[];  // PnL of last N trades
int      g_TradeResultsIdx = 0;
int      g_TradeResultsCount = 0;

// Volatility regime cache
string   g_VolRegime     = "MID";

// v4.10: HTF bias cache
int      g_HTFBias_EmaF  = INVALID_HANDLE;
int      g_HTFBias_EmaS  = INVALID_HANDLE;
int      g_HTFBiasDir    = 0;        // +1 bull, -1 bear, 0 neutral

// v4.10: Hurst cache
double   g_Hurst         = 0.5;
string   g_HurstRegime   = "RANDOM"; // TREND / MEANREV / RANDOM

// v4.10: Direction-aware cooldown
int      g_BuyConsecLoss  = 0;
int      g_SellConsecLoss = 0;
int      g_BuyLockBars    = 0;
int      g_SellLockBars   = 0;

// v4.10: Equity curve filter
double   g_ECurve[];        // rolling profits
int      g_ECurveIdx       = 0;
int      g_ECurveCount     = 0;
bool     g_ECBlocked       = false;

// v4.10: Tick velocity tracking
datetime g_TickTimes[];
int      g_TickTimesIdx    = 0;
double   g_TickVelocity    = 0;

// v4.10: Audit CSV file handle
int      g_AuditFile       = INVALID_HANDLE;

// v4.11: MAE/MFE cache (ring buffer keyed by ticket, looked up in OnTradeTransaction)
// v4.16: extended with exit reason + effective risk % per trade
#define  MaeMfeCacheSize  64
ulong    g_MMTicket [MaeMfeCacheSize];
double   g_MMmaeR   [MaeMfeCacheSize];   // R-multiple (excursion / initial risk)
double   g_MMmfeR   [MaeMfeCacheSize];   // R-multiple
string   g_MMExit   [MaeMfeCacheSize];   // v4.16: SL / TP1 / TP2 / TP3 / BE / TRAIL / TIME / EXHAUST
double   g_MMRiskPct[MaeMfeCacheSize];   // v4.16: effective risk % at open (after Kelly + DynRisk)
int      g_MMIdx           = 0;
// rolling aggregate stats (last N closed trades)
double   g_SumMaeR         = 0;
double   g_SumMfeR         = 0;
int      g_MMCount         = 0;
double   g_AvgMaeR         = 0;          // exposed on dashboard
double   g_AvgMfeR         = 0;

//+------------------------------------------------------------------+
//| STRUCTS                                                          |
//+------------------------------------------------------------------+

struct TradeState
{
   ulong              ticket;
   bool               tp1Hit;
   bool               tp2Hit;
   bool               beSet;
   double             openPrice;
   double             sl;
   double             tp1, tp2, tp3;
   double             atr;
   double             initialLots;
   double             initialRiskAmt;
   double             highestPx;       // chandelier highs
   double             lowestPx;        // chandelier lows
   ENUM_POSITION_TYPE type;
   datetime           openTime;
   int                barsOpen;
   int                stallBars;       // for exhaustion exit
   datetime           lastStallBarTime;// per-trade bar marker
   double             peakProfit;      // peak unrealized profit (=MFE in $)
   double             maeAbs;          // v4.11: Maximum Adverse Excursion in PRICE
   double             mfeAbs;          // v4.11: Maximum Favorable Excursion in PRICE
   double             effRiskPct;      // v4.16: risk % actually used at open (post Kelly + DynRisk)
   string             plannedExit;     // v4.16: set when WE close (TIME/EXHAUST/HEAT); empty means broker closed
   int                layer;
   string             strategy;
   double             dynamicTP;
};
TradeState g_Trades[];

struct SignalState
{
   int    score;
   int    requiredScore;
   bool   bullish;
   bool   bearish;
   double atr;
   double adx;
   double spread;
   double medianSpread;
   bool   spreadOK;
   bool   sessionOK;
   bool   newsOK;
   bool   circuitOK;
   bool   pauseOK;
   bool   heatOK;
   bool   corrBlockBuy;
   bool   corrBlockSell;
   bool   sweepBlocked;
   string session;
   string regime;
   string volRegime;
   string detail;
   string strategy;
};

//+------------------------------------------------------------------+
//| ARRAY HELPERS                                                    |
//+------------------------------------------------------------------+
void RemoveTradeAt(int idx)
{
   int sz = ArraySize(g_Trades);
   if(idx < 0 || idx >= sz) return;
   for(int i = idx; i < sz-1; i++) g_Trades[i] = g_Trades[i+1];
   ArrayResize(g_Trades, sz-1);
}

double GB(int h, int buf, int shift)
{
   if(h==INVALID_HANDLE) return 0;
   double a[]; ArraySetAsSeries(a,true);
   if(CopyBuffer(h,buf,shift,1,a)<=0) return 0;
   return a[0];
}

int CountPos(int type=-1)
{
   int c=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(PosInfo.SelectByIndex(i) && PosInfo.Symbol()==_Symbol && PosInfo.Magic()==Magic)
         if(type==-1 || (int)PosInfo.PositionType()==type) c++;
   return c;
}

//+------------------------------------------------------------------+
//| v4.01 PERSISTENT BASELINE                                        |
//|  Day/Week DD baseline stored in MT5 GlobalVariables so it        |
//|  survives EA reload. Restored in OnInit if still same day.       |
//+------------------------------------------------------------------+
string GvKey(string suffix)
{
   return StringFormat("GV5_%I64u_%s", Magic, suffix);   // v5.0: isolates state from v4 GlobalVariables
}

void PersistBaseline()
{
   GlobalVariableSet(GvKey("DayEquity"),     g_DayEquity);
   GlobalVariableSet(GvKey("WeekEquity"),    g_WeekEquity);
   GlobalVariableSet(GvKey("LastDayReset"),  (double)g_LastDayReset);
   GlobalVariableSet(GvKey("LastWeekReset"), (double)g_LastWeekReset);
   GlobalVariableSet(GvKey("DayPnL"),        g_DayPnL);
   GlobalVariableSet(GvKey("DayTrades"),     (double)g_DayTrades);
}

bool RestoreBaseline()
{
   if(!GlobalVariableCheck(GvKey("DayEquity"))) return false;
   double dEq = GlobalVariableGet(GvKey("DayEquity"));
   double wEq = GlobalVariableGet(GvKey("WeekEquity"));
   datetime dT = (datetime)GlobalVariableGet(GvKey("LastDayReset"));
   datetime wT = (datetime)GlobalVariableGet(GvKey("LastWeekReset"));
   double dP  = GlobalVariableGet(GvKey("DayPnL"));
   double dC  = GlobalVariableGet(GvKey("DayTrades"));
   MqlDateTime now, stored;
   TimeToStruct(TimeCurrent(), now);
   TimeToStruct(dT, stored);
   if(now.day==stored.day && now.mon==stored.mon && now.year==stored.year) {
      g_DayEquity     = dEq;
      g_DayPnL        = dP;
      g_DayTrades     = (int)dC;
      g_LastDayReset  = dT;
      if(TimeCurrent()-wT < 7*86400) {
         g_WeekEquity    = wEq;
         g_LastWeekReset = wT;
      }
      Print("GV5.2: Baseline restored | DayEq=$",DoubleToString(dEq,2),
            " DayPnL=$",DoubleToString(dP,2)," Trades=",(int)dC);
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| v4.12 HISTORY-DERIVED BASELINE                                   |
//|  Walks MT5 deal history for today's calendar date, filters by    |
//|  our Magic, sums realized PnL and counts unique positions. This  |
//|  is the AUTHORITATIVE source — independent of persisted state.   |
//|  Called from OnInit after RestoreBaseline to overwrite g_DayPnL  |
//|  with the truth, so an EA reload mid-drawdown can never reset    |
//|  the daily PnL to zero.                                          |
//+------------------------------------------------------------------+
double ComputeDayPnLFromHistory(int &outTradeCount)
{
   outTradeCount = 0;
   // build today's midnight in server time
   MqlDateTime now; TimeToStruct(TimeCurrent(), now);
   now.hour=0; now.min=0; now.sec=0;
   datetime dayStart = StructToTime(now);

   if(!HistorySelect(dayStart, TimeCurrent())) return 0.0;

   double sum = 0.0;
   int closes = 0;
   int total  = HistoryDealsTotal();
   for(int i=0; i<total; i++) {
      ulong did = HistoryDealGetTicket(i);
      if(did==0) continue;
      if((ulong)HistoryDealGetInteger(did, DEAL_MAGIC) != Magic) continue;
      ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(did, DEAL_ENTRY);
      // only count closes (and partial closes) — opens don't realize PnL
      if(entry==DEAL_ENTRY_OUT || entry==DEAL_ENTRY_INOUT || entry==DEAL_ENTRY_OUT_BY) {
         sum += HistoryDealGetDouble(did, DEAL_PROFIT)
              + HistoryDealGetDouble(did, DEAL_SWAP)
              + HistoryDealGetDouble(did, DEAL_COMMISSION);
         closes++;
      }
   }
   outTradeCount = closes;
   return sum;
}

//+------------------------------------------------------------------+
//| v4.10 HTF BIAS MASTER FILTER                                     |
//|  Computes M15 (or chosen HTF) EMA-slope direction. Same-direction|
//|  entries are blocked when HTF bias disagrees.                    |
//+------------------------------------------------------------------+
void UpdateHTFBias()
{
   if(!UseHTFBias) { g_HTFBiasDir = 0; return; }
   if(g_HTFBias_EmaF==INVALID_HANDLE || g_HTFBias_EmaS==INVALID_HANDLE) {
      g_HTFBiasDir = 0; return;
   }
   double f0 = GB(g_HTFBias_EmaF, 0, 1);
   double s0 = GB(g_HTFBias_EmaS, 0, 1);
   double f1 = GB(g_HTFBias_EmaF, 0, 1+HTFBias_SlopeBars);
   double s1 = GB(g_HTFBias_EmaS, 0, 1+HTFBias_SlopeBars);
   bool bullStruct = (f0 > s0) && (f0 > f1);
   bool bearStruct = (f0 < s0) && (f0 < f1);
   if(bullStruct)      g_HTFBiasDir = +1;
   else if(bearStruct) g_HTFBiasDir = -1;
   else                g_HTFBiasDir = 0;
}

bool HTFBiasAllows(bool isBuy)
{
   if(!UseHTFBias) return true;
   if(g_HTFBiasDir == 0) return !HTFBias_Strict;  // neutral: allow only if not strict
   if(isBuy  && g_HTFBiasDir<0) return false;     // HTF bearish → no buys
   if(!isBuy && g_HTFBiasDir>0) return false;     // HTF bullish → no sells
   return true;
}

//+------------------------------------------------------------------+
//| v4.10 HURST EXPONENT REGIME                                      |
//|  Rescaled-range (R/S) implementation on N closes. Cheap version  |
//|  with single-window estimate (institutional desks use multi-     |
//|  scale; this is a faithful approximation for retail terminals).  |
//+------------------------------------------------------------------+
void UpdateHurst()
{
   if(!UseHurst) { g_HurstRegime = "RANDOM"; return; }
   double cl[];
   ArraySetAsSeries(cl, true);
   int n = Hurst_Bars;
   if(CopyClose(_Symbol, Hurst_TF, 1, n, cl) < n) { g_HurstRegime="RANDOM"; return; }
   // log returns
   double r[]; ArrayResize(r, n-1);
   double mean = 0;
   for(int i=0;i<n-1;i++) {
      if(cl[i+1]<=0||cl[i]<=0) { g_HurstRegime="RANDOM"; return; }
      r[i] = MathLog(cl[i]/cl[i+1]);
      mean += r[i];
   }
   mean /= (n-1);
   // cumulative deviations, range and stdev
   double cum = 0, mn = 0, mx = 0, sq = 0;
   for(int i=0;i<n-1;i++) {
      double d = r[i]-mean;
      cum += d;
      if(i==0 || cum<mn) mn = cum;
      if(i==0 || cum>mx) mx = cum;
      sq += d*d;
   }
   double R = mx - mn;
   double S = MathSqrt(sq/(n-1));
   if(S<=0 || R<=0) { g_HurstRegime="RANDOM"; return; }
   double H = MathLog(R/S) / MathLog((double)(n-1));
   g_Hurst = H;
   if(H >= Hurst_TrendTh)      g_HurstRegime = "TREND";
   else if(H <= Hurst_RevertTh) g_HurstRegime = "MEANREV";
   else                         g_HurstRegime = "RANDOM";
}

//+------------------------------------------------------------------+
//| v4.10 DIRECTION-AWARE COOLDOWN                                   |
//+------------------------------------------------------------------+
bool DirCooldownAllows(bool isBuy)
{
   if(!UseDirCooldown) return true;
   if(isBuy  && g_BuyLockBars>0)  return false;
   if(!isBuy && g_SellLockBars>0) return false;
   return true;
}

void RecordDirOutcome(bool wasBuy, double profit)
{
   if(!UseDirCooldown) return;
   if(profit < 0) {
      if(wasBuy) {
         g_BuyConsecLoss++; g_SellConsecLoss=0;
         if(g_BuyConsecLoss >= DirCool_Consec) {
            g_BuyLockBars = DirCool_LockBars;
            Print("GV5.2: BUY direction locked for ",DirCool_LockBars," bars");
         }
      } else {
         g_SellConsecLoss++; g_BuyConsecLoss=0;
         if(g_SellConsecLoss >= DirCool_Consec) {
            g_SellLockBars = DirCool_LockBars;
            Print("GV5.2: SELL direction locked for ",DirCool_LockBars," bars");
         }
      }
   } else if(profit > 0) {
      if(wasBuy) g_BuyConsecLoss = 0;
      else       g_SellConsecLoss = 0;
   }
}

void TickDirCooldown()
{
   // called on new bar
   if(g_BuyLockBars  > 0) g_BuyLockBars--;
   if(g_SellLockBars > 0) g_SellLockBars--;

   // v4.14 FIX #1: decrement LossPause counter — previously never decremented,
   // causing the bot to stay paused indefinitely after 3 consecutive losses.
   if(g_PauseBars > 0) {
      g_PauseBars--;
      if(g_PauseBars == 0 && g_LossPause) {
         g_LossPause = false;
         g_ConsecLoss = 0;
         Print("GV5.2: LossPause auto-released after cooldown bars elapsed");
      }
   }
}

//+------------------------------------------------------------------+
//| v4.10 EQUITY CURVE FILTER                                        |
//+------------------------------------------------------------------+
void RecordEquityPoint(double pnl)
{
   if(!UseECFilter) return;
   if(ArraySize(g_ECurve) < EC_Window) ArrayResize(g_ECurve, EC_Window);
   g_ECurve[g_ECurveIdx % EC_Window] = pnl;
   g_ECurveIdx++;
   if(g_ECurveCount < EC_Window) g_ECurveCount++;
}

bool ECurveAllows()
{
   if(!UseECFilter) return true;
   if(g_ECurveCount < EC_MinTrades) return true;
   int n = MathMin(g_ECurveCount, EC_Window);
   // cumulative recent EC
   double cum = 0;
   for(int i=0;i<n;i++) cum += g_ECurve[i];
   // SMA over last EC_SMABars values
   int sN = MathMin(EC_SMABars, n);
   double sumS = 0;
   for(int j=0; j<sN; j++) {
      int idx = (g_ECurveIdx - 1 - j + EC_Window) % EC_Window;
      sumS += g_ECurve[idx];
   }
   double sma = sumS / sN;
   // simple rule: if cumulative EC drifting down AND recent SMA negative → block
   g_ECBlocked = (cum < 0 && sma < 0);
   return !g_ECBlocked;
}

//+------------------------------------------------------------------+
//| v4.10 SELF-HEALING POSITION RECOVERY                             |
//|  On attach, scan PositionsTotal() for any open position whose    |
//|  Magic == this EA's Magic and rebuild a TradeState for it.       |
//+------------------------------------------------------------------+
void RecoverOpenPositions()
{
   if(!UseSelfHeal) return;
   int recovered = 0;
   for(int i=PositionsTotal()-1; i>=0; i--) {
      if(!PosInfo.SelectByIndex(i)) continue;
      if(PosInfo.Symbol()!=_Symbol) continue;
      if(PosInfo.Magic()!=Magic)    continue;
      ulong tk = PosInfo.Ticket();
      // skip if already tracked
      bool exists=false;
      for(int k=0;k<ArraySize(g_Trades);k++)
         if(g_Trades[k].ticket==tk){ exists=true; break; }
      if(exists) continue;

      TradeState ts;
      ts.ticket          = tk;
      ts.tp1Hit          = false;
      ts.tp2Hit          = false;
      ts.beSet           = false;
      ts.openPrice       = PosInfo.PriceOpen();
      ts.sl              = PosInfo.StopLoss();
      ts.tp1             = 0;
      ts.tp2             = 0;
      ts.tp3             = PosInfo.TakeProfit();
      ts.atr             = GB(h_ATR,0,1);
      ts.initialLots     = PosInfo.Volume();
      ts.initialRiskAmt  = 0;
      ts.highestPx       = PosInfo.PriceOpen();
      ts.lowestPx        = PosInfo.PriceOpen();
      ts.type            = PosInfo.PositionType();
      ts.openTime        = (datetime)PosInfo.Time();
      ts.barsOpen        = 0;
      ts.stallBars       = 0;
      ts.lastStallBarTime= iTime(_Symbol,Base_TF,0);
      ts.peakProfit      = 0;
      ts.maeAbs          = 0;   // v4.11
      ts.mfeAbs          = 0;   // v4.11
      ts.effRiskPct      = 0;   // v4.16
      ts.plannedExit     = "";  // v4.16
      ts.layer           = 0;
      ts.strategy        = "RECOVERED";
      ts.dynamicTP       = 0;

      int sz = ArraySize(g_Trades);
      ArrayResize(g_Trades, sz+1);
      g_Trades[sz] = ts;
      recovered++;
   }
   if(recovered>0)
      Print("GV5.2: Self-heal recovered ",recovered," open position(s)");
}

//+------------------------------------------------------------------+
//| v4.10 TRADE AUDIT CSV                                            |
//+------------------------------------------------------------------+
void AuditOpen()
{
   if(!UseAuditCSV) return;
   g_AuditFile = FileOpen(Audit_Filename, FILE_WRITE|FILE_READ|FILE_CSV|FILE_ANSI|FILE_COMMON, ',');
   if(g_AuditFile==INVALID_HANDLE) {
      g_AuditFile = FileOpen(Audit_Filename, FILE_WRITE|FILE_READ|FILE_CSV|FILE_ANSI, ',');
   }
   if(g_AuditFile==INVALID_HANDLE) {
      Print("GV5.2: Audit CSV open failed; logging disabled");
      return;
   }
   if(FileSize(g_AuditFile)==0) {
      FileWrite(g_AuditFile,
         "time","event","ticket","dir","strategy","score","reqScore",
         "atr","spread","volReg","htfBias","hurst","ecBlk","tickVel",
         "lots","price","sl","tp","pnl",
         "mae_R","mfe_R",                                 // v4.11
         "exit_reason","eff_risk_pct");                   // v4.16
   } else {
      FileSeek(g_AuditFile, 0, SEEK_END);
   }
}

void AuditClose()
{
   if(g_AuditFile!=INVALID_HANDLE) FileClose(g_AuditFile);
   g_AuditFile = INVALID_HANDLE;
}

void AuditWrite(string event, ulong ticket, string dir, string strategy,
                int score, int reqScore, double atr, double spread,
                double lots, double price, double sl, double tp, double pnl,
                double maeR=0.0, double mfeR=0.0,        // v4.11: trailing optional
                string exitReason="", double effRiskPct=0.0)  // v4.16
{
   if(!UseAuditCSV || g_AuditFile==INVALID_HANDLE) return;
   FileWrite(g_AuditFile,
      TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS),
      event,
      (long)ticket,
      dir,
      strategy,
      score,
      reqScore,
      DoubleToString(atr,4),
      DoubleToString(spread,1),
      g_VolRegime,
      IntegerToString(g_HTFBiasDir),
      DoubleToString(g_Hurst,3),
      g_ECBlocked?"Y":"N",
      DoubleToString(g_TickVelocity,2),
      DoubleToString(lots,2),
      DoubleToString(price,_Digits),
      DoubleToString(sl,_Digits),
      DoubleToString(tp,_Digits),
      DoubleToString(pnl,2),
      DoubleToString(maeR,3),                  // v4.11
      DoubleToString(mfeR,3),                  // v4.11
      exitReason,                              // v4.16
      DoubleToString(effRiskPct,3));           // v4.16
   FileFlush(g_AuditFile);
}

//+------------------------------------------------------------------+
//| v4.11 MAE/MFE CACHE + ROLLING STATS                              |
//|  ManageTrades pushes per-trade {ticket, mae_R, mfe_R} into a     |
//|  small ring buffer just before RemoveTradeAt. OnTradeTransaction |
//|  looks it up by ticket so the audit row carries excursion data.  |
//+------------------------------------------------------------------+
// v4.16: extended signature — carries exit reason and effective risk %
void CacheMaeMfe(ulong ticket, double maeR, double mfeR,
                 string exitReason="", double effRiskPct=0.0)
{
   int slot = g_MMIdx % MaeMfeCacheSize;
   g_MMTicket [slot] = ticket;
   g_MMmaeR   [slot] = maeR;
   g_MMmfeR   [slot] = mfeR;
   g_MMExit   [slot] = exitReason;   // v4.16
   g_MMRiskPct[slot] = effRiskPct;   // v4.16
   g_MMIdx++;
   // rolling aggregate (uncapped average over last N; capped at MaeMfeCacheSize entries)
   if(g_MMCount < MaeMfeCacheSize) g_MMCount++;
   g_SumMaeR = 0; g_SumMfeR = 0;
   int n = g_MMCount;
   for(int i=0; i<n; i++) {
      g_SumMaeR += g_MMmaeR[i];
      g_SumMfeR += g_MMmfeR[i];
   }
   g_AvgMaeR = (n>0)? g_SumMaeR/n : 0;
   g_AvgMfeR = (n>0)? g_SumMfeR/n : 0;
}

bool FindMaeMfe(ulong ticket, double &maeR, double &mfeR,
                string &exitReason, double &effRiskPct)
{
   for(int i=0; i<MaeMfeCacheSize; i++) {
      if(g_MMTicket[i]==ticket) {
         maeR       = g_MMmaeR[i];
         mfeR       = g_MMmfeR[i];
         exitReason = g_MMExit[i];      // v4.16
         effRiskPct = g_MMRiskPct[i];   // v4.16
         return true;
      }
   }
   maeR=0; mfeR=0; exitReason=""; effRiskPct=0;
   return false;
}

// v4.16: categorize how a trade closed. Broker-close path uses only state flags
// (final price/profit unknown at that moment); our-initiated closes are explicit.
string ClassifyExit(const TradeState &ts)
{
   if(ts.plannedExit != "") return ts.plannedExit;   // TIME_EXIT / EXHAUST_EXIT
   // Broker closed — infer from progression flags
   if(ts.tp1Hit && ts.tp2Hit)   return "AFTER_TP2";   // TP3 or trailed after TP2
   if(ts.tp1Hit)                return "AFTER_TP1";   // TP2, trailed, or BE-stopped after TP1
   if(ts.beSet)                 return "BE_STOP";     // BE moved but never got to TP1
   return "SL_LIKELY";                                 // Never hit anything — full SL
}

// Emit a one-line tuning hint per close. Conservative — only when ratios are clearly extreme.
void EmitMaeMfeHint(ulong ticket, double profit, double maeR, double mfeR, bool wasBuy)
{
   if(MathAbs(maeR)<0.01 && MathAbs(mfeR)<0.01) return;
   string dir = wasBuy?"BUY":"SELL";
   if(profit<0 && mfeR > 0.6) {
      PrintFormat("GV5.2 HINT [tk %I64u %s]: trade went +%.2fR before stop. "
                  "Consider tighter trail or earlier BE — left winner on the table.",
                  ticket, dir, mfeR);
   }
   else if(profit<0 && MathAbs(maeR) > 1.3) {
      PrintFormat("GV5.2 HINT [tk %I64u %s]: SL overshoot %.2fR (loss > 1R). "
                  "Slippage/spread spike or SL too snug to the structure.",
                  ticket, dir, MathAbs(maeR));
   }
   else if(profit>0 && mfeR > 0 && (mfeR - maeR) > 2.0 && maeR < 0) {
      // won, but had a sizeable adverse swing first
      PrintFormat("GV5.2 HINT [tk %I64u %s]: winner but dipped to %.2fR before turning. "
                  "Heat-of-trade was uncomfortable — entry timing could be sharper.",
                  ticket, dir, maeR);
   }
   else if(profit>0 && mfeR > 0 && mfeR > 2.5*(profit/MathMax(0.0001,profit))) {
      // peak >> realized → left a lot on the table (rough heuristic)
      PrintFormat("GV5.2 HINT [tk %I64u %s]: peak MFE %.2fR vs exit. "
                  "Consider wider TP or smarter trail on this setup.",
                  ticket, dir, mfeR);
   }
}

//+------------------------------------------------------------------+
//| v4.10 TICK VELOCITY GATE                                         |
//+------------------------------------------------------------------+
void RecordTick()
{
   if(!UseTickVelocity) return;
   if(ArraySize(g_TickTimes) < TickVel_WindowSec*4)
      ArrayResize(g_TickTimes, TickVel_WindowSec*4);
   g_TickTimes[g_TickTimesIdx % ArraySize(g_TickTimes)] = TimeCurrent();
   g_TickTimesIdx++;
   // compute velocity
   datetime now = TimeCurrent();
   int sz = ArraySize(g_TickTimes);
   int count = 0;
   for(int i=0;i<sz;i++) {
      if(g_TickTimes[i] > 0 && (now - g_TickTimes[i]) <= TickVel_WindowSec) count++;
   }
   g_TickVelocity = (double)count / MathMax(TickVel_WindowSec,1);
}

bool TickVelocityOK()
{
   if(!UseTickVelocity) return true;
   if(g_TickTimesIdx < TickVel_WindowSec) return true; // warmup
   return (g_TickVelocity >= TickVel_MinPerSec);
}

//+------------------------------------------------------------------+
//| v4.10 PRE-TRADE COST-VS-EDGE GATE                                |
//+------------------------------------------------------------------+
bool CostEdgeOK(double atr, double spread_pts)
{
   if(!UseCostEdgeGate) return true;
   if(atr<=0) return true;
   double spread_pr = spread_pts * _Point;
   double slip_est  = MathMax(g_AvgLatency,0) * LatencySlippMult * _Point;
   double cost      = spread_pr + slip_est;
   double tp1       = atr * ATR_TP1_Mult;
   if(tp1<=0) return true;
   double frac = cost / tp1;
   return (frac <= MaxCostFracOfTP1);
}

//+------------------------------------------------------------------+
//| DAY / WEEK RESET                                                 |
//+------------------------------------------------------------------+
void CheckReset()
{
   MqlDateTime n,d,w;
   TimeToStruct(TimeCurrent(),n);
   TimeToStruct(g_LastDayReset,d);
   TimeToStruct(g_LastWeekReset,w);

   if(n.day!=d.day || n.mon!=d.mon) {
      g_DayEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      g_DayPnL    = 0;
      g_DayTrades = 0;
      g_CBDay     = false;
      g_ProfitLock= false;
      g_Recovery  = false;
      g_LossPause = false;
      g_PauseBars = 0;
      // v4.14 FIX #2: ALSO reset stuck-state flags on day rollover.
      // Previously these persisted across days and caused the bot to stay
      // blocked for 60+ days after early losses in the backtest.
      g_ConsecLoss     = 0;
      g_ConsecWin      = 0;
      g_ECBlocked      = false;
      g_ECurveCount    = 0;      // fresh EC window per day — old bad data ages out
      g_ECurveIdx      = 0;
      g_BuyLockBars    = 0;
      g_SellLockBars   = 0;
      g_BuyConsecLoss  = 0;
      g_SellConsecLoss = 0;
      g_LastDayReset = TimeCurrent();
      PersistBaseline();
      if(VerboseLogging) Print("GV5.2: Day reset | equity=$",DoubleToString(g_DayEquity,2),
                               " (all cooldowns + EC filter cleared)");
   }
   if(n.day_of_week<w.day_of_week || (n.day!=w.day && n.day_of_week==1)) {
      g_WeekEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      g_CBWeek     = false;
      g_LastWeekReset = TimeCurrent();
      PersistBaseline();
      if(VerboseLogging) Print("GV5.2: Week reset | equity=$",DoubleToString(g_WeekEquity,2));
   }
}

//+------------------------------------------------------------------+
//| CIRCUIT BREAKERS                                                 |
//+------------------------------------------------------------------+
bool CheckCircuit()
{
   double eq  = AccountInfoDouble(ACCOUNT_EQUITY);
   double base= MathMax(g_DayEquity,1);
   double dloss=((base-eq)/base)*100.0;
   double dgain=((eq-base)/base)*100.0;
   g_DayPnL   = eq-g_DayEquity;

   if(dloss>=MaxDailyLossPct) {
      if(!g_CBDay) { g_CBDay=true;
         Print("GV5: DAILY CIRCUIT BREAKER -",DoubleToString(dloss,2),"%"); }
      return false;
   }
   double wbase = MathMax(g_WeekEquity,1);
   double wloss = ((wbase-eq)/wbase)*100.0;
   if(wloss>=MaxWeeklyLossPct) {
      if(!g_CBWeek) { g_CBWeek=true;
         Print("GV5: WEEKLY CIRCUIT BREAKER -",DoubleToString(wloss,2),"%"); }
      return false;
   }
   if(UseRecoveryMode && dloss>=RecoveryTrigger && !g_Recovery) {
      g_Recovery=true;
      Print("GV5: Recovery mode ON | risk=",RecoveryRiskPct,"%");
   }
   if(UseRecoveryMode && dloss<RecoveryTrigger*0.5 && g_Recovery) {
      g_Recovery=false;
      Print("GV5: Recovery mode OFF");
   }
   if(dgain>=MaxDailyProfitPct) {
      if(!g_ProfitLock){ g_ProfitLock=true;
         Print("GV5: PROFIT LOCK +",DoubleToString(dgain,2),"%"); }
      return false;
   }
   g_CBDay=false;
   return true;
}

bool CheckPause()
{
   if(!g_LossPause) return true;
   if(g_PauseBars>0) return false;
   g_LossPause=false; g_ConsecLoss=0;
   Print("GV5: Loss pause ended");
   return true;
}

//+------------------------------------------------------------------+
//| PORTFOLIO HEAT MANAGER                                           |
//+------------------------------------------------------------------+
double PortfolioHeatPct()
{
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   if(eq<=0) return 0;
   double totalRisk = 0;
   for(int i=0;i<ArraySize(g_Trades);i++) {
      if(!PosInfo.SelectByTicket(g_Trades[i].ticket)) continue;
      double curSL = PosInfo.StopLoss();
      double vol   = PosInfo.Volume();
      double op    = PosInfo.PriceOpen();
      if(curSL<=0 || vol<=0) continue;
      double ts = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
      double tv = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
      if(ts<=0 || tv<=0) continue;
      double dist = MathAbs(op-curSL);
      double r    = (dist/ts) * tv * vol;
      totalRisk  += r;
   }
   return (totalRisk/eq)*100.0;
}

//+------------------------------------------------------------------+
//| SESSION                                                          |
//+------------------------------------------------------------------+
bool IsSession(string &nm)
{
   if(!UseSessionFilter) { nm="24/5 All"; return true; }
   datetime gmt = TimeCurrent()-GMT_Offset*3600;
   MqlDateTime dt; TimeToStruct(gmt,dt);
   int h = dt.hour;
   if(TradeOverlap && h>=12 && h<16)                  { nm="LDN-NY";   return true; }
   if(TradeLondon  && h>=London_Start && h<London_End){ nm="London";   return true; }
   if(TradeNewYork && h>=NY_Start && h<NY_End)        { nm="New York"; return true; }
   if(TradeAsian   && h>=Asian_Start && h<Asian_End)  { nm="Asian";    return true; }
   nm="Off"; return false;
}

// Session-adaptive score adjustment (lower = looser threshold, more trades)
int SessionScoreAdj(string sess)
{
   if(!UseSessionAdaptive) return 0;
   if(sess=="LDN-NY")   return -1;   // best liquidity; allow more trades
   if(sess=="London")   return  0;
   if(sess=="New York") return  0;
   if(sess=="Asian")    return +1;   // require higher confluence
   return 0;
}

//+------------------------------------------------------------------+
//| NEWS                                                             |
//+------------------------------------------------------------------+
bool IsNews()
{
   if(!UseNewsFilter) return false;
   if(TimeCurrent()-g_LastNewsScan<60) return g_NewsActive;
   g_LastNewsScan = TimeCurrent();
   datetime fr = TimeCurrent()-NewsAfter*60;
   datetime to = TimeCurrent()+NewsBefore*60;
   MqlCalendarValue v[];
   int n = CalendarValueHistory(v,fr,to,"USD");
   for(int i=0;i<n;i++) {
      MqlCalendarEvent ev;
      if(!CalendarEventById(v[i].event_id,ev)) continue;
      bool hi = (ev.importance==CALENDAR_IMPORTANCE_HIGH);
      bool md = (ev.importance==CALENDAR_IMPORTANCE_MODERATE);
      if((FilterHigh&&hi) || (FilterMed&&md)) {
         g_NewsActive=true; g_NewsDesc=ev.name; return true;
      }
   }
   g_NewsActive=false; g_NewsDesc=""; return false;
}

//+------------------------------------------------------------------+
//| SPREAD QUALITY                                                   |
//+------------------------------------------------------------------+
void RecordSpread(double pts)
{
   if(ArraySize(g_SpreadHist)<SpreadMedianBars)
      ArrayResize(g_SpreadHist, SpreadMedianBars);
   g_SpreadHist[g_SpreadIdx % SpreadMedianBars] = pts;
   g_SpreadIdx++;
   // compute median over filled portion
   int n = MathMin(g_SpreadIdx, SpreadMedianBars);
   if(n<5) { g_MedianSpread = pts; return; }
   double tmp[];
   ArrayResize(tmp,n);
   for(int i=0;i<n;i++) tmp[i] = g_SpreadHist[i];
   ArraySort(tmp);
   g_MedianSpread = tmp[n/2];
}

bool IsSpreadOK(double &pts)
{
   pts = (SymbolInfoDouble(_Symbol,SYMBOL_ASK)-SymbolInfoDouble(_Symbol,SYMBOL_BID))/_Point;
   RecordSpread(pts);
   if(!UseSpreadFilter) return true;
   // hard cap
   if(pts > MaxSpreadPoints) {
      if(WaitForSpread) {
         int w=0;
         while(pts>MaxSpreadPoints && w<SpreadWaitSec*10) {
            Sleep(100);
            pts=(SymbolInfoDouble(_Symbol,SYMBOL_ASK)-SymbolInfoDouble(_Symbol,SYMBOL_BID))/_Point;
            w++;
         }
         RecordSpread(pts);
      }
      if(pts>MaxSpreadPoints) return false;
   }
   // adaptive median-based filter
   if(g_MedianSpread>0 && pts > g_MedianSpread*AdaptiveSpreadMult) return false;
   return true;
}

//+------------------------------------------------------------------+
//| VWAP                                                             |
//+------------------------------------------------------------------+
void CalcVWAP()
{
   double cumPV=0, cumVol=0;
   double highs[], lows[], closes[];
   long   vols[];
   ArraySetAsSeries(highs,true); ArraySetAsSeries(lows,true);
   ArraySetAsSeries(closes,true); ArraySetAsSeries(vols,true);
   int bars = MathMin(VWAP_Bars, Bars(_Symbol,Base_TF));
   if(CopyHigh(_Symbol,Base_TF,0,bars,highs)<=0) return;
   if(CopyLow(_Symbol,Base_TF,0,bars,lows)<=0)   return;
   if(CopyClose(_Symbol,Base_TF,0,bars,closes)<=0) return;
   if(CopyTickVolume(_Symbol,Base_TF,0,bars,vols)<=0) return;
   for(int i=0;i<bars;i++) {
      double tp=(highs[i]+lows[i]+closes[i])/3.0;
      cumPV  += tp*(double)vols[i];
      cumVol += (double)vols[i];
   }
   if(cumVol>0) {
      g_VWAP = cumPV/cumVol;
      double var=0;
      for(int i=0;i<bars;i++) {
         double tp=(highs[i]+lows[i]+closes[i])/3.0;
         var += MathPow(tp-g_VWAP,2) * (double)vols[i];
      }
      double sd = MathSqrt(var/cumVol);
      g_VWAPUpperBand = g_VWAP + VWAP_BandMult*sd;
      g_VWAPLowerBand = g_VWAP - VWAP_BandMult*sd;
   }
}

//+------------------------------------------------------------------+
//| SMC: ORDER BLOCK                                                 |
//+------------------------------------------------------------------+
bool FindOrderBlock(bool isBull, double &obHigh, double &obLow)
{
   double closes[], highs[], lows[];
   ArraySetAsSeries(closes,true); ArraySetAsSeries(highs,true); ArraySetAsSeries(lows,true);
   if(CopyClose(_Symbol,Base_TF,1,OB_LookbackBars+3,closes)<=0) return false;
   if(CopyHigh (_Symbol,Base_TF,1,OB_LookbackBars+3,highs )<=0) return false;
   if(CopyLow  (_Symbol,Base_TF,1,OB_LookbackBars+3,lows  )<=0) return false;

   if(isBull) {
      for(int i=1;i<OB_LookbackBars;i++) {
         if(closes[i]<closes[i+1]) {
            if(closes[0]>highs[i+1]) {
               obHigh=highs[i+1]; obLow=lows[i+1]; return true;
            }
         }
      }
   } else {
      for(int i=1;i<OB_LookbackBars;i++) {
         if(closes[i]>closes[i+1]) {
            if(closes[0]<lows[i+1]) {
               obHigh=highs[i+1]; obLow=lows[i+1]; return true;
            }
         }
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| SMC: FVG                                                         |
//+------------------------------------------------------------------+
bool HasFVG(bool isBull)
{
   double highs[], lows[];
   ArraySetAsSeries(highs,true); ArraySetAsSeries(lows,true);
   if(CopyHigh(_Symbol,Base_TF,1,4,highs)<=0) return false;
   if(CopyLow (_Symbol,Base_TF,1,4,lows )<=0) return false;
   if(isBull && lows[0]>highs[2]) {
      double gap=(lows[0]-highs[2])/_Point;
      return (gap>=FVG_MinPoints);
   }
   if(!isBull && highs[0]<lows[2]) {
      double gap=(lows[2]-highs[0])/_Point;
      return (gap>=FVG_MinPoints);
   }
   return false;
}

//+------------------------------------------------------------------+
//| SMC: LIQUIDITY SWEEP                                             |
//+------------------------------------------------------------------+
bool IsLiquiditySweep()
{
   if(!UseLiquiditySweep) return false;
   double highs[], lows[], closes[];
   ArraySetAsSeries(highs,true); ArraySetAsSeries(lows,true); ArraySetAsSeries(closes,true);
   int bars = SweepLookback+2;
   if(CopyHigh (_Symbol,Base_TF,1,bars,highs )<=0) return false;
   if(CopyLow  (_Symbol,Base_TF,1,bars,lows  )<=0) return false;
   if(CopyClose(_Symbol,Base_TF,1,bars,closes)<=0) return false;

   double swH = highs[ArrayMaximum(highs,1,SweepLookback)];
   double swL = lows [ArrayMinimum(lows ,1,SweepLookback)];
   double range = highs[0]-lows[0];
   if(range<=0) return false;
   if(highs[0]>swH && closes[0]<swH) {
      double rev=(highs[0]-closes[0])/range;
      if(rev>=SweepReverseRatio) return true;
   }
   if(lows[0]<swL && closes[0]>swL) {
      double rev=(closes[0]-lows[0])/range;
      if(rev>=SweepReverseRatio) return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| DIVERGENCE                                                       |
//+------------------------------------------------------------------+
int SignalDivergence(bool isBull)
{
   if(!UseDivergence) return 0;
   double closes[];
   ArraySetAsSeries(closes,true);
   if(CopyClose(_Symbol,Base_TF,1,Div_Lookback+1,closes)<=0) return 0;

   int pricePeak=-1; double peakVal=0;
   for(int i=1;i<Div_Lookback;i++) {
      if(isBull) { if(closes[i]<peakVal||pricePeak<0){peakVal=closes[i];pricePeak=i;} }
      else        { if(closes[i]>peakVal||pricePeak<0){peakVal=closes[i];pricePeak=i;} }
   }
   if(pricePeak<2) return 0;

   int score=0;
   if(UseRSI_Div) {
      double rsiNow=GB(h_RSI,0,1);
      double rsiOld=GB(h_RSI,0,pricePeak);
      if(isBull  && closes[0]<closes[pricePeak] && rsiNow>rsiOld) score+=2;
      if(!isBull && closes[0]>closes[pricePeak] && rsiNow<rsiOld) score+=2;
   }
   if(UseMACD_Div) {
      double macdNow=GB(h_MACD,0,1);
      double macdOld=GB(h_MACD,0,pricePeak);
      if(isBull  && closes[0]<closes[pricePeak] && macdNow>macdOld) score+=2;
      if(!isBull && closes[0]>closes[pricePeak] && macdNow<macdOld) score+=2;
   }
   return score;
}

//+------------------------------------------------------------------+
//| DYNAMIC S/R TP                                                   |
//+------------------------------------------------------------------+
double FindSRTP(bool isBull, double entryPrice)
{
   if(!UseDynamicTP) return 0;
   double highs[], lows[];
   ArraySetAsSeries(highs,true); ArraySetAsSeries(lows,true);
   if(CopyHigh(_Symbol,Base_TF,2,SR_Lookback,highs)<=0) return 0;
   if(CopyLow (_Symbol,Base_TF,2,SR_Lookback,lows )<=0) return 0;

   double zone = entryPrice*SR_ZonePct/100.0;
   double bestLevel=0;
   if(isBull) {
      double nearest=0;
      for(int i=0;i<SR_Lookback-SR_MinTouches;i++) {
         double lvl=highs[i];
         if(lvl<=entryPrice+zone) continue;
         int touches=0;
         for(int j=0;j<SR_Lookback;j++) if(MathAbs(highs[j]-lvl)<=zone) touches++;
         if(touches>=SR_MinTouches) {
            if(nearest==0||lvl<nearest) nearest=lvl;
         }
      }
      bestLevel=nearest;
   } else {
      double nearest=0;
      for(int i=0;i<SR_Lookback-SR_MinTouches;i++) {
         double lvl=lows[i];
         if(lvl>=entryPrice-zone) continue;
         int touches=0;
         for(int j=0;j<SR_Lookback;j++) if(MathAbs(lows[j]-lvl)<=zone) touches++;
         if(touches>=SR_MinTouches) {
            if(nearest==0||lvl>nearest) nearest=lvl;
         }
      }
      bestLevel=nearest;
   }
   return bestLevel;
}

//+------------------------------------------------------------------+
//| KALMAN FILTER  [NEW v4.00]                                       |
//+------------------------------------------------------------------+
void UpdateKalman()
{
   if(!UseKalman) return;
   double cl = iClose(_Symbol,Base_TF,1);
   if(cl<=0) return;
   if(!g_KalmanInit) {
      g_KalmanX    = cl;
      g_KalmanP    = 1.0;
      g_KalmanInit = true;
   } else {
      g_KalmanP += Kalman_Q;
      double K   = g_KalmanP / (g_KalmanP + Kalman_R);
      g_KalmanX  = g_KalmanX + K * (cl - g_KalmanX);
      g_KalmanP  = (1.0 - K) * g_KalmanP;
   }
   // store history
   int sz = ArraySize(g_KalmanHist);
   int need = Kalman_SlopeBars+2;
   if(sz < need) ArrayResize(g_KalmanHist, need);
   // shift
   for(int i=need-1;i>0;i--) g_KalmanHist[i] = g_KalmanHist[i-1];
   g_KalmanHist[0] = g_KalmanX;
}

// returns +2 strong up, +1 up, -1 down, -2 strong down, 0 flat
int KalmanDir()
{
   if(!UseKalman || !g_KalmanInit) return 0;
   int n = MathMin(Kalman_SlopeBars+1, ArraySize(g_KalmanHist));
   if(n<3) return 0;
   double slope = g_KalmanHist[0] - g_KalmanHist[n-1];
   double atr = GB(h_ATR,0,1);
   if(atr<=0) return 0;
   double norm = slope / atr;
   if(norm >  0.6) return  2;
   if(norm >  0.2) return  1;
   if(norm < -0.6) return -2;
   if(norm < -0.2) return -1;
   return 0;
}

int Sig_Kalman(bool b)
{
   int d = KalmanDir();
   if(b) {
      if(d>= 2) return 2;
      if(d>= 1) return 1;
      return 0;
   } else {
      if(d<=-2) return 2;
      if(d<=-1) return 1;
      return 0;
   }
}

//+------------------------------------------------------------------+
//| MICROSTRUCTURE  [NEW v4.00]                                      |
//|   Uses last N ticks: classify each as up/down by tick rule,      |
//|   compute volume-weighted imbalance.                             |
//+------------------------------------------------------------------+
int Sig_Microstructure(bool isBull)
{
   if(!UseMicrostructure) return 0;
   MqlTick ticks[];
   int got = CopyTicks(_Symbol, ticks, COPY_TICKS_ALL, 0, Micro_TickWindow);
   if(got<20) return 0;
   double upVol=0, dnVol=0;
   double last = ticks[0].last>0 ? ticks[0].last : (ticks[0].bid+ticks[0].ask)/2.0;
   for(int i=1;i<got;i++) {
      double px = ticks[i].last>0 ? ticks[i].last : (ticks[i].bid+ticks[i].ask)/2.0;
      double v  = (double)ticks[i].volume;
      if(v<=0) v=1.0;
      if(px>last)      upVol+=v;
      else if(px<last) dnVol+=v;
      last = px;
   }
   double total = upVol+dnVol;
   if(total<=0) return 0;
   double imbBull = upVol/total;
   double imbBear = dnVol/total;
   if(isBull) {
      if(imbBull>=Micro_ImbalanceTh+0.05) return 2;
      if(imbBull>=Micro_ImbalanceTh)      return 1;
      return 0;
   } else {
      if(imbBear>=Micro_ImbalanceTh+0.05) return 2;
      if(imbBear>=Micro_ImbalanceTh)      return 1;
      return 0;
   }
}

//+------------------------------------------------------------------+
//| VOLATILITY REGIME  (ATR percentile rank)                         |
//+------------------------------------------------------------------+
void UpdateVolRegime()
{
   double atrs[];
   ArraySetAsSeries(atrs,true);
   if(CopyBuffer(h_ATR_Long,0,1,VolRegime_Lookback,atrs)<=0) { g_VolRegime="MID"; return; }
   double cur = atrs[0];
   int below=0;
   for(int i=1;i<VolRegime_Lookback;i++) if(atrs[i]<cur) below++;
   double pct = ((double)below/(VolRegime_Lookback-1))*100.0;
   if(pct<=VolRegime_LowPct)       g_VolRegime="LOW";
   else if(pct>=VolRegime_HighPct) g_VolRegime="HIGH";
   else                            g_VolRegime="MID";
}

//+------------------------------------------------------------------+
//| CORRELATION GUARD  (EURUSD proxy for USD strength)               |
//+------------------------------------------------------------------+
bool CorrelationBlock(bool isBuy)
{
   if(!UseCorrelationGuard) return false;
   if(USD_ProxySymbol=="" ) return false;
   if(!SymbolSelect(USD_ProxySymbol,true)) return false;
   double cl[];
   ArraySetAsSeries(cl,true);
   if(CopyClose(USD_ProxySymbol, Base_TF, 0, Corr_Bars+1, cl)<=0) return false;
   double mv = cl[0] - cl[Corr_Bars];
   // EURUSD up => USD weak => bullish gold; EURUSD down => USD strong => bearish gold
   if(isBuy && mv < -Corr_Threshold) return true;   // USD spiking, block longs
   if(!isBuy && mv >  Corr_Threshold) return true;  // USD weak, block shorts
   return false;
}

//+------------------------------------------------------------------+
//| MARKET REGIME (trend)                                            |
//+------------------------------------------------------------------+
string DetectRegime(double adx)
{
   double f=GB(h_EMA_F,0,1), s=GB(h_EMA_S,0,1), t=GB(h_EMA_T,0,1);
   if(adx>=ADX_StrongTrend) {
      if(f>s&&s>t) return "STRONG BULL";
      if(f<s&&s<t) return "STRONG BEAR";
      return "STRONG TREND";
   }
   if(adx>=ADX_MinStrength) return (f>s)?"BULL TREND":"BEAR TREND";
   return "RANGING";
}

//+------------------------------------------------------------------+
//| SIGNAL MODULES                                                   |
//+------------------------------------------------------------------+
int Sig_EMA(bool &bull, bool &bear)
{
   double f0=GB(h_EMA_F,0,0), f1=GB(h_EMA_F,0,1);
   double s0=GB(h_EMA_S,0,0), s1=GB(h_EMA_S,0,1);
   double tr=GB(h_EMA_T,0,1), cl=iClose(_Symbol,Base_TF,1);
   bool bx=(f1<=s1&&f0>s0), sx=(f1>=s1&&f0<s0);
   bull=(f0>s0&&cl>tr); bear=(f0<s0&&cl<tr);
   if((bx&&bull)||(sx&&bear)) return 2;
   if(bull||bear) return 1;
   return 0;
}

int Sig_RSI(bool b)
{
   double r=GB(h_RSI,0,1); if(r<=0) return 0;
   if(b){ if(r>=RSI_BuyZone&&r<RSI_OB) return 2; if(r>=40&&r<RSI_OB) return 1; }
   else { if(r<=RSI_SellZone&&r>RSI_OS) return 2; if(r<=60&&r>RSI_OS) return 1; }
   return 0;
}

int Sig_ADX(double &out)
{
   out=GB(h_ADX,0,1);
   if(out>=ADX_StrongTrend) return 2;
   if(out>=ADX_MinStrength) return 1;
   return 0;
}

int Sig_MACD(bool b)
{
   double m0=GB(h_MACD,0,1), m1=GB(h_MACD,0,2);
   double s0=GB(h_MACD,1,1), s1=GB(h_MACD,1,2);
   bool bx=(m1<=s1&&m0>s0), sx=(m1>=s1&&m0<s0);
   if(b){ if(bx) return 2; if(m0>s0) return 1; }
   else { if(sx) return 2; if(m0<s0) return 1; }
   return 0;
}

int Sig_Stoch(bool b)
{
   double k=GB(h_Stoch,0,1), d=GB(h_Stoch,1,1);
   if(k<=0&&d<=0) return 1;
   if(b){ if(k>Stoch_OB) return 0; if(k<Stoch_OS&&k>d) return 2; return 1; }
   else { if(k<Stoch_OS) return 0; if(k>Stoch_OB&&k<d) return 2; return 1; }
}

int Sig_BB(bool b)
{
   double u=GB(h_BB,1,1), l=GB(h_BB,2,1), m=GB(h_BB,0,1);
   double cl=iClose(_Symbol,Base_TF,1);
   if(u<=l) return 0;
   double z=MathAbs(cl-m)/MathMax(u-m,_Point);
   if(b){ if(cl<m&&z>=BB_ZScore) return 2; if(cl>m&&cl<u) return 1; }
   else { if(cl>m&&z>=BB_ZScore) return 2; if(cl<m&&cl>l) return 1; }
   return 0;
}

int Sig_OrderFlow(bool b)
{
   long   vols[]; double cls[];
   ArraySetAsSeries(vols,true); ArraySetAsSeries(cls,true);
   if(CopyTickVolume(_Symbol,Base_TF,1,OF_Bars,vols)<OF_Bars) return 0;
   if(CopyClose(_Symbol,Base_TF,1,OF_Bars+1,cls)<OF_Bars)     return 0;
   double bv=0, sv=0;
   for(int i=0;i<OF_Bars;i++) {
      if(cls[i]>cls[i+1]) bv+=(double)vols[i]; else sv+=(double)vols[i];
   }
   if(bv+sv<=0) return 0;
   double r = b ? (bv/MathMax(sv,1)) : (sv/MathMax(bv,1));
   if(r>=OF_Ratio*1.4) return 2;
   if(r>=OF_Ratio)     return 1;
   return 0;
}

int Sig_MTF(bool b)
{
   double hf=GB(h_EMA_HF,0,1), hs=GB(h_EMA_HS,0,1);
   double mf=GB(h_MTF_F,0,1),  ms=GB(h_MTF_S,0,1);
   bool hb=(hf>hs), mb=(mf>ms);
   if(b) { if(hb&&mb) return 2; if(hb||mb) return 1; }
   else  { if(!hb&&!mb) return 2; if(!hb||!mb) return 1; }
   return 0;
}

bool Sig_VolOK()
{
   long vc=iVolume(_Symbol,Base_TF,1), va=0;
   for(int i=2;i<=11;i++) va+=iVolume(_Symbol,Base_TF,i);
   va/=10;
   if(va<=0) return true;
   double r=(double)vc/va;
   return (r>=0.4 && r<=5.0);
}

int Sig_VWAP(bool b)
{
   if(!UseVWAP || g_VWAP<=0) return 0;
   double cl=iClose(_Symbol,Base_TF,1);
   if(b) {
      if(cl>g_VWAP && cl<g_VWAPUpperBand) return 2;
      if(cl>g_VWAP) return 1;
      return 0;
   } else {
      if(cl<g_VWAP && cl>g_VWAPLowerBand) return 2;
      if(cl<g_VWAP) return 1;
      return 0;
   }
}

int Sig_SMC(bool b)
{
   if(!UseSMC) return 0;
   int score=0;
   double obH=0, obL=0;
   double cl=iClose(_Symbol,Base_TF,1);
   if(UseOrderBlock && FindOrderBlock(b,obH,obL)) {
      if(cl>=obL && cl<=obH) score+=2;
   }
   if(UseFVG && HasFVG(b)) score+=2;
   return MathMin(score,4);
}

bool AtrOK(double &out)
{
   out=GB(h_ATR,0,1);
   return (out>=ATR_Min && out<=ATR_Max);
}

//+------------------------------------------------------------------+
//| BREAKOUT SIGNAL                                                  |
//+------------------------------------------------------------------+
bool BreakoutSignal(bool &isBull)
{
   double highs[], lows[];
   long   vols[];
   ArraySetAsSeries(highs,true); ArraySetAsSeries(lows,true); ArraySetAsSeries(vols,true);
   if(CopyHigh(_Symbol,Base_TF,2,BreakoutLookback,highs)<=0) return false;
   if(CopyLow (_Symbol,Base_TF,2,BreakoutLookback,lows )<=0) return false;
   if(CopyTickVolume(_Symbol,Base_TF,1,BreakoutLookback+1,vols)<=0) return false;
   double swH=highs[ArrayMaximum(highs)];
   double swL=lows [ArrayMinimum(lows )];
   double cl1=iClose(_Symbol,Base_TF,1);
   double cl2=iClose(_Symbol,Base_TF,2);
   long vavg=0;
   for(int i=1;i<BreakoutLookback;i++) vavg += vols[i];
   vavg /= (BreakoutLookback-1);
   bool volOK = (vols[0] >= (long)(vavg*BreakoutVolMult));
   if(cl1>swH && cl2<=swH && volOK) { isBull=true;  return true; }
   if(cl1<swL && cl2>=swL && volOK) { isBull=false; return true; }
   return false;
}

//+------------------------------------------------------------------+
//| MEAN REVERSION SIGNAL                                            |
//+------------------------------------------------------------------+
bool ReversionSignal(bool &isBull)
{
   double u=GB(h_BB,1,1), l=GB(h_BB,2,1);
   double cl=iClose(_Symbol,Base_TF,1);
   double rsi=GB(h_RSI,0,1);
   double k  =GB(h_Stoch,0,1);
   if(cl<=l && rsi<RSI_OS && k<Stoch_OS) { isBull=true;  return true; }
   if(cl>=u && rsi>RSI_OB && k>Stoch_OB) { isBull=false; return true; }
   return false;
}

//+------------------------------------------------------------------+
//| MASTER SIGNAL                                                    |
//+------------------------------------------------------------------+
SignalState GetSignal()
{
   SignalState sig;
   sig.score=0; sig.requiredScore=MinScoreTrend;
   sig.bullish=false; sig.bearish=false;
   sig.adx=0; sig.atr=0; sig.spread=0; sig.medianSpread=g_MedianSpread;
   sig.spreadOK    = IsSpreadOK(sig.spread);
   sig.sessionOK   = IsSession(sig.session);
   sig.newsOK      = !IsNews();
   sig.circuitOK   = CheckCircuit() && !g_CBDay && !g_CBWeek && !g_ProfitLock;
   sig.pauseOK     = CheckPause();
   sig.sweepBlocked= IsLiquiditySweep();
   sig.heatOK      = (PortfolioHeatPct() < MaxPortfolioHeatPct);
   sig.regime      = "N/A"; sig.detail=""; sig.strategy="";
   sig.volRegime   = g_VolRegime;
   sig.corrBlockBuy  = CorrelationBlock(true);
   sig.corrBlockSell = CorrelationBlock(false);

   if(!sig.spreadOK || !sig.newsOK || !sig.circuitOK || !sig.pauseOK
      || sig.sweepBlocked || !sig.heatOK || !sig.sessionOK) return sig;

   double atrOut=0;
   if(UseATRFilter && !AtrOK(atrOut)) return sig;
   if(!UseATRFilter) atrOut=GB(h_ATR,0,1);
   sig.atr=atrOut;
   if(UseVolumeFilter && !Sig_VolOK()) return sig;

   CalcVWAP();
   UpdateKalman();
   UpdateVolRegime();
   sig.volRegime = g_VolRegime;

   // ADX gate
   double adxV=0;
   if(UseADX) {
      int s=Sig_ADX(adxV); sig.adx=adxV;
      if(s==0) return sig;
      sig.score+=s; sig.detail+=StringFormat("ADX:%.1f(+%d) ",adxV,s);
   }
   sig.regime = UseMarketRegime ? DetectRegime(sig.adx) : "ALL";

   int sessAdj = SessionScoreAdj(sig.session);

   // ── TREND STRATEGY ──
   if(UseTrendStrategy) {
      bool bull=false, bear=false;
      int sc=0;
      if(UseEMACross) { int s=Sig_EMA(bull,bear); sc+=s; sig.detail+=StringFormat("EMA(+%d) ",s); }
      else { double t=GB(h_EMA_T,0,1), cl=iClose(_Symbol,Base_TF,1); bull=(cl>t); bear=(cl<t); }

      if(bull||bear) {
         bool dir=bull;
         if(UseRSI)             { int s=Sig_RSI(dir);            sc+=s; }
         if(UseMACD)            { int s=Sig_MACD(dir);           sc+=s; }
         if(UseStochastic)      { int s=Sig_Stoch(dir);          sc+=s; }
         if(UseBB)              { int s=Sig_BB(dir);             sc+=s; }
         if(UseOrderFlow)       { int s=Sig_OrderFlow(dir);      sc+=s; }
         if(UseMTF)             { int s=Sig_MTF(dir);            sc+=s; }
         if(UseVWAP)            { int s=Sig_VWAP(dir);           sc+=s; }
         if(UseSMC)             { int s=Sig_SMC(dir);            sc+=s; }
         if(UseDivergence)      { int s=SignalDivergence(dir);   sc+=s; }
         if(UseKalman)          { int s=Sig_Kalman(dir);         sc+=s; }
         if(UseMicrostructure)  { int s=Sig_Microstructure(dir); sc+=s; }

         int req = MinScoreTrend + sessAdj;
         sig.requiredScore = req;
         if(sc>=req) {
            // Regime gate: only take strong-trend longs/shorts in BULL/BEAR regimes
            bool regimeOK = true;
            if(UseMarketRegime) {
               if(dir  && (sig.regime=="STRONG BEAR")) regimeOK=false;
               if(!dir && (sig.regime=="STRONG BULL")) regimeOK=false;
            }
            if(regimeOK) {
               sig.score=sc; sig.bullish=bull; sig.bearish=bear;
               sig.strategy="TREND"; return sig;
            }
         }
      }
   }

   // ── MEAN REVERSION ── (prefer in LOW vol regime)
   if(UseReversionStrat && g_VolRegime!="HIGH") {
      bool revBull=false;
      if(ReversionSignal(revBull)) {
         int sc=3;
         if(Sig_MTF(revBull)>0)        sc++;
         if(Sig_OrderFlow(revBull)>0)  sc++;
         if(UseVWAP && Sig_VWAP(revBull)>0)         sc++;
         if(UseMicrostructure && Sig_Microstructure(revBull)>0) sc++;
         int req = MinScoreReversion + sessAdj;
         sig.requiredScore = req;
         if(sc>=req) {
            sig.score=sc; sig.bullish=revBull; sig.bearish=!revBull;
            sig.strategy="REVERSION"; return sig;
         }
      }
   }

   // ── BREAKOUT ── (prefer HIGH or MID vol; skip LOW)
   if(UseBreakoutStrat && g_VolRegime!="LOW") {
      bool boBull=false;
      if(BreakoutSignal(boBull)) {
         int sc=3;
         if(Sig_ADX(adxV)>0)            sc++;
         if(Sig_MACD(boBull)>0)         sc++;
         if(Sig_OrderFlow(boBull)>0)    sc++;
         if(UseKalman && Sig_Kalman(boBull)>0) sc++;
         int req = MinScoreBreakout + sessAdj;
         sig.requiredScore = req;
         if(sc>=req) {
            sig.score=sc; sig.bullish=boBull; sig.bearish=!boBull;
            sig.strategy="BREAKOUT"; return sig;
         }
      }
   }

   return sig;
}

//+------------------------------------------------------------------+
//| LATENCY                                                          |
//+------------------------------------------------------------------+
void RecordLatency(ulong sentUsec)
{
   if(!UseLatencyAdapt || sentUsec==0) return;
   double ms = (double)(GetMicrosecondCount()-sentUsec)/1000.0;
   if(ArraySize(g_LatencyArr)<LatencyWindowSize)
      ArrayResize(g_LatencyArr, LatencyWindowSize);
   g_LatencyArr[g_LatencyIdx%LatencyWindowSize] = ms;
   g_LatencyIdx++;
   double sum=0;
   int n=MathMin(g_LatencyIdx, LatencyWindowSize);
   for(int i=0;i<n;i++) sum+=g_LatencyArr[i];
   g_AvgLatency = (n>0) ? sum/n : 0;
}

int AdaptiveSlippage()
{
   if(!UseLatencyAdapt) return BaseSlippage;
   return (int)(BaseSlippage + g_AvgLatency * LatencySlippMult);
}

//+------------------------------------------------------------------+
//| KELLY SIZING                                                     |
//|   Kelly fraction f* = (W*B - L) / B                              |
//|   where W = win rate, L = 1-W, B = avg_win/avg_loss              |
//+------------------------------------------------------------------+
double KellyMult()
{
   if(!UseKelly) return 1.0;
   int n = MathMin(g_TradeResultsCount, Kelly_WindowTrades);
   if(n < (int)Kelly_MinSamples) return 1.0;
   double sumW=0, sumL=0; int nW=0, nL=0;
   for(int i=0;i<n;i++) {
      double p = g_TradeResults[i];
      if(p>0) { sumW+=p; nW++; }
      else if(p<0) { sumL+=-p; nL++; }
   }
   if(nW==0 || nL==0) return 1.0;
   double W = (double)nW/(nW+nL);
   double L = 1.0-W;
   double avgW = sumW/nW;
   double avgL = sumL/nL;
   if(avgL<=0) return 1.0;
   double B = avgW/avgL;
   double f = (W*B - L)/B;           // full Kelly fraction
   if(f<=0) return Kelly_MinMult;
   // Normalize so a "typical decent edge" (f≈0.20 at quarter-Kelly) maps to mult=1.0.
   // mult = (f * Kelly_Fraction) / 0.05  →  f=0.20,KF=0.25 ⇒ 1.0
   double mult = (f * Kelly_Fraction) / 0.05;
   mult = MathMax(Kelly_MinMult, MathMin(Kelly_MaxMult, mult));
   return mult;
}

void RecordTradePnL(double pnl)
{
   if(ArraySize(g_TradeResults)<Kelly_WindowTrades)
      ArrayResize(g_TradeResults, Kelly_WindowTrades);
   g_TradeResults[g_TradeResultsIdx % Kelly_WindowTrades] = pnl;
   g_TradeResultsIdx++;
   if(g_TradeResultsCount<Kelly_WindowTrades) g_TradeResultsCount++;
}

//+------------------------------------------------------------------+
//| LOT SIZE                                                         |
//+------------------------------------------------------------------+
// v4.15: Dynamic risk throttle — reduces position size after consecutive losses OR intraday drawdown.
// Cuts drawdown without cutting trade frequency. Uses multiplicative dampers so effects stack cleanly.
double DynamicRiskMult()
{
   if(!UseDynamicRisk) return 1.0;
   double mult = 1.0;
   // Damper #1: consecutive-loss tier
   if(g_ConsecLoss >= 4)      mult *= 0.35;   // brutal streak — quarter size
   else if(g_ConsecLoss >= 2) mult *= 0.60;   // starting to bleed — 60%
   // Damper #2: intraday drawdown tier
   double eq   = AccountInfoDouble(ACCOUNT_EQUITY);
   double base = MathMax(g_DayEquity, 1.0);
   double dd   = ((base - eq) / base) * 100.0;
   if(dd >= 6.0)      mult *= 0.40;   // 6%+ intraday drawdown — 40% of size
   else if(dd >= 3.0) mult *= 0.65;   // 3-6% intraday drawdown — 65% of size
   // Damper #3: rolling MAE/MFE tilt (if avg MAE noticeably deeper than avg MFE, market is choppy for us)
   if(g_MMCount >= 10 && MathAbs(g_AvgMaeR) > 1.5 * g_AvgMfeR && g_AvgMfeR > 0)
      mult *= 0.75;
   return MathMax(mult, 0.15);   // floor: never below 15% of base size
}

// v4.16: exposes last-computed effective risk % for audit logging
double g_LastEffectiveRiskPct = 0.0;

double CalcLots(double atr, int layer=0)
{
   double eq    = AccountInfoDouble(ACCOUNT_EQUITY);
   double risk  = g_Recovery ? RecoveryRiskPct : RiskPercent;
   if(layer>0) risk *= MathPow(PyramidLotMult,layer);
   risk *= KellyMult();
   risk *= DynamicRiskMult();   // v4.15: drawdown-aware throttle
   g_LastEffectiveRiskPct = risk;  // v4.16: capture for audit
   double rAmt  = eq*(risk/100.0);
   double tv    = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double ts    = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double ls    = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   double minL  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxL  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double slD   = atr*ATR_SL_Mult;
   if(slD<=0 || ts<=0 || tv<=0) return MinLotSize;
   double rpl = (slD/ts)*tv;
   if(rpl<=0) return MinLotSize;
   double lots = MathFloor((rAmt/rpl)/ls)*ls;
   lots = MathMax(lots, MathMax(minL,MinLotSize));
   // v4.12: chained cap — broker max, user input, AND hardcoded ceiling. The const wins.
   double cap = MathMin(maxL, MathMin(MaxLotSize, HARD_LOT_CEILING));
   lots = MathMin(lots, cap);
   return NormalizeDouble(lots,2);
}

//+------------------------------------------------------------------+
//| ARROW                                                            |
//+------------------------------------------------------------------+
void Arrow(bool buy, double price, string strat)
{
   if(!ShowArrows) return;
   g_ArrowIdx++;
   string nm=g_ObjPrefix+"A"+IntegerToString(g_ArrowIdx);
   color  clr=buy?Clr_Bull:Clr_Bear;
   int    code=buy?233:234;
   double yp=buy?price-_Point*50:price+_Point*50;
   ObjectCreate(0,nm,OBJ_ARROW,0,TimeCurrent(),yp);
   ObjectSetInteger(0,nm,OBJPROP_ARROWCODE,code);
   ObjectSetInteger(0,nm,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,nm,OBJPROP_WIDTH,2);
   ObjectSetInteger(0,nm,OBJPROP_SELECTABLE,false);
   string lnm=g_ObjPrefix+"L"+IntegerToString(g_ArrowIdx);
   ObjectCreate(0,lnm,OBJ_TEXT,0,TimeCurrent(),yp+(buy?-_Point*80:_Point*80));
   ObjectSetString(0,lnm,OBJPROP_TEXT,strat);
   ObjectSetInteger(0,lnm,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,lnm,OBJPROP_FONTSIZE,7);
}

//+------------------------------------------------------------------+
//| OPEN TRADE                                                       |
//+------------------------------------------------------------------+
bool OpenTrade(bool buy, double atr, const SignalState &sig, ulong &ticket, int layer=0)
{
   SymInfo.RefreshRates();
   double ask  = SymInfo.Ask(), bid=SymInfo.Bid();
   double lots = CalcLots(atr, layer);

   // v4.12: HARD CEILING DEFENSE-IN-DEPTH — second check after CalcLots, in case any
   // path bypasses the cap. If we ever see lots above the const here, REFUSE the trade
   // outright and emit a loud diagnostic. Better to miss a trade than fire an oversized one.
   if(lots > HARD_LOT_CEILING + 0.001) {
      PrintFormat("GV5.2 KILL-SWITCH: computed lots %.2f > HARD_LOT_CEILING %.2f. "
                  "Trade REFUSED. Check MaxLotSize input; recompile to raise the const.",
                  lots, (double)HARD_LOT_CEILING);
      return false;
   }

   double slD  = atr*ATR_SL_Mult;
   double tp3D = atr*ATR_TP3_Mult;
   double minSt= SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point;
   double price,sl,tp1,tp2,tp3;

   if(buy) {
      price=ask; sl=NormalizeDouble(price-slD,_Digits);
      tp1=NormalizeDouble(price+atr*ATR_TP1_Mult,_Digits);
      tp2=NormalizeDouble(price+atr*ATR_TP2_Mult,_Digits);
      tp3=NormalizeDouble(price+tp3D,_Digits);
   } else {
      price=bid; sl=NormalizeDouble(price+slD,_Digits);
      tp1=NormalizeDouble(price-atr*ATR_TP1_Mult,_Digits);
      tp2=NormalizeDouble(price-atr*ATR_TP2_Mult,_Digits);
      tp3=NormalizeDouble(price-tp3D,_Digits);
   }
   if(MathAbs(price-sl)<minSt || MathAbs(price-tp3)<minSt) return false;

   double srTP=FindSRTP(buy,price);
   if(srTP>0) {
      if(buy  && srTP>price+minSt) tp3=srTP;
      if(!buy && srTP<price-minSt) tp3=srTP;
   }

   string cmt = StringFormat("%s|%s|L%d|R%.2f|%s",
                  EA_Comment, sig.strategy, layer, lots, sig.volRegime);
   int slip = AdaptiveSlippage();
   Trade.SetDeviationInPoints(slip);

   bool ok=false;
   g_OrderSentUsec = GetMicrosecondCount();
   for(int t=1;t<=MaxRetryAttempts;t++) {
      ok = buy ? Trade.Buy (lots,_Symbol,price,sl,tp3,cmt)
               : Trade.Sell(lots,_Symbol,price,sl,tp3,cmt);
      if(ok) break;
      uint rc=Trade.ResultRetcode();
      if(rc!=10004 && rc!=10006 && rc!=10007 && rc!=10016 && rc!=10018) break;
      if(t<MaxRetryAttempts) { Sleep(RetryDelayMs); SymInfo.RefreshRates();
         price = buy?SymInfo.Ask():SymInfo.Bid(); }
   }
   if(!ok) {
      if(VerboseLogging) Print("GV5: OpenTrade FAILED rc=",Trade.ResultRetcode());
      return false;
   }

   RecordLatency(g_OrderSentUsec);
   ticket = Trade.ResultOrder();
   g_DayTrades++;
   g_BarsSinceEntry = 0;
   if(buy) g_LastBuyTime  = TimeCurrent();
   else    g_LastSellTime = TimeCurrent();

   TradeState ts;
   ts.ticket    = ticket;
   ts.tp1Hit    = false; ts.tp2Hit=false; ts.beSet=false;
   ts.openPrice = price; ts.sl=sl; ts.tp1=tp1; ts.tp2=tp2; ts.tp3=tp3;
   ts.atr       = atr;
   ts.initialLots = lots;
   ts.initialRiskAmt = lots * (slD / MathMax(SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE),_Point))
                       * SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   ts.highestPx = price;
   ts.lowestPx  = price;
   ts.type      = buy?POSITION_TYPE_BUY:POSITION_TYPE_SELL;
   ts.openTime  = TimeCurrent();
   ts.barsOpen  = 0;
   ts.stallBars = 0;
   ts.lastStallBarTime = iTime(_Symbol,Base_TF,0);
   ts.peakProfit= 0;
   ts.maeAbs    = 0;   // v4.11
   ts.mfeAbs    = 0;   // v4.11
   ts.effRiskPct= g_LastEffectiveRiskPct;   // v4.16: risk % actually used for this trade
   ts.plannedExit = "";                     // v4.16
   ts.layer     = layer;
   ts.strategy  = sig.strategy;
   ts.dynamicTP = srTP;

   int sz=ArraySize(g_Trades);
   ArrayResize(g_Trades, sz+1);
   g_Trades[sz] = ts;
   Arrow(buy, price, sig.strategy+(layer>0?StringFormat("+%d",layer):""));
   if(VerboseLogging) {
      double kmult = KellyMult();
      Print("GV4 OPEN ",(buy?"BUY":"SELL")," [",sig.strategy,"] L",layer,
            " Lots=",lots," SL=",sl," TP=",tp3,
            " Score=",sig.score,"/",sig.requiredScore,
            " VolReg=",sig.volRegime," Kelly=",DoubleToString(kmult,2),
            "x Slip=",slip," Lat=",DoubleToString(g_AvgLatency,1),"ms");
   }
   return true;
}

//+------------------------------------------------------------------+
//| PYRAMID                                                          |
//+------------------------------------------------------------------+
void TryPyramid()
{
   if(!UsePyramid) return;
   for(int i=0;i<ArraySize(g_Trades);i++) {
      if(g_Trades[i].layer>=MaxPyramidLayers) continue;
      if(!PosInfo.SelectByTicket(g_Trades[i].ticket)) continue;
      bool buy   = (g_Trades[i].type==POSITION_TYPE_BUY);
      double cur = buy?SymbolInfoDouble(_Symbol,SYMBOL_BID)
                      :SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      double prof= buy?(cur-g_Trades[i].openPrice):(g_Trades[i].openPrice-cur);
      double atr = g_Trades[i].atr;
      double target=(g_Trades[i].layer==0)?PyramidLayer1ATR*atr:PyramidLayer2ATR*atr;
      if(prof>=target
         && CountPos()<MaxOpenPositions
         && g_DayTrades<MaxDailyTrades
         && PortfolioHeatPct()<MaxPortfolioHeatPct) {
         SignalState fakeS;
         fakeS.strategy = g_Trades[i].strategy;
         fakeS.atr=atr;
         fakeS.volRegime=g_VolRegime;
         fakeS.score=0; fakeS.requiredScore=0;
         double sp=0;
         if(!IsSpreadOK(sp)) continue;
         ulong newT=0;
         if(OpenTrade(buy, atr, fakeS, newT, g_Trades[i].layer+1))
            if(VerboseLogging) Print("GV5: Pyramid L",g_Trades[i].layer+1,
                                     " added to ticket ",g_Trades[i].ticket);
      }
   }
}

//+------------------------------------------------------------------+
//| EXHAUSTION EXIT  [NEW v4.00]                                     |
//+------------------------------------------------------------------+
bool ShouldExhaustExit(const TradeState &ts, double curPx, double profit)
{
   if(!UseExhaustionExit) return false;
   bool buy = (ts.type==POSITION_TYPE_BUY);
   double atr = ts.atr;
   if(profit < atr*ExhMinProfitATR) return false;
   double rsi = GB(h_RSI,0,1);
   bool extreme = buy ? (rsi>=RSI_Extreme_OB) : (rsi<=RSI_Extreme_OS);
   if(!extreme) return false;
   // Stall = no new peak for N bars
   if(ts.stallBars >= ExhStallBars) return true;
   return false;
}

//+------------------------------------------------------------------+
//| MANAGE TRADES                                                    |
//+------------------------------------------------------------------+
void ManageTrades()
{
   for(int i=ArraySize(g_Trades)-1;i>=0;i--) {
      if(!PosInfo.SelectByTicket(g_Trades[i].ticket)) {
         // v4.11: position closed by broker (SL/TP/manual) — cache last-known MAE/MFE for audit lookup
         double r1 = MathMax(0.0001, g_Trades[i].atr * ATR_SL_Mult);
         CacheMaeMfe(g_Trades[i].ticket,
                     -g_Trades[i].maeAbs / r1,
                      g_Trades[i].mfeAbs / r1,
                     ClassifyExit(g_Trades[i]),          // v4.16
                     g_Trades[i].effRiskPct);            // v4.16
         RemoveTradeAt(i); continue;
      }
      g_Trades[i].barsOpen = (int)((TimeCurrent()-g_Trades[i].openTime)/PeriodSeconds(Base_TF));
      bool   buy   = (g_Trades[i].type==POSITION_TYPE_BUY);
      double curPx = buy?SymbolInfoDouble(_Symbol,SYMBOL_BID)
                        :SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      double curSL = PosInfo.StopLoss();
      double curLts= PosInfo.Volume();
      double atr   = g_Trades[i].atr;
      double profit= buy?(curPx-g_Trades[i].openPrice):(g_Trades[i].openPrice-curPx);
      double minSt = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point;
      double ls    = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
      double minL  = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);

      // Update chandelier high/low and peak profit tracking
      if(buy) {
         if(curPx>g_Trades[i].highestPx) g_Trades[i].highestPx = curPx;
      } else {
         if(g_Trades[i].lowestPx==0 || curPx<g_Trades[i].lowestPx) g_Trades[i].lowestPx = curPx;
      }
      if(profit>g_Trades[i].peakProfit) {
         g_Trades[i].peakProfit       = profit;
         g_Trades[i].stallBars        = 0;
         g_Trades[i].lastStallBarTime = iTime(_Symbol,Base_TF,0);
      } else {
         datetime tb = iTime(_Symbol,Base_TF,0);
         if(tb != g_Trades[i].lastStallBarTime) {
            g_Trades[i].stallBars++;
            g_Trades[i].lastStallBarTime = tb;
         }
      }

      // v4.11: MAE/MFE — mfeAbs mirrors peakProfit; maeAbs is deepest adverse excursion in price
      if(profit  > g_Trades[i].mfeAbs) g_Trades[i].mfeAbs = profit;
      if(-profit > g_Trades[i].maeAbs) g_Trades[i].maeAbs = -profit;

      // Time exit
      if(UseTimeExit && g_Trades[i].barsOpen>=MaxBarsInTrade) {
         if(!TimeExitOnlyLoss || profit<0) {
            g_Trades[i].plannedExit = "TIME_EXIT";     // v4.16
            Trade.PositionClose(g_Trades[i].ticket, AdaptiveSlippage());
            double r2 = MathMax(0.0001, g_Trades[i].atr * ATR_SL_Mult);
            CacheMaeMfe(g_Trades[i].ticket,
                        -g_Trades[i].maeAbs/r2, g_Trades[i].mfeAbs/r2,
                        ClassifyExit(g_Trades[i]),      // v4.16
                        g_Trades[i].effRiskPct);        // v4.16
            RemoveTradeAt(i); continue;
         }
      }

      // Exhaustion exit
      if(ShouldExhaustExit(g_Trades[i], curPx, profit)) {
         g_Trades[i].plannedExit = "EXHAUST_EXIT";     // v4.16
         Trade.PositionClose(g_Trades[i].ticket, AdaptiveSlippage());
         double r3 = MathMax(0.0001, g_Trades[i].atr * ATR_SL_Mult);
         CacheMaeMfe(g_Trades[i].ticket,
                     -g_Trades[i].maeAbs/r3, g_Trades[i].mfeAbs/r3,
                     ClassifyExit(g_Trades[i]),         // v4.16
                     g_Trades[i].effRiskPct);           // v4.16
         RemoveTradeAt(i); continue;
      }

      // Partial TP1
      if(UsePartialTP && !g_Trades[i].tp1Hit && profit>=atr*ATR_TP1_Mult*0.90) {
         double cv = NormalizeDouble(MathFloor(curLts*(TP1_ClosePct/100.0)/ls)*ls,2);
         if(cv>=minL && curLts-cv>=minL && Trade.PositionClosePartial(g_Trades[i].ticket,cv))
            g_Trades[i].tp1Hit = true;
      }
      if(UsePartialTP && g_Trades[i].tp1Hit && !g_Trades[i].tp2Hit
         && profit>=atr*ATR_TP2_Mult*0.90) {
         if(PosInfo.SelectByTicket(g_Trades[i].ticket)) {
            double rem=PosInfo.Volume();
            double cv = NormalizeDouble(MathFloor(rem*(TP2_ClosePct/100.0)/ls)*ls,2);
            if(cv>=minL && rem-cv>=minL && Trade.PositionClosePartial(g_Trades[i].ticket,cv))
               g_Trades[i].tp2Hit = true;
         }
      }
      // Break-even
      if(UseBEStop && !g_Trades[i].beSet && profit>=atr*BE_ActivateATR) {
         double bePx = buy?NormalizeDouble(g_Trades[i].openPrice+_Point*3,_Digits)
                          :NormalizeDouble(g_Trades[i].openPrice-_Point*3,_Digits);
         bool mv = buy?(bePx>curSL || curSL==0):(bePx<curSL || curSL==0);
         if(mv && MathAbs(curPx-bePx)>=minSt
            && Trade.PositionModify(g_Trades[i].ticket, bePx, g_Trades[i].tp3)) {
            g_Trades[i].beSet = true;
            g_Trades[i].sl    = bePx;
         }
      }
      // Trailing: Chandelier or fixed ATR
      if(UseTrailingStop && profit>=atr*Trail_ActivateATR) {
         double newSL=0;
         if(UseChandelierTrail) {
            if(buy)  newSL = NormalizeDouble(g_Trades[i].highestPx - atr*Chand_ATR_Mult, _Digits);
            else     newSL = NormalizeDouble(g_Trades[i].lowestPx  + atr*Chand_ATR_Mult, _Digits);
         } else {
            double td=atr*Trail_ATR_Mult;
            if(buy)  newSL = NormalizeDouble(curPx - td, _Digits);
            else     newSL = NormalizeDouble(curPx + td, _Digits);
         }
         bool mv2 = buy?(newSL>curSL):(newSL<curSL || curSL==0);
         if(mv2 && MathAbs(curPx-newSL)>=minSt
            && Trade.PositionModify(g_Trades[i].ticket, newSL, g_Trades[i].tp3)) {
            g_Trades[i].sl = newSL;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| NEW BAR                                                          |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   datetime t=iTime(_Symbol,Base_TF,0);
   if(t!=g_LastBar){
      g_LastBar=t;
      g_BarsSinceEntry++;
      TickDirCooldown();   // v4.10: decrement direction locks per bar
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| DASHBOARD (v4.10)                                                |
//+------------------------------------------------------------------+
void InitDash()
{
   string bg=g_ObjPrefix+"BG";
   ObjectCreate(0,bg,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,bg,OBJPROP_XDISTANCE,Dash_X);
   ObjectSetInteger(0,bg,OBJPROP_YDISTANCE,Dash_Y);
   ObjectSetInteger(0,bg,OBJPROP_XSIZE,320);
   ObjectSetInteger(0,bg,OBJPROP_YSIZE,420);
   ObjectSetInteger(0,bg,OBJPROP_BGCOLOR,Clr_BG);
   ObjectSetInteger(0,bg,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,bg,OBJPROP_COLOR,clrDimGray);
   ObjectSetInteger(0,bg,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,bg,OBJPROP_BACK,true);
}

void DL(string id,string txt,int x,int y,color clr,int sz=8,string font="Consolas")
{
   string n=g_ObjPrefix+id;
   if(ObjectFind(0,n)<0){
      ObjectCreate(0,n,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
   }
   ObjectSetString(0,n,OBJPROP_TEXT,txt);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,Dash_X+x);
   ObjectSetInteger(0,n,OBJPROP_YDISTANCE,Dash_Y+y);
   ObjectSetInteger(0,n,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,sz);
   ObjectSetString(0,n,OBJPROP_FONT,font);
}

void UpdateDash(const SignalState &sig)
{
   if(!ShowDashboard) return;
   double eq =AccountInfoDouble(ACCOUNT_EQUITY);
   double pnl=eq-g_DayEquity;
   double pct=(g_DayEquity>0)?(pnl/g_DayEquity*100.0):0;
   int    op =CountPos();

   DL("H0","  GOLD V5 LNY  v5.2  |  LONDON/NY",5,5,clrGold,8);
   DL("HL","━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",5,17,clrDimGray,7);

   color  sc=sig.bullish?Clr_Bull:(sig.bearish?Clr_Bear:Clr_Neutral);
   string ss=sig.bullish?"▲  BUY":(sig.bearish?"▼  SELL":"─  WAIT");
   string st=sig.strategy!=""?" ["+sig.strategy+"]":"";
   DL("SIG",StringFormat("  [%2d/%d] %s%s",sig.score,sig.requiredScore,ss,st),5,30,sc,9);
   DL("ADX",StringFormat("  ADX:%.1f  VWAP:%.2f  Reg:%s/%s",
      sig.adx,g_VWAP,sig.regime,sig.volRegime),
      5,44,(sig.adx>=ADX_MinStrength?clrCyan:Clr_Warn));

   DL("HL2","━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",5,57,clrDimGray,7);

   DL("SPR",StringFormat("  SPREAD: %.1f / med %.1f [%s]",
      sig.spread,sig.medianSpread,sig.spreadOK?"OK":"HIGH"),
      5,69,sig.spreadOK?Clr_Bull:Clr_Bear);
   DL("SES",StringFormat("  SESSION: %s",sig.session),5,83,sig.sessionOK?Clr_Bull:Clr_Neutral);
   DL("ATR",StringFormat("  ATR: %.4f  |  Lat: %.1f ms",sig.atr,g_AvgLatency),5,97,clrSilver);

   DL("HL3","━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",5,110,clrDimGray,7);

   // v4.10: institutional gate row
   string htfStr = (g_HTFBiasDir>0)?"BULL":(g_HTFBiasDir<0?"BEAR":"NEUT");
   color  htfClr = (g_HTFBiasDir>0)?Clr_Bull:(g_HTFBiasDir<0?Clr_Bear:Clr_Neutral);
   DL("HTF",StringFormat("  HTF BIAS: %s  |  HURST: %.2f [%s]",
      htfStr,g_Hurst,g_HurstRegime),5,122,htfClr);
   string lockStr = "";
   if(g_BuyLockBars>0)  lockStr += StringFormat("BUY-LOCK %d ",g_BuyLockBars);
   if(g_SellLockBars>0) lockStr += StringFormat("SELL-LOCK %d ",g_SellLockBars);
   if(lockStr=="") lockStr = "CLEAR";
   color  lkClr = (g_BuyLockBars>0||g_SellLockBars>0)?Clr_Warn:Clr_Bull;
   DL("DCD",StringFormat("  DIR-COOL: %s",lockStr),5,136,lkClr);
   color  ecClr = g_ECBlocked?Clr_Bear:Clr_Bull;
   DL("ECF",StringFormat("  EQ-CURVE: %s  |  Trades: %d",
      g_ECBlocked?"BLOCKED":"OK",g_ECurveCount),5,150,ecClr);
   color  tvClr = (g_TickVelocity>=TickVel_MinPerSec)?Clr_Bull:Clr_Warn;
   DL("TVL",StringFormat("  TICK-VEL: %.1f /s",g_TickVelocity),5,164,tvClr);

   DL("HL4","━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",5,177,clrDimGray,7);

   color pc=(pnl>=0)?Clr_Bull:Clr_Bear;
   DL("EQ", StringFormat("  EQUITY:  $%.2f",eq),5,189,clrSilver);
   DL("PNL",StringFormat("  DAY P&L: $%.2f  (%.2f%%)",pnl,pct),5,203,pc);
   DL("TRD",StringFormat("  TRADES:  %d / %d  |  Open: %d / %d",
      g_DayTrades,MaxDailyTrades,op,MaxOpenPositions),5,217,clrSilver);
   DL("HEAT",StringFormat("  HEAT: %.2f%% / cap %.1f%%",
      PortfolioHeatPct(),MaxPortfolioHeatPct),5,231,
      (PortfolioHeatPct()<MaxPortfolioHeatPct?clrSilver:Clr_Warn));

   DL("HL5","━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",5,244,clrDimGray,7);

   color  rc=g_Recovery?Clr_Warn:Clr_Bull;
   string rs=g_Recovery?StringFormat("RECOVERY %.1f%%",RecoveryRiskPct):StringFormat("NORMAL %.1f%%",RiskPercent);
   double kMult = UseKelly?KellyMult():1.0;
   DL("RSK",StringFormat("  RISK: %s  |  Kelly x%.2f",rs,kMult),5,256,rc);
   string ls2=g_LossPause?StringFormat("PAUSED %d bars",g_PauseBars)
                          :StringFormat("%d consec / %d max",g_ConsecLoss,MaxConsecLosses);
   color  lc=(g_ConsecLoss>=MaxConsecLosses-1)?Clr_Warn:clrSilver;
   DL("LSS",StringFormat("  LOSSES:  %s",ls2),5,270,lc);

   DL("HL6","━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",5,283,clrDimGray,7);

   DL("NWS",StringFormat("  NEWS:    %s",sig.newsOK?"CLEAR":("! "+g_NewsDesc)),
      5,295,sig.newsOK?Clr_Bull:Clr_Bear);
   string cbs=(!sig.circuitOK)?(g_CBDay?"DAY BREAKER":(g_CBWeek?"WEEK BREAKER":"PROFIT LOCK")):"ACTIVE";
   DL("CB", StringFormat("  SYSTEM:  %s",cbs),5,309,sig.circuitOK?Clr_Bull:Clr_Bear);
   DL("AUD",StringFormat("  AUDIT:   %s",
      (UseAuditCSV && g_AuditFile!=INVALID_HANDLE)?"LOGGING":"OFF"),
      5,323,(UseAuditCSV && g_AuditFile!=INVALID_HANDLE)?Clr_Bull:Clr_Neutral);

   // v4.11: MAE/MFE rolling averages over last g_MMCount closed trades
   color mmClr = clrSilver;
   if(g_MMCount >= 5) {
      // hint cues: avg MFE > 1.5R while losers' MAE shallow = TPs too greedy
      if(g_AvgMfeR > 1.5 && MathAbs(g_AvgMaeR) < 0.5)      mmClr = Clr_Warn;   // leaving profit
      else if(MathAbs(g_AvgMaeR) > 1.0)                    mmClr = Clr_Bear;   // stops too tight or overshooting
   }
   DL("MMM",StringFormat("  MAE %.2fR / MFE %.2fR  (n=%d)",
      g_AvgMaeR,g_AvgMfeR,g_MMCount),5,337,mmClr);

   DL("HL7","━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",5,350,clrDimGray,7);
   DL("MGC",StringFormat("  Magic: %I64u  |  v5.2",Magic),5,362,clrDimGray,7);
   DL("VER","  Gold V5 LNY | Institutional London/NY Scalper",5,376,clrDimGray,7);
   ChartRedraw(0);
}

void RemoveDash(){ObjectsDeleteAll(0,g_ObjPrefix);}

//+------------------------------------------------------------------+
//| INIT (v4.10)                                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   if(!SymInfo.Name(_Symbol)){Alert("GV5.2: Symbol fail");return INIT_FAILED;}
   SymInfo.RefreshRates();
   Trade.SetExpertMagicNumber(Magic);
   Trade.SetDeviationInPoints(BaseSlippage);
   Trade.SetTypeFilling(ORDER_FILLING_FOK);
   Trade.LogLevel(LOG_LEVEL_ERRORS);

   // Core indicator handles
   h_EMA_F  = iMA(_Symbol,Base_TF,EMA_Fast, 0,MODE_EMA,PRICE_CLOSE);
   h_EMA_S  = iMA(_Symbol,Base_TF,EMA_Slow, 0,MODE_EMA,PRICE_CLOSE);
   h_EMA_T  = iMA(_Symbol,Base_TF,EMA_Trend,0,MODE_EMA,PRICE_CLOSE);
   h_RSI    = iRSI(_Symbol,Base_TF,RSI_Period,PRICE_CLOSE);
   h_ATR    = iATR(_Symbol,Base_TF,ATR_Period);
   h_BB     = iBands(_Symbol,Base_TF,BB_Period,0,BB_Dev,PRICE_CLOSE);
   h_ADX    = iADX(_Symbol,Base_TF,ADX_Period);
   h_MACD   = iMACD(_Symbol,Base_TF,MACD_Fast,MACD_Slow,MACD_Signal,PRICE_CLOSE);
   h_Stoch  = iStochastic(_Symbol,Base_TF,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,STO_LOWHIGH);
   h_EMA_HF = iMA(_Symbol,HTF_TF,EMA_HTF_Fast,0,MODE_EMA,PRICE_CLOSE);
   h_EMA_HS = iMA(_Symbol,HTF_TF,EMA_HTF_Slow,0,MODE_EMA,PRICE_CLOSE);
   h_MTF_F  = iMA(_Symbol,MTF_TF,EMA_Fast,0,MODE_EMA,PRICE_CLOSE);
   h_MTF_S  = iMA(_Symbol,MTF_TF,EMA_Slow,0,MODE_EMA,PRICE_CLOSE);
   h_ATR_Long = iATR(_Symbol,Base_TF,50);   // long ATR for vol-regime percentile

   // v4.10: HTF bias dedicated handles (HTFBias_TF, falls back to HTF_TF if same)
   g_HTFBias_EmaF = iMA(_Symbol,HTFBias_TF,HTFBias_EMAFast,0,MODE_EMA,PRICE_CLOSE);
   g_HTFBias_EmaS = iMA(_Symbol,HTFBias_TF,HTFBias_EMASlow,0,MODE_EMA,PRICE_CLOSE);

   int chk[]={h_EMA_F,h_EMA_S,h_EMA_T,h_RSI,h_ATR,h_BB,h_ADX,h_MACD,h_Stoch,
              h_EMA_HF,h_EMA_HS,h_MTF_F,h_MTF_S,h_ATR_Long,
              g_HTFBias_EmaF,g_HTFBias_EmaS};
   for(int i=0;i<ArraySize(chk);i++)
      if(chk[i]==INVALID_HANDLE){Alert("GV5.2: Handle #",i," fail");return INIT_FAILED;}

   // Rolling buffers (helpers lazy-allocate as needed; OnInit primes only the simple ones)
   ArrayResize(g_LatencyArr,LatencyWindowSize);    ArrayInitialize(g_LatencyArr,0);
   ArrayResize(g_TradeResults,Kelly_WindowTrades); ArrayInitialize(g_TradeResults,0);
   ArrayResize(g_ECurve,EC_Window);                ArrayInitialize(g_ECurve,0);
   ArrayResize(g_TickTimes,TickVel_WindowSec*4);   // matches RecordTick sizing

   // v4.01: persistent baselines
   if(!RestoreBaseline()) {
      g_DayEquity = g_WeekEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      g_LastDayReset = g_LastWeekReset = TimeCurrent();
      PersistBaseline();
   }

   // v4.12: AUTHORITATIVE override — recompute today's PnL from MT5 deal history,
   // independent of any persisted state. This is the fix for "DAY P&L = $0 after
   // a reload during drawdown". Equity baseline is derived: dayStartEq = currentEq - realPnL.
   {
      int    histTrades = 0;
      double histPnL    = ComputeDayPnLFromHistory(histTrades);
      double curEq      = AccountInfoDouble(ACCOUNT_EQUITY);
      double derivedBase= curEq - histPnL;
      // only OVERWRITE if history indicates real activity OR the persisted value drifts
      if(histTrades > 0 || MathAbs(g_DayPnL - histPnL) > 0.01) {
         PrintFormat("GV5.2: history-derived baseline | trades=%d  realPnL=$%.2f  "
                     "curEq=$%.2f  derivedDayEq=$%.2f  (was persisted $%.2f / $%.2f)",
                     histTrades, histPnL, curEq, derivedBase, g_DayEquity, g_DayPnL);
         g_DayEquity = derivedBase;
         g_DayPnL    = histPnL;
         g_DayTrades = histTrades;
         PersistBaseline();
      } else {
         PrintFormat("GV5.2: no day activity in history | dayEq=$%.2f  dayPnL=$%.2f",
                     g_DayEquity, g_DayPnL);
      }
   }

   ArrayResize(g_Trades,0);

   // v4.10: self-heal — pick up any pre-existing positions with our Magic
   RecoverOpenPositions();

   // v4.10: open audit CSV
   AuditOpen();

   if(ShowDashboard) InitDash();

   // v4.12: full safety-config dump — one block, copy-pasteable, no scrolling
   double effectiveLotCeiling = MathMin(MaxLotSize, (double)HARD_LOT_CEILING);
   Print  ("================ GV5.2 STARTUP CONFIG ================");
   PrintFormat("  Magic              : %I64u  |  Build: v5.2 LNY", Magic);
   PrintFormat("  EnableLiveTrading  : %s",          EnableLiveTrading?"ON":"OFF");
   Print  ("  --- RISK / SIZING ---");
   PrintFormat("  RiskPercent        : %.2f %%",     RiskPercent);
   PrintFormat("  MaxLotSize (input) : %.2f",        MaxLotSize);
   PrintFormat("  HARD_LOT_CEILING   : %.2f         (compile-time constant, cannot be raised by input)", (double)HARD_LOT_CEILING);
   PrintFormat("  Effective max lots : %.2f         (= min of input and ceiling)", effectiveLotCeiling);
   PrintFormat("  MinLotSize         : %.2f",        MinLotSize);
   PrintFormat("  ATR_SL_Mult        : %.2f",        ATR_SL_Mult);
   PrintFormat("  MaxPyramidLayers   : %d",          MaxPyramidLayers);
   PrintFormat("  Kelly              : %s  (frac %.2f, window %d, min mult %.2f, max %.2f)",
               UseKelly?"ON":"OFF", Kelly_Fraction, Kelly_WindowTrades, Kelly_MinMult, Kelly_MaxMult);
   Print  ("  --- DRAWDOWN / FREQUENCY ---");
   PrintFormat("  MaxDailyLossPct    : %.2f %%",     MaxDailyLossPct);
   PrintFormat("  MaxWeeklyLossPct   : %.2f %%",     MaxWeeklyLossPct);
   PrintFormat("  MaxDailyTrades     : %d",          MaxDailyTrades);
   PrintFormat("  MaxOpenPositions   : %d",          MaxOpenPositions);
   PrintFormat("  MaxPortfolioHeat   : %.2f %%",     MaxPortfolioHeatPct);
   PrintFormat("  MaxConsecLosses    : %d  (cooldown %d bars)", MaxConsecLosses, LossCooldown);
   Print  ("  --- INSTITUTIONAL GATES (v4.10) ---");
   PrintFormat("  HTFBias            : %s  strict=%s  TF=%s  EMA(%d,%d)",
               UseHTFBias?"ON":"OFF", HTFBias_Strict?"YES":"NO",
               EnumToString(HTFBias_TF), HTFBias_EMAFast, HTFBias_EMASlow);
   PrintFormat("  Hurst              : %s  TF=%s  bars=%d  trendTh=%.2f  revTh=%.2f",
               UseHurst?"ON":"OFF", EnumToString(Hurst_TF), Hurst_Bars, Hurst_TrendTh, Hurst_RevertTh);
   PrintFormat("  DirCooldown        : %s  consec=%d  lockBars=%d",
               UseDirCooldown?"ON":"OFF", DirCool_Consec, DirCool_LockBars);
   PrintFormat("  ECurveFilter       : %s  window=%d  smaBars=%d",
               UseECFilter?"ON":"OFF", EC_Window, EC_SMABars);
   PrintFormat("  SelfHeal           : %s",          UseSelfHeal?"ON":"OFF");
   PrintFormat("  AuditCSV           : %s  (file %s)",
               (UseAuditCSV && g_AuditFile!=INVALID_HANDLE)?"ON":"OFF", Audit_Filename);
   PrintFormat("  TickVelocity       : %s  minTicks/s=%.1f  window=%d s",
               UseTickVelocity?"ON":"OFF", TickVel_MinPerSec, TickVel_WindowSec);
   PrintFormat("  CostEdgeGate       : %s  maxCostFrac=%.2f",
               UseCostEdgeGate?"ON":"OFF", MaxCostFracOfTP1);
   Print  ("=======================================================");

   // v4.12: loud warning if user input is above the hard ceiling — config drift detector
   if(MaxLotSize > HARD_LOT_CEILING + 0.001) {
      PrintFormat(">>> CONFIG WARNING: MaxLotSize input (%.2f) is ABOVE HARD_LOT_CEILING (%.2f).",
                  MaxLotSize, (double)HARD_LOT_CEILING);
      PrintFormat(">>> Trades will be capped at %.2f lots. To allow higher, edit the const and recompile.",
                  (double)HARD_LOT_CEILING);
      Alert(StringFormat("GV5.2: MaxLotSize=%.2f exceeds hard ceiling %.2f. Trades will cap at ceiling.",
                          MaxLotSize, (double)HARD_LOT_CEILING));
   }

   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| DEINIT (v4.10)                                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   PersistBaseline();   // v4.01: keep day/week baseline across reload
   AuditClose();        // v4.10: close audit CSV

   int rel[]={h_EMA_F,h_EMA_S,h_EMA_T,h_RSI,h_ATR,h_BB,h_ADX,h_MACD,h_Stoch,
              h_EMA_HF,h_EMA_HS,h_MTF_F,h_MTF_S,h_ATR_Long,
              g_HTFBias_EmaF,g_HTFBias_EmaS};
   for(int i=0;i<ArraySize(rel);i++)
      if(rel[i]!=INVALID_HANDLE) IndicatorRelease(rel[i]);

   if(ShowDashboard) RemoveDash();
   PrintFormat("GV5.2 deinit. Reason:%d",reason);
}

//+------------------------------------------------------------------+
//| MAIN TICK (v4.10)                                                |
//+------------------------------------------------------------------+
void OnTick()
{
   // v4.10: tick velocity tracking
   RecordTick();

   // Spread sampling
   double curSpread = (double)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   RecordSpread(curSpread);

   // Day/week reset + circuit breakers
   CheckReset();

   // Per-bar regime / filter updates
   bool newBar = IsNewBar();
   if(newBar) {
      UpdateVolRegime();
      UpdateKalman();
      UpdateHTFBias();
      UpdateHurst();
      CalcVWAP();
   }

   // Manage existing positions (BE, partial TPs, trailing, exits)
   ManageTrades();
   TryPyramid();

   // Signal evaluation
   SignalState sig = GetSignal();
   if(ShowDashboard) UpdateDash(sig);

   // Tick-based entry: only on ultra-high score mid-bar
   bool tickEntry = (sig.score>=HFTTickScore && g_BarsSinceEntry>=MinBarsBetweenEntry);
   if(!newBar && !tickEntry) return;

   // ===== Pre-entry gates (v3.20 + v4.10) =====
   if(!EnableLiveTrading)              return;
   if(!sig.circuitOK)                  return;
   if(!sig.newsOK)                     return;
   if(!sig.spreadOK)                   return;
   if(!sig.pauseOK)                    return;
   if(!sig.heatOK)                     return;
   if(sig.sweepBlocked)                return;
   if(g_DayTrades>=MaxDailyTrades)     return;
   if(CountPos()>=MaxOpenPositions)    return;
   if(!newBar && g_BarsSinceEntry<MinBarsBetweenEntry) return;

   // v4.10 institutional gates
   if(!ECurveAllows())                 return;   // equity curve drift filter
   if(!TickVelocityOK())               return;   // illiquid window
   if(!CostEdgeOK(sig.atr,sig.spread)) return;   // cost-vs-edge

   // Direction-specific gates
   if(sig.bullish) {
      if(!HTFBiasAllows(true))      return;
      if(!DirCooldownAllows(true))  return;
      if(sig.corrBlockBuy)          return;
      if(CountPos((int)POSITION_TYPE_BUY)>=MaxOpenPositions) return;

      // ===== v6.1 BUY-STRICT FILTERS (direction-asymmetric) =====
      // Live report (169 trades, PF 1.57): sells 66.7% WR vs buys 59.3% WR.
      // Apply 3 additional gates for buys ONLY. Sells unchanged.
      if(UseDirectionAsymmetric) {
         if(sig.adx < ADX_MinStrength_Buy) {
            if(VerboseLogging) PrintFormat("GV5.2 BUY BLOCKED: ADX %.1f < BuyMin %.1f",
                                           sig.adx, ADX_MinStrength_Buy);
            return;
         }
         if(Buy_RequireBullHTF && g_HTFBiasDir != +1) {
            if(VerboseLogging) PrintFormat("GV5.2 BUY BLOCKED: HTF not BULL (dir=%d)",
                                           g_HTFBiasDir);
            return;
         }
         if(Buy_RequireTrendHurst && g_HurstRegime != "TREND") {
            if(VerboseLogging) PrintFormat("GV5.2 BUY BLOCKED: Hurst not TREND (regime=%s)",
                                           g_HurstRegime);
            return;
         }
      }
      // ===== END v6.1 BUY-STRICT =====

      ulong t=0;
      if(OpenTrade(true,sig.atr,sig,t,0)) {
         g_LastBuyTime = TimeCurrent();
         PrintFormat("GV5.2 BUY [%s] Score:%d/%d Tick:%s HTF:%d Hurst:%.2f",
                     sig.strategy,sig.score,sig.requiredScore,
                     newBar?"no":"YES",g_HTFBiasDir,g_Hurst);
      }
   } else if(sig.bearish) {
      if(!HTFBiasAllows(false))     return;
      if(!DirCooldownAllows(false)) return;
      if(sig.corrBlockSell)         return;
      if(CountPos((int)POSITION_TYPE_SELL)>=MaxOpenPositions) return;
      ulong t=0;
      if(OpenTrade(false,sig.atr,sig,t,0)) {
         g_LastSellTime = TimeCurrent();
         PrintFormat("GV5.2 SELL [%s] Score:%d/%d Tick:%s HTF:%d Hurst:%.2f",
                     sig.strategy,sig.score,sig.requiredScore,
                     newBar?"no":"YES",g_HTFBiasDir,g_Hurst);
      }
   }
}

//+------------------------------------------------------------------+
//| TRADE TRANSACTION (v4.10)                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest     &request,
                        const MqlTradeResult      &result)
{
   if(trans.type!=TRADE_TRANSACTION_DEAL_ADD) return;
   if(trans.deal_type!=DEAL_TYPE_BUY && trans.deal_type!=DEAL_TYPE_SELL) return;
   if(!HistoryDealSelect(trans.deal)) return;
   if((ulong)HistoryDealGetInteger(trans.deal,DEAL_MAGIC)!=Magic) return;

   ENUM_DEAL_ENTRY entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
   if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_INOUT) return;

   double profit = HistoryDealGetDouble(trans.deal,DEAL_PROFIT)
                  +HistoryDealGetDouble(trans.deal,DEAL_SWAP)
                  +HistoryDealGetDouble(trans.deal,DEAL_COMMISSION);
   double price  = HistoryDealGetDouble(trans.deal,DEAL_PRICE);
   double vol    = HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
   ulong  ticket = (ulong)HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);
   ENUM_DEAL_TYPE dt = (ENUM_DEAL_TYPE)HistoryDealGetInteger(trans.deal,DEAL_TYPE);
   // closing deal type is opposite of original position direction, so:
   bool wasBuy = (dt == DEAL_TYPE_SELL);   // closing SELL deal = was a BUY position

   g_DayPnL += profit;

   // v3.20 consecutive-loss tracking
   if(profit<0) {
      g_ConsecLoss++; g_ConsecWin=0;
      PrintFormat("GV5.2: Loss $%.2f | Consec:%d/%d",profit,g_ConsecLoss,MaxConsecLosses);
      if(g_ConsecLoss>=MaxConsecLosses && !g_LossPause) {
         g_LossPause=true; g_PauseBars=LossCooldown;
         PrintFormat("GV5.2: Loss pause %d bars.",LossCooldown);
      }
   } else if(profit>0) {
      g_ConsecWin++; g_ConsecLoss=0;
      if(g_LossPause){
         g_LossPause=false; g_PauseBars=0;
         Print("GV5.2: Pause cleared by winner.");
      }
   }

   // v4.10 recordings
   RecordTradePnL(profit);        // Kelly window
   RecordEquityPoint(profit);     // EC filter
   RecordDirOutcome(wasBuy,profit); // Direction-aware cooldown

   // v4.11+v4.16: look up MAE/MFE + exit reason + effective risk % from cache
   double maeR=0.0, mfeR=0.0, effRisk=0.0;
   string exitReason = "";
   FindMaeMfe(ticket, maeR, mfeR, exitReason, effRisk);
   EmitMaeMfeHint(ticket, profit, maeR, mfeR, wasBuy);

   // v4.10 audit CSV close event
   if(UseAuditCSV && Audit_LogTrades) {
      AuditWrite("CLOSE", ticket, wasBuy?"BUY":"SELL", "",
                 0, 0, 0.0, 0.0, vol, price, 0.0, 0.0, profit,
                 maeR, mfeR,
                 exitReason, effRisk);           // v4.16
   }

   // Persist baseline opportunistically (cheap GlobalVar write)
   PersistBaseline();
}

//+------------------------------------------------------------------+
//| v4.13 STRATEGY TESTER — INSTITUTIONAL METRICS                    |
//|  Runs only inside MT5's Strategy Tester. Walks the full deal     |
//|  history of the test run, computes desk-grade statistics, prints |
//|  a single report to the Experts log, and returns a composite     |
//|  optimization criterion (used by Strategy Tester optimization).  |
//+------------------------------------------------------------------+
double OnTester()
{
   if(!HistorySelect(0, TimeCurrent())) return 0.0;

   int    deals = HistoryDealsTotal();
   double grossWin = 0, grossLoss = 0;
   int    nWin = 0, nLoss = 0, nTrades = 0;
   double biggestWin = 0, biggestLoss = 0;
   int    consecLoss = 0, maxConsecLoss = 0;
   double peakEquity = AccountInfoDouble(ACCOUNT_BALANCE);
   double curEquity  = peakEquity;
   double maxDD = 0;

   double sessionPnL[4]   = {0,0,0,0};
   int    sessionTrades[4]= {0,0,0,0};
   string sessionName[4]  = {"Asia","London","NY","Late"};

   for(int i=0; i<deals; i++) {
      ulong did = HistoryDealGetTicket(i);
      if(did==0) continue;
      if((ulong)HistoryDealGetInteger(did, DEAL_MAGIC) != Magic) continue;
      ENUM_DEAL_ENTRY entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(did, DEAL_ENTRY);
      if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_INOUT && entry!=DEAL_ENTRY_OUT_BY)
         continue;

      double p = HistoryDealGetDouble(did, DEAL_PROFIT)
               + HistoryDealGetDouble(did, DEAL_SWAP)
               + HistoryDealGetDouble(did, DEAL_COMMISSION);
      datetime t = (datetime)HistoryDealGetInteger(did, DEAL_TIME);
      MqlDateTime mdt; TimeToStruct(t, mdt);
      int sIdx = (mdt.hour<7)?0:((mdt.hour<12)?1:((mdt.hour<17)?2:3));

      nTrades++;
      sessionPnL[sIdx]    += p;
      sessionTrades[sIdx] += 1;
      curEquity += p;
      if(curEquity > peakEquity) peakEquity = curEquity;
      double dd = peakEquity - curEquity;
      if(dd > maxDD) maxDD = dd;

      if(p > 0) {
         grossWin += p; nWin++;
         if(p > biggestWin) biggestWin = p;
         consecLoss = 0;
      } else if(p < 0) {
         grossLoss += -p; nLoss++;
         if(-p > biggestLoss) biggestLoss = -p;
         consecLoss++;
         if(consecLoss > maxConsecLoss) maxConsecLoss = consecLoss;
      }
   }

   double netPnL    = grossWin - grossLoss;
   double winRate   = (nTrades>0)? (100.0*nWin/nTrades) : 0;
   double avgWin    = (nWin>0)?  grossWin / nWin   : 0;
   double avgLoss   = (nLoss>0)? grossLoss / nLoss : 0;
   double pf        = (grossLoss>0)? grossWin / grossLoss : (grossWin>0?999.0:0);
   double expect    = (nTrades>0)? netPnL / nTrades : 0;
   double rr        = (avgLoss>0)? avgWin / avgLoss : 0;
   double finalBal  = AccountInfoDouble(ACCOUNT_BALANCE);
   double startBal  = finalBal - netPnL;
   double ddPct     = (peakEquity>0)? (100.0*maxDD/peakEquity) : 0;

   Print  ("================ GV5.2 TESTER REPORT ================");
   PrintFormat("  Net PnL          : $%.2f   (start $%.2f  -> end $%.2f)", netPnL, startBal, finalBal);
   PrintFormat("  Trades           : %d  (wins %d / losses %d)", nTrades, nWin, nLoss);
   PrintFormat("  Win rate         : %.1f %%",  winRate);
   PrintFormat("  Profit factor    : %.2f",     pf);
   PrintFormat("  Expectancy       : $%.2f per trade", expect);
   PrintFormat("  Avg win / loss   : $%.2f / $%.2f   (R:R %.2f)", avgWin, avgLoss, rr);
   PrintFormat("  Biggest win/loss : $%.2f / -$%.2f", biggestWin, biggestLoss);
   PrintFormat("  Max drawdown     : $%.2f  (%.2f %% of peak)", maxDD, ddPct);
   PrintFormat("  Max consec loss  : %d trades", maxConsecLoss);
   Print  ("  --- By session (server time) ---");
   for(int s=0; s<4; s++) {
      PrintFormat("    %-6s : %4d trades   PnL $%.2f", sessionName[s], sessionTrades[s], sessionPnL[s]);
   }
   Print  ("=======================================================");

   double tradesFactor = MathSqrt(MathMax(1.0, (double)nTrades));
   double crit = (netPnL > 0)
                 ? (netPnL * pf * tradesFactor) / (1.0 + ddPct)
                 : netPnL;
   return crit;
}

//+------------------------------------------------------------------+
//| END — Gold V5 LNY v5.0 (forked from Gold V4 MT5 v4.19)           |
//+------------------------------------------------------------------+