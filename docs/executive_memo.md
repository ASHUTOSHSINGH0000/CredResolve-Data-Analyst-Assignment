# Executive Memo - Collections Recovery Review

## Decision

I would **not use the reported 11% MoM figure as evidence that collection performance has structurally improved**.

The cleaned data does show an **11.11% increase in successful cash recovered from February to March**. However, recovery rate per targeted account increased only **1.38%**, recovery per targeted account increased **1.18%**, and recovery per agent-hour increased **5.38%**. From January to July, cash recovered was essentially flat at **+0.01%**.

## What happened?

The data covers 1 January to 8 August 2026. August is incomplete, so I used complete months for the main trend comparison.

After removing exact duplicate payment events, February cash recovered was about ₹170.3M and March was about ₹189.2M. The number of recovered accounts also increased by about 11.3%.

At the same time, the targeted-account base increased by about 9.8%. That means most of the 11% cash increase came from reaching more recovered accounts, rather than a large improvement in the probability of recovery for each targeted account.

## What is wrong with the data?

There are several issues that affect how much confidence I can place in the analysis.

**Strong evidence:** 98.46% of calls have a borrower ID that does not agree with the account master. The same problem appears in other event data. I therefore avoided relying on borrower ID for event-level attribution.

**Strong evidence:** 8,376 of 9,021 `PROMISE_BROKEN` targets (92.85%) do not have a previous broken PTP event in the available history. This suggests that the target definition or the source history is not being applied consistently.

**Strong evidence:** 30,191 status records have `recorded_at` earlier than `event_at`, and around 66.7% of calls have a timezone mismatch with the account timezone. Hour-of-day analysis should therefore be treated carefully.

**Fact:** there are 486 duplicate payment events and 1,271 exact duplicate call rows. These were removed or flagged before calculating the main KPIs.

## Is the 11% claim real?

**For Feb -> Mar cash volume: yes.**

**As a statement about overall recovery performance: no.**

The better set of measures is recovery per targeted account, recovery rate, recovery per agent-hour and net successful cash, rather than using one month of cash-volume growth on its own.

## ₹10 Cr recommendation

### Recommended area: Better borrower targeting

I would invest in targeting first, but through a **stage-gated pilot** rather than committing the entire ₹10 Cr immediately.

The targeting data contains a clear quality problem. By comparison, the observed vendor answer rates are relatively close, and the available data does not give a clean causal estimate for adding agents, AI voice, digital engagement or field operations.

### Financial view

Observed 7-day target-attributed recovery is approximately ₹93.7M on an annualized basis at the observed targeting volume.

| Relative uplift | Incremental annual recovery | 1-year ROI on ₹10 Cr |
|---:|---:|---:|
| 10% | ₹9.4M | -91% |
| 20% | ₹18.7M | -81% |
| 30% | ₹28.1M | -72% |
| 50% | ₹46.9M | -53% |

A full ₹10 Cr investment would need roughly a **107% relative uplift** in target-attributed recovery in one year just to break even. The current observational data does not support assuming that level of uplift.

So the financially safer decision is to test the targeting change first.

## Experiment

Randomly assign eligible accounts to the existing targeting strategy or the new targeting strategy, keeping the assignment within DPD, risk and loan-type groups.

The primary metric should be **30-day net recovered ₹ per eligible account**. Contact rate, RPC, PTP, kept PTP and cost per ₹ recovered can be secondary measures.

Keep a 10% holdout group and use an immutable assignment timestamp so that the result can be audited later.

## Confidence

- **High:** duplicate cleaning, borrower-ID mismatch, targeting-rule mismatch and the Feb -> Mar 11.11% cash increase.
- **Medium:** broad portfolio and vendor-mix observations.
- **Low:** causal channel/agent effects and ROI, because cost data and a clean randomized treatment assignment are not available.
