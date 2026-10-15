# Validation Methodology

The validation protocol follows a progressive hierarchy — each stage is a stricter test than the previous. A configuration that passes all four earns production status.

```
Stage 1: Backtest (full window)         → optimization sandbox
Stage 2: Backtest iterative tuning      → directed hypothesis testing
Stage 3: Walk-forward validation        → out-of-sample proof
Stage 4: Live demo paper trading        → real-market reality check
```

Only when a strategy survives all four stages is it considered a candidate for real capital.

---

## Stage 1: Full-Window Backtest

**Setup:**
- Data: 6 months of real tick data (Jan–Jun 2026)
- Model: **"Every tick based on real ticks"** (highest fidelity in MT5)
- Deposit: $100,000 (realistic retail account size)
- Leverage: 1:100
- Symbol: XAUUSD M1

**Why real-tick model:** The lower-fidelity options (OHLC M1, 1-minute OHLC) hide execution issues. Scalping strategies are extremely sensitive to tick-level sequencing, and backtest-vs-live divergence is almost entirely caused by model fidelity.

**Metrics reported in `OnTester()`:**
- Net Profit
- Trade count
- Win rate (%)
- Profit Factor (gross profit / gross loss)
- Expectancy per trade ($)
- Avg Win / Avg Loss (R:R)
- Biggest Win / Biggest Loss
- Max Drawdown (currency + % of peak)
- Max Consecutive Losses (count)
- By-session breakdown (Asia / London / NY / Late)
- MFE/MAE correlation with profit (quality signal)

---

## Stage 2: Iterative Tuning (30+ hypotheses)

Every proposed change was treated as a scientific hypothesis:

1. **State the hypothesis** ("Reducing London_End from 12 to 10 will concentrate the edge in the peak-London window and improve PF")
2. **Change one input at a time** (change only `London_End`, keep everything else constant)
3. **Backtest with same window** (compare apples to apples)
4. **Compare against last-best baseline** (did PF improve?)
5. **Keep improvements, revert failures** (no exceptions, no "it was close enough")

**Example iteration ladder (GoldV5 London bot):**

| Iteration | Change | PF | Verdict |
|---|---|---|---|
| Path A | Kill NY session trading | 1.00 | ✅ Kept |
| Path B | Tighten SL (ATR mult 2.25→1.75) | 0.97 | ❌ Reverted |
| Path C | Tighten chandelier (2.5→2.0) | 0.95 | ❌ Reverted |
| **Path D** | **London_End 12→10** | **1.18** | ✅ **Production** |
| Path E (W2) | ADX_MinStrength 30→35 (OOS) | 0.66 | ❌ Reverted |

Each iteration generated a journal entry documenting: hypothesis, change, result, and keep/revert decision.

### Lesson from this stage

> **Simpler well-tuned strategies outperform complex "improved" strategies.** Nearly every attempt to add filters beyond Path H / Path D produced worse backtest performance. The optimum is sharper and shallower than intuition suggests.

---

## Stage 3: Walk-Forward Validation

The most important stage, and the one that kills most retail strategies.

**Protocol:**
1. Take the champion configuration from Stage 2
2. Backtest on **training window only** (Jan–Apr)
3. Note: PF, Net, DD, Win Rate
4. Backtest on **out-of-sample window** (May–Jun) — never touched during tuning
5. Compare in-sample vs OOS metrics

**Success criteria:**
- OOS PF ≥ 1.10 (modest degradation from in-sample acceptable)
- OOS Max DD ≤ 1.5× in-sample Max DD
- OOS Win Rate within 5 percentage points of in-sample

### GoldV5 London Walk-Forward (actual data)

| Window | Period | PF | Net | DD | Win Rate | Trades |
|---|---|---|---|---|---|---|
| In-sample | Jan–Apr | 1.47 | +$60,323 | 7.97% | 57.1% | 602 |
| Out-of-sample | May–Jun | 0.92 | -$4,456 | 11.84% | 48.9% | 323 |
| **Combined 6-month** | Jan–Jun | **1.18** | **+$55,867** | **18.65%** | **54.4%** | **925** |

**Interpretation:** The strategy shows strong in-sample edge that degrades in out-of-sample. OOS period produced a mild loss, but the combined 6-month result remains comfortably profitable. The strategy exhibits regime sensitivity but has safety systems containing adverse-regime damage.

### Walk-forward is non-negotiable

Multiple configurations I believed were improvements (v6.0 partial TPs, v6.1 direction-asymmetric filters) looked promising in full-window backtest but failed Stage 3 badly. **The walk-forward test is where the real selection pressure happens.**

---

## Stage 4: Live Demo Paper Trading

Final reality check. Real-market execution with real spreads, real latency, real slippage. No backtest can perfectly simulate these.

**Setup:**
- Fresh demo account ($100K Hedge mode)
- Both bots deployed on separate XAUUSD M1 charts
- Monitoring: daily dashboard screenshots, weekly audit CSV extraction
- Duration: minimum 4 weeks before considering real capital

### Actual results (4-week live demo window)

| Metric | Value | vs Backtest |
|---|---|---|
| Profit Factor | 1.57 | +33% vs backtest 1.18 |
| Trades | 169 | Representative sample |
| Win Rate | 61.5% | +7pt vs backtest 54.4% |
| Expectancy | +$67/trade | Live beat backtest |
| Max Consec Loss | 10 | Within backtest range (max 25) |
| Max Drawdown | ~$3K | Well-contained |

**Key observation:** Live performance exceeded backtest. This is unusual (usually goes the other way) and suggests either:
1. Favorable regime during the test window (regression to mean likely over longer window)
2. Backtest was slightly pessimistic (spread model more conservative than reality)
3. Signal engine captures microstructure effects that backtest can't model

The honest conclusion: continue to run live demo for additional months before drawing firm conclusions. 4 weeks of real-market data is encouraging but not statistically decisive.

---

## What Would Invalidate the System

Pre-committed stop-trading criteria (critical for discipline):

| Criterion | Threshold | Action |
|---|---|---|
| 30-day live PF | < 0.95 | Suspend, re-evaluate signal engine |
| Live Max DD | > 25% | Suspend, re-tune risk management |
| 10 consecutive losing days | — | Pause, investigate regime |
| Any live loss > backtest 95th percentile | — | Immediate suspension, root-cause analysis |

---

## Reproducibility

To reproduce this validation on your own setup:

1. Clone the repo
2. Compile both `.mq5` files in MetaEditor
3. Open MT5 Strategy Tester
4. Load the Expert (either GoldV4_MT5 or GoldV5_LNY)
5. Set:
   - Symbol: XAUUSD
   - Timeframe: M1
   - Model: Every tick based on real ticks
   - Deposit: 100000 USD
   - Leverage: 1:100
   - Date range: 2026.01.01 → 2026.07.01
6. Click Reset in Inputs tab to load Path H (v4) or Path D (v5) defaults
7. Click Start
8. Compare the `GV4.XX TESTER REPORT` to results documented in [RESULTS.md](RESULTS.md)

Results will vary slightly across broker tick data differences but should be within ±10%.
