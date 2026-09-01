# Data Analyst Assignment - Collections

## What I found

The reported **11% month-on-month recovery improvement** is only true if we look at the increase in successful cash recovered from February to March.

After removing exact duplicate payment events:

- Feb -> Mar cash recovered: **+11.11%**
- Recovered accounts: **+11.32%**
- Recovery rate per targeted account: **+1.38%**
- Recovery per targeted account: **+1.18%**
- Recovery per agent-hour: **+5.38%**
- Jan -> Jul cash recovered: **almost flat (+0.01%)**

So I would not describe the overall year as an 11% operational improvement.

## Main data issues

The raw data has a few problems that matter for the analysis:

- **98.46%** of calls have a borrower ID that does not match the borrower ID in the account table.
- Only **5,946 of 30,000 accounts** have an unambiguous borrower record.
- There are **486 duplicate payment events** in the payment data.
- There are **1,271 exact duplicate call rows**.
- About **66.7% of calls** have a timezone mismatch with the account timezone.
- **8,376 of 9,021 PROMISE_BROKEN targets (92.85%)** do not have a matching earlier broken PTP event.

Because of this, I avoided using borrower-level joins as if they were reliable, and I have treated the targeting and channel results as descriptive rather than causal.

## Investment view

My recommendation is **better borrower targeting**, but I would not approve a blind ₹10 Cr rollout from this dataset.

The targeting data has a clear quality problem, while the dataset does not contain enough reliable cost and treatment information to calculate a defensible positive ROI.

I would first run a controlled targeting experiment and use the result to decide whether the full investment is justified.

## Repository contents

- `notebook/collections_analysis.ipynb` - analysis and calculations
- `sql/01_cleaning_and_metrics.sql` - cleaning and KPI queries
- `sql/02_forensics.sql` - data-quality checks
- `golden/` - cleaned analytical outputs
- `dashboard/` - executive dashboard
- `docs/executive_memo.pdf` - executive summary
- `docs/data_quality_report.csv` - data-quality findings
- `docs/architecture.svg` - production design
- `requirements.txt` - Python packages used
