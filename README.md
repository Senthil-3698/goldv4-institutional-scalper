# GoldV4 Institutional Scalper

> Dual-strategy institutional-grade algorithmic trading system for XAUUSD M1 scalping on MetaTrader 5.

![Language](https://img.shields.io/badge/language-MQL5-blue)
![Platform](https://img.shields.io/badge/platform-MetaTrader%205-orange)
![Status](https://img.shields.io/badge/status-live%20demo%20validated-green)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

---

## 🎯 Overview

A production-grade quantitative trading system developed as a personal research project. Combines **two independent strategies** targeting different market microstructures on gold (XAUUSD) M1 timeframe, deployed simultaneously on the same account with isolated state management.

- **GoldV4 Asia Bot** — captures the late-NY-to-Tokyo institutional handoff (broker hours 00:00-03:00)
- **GoldV5 LNY Bot** — captures London open volatility surge (broker hours 08:00-10:00)

Built from first principles with ~6,000 lines of MQL5 code, 30+ backtest iterations, walk-forward validation methodology, and 4 weeks of live demo paper trading.

---

## 📊 Headline Results

### Backtest (6 months tick-level real data, Jan–Jun 2026)

| Strategy | Profit Factor | Net Return | Max Drawdown | Trades | Win Rate |
|---|---|---|---|---|---|
| **GoldV4 Asia** | **1.44** | +107% | 6.39% | 1,146 | 49.1% |
| **GoldV5 London** | **1.18** | +46% | 18.65% | 925 | 53.5% |
| **Combined** | ~1.30 | ~+150% | ~20% | ~2,071 | ~51% |

### Live Demo Paper Trading (4 weeks, 169 trades)

| Metric | Value | Benchmark |
|---|---|---|
| Profit Factor | **1.57** | Production threshold: >1.20 |
| Win Rate | **61.5%** | Target: 55-65% |
| Expectancy | **+$67/trade** | Positive = profitable |
| Recovery Factor | **1.49** | Target: >1.0 |
| Max Consec Loss | 10 | Within tolerance |

**Live performance exceeded backtest by 33%** — strong signal that the strategy generalizes well.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                MT5 Terminal (Local or VPS)                   │
│                                                              │
│  ┌──────────────────┐         ┌──────────────────┐         │
│  │   Chart A         │         │   Chart B         │         │
│  │   XAUUSD M1       │         │   XAUUSD M1       │         │
│  │                   │         │                   │         │
│  │   EA: GoldV4      │         │   EA: GoldV5_LNY  │         │
│  │   Magic: 400      │         │   Magic: 500      │         │
│  │   Session: Asia   │         │   Session: London │         │
│  └──────────────────┘         └──────────────────┘         │
│           │                              │                   │
│           ▼                              ▼                   │
│  ┌──────────────────────────────────────────────────┐      │
│  │           SHARED SAFETY LAYER                     │      │
│  │  (each bot enforces independently)                │      │
│  └──────────────────────────────────────────────────┘      │
│                                                              │
│  ┌──────────────────────────────────────────────────┐      │
│  │              AUDIT TRAIL LAYER                    │      │
│  │  GoldV4_audit.csv    │    GoldV5_LNY_audit.csv   │      │
│  └──────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │  MT5 Broker    │
                    │  Server        │
                    └────────────────┘
```

**Isolation guarantees:** Different Magic numbers, EA comment tags, GlobalVariable prefixes, and audit CSV filenames ensure the two bots never interfere with each other's state or positions.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for full architectural details.

---

## 🧠 Signal Engine

Multi-strategy router with **three parallel strategies** (Trend / Reversion / Breakout) and an 8-point confluence scoring system across 15+ filters:

| Filter | Purpose |
|---|---|
| **HTF Bias** | M15 EMA slope agreement required |
| **Hurst Exponent** | Regime classifier (trending vs mean-reverting vs random) |
| **ADX** | Trend strength (threshold 25-30) |
| **ATR percentile** | Volatility regime routing |
| **VWAP** | Institutional benchmark alignment |
| **Smart Money Concepts** | Order Block, FVG, Liquidity Sweep detection |
| **Tick Velocity Gate** | Rejects illiquid windows |
| **Cost-vs-Edge Gate** | Rejects when spread erodes expected edge |
| **Session Filter** | Session-adaptive confluence thresholds |
| **News Blackout** | Blocks 30 min pre/post high-impact news |
| **Direction Cooldown** | Locks direction after N consecutive losses |
| **Equity Curve Filter** | Pauses entries during drawdown streaks |
| **HTF Correlation Guard** | USD-strength-based entry filter |
| **Portfolio Heat Manager** | Caps combined open R% at 3.5% |
| **Anti-cluster Filter** | Minimum bars between same-direction entries |

Entry requires score ≥ 7/8 AND all 12 master gates to pass simultaneously.

---

## 🛡️ Safety Infrastructure

**12-layer institutional risk framework:**

1. **HARD_LOT_CEILING** — compile-time immutable lot cap (defense-in-depth)
2. **Kelly Fractional Sizing** — rolling 30-trade adaptive position sizing
3. **DynamicRiskMult** — throttles risk after consecutive losses and intraday drawdown
4. **Daily Circuit Breaker** — halts entries at -3% daily loss
5. **Weekly Circuit Breaker** — halts entries at -6% weekly loss
6. **Direction Cooldown** — locks direction after 3 consecutive same-direction losses
7. **Equity Curve Filter** — pauses when 20-trade EC drops below 5-trade SMA
8. **MaxOpenPositions** — caps concurrent exposure (default 5)
9. **Portfolio Heat Cap** — total R% exposure limit (3.5%)
10. **Anti-cluster Filter** — minimum bars between same-direction entries
11. **Self-healing Recovery** — rebuilds internal state from broker on crash/reload
12. **Spread/Latency Gates** — rejects fills when execution conditions degrade

---

## 🔬 Validation Methodology

**Progressive validation from backtest → walk-forward → live:**

1. **Backtest** — 6-month tick-level real data (Strategy Tester, "Every tick based on real ticks")
2. **Iterative tuning** — 30+ documented iterations with per-change hypothesis + result
3. **Walk-forward validation** — Train on Jan-Apr, out-of-sample test May-Jun
4. **Live demo paper trading** — 4 weeks real-market execution, real spreads, real slippage
5. **MAE/MFE audit trail** — Per-trade adverse/favorable excursion in R-multiples
6. **OnTester() institutional report** — Composite scoring for parameter sweeps

See [docs/METHODOLOGY.md](docs/METHODOLOGY.md) for the full validation protocol.

---

## 📁 Repository Structure

```
goldv4-institutional-scalper/
├── README.md                     # You are here
├── LICENSE                       # MIT
├── .gitignore                    # MQL5-specific ignores
├── docs/
│   ├── ARCHITECTURE.md          # System design deep-dive
│   ├── METHODOLOGY.md           # Validation protocol
│   ├── RESULTS.md               # Detailed backtest + live results
│   └── SYSTEM_REFERENCE.md      # Full technical reference
├── src/
│   ├── GoldV4_MT5.mq5           # Asia bot (v4.21)
│   └── GoldV5_LNY.mq5           # London bot (v5.2)
└── backtests/
    └── README.md                 # Backtest screenshots directory
```

---

## 💻 Technology Stack

- **MQL5** (MetaQuotes Language 5) — primary development language
- **MetaTrader 5** — execution platform
- **Strategy Tester** — tick-level backtesting engine
- **Smart Money Concepts** — institutional order flow analysis
- **Quantitative risk management** — Kelly criterion, equity curve filtering, dynamic drawdown throttling

---

## 📥 Installation & Usage

### Prerequisites
- MetaTrader 5 (build 6000+)
- A broker with XAUUSD symbol and tick history (MetaQuotes-Demo works)
- **Hedge** account mode (not Netting — the bots open multiple simultaneous positions)

### Compile & deploy

1. Copy `src/GoldV4_MT5.mq5` and `src/GoldV5_LNY.mq5` to your MT5 `MQL5\Experts\` directory
2. Open MetaEditor → open each file → press **F7** to compile
3. Verify "0 errors, 0 warnings" in output pane
4. Open two XAUUSD M1 charts in MT5
5. Drag `GoldV4_MT5` onto Chart A, `GoldV5_LNY` onto Chart B
6. Click "Reset" in inputs dialog to load production defaults (Path H for v4, Path D for v5)
7. Enable "Algo Trading" in MT5 toolbar
8. Verify both dashboards show `SYSTEM: ACTIVE` and `AUDIT: LOGGING`

### Backtest

1. Open Strategy Tester (Ctrl+R)
2. Select Expert, Symbol = XAUUSD, Timeframe = M1
3. Date range: 6-month window of your choice
4. Model: **"Every tick based on real ticks"**
5. Click Start → review `GV4.XX TESTER REPORT` in Journal

---

## 🎓 Lessons Learned

- **Signal engineering is 20% of the problem; exit structure and risk management are 80%.** The biggest performance jumps came from refining exits (Path C trail-only breakthrough), not from improving entries.
- **Backtest optimization has sharp diminishing returns.** Beyond Path H / Path D, every attempted "improvement" (v6.0 partial TPs, v6.1 direction-asymmetric filters) made results worse. Simple, well-tuned strategies outperform "improved" complex ones.
- **Walk-forward validation is non-negotiable.** Several configurations looked excellent on full-period backtest but failed in out-of-sample windows. Train/test discipline exposed the real edge.
- **Market regime matters enormously.** The same strategy produced +$107K across 4 months and -$10K across the next 2 months. Safety systems containing drawdown during adverse regimes is more important than peak returns during favorable ones.
- **Discipline > activity.** On many trading days the bots do nothing. Skipping choppy markets preserves the edge for trending ones.
- **Institutional-grade means layered, not clever.** 12 independent safety layers each handling one failure mode is more robust than one brilliant algorithm.

---

## 🔮 Future Work

- VPS deployment for 24/7 uptime (eliminating missed Asia session trades)
- Multi-symbol expansion (silver, major FX pairs)
- Python/ZeroMQ bridge for ML-based regime detection
- Real-time telemetry dashboard (web-based performance monitor)
- Walk-forward optimization harness
- Monte Carlo synthetic data validation

---

## ⚠️ Disclaimer

This is a **personal quantitative research and portfolio project**. All results presented are from **backtest simulation** and **live demo (paper) trading**. No real capital has been deployed.

- Not financial advice
- Past performance does not guarantee future results
- Algorithmic trading involves substantial risk of loss
- Backtest and demo results may not translate to live profitability
- Use entirely at your own risk

---

## 📄 License

MIT License — see [LICENSE](LICENSE).

You are welcome to study, fork, or adapt this code for your own research. Attribution appreciated but not required.

---

## 📧 Contact

Questions, feedback, or collaboration interest welcome. Open an issue on this repository.

---

**⭐ If this project helped you learn something about systematic trading, consider starring the repo.**
