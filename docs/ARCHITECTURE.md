# System Architecture

## Design Philosophy

Every design decision in this system follows one principle: **make it impossible to lose more than you can afford**. Signal quality is subordinate to risk management; risk management is subordinate to institutional-grade safety invariants.

The system follows a layered defense model inspired by hedge-fund risk frameworks, retail-adapted for MT5.

---

## High-Level Component View

```
┌──────────────────────────────────────────────────────────┐
│                     MT5 TERMINAL                          │
│  ┌──────────────────────────────────────────────────┐    │
│  │                  SIGNAL ENGINE                    │    │
│  │  ┌────────┐ ┌──────────┐ ┌──────────┐            │    │
│  │  │ TREND  │ │REVERSION │ │BREAKOUT  │            │    │
│  │  └────────┘ └──────────┘ └──────────┘            │    │
│  │                                                   │    │
│  │  Confluence Scorer (0-8 points)                   │    │
│  │  Strategy Router (regime-based)                   │    │
│  └──────────────────────────────────────────────────┘    │
│                       │                                   │
│                       ▼                                   │
│  ┌──────────────────────────────────────────────────┐    │
│  │                MASTER FILTERS (12 gates)          │    │
│  │  Session | News | Spread | HTF Bias | Hurst |    │    │
│  │  ADX | ATR Regime | Tick Velocity | Cost Gate |   │    │
│  │  Direction Cooldown | EC Filter | Correlation    │    │
│  └──────────────────────────────────────────────────┘    │
│                       │                                   │
│                       ▼                                   │
│  ┌──────────────────────────────────────────────────┐    │
│  │              RISK & SIZING ENGINE                 │    │
│  │  Kelly Fractional | DynamicRiskMult |             │    │
│  │  HARD_LOT_CEILING | Portfolio Heat Cap            │    │
│  └──────────────────────────────────────────────────┘    │
│                       │                                   │
│                       ▼                                   │
│  ┌──────────────────────────────────────────────────┐    │
│  │               EXECUTION LAYER                     │    │
│  │  Retry logic | Slippage guard | Self-heal         │    │
│  └──────────────────────────────────────────────────┘    │
│                       │                                   │
│                       ▼                                   │
│  ┌──────────────────────────────────────────────────┐    │
│  │              EXIT MANAGEMENT                      │    │
│  │  ATR-based SL | Chandelier Trail |                │    │
│  │  Time Exit | Exhaustion Exit                      │    │
│  └──────────────────────────────────────────────────┘    │
│                       │                                   │
│                       ▼                                   │
│  ┌──────────────────────────────────────────────────┐    │
│  │           CIRCUIT BREAKERS (safety nets)          │    │
│  │  Daily -3% | Weekly -6% | Consec Loss Pause       │    │
│  │  Direction Lock | News Blackout                   │    │
│  └──────────────────────────────────────────────────┘    │
│                       │                                   │
│                       ▼                                   │
│  ┌──────────────────────────────────────────────────┐    │
│  │          AUDIT & TELEMETRY LAYER                  │    │
│  │  MAE/MFE tracking | Exit reason classification    │    │
│  │  23-column CSV | OnTester() report | Dashboard    │    │
│  └──────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────┘
```

---

## The Two Bots

### GoldV4 Asia Bot

**Purpose:** Capture the late-NY-close to early-Tokyo-open institutional handoff on XAUUSD.

| Setting | Value | Rationale |
|---|---|---|
| Trading window (broker) | 00:00 - 03:00 | Peak late-NY-close microstructure |
| ADX_MinStrength | 25 | Lower threshold acceptable given tight session |
| ATR_SL_Mult | 1.75 | Tighter stops suitable for Asia's compressed ranges |
| Trail_ActivateATR | 1.0 | Earlier trail activation |
| Chandelier_ATR_Mult | 2.5 | Classical chandelier distance |
| UsePartialTP | false | Trail-only concentrates winners |
| UseBEStop | false | BE stops proved to cut winners early |

**Backtest performance (6 months):** PF 1.44, max DD 6.39%, +107% net.

### GoldV5 LNY Bot (London/NY, London-only in production)

**Purpose:** Capture London open volatility surge on XAUUSD.

| Setting | Value | Rationale |
|---|---|---|
| Trading window (broker) | 08:00 - 10:00 | Peak London-open edge concentration |
| ADX_MinStrength | 30 | Higher threshold required for LNY noise filtering |
| ATR_SL_Mult | 2.25 | Wider stops for LNY volatility |
| Trail_ActivateATR | 1.5 | Later activation to accommodate wider moves |
| TradeNewYork | **false** | Backtest showed NY hours losing (-$425/trade avg) |
| TradeOverlap | **false** | Overlap period = chop zone |
| London_End | **10** (not 12) | Edge concentrated in first 2 hours |

**Backtest performance (6 months):** PF 1.18, max DD 18.65%, +46% net.

### Isolation Mechanism

Both bots can run simultaneously on the same account with zero interference:

| Resource | GoldV4 | GoldV5 |
|---|---|---|
| Magic number | 202600400 | 202600500 |
| EA_Comment tag | "GV4" | "GV5" |
| GlobalVariable prefix | GV4_ | GV5_ |
| Audit CSV | GoldV4_audit.csv | GoldV5_LNY_audit.csv |
| Dashboard header | "GOLD V4 MT5 \| INSTITUTIONAL" | "GOLD V5 LNY \| LONDON/NY" |
| Log prefix | GV4.XX: | GV5.X: |

---

## Signal Engine Deep-Dive

### Strategy Router

Three parallel strategies evaluate every bar:

1. **TREND** — EMA alignment + MACD + ADX + VWAP position
2. **REVERSION** — RSI extremes + VWAP distance + Bollinger behavior
3. **BREAKOUT** — Volatility expansion + SMC concepts + range breaks

The **Hurst Exponent** regime classifier (M5, 100 bars) routes which strategies are allowed:
- Hurst > 0.55 → TREND strategies enabled
- Hurst < 0.45 → REVERSION strategies enabled
- 0.45 < Hurst < 0.55 → **RANDOM** regime, no entries

### Confluence Scoring

Each candidate signal evaluates 8 signal factors, awarding 0-1 points each. Entry requires score ≥ 7/8 AND all 12 master gates to pass.

The session-adaptive scoring adjustment makes some sessions more selective:
- Asia session: +1 confluence required (higher conviction)
- London: baseline
- LDN/NY Overlap: -1 (allow slightly looser)

---

## Risk & Position Sizing

### Kelly Fractional Sizing

- Rolling 30-trade window computes empirical win rate + R:R
- Full Kelly fraction computed, then multiplied by 0.25 (quarter-Kelly) for safety
- Clipped to [MinMultiplier, MaxMultiplier] = [0.35, 1.50]
- Resulting multiplier applied to base `RiskPercent` (1.0%)

### DynamicRiskMult Throttle

Cascading dampers after adverse events:

| Trigger | Multiplier |
|---|---|
| 2 consecutive losses | 0.60× |
| 3 consecutive losses | 0.40× |
| 4 consecutive losses | 0.20× |
| Intraday DD -3% | 0.65× |
| Intraday DD -6% | 0.40× |

Multiplicative stacking with floor at 0.15× of base risk.

### HARD_LOT_CEILING

**Compile-time constant.** Cannot be modified by user inputs. The `OpenTrade()` function has a kill-switch that **refuses** any order exceeding this value (not caps — refuses). Defense-in-depth against configuration drift bugs.

---

## Execution Layer

- **BaseSlippage** guard (30 points default)
- **RetryDelayMs** between failed attempts
- **MaxRetryAttempts** = 3 before giving up
- **Self-heal on OnInit** — rebuilds internal `g_Trades[]` state from broker's existing positions by Magic number (crash/reload recovery)

---

## Exit Management

**Trail-only exit philosophy** (Path C discovery): partial TPs cap winners while losses still take full 1R. The winning configuration uses:

1. Initial SL at `entry ∓ (ATR_SL_Mult × ATR)`
2. Trail activates when profit reaches `Trail_ActivateATR × ATR`
3. **Chandelier trail** follows highest high / lowest low minus `Chand_ATR_Mult × ATR`
4. Position closes when trail hits
5. Time exit: max 30 bars for losing trades (`UseTimeExit`)
6. Exhaustion exit: RSI extreme + price stall

Exit reason classified for every trade: `SL_LIKELY`, `TRAIL_HIT`, `TIME_EXIT`, `EXHAUST_EXIT`, `AFTER_TP1`, `AFTER_TP2`, `BE_STOP`.

---

## Circuit Breakers

| Breaker | Trigger | Action |
|---|---|---|
| **Daily Loss** | DayPnL% ≤ -3% | No new entries today |
| **Weekly Loss** | WeekPnL% ≤ -6% | No new entries this week |
| **Direction Cooldown** | 3 consec same-direction losses | Lock that direction for 10 bars |
| **Loss Pause** | 3 consec losses (any direction) | Pause all entries 5 bars |
| **News Blackout** | High-impact event within window | Block ±30 min around event |
| **EC Filter** | 20-trade EC below 5-SMA | Pause until EC recovers |

**On day rollover:** All stuck-state counters reset (DD counter, direction lock bars, pause bars, consec loss counter). Daily reset is the system's "fresh start" guarantee.

---

## Audit Trail

Every trade generates a 23-column CSV row:

```
time, event, ticket, dir, strategy, score, reqScore, atr, spread, volReg,
htfBias, hurst, ecBlk, tickVel, lots, price, sl, tp, pnl, mae_R, mfe_R,
exit_reason, eff_risk_pct
```

**MAE (Maximum Adverse Excursion)** and **MFE (Maximum Favorable Excursion)** are tracked in R-multiples (1R = ATR × ATR_SL_Mult), enabling institutional-grade trade quality analysis.

**OnTester()** returns a composite score for Strategy Tester optimization:

```
score = NetProfit × log(TradeCount) / (MaxDD × (1 + ConsecLosses/10))
```

---

## Dashboard

Real-time status visualization on chart (18 lines):

```
GOLD V4 MT5 v4.21 | INSTITUTIONAL
[6/8] WAIT [TREND] | ADX: 32.1 VWAP: 2341.56
Reg: STRONG BULL/MID SPREAD: 18.0 / med 22.0 [OK]
SESSION: Asian ATR: 1.2345 Lat: 45 ms
HTF BIAS: BULL HURST: 0.62 [TREND] DIR-COOL: CLEAR
EQ-CURVE: OK Trades: 3 TICK-VEL: 4.2/s
EQUITY: $100000.00 DAY P&L: +$125.00 (+0.13%)
TRADES: 3/18 Open: 1/5 HEAT: 0.85% / cap 3.50%
RISK: NORMAL 1.0% Kelly x1.00 LOSSES: 0 consec / 3 max
NEWS: CLEAR SYSTEM: ACTIVE AUDIT: LOGGING
MAE: -0.23R / MFE: +0.78R (n=3) Magic: 202600400 v4.21
```

Color-coded (green = healthy, red = alert, gray = inactive).

---

## Scalability Notes

The two-bot architecture is a template for scaling. Adding a third bot (e.g., XAUUSD Overlap trader or EURUSD Asia) requires:

1. Fork existing source → new filename
2. Change Magic number
3. Change EA_Comment
4. Change GlobalVariable prefix
5. Change audit CSV filename
6. Set session + indicator defaults for new window
7. Walk-forward validate before deployment

No shared mutable state means isolation is guaranteed by construction.
