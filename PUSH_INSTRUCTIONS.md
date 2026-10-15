# How to Push This Repo to GitHub

Follow these steps to make your project public and resume-ready.

---

## Prerequisites

- GitHub account (if you don't have one: https://github.com/signup)
- Git installed on your PC (if you don't have it: https://git-scm.com/download/win)

Open PowerShell and verify git is installed:
```powershell
git --version
```

Should show something like `git version 2.42.0.windows.2`. If not, install git first.

---

## Step 1: Copy the .mq5 source files into the repo

Open PowerShell and run:

```powershell
# Copy the two MQL5 source files from your MT5 folder into the repo
Copy-Item "C:\Users\senth\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\GoldV4_MT5.mq5" "C:\Users\senth\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\local-agent-mode-sessions\a548c035-8361-4ff5-b172-1915a080914c\f0b83ff8-39c2-4ca5-9a1a-327e3c45938f\local_05563da1-c652-4514-84fd-87c3ab8be984\outputs\goldv4-institutional-scalper\src\"

Copy-Item "C:\Users\senth\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\GoldV5_LNY.mq5" "C:\Users\senth\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\local-agent-mode-sessions\a548c035-8361-4ff5-b172-1915a080914c\f0b83ff8-39c2-4ca5-9a1a-327e3c45938f\local_05563da1-c652-4514-84fd-87c3ab8be984\outputs\goldv4-institutional-scalper\src\"
```

Verify both files are now in `src/`:

```powershell
dir "C:\Users\senth\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\local-agent-mode-sessions\a548c035-8361-4ff5-b172-1915a080914c\f0b83ff8-39c2-4ca5-9a1a-327e3c45938f\local_05563da1-c652-4514-84fd-87c3ab8be984\outputs\goldv4-institutional-scalper\src\"
```

You should see:
- GoldV4_MT5.mq5
- GoldV5_LNY.mq5
- README.md

---

## Step 2: Also copy the SystemReference.md (if it exists)

```powershell
# Check if it exists first
if (Test-Path "C:\Users\senth\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\GoldV4V5_SystemReference.md") {
    Copy-Item "C:\Users\senth\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\GoldV4V5_SystemReference.md" "C:\Users\senth\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\local-agent-mode-sessions\a548c035-8361-4ff5-b172-1915a080914c\f0b83ff8-39c2-4ca5-9a1a-327e3c45938f\local_05563da1-c652-4514-84fd-87c3ab8be984\outputs\goldv4-institutional-scalper\docs\SYSTEM_REFERENCE.md"
}
```

---

## Step 3: Create a new GitHub repo (via web UI)

1. Go to https://github.com/new
2. Fill in:
   - **Repository name:** `goldv4-institutional-scalper`
   - **Description:** `Dual-strategy institutional-grade algorithmic trading system for XAUUSD on MetaTrader 5`
   - **Visibility:** Public (makes it resume-visible)
   - **Initialize this repository with:** ❌ Do NOT check any boxes (we already have files)
3. Click **"Create repository"**
4. On the next page, copy the URL that looks like `https://github.com/YOUR-USERNAME/goldv4-institutional-scalper.git` — you'll need it in Step 4

---

## Step 4: Initialize git and push

In PowerShell, navigate to the repo folder:

```powershell
cd "C:\Users\senth\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\local-agent-mode-sessions\a548c035-8361-4ff5-b172-1915a080914c\f0b83ff8-39c2-4ca5-9a1a-327e3c45938f\local_05563da1-c652-4514-84fd-87c3ab8be984\outputs\goldv4-institutional-scalper"
```

Initialize git and configure (one-time):

```powershell
git init
git config user.name "Senthil Kumaran Balakrishnan"
git config user.email "senthilvit2004@gmail.com"
```

Stage all files:

```powershell
git add .
```

Verify what's about to be committed:

```powershell
git status
```

Should show these files staged:
- README.md
- LICENSE
- .gitignore
- PUSH_INSTRUCTIONS.md (you can `git rm` this if you don't want to commit it)
- docs/ARCHITECTURE.md
- docs/METHODOLOGY.md
- docs/RESULTS.md
- docs/SYSTEM_REFERENCE.md (if copied)
- src/README.md
- src/GoldV4_MT5.mq5
- src/GoldV5_LNY.mq5
- backtests/README.md

Commit:

```powershell
git commit -m "Initial commit: GoldV4/V5 institutional scalper system"
```

Set main branch and add remote (replace YOUR-USERNAME with your actual GitHub username):

```powershell
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/goldv4-institutional-scalper.git
```

Push to GitHub:

```powershell
git push -u origin main
```

If prompted, authenticate with your GitHub credentials or a Personal Access Token. If you've never done this before, GitHub will walk you through creating a token.

---

## Step 5: Verify it worked

Open your browser and go to:
```
https://github.com/YOUR-USERNAME/goldv4-institutional-scalper
```

You should see:
- The README displayed with all your metrics, architecture diagrams, and badges
- All folders (docs/, src/, backtests/) visible
- MIT License badge
- Repo looking professional

---

## Step 6: Add it to your resume & LinkedIn

### LinkedIn

1. Go to your profile → Add profile section → Projects
2. Fill in:
   - **Name:** GoldV4 Institutional Scalper
   - **Description:** Use the LinkedIn narrative I drafted earlier
   - **Associated with:** (your education or self)
   - **Project URL:** https://github.com/YOUR-USERNAME/goldv4-institutional-scalper
3. Save

Also add to your "Experience" or "Featured" sections for maximum visibility.

### Resume

Add this bullet (uses the resume language from earlier):

```
INSTITUTIONAL-GRADE XAUUSD ALGORITHMIC TRADING SYSTEM | Personal Project
GitHub: github.com/YOUR-USERNAME/goldv4-institutional-scalper

• Designed and developed dual-strategy MetaTrader 5 Expert Advisor system
  (~6,000 LOC MQL5) for gold M1 scalping with institutional-grade risk
  management framework
• Architected 12-layer safety infrastructure: Kelly sizing, equity curve
  filter, dynamic drawdown throttle, portfolio heat manager, hardcoded
  lot ceiling
• Conducted 30+ backtest iterations with walk-forward validation on 6-month
  tick-level real data; achieved backtest PF 1.44 (Asia strategy), PF 1.18
  (London strategy)
• Validated via 4-week live demo paper trading: PF 1.57, 61.5% win rate
  across 169 trades
• Technologies: MQL5, MetaTrader 5, Smart Money Concepts, quantitative risk
  management, tick-level backtesting
```

---

## Step 7 (optional but recommended): Add topic tags

On the GitHub repo page, click the ⚙️ icon next to "About" (top right).

Add these topics for discoverability:
```
algorithmic-trading, mql5, metatrader5, quantitative-finance,
trading-bot, backtesting, risk-management, smart-money-concepts,
xauusd, forex, scalping, portfolio-project
```

Also add the GitHub repo URL to the "Website" field.

---

## Step 8: Pin the repo on your profile

On your GitHub profile:
1. Click "Customize your pins"
2. Select `goldv4-institutional-scalper`
3. Save

This makes it the first repo visitors see when they land on your profile — critical for recruiters browsing.

---

## Troubleshooting

### "git push" asks for password
Modern GitHub requires Personal Access Tokens, not passwords. Create one:
1. Go to https://github.com/settings/tokens
2. Generate new token (classic) → Give it `repo` scope → 90-day expiry
3. Use the token in place of your password when prompted

### Repo already exists error
If you already pushed something to this repo name, either:
- Delete the old GitHub repo and create new, or
- Use `git push -f origin main` to force-push (careful — overwrites remote)

### Files too large
If any single file is over 100MB, GitHub will reject it. The .mq5 files are well under this. If you're adding big backtest HTM files, remove them (they're already in .gitignore).

---

## After pushing, delete PUSH_INSTRUCTIONS.md

Once your repo is live, this file is clutter. Remove it:

```powershell
Remove-Item "C:\Users\senth\AppData\Local\Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\local-agent-mode-sessions\a548c035-8361-4ff5-b172-1915a080914c\f0b83ff8-39c2-4ca5-9a1a-327e3c45938f\local_05563da1-c652-4514-84fd-87c3ab8be984\outputs\goldv4-institutional-scalper\PUSH_INSTRUCTIONS.md"
git add -A
git commit -m "Remove push instructions"
git push
```

Done.
