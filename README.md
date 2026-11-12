# Card Fraud Rule Performance & Net Benefit Analysis

**Business question:** Which transaction patterns carry the most fraud, and which flagging rule catches the most fraud at an acceptable review cost?

## Dashboard

[Live interactive dashboard on Tableau Public](https://public.tableau.com/app/profile/kanwal.nabeel/viz/FraudRulePerformanceandNetBenefit/Dashboard)

## Data

[Credit Card Transactions Fraud Detection Dataset](https://www.kaggle.com/datasets/kartik2112/fraud-detection) (Kaggle, `fraudTrain.csv`): 1,296,675 **simulated** card transactions with merchant category, amount, timestamp and an `is_fraud` label. Because the data is simulated, the patterns below reflect how it was generated, not real-world fraud. The raw file is not included in this repo.

## Approach

All analysis is in PostgreSQL (see `/sql`, run in order):

| File | Question it answers |
|---|---|
| `00_create_table.sql` | Creates the table with explicit column types before importing the CSV |
| `01_baseline_fraud_rate.sql` | How rare is fraud? (class imbalance) |
| `02_fraud_by_category.sql` | Which merchant categories carry the most fraud, by rate and by dollars? |
| `03_fraud_by_hour.sql` | Is fraud concentrated at certain hours? |
| `04_fraud_by_amount_band.sql` | Is fraud concentrated at certain amounts? |
| `05_rule_evaluation.sql` | How do six flagging rules compare on precision, recall and false positives? |
| `06_net_benefit_by_review_cost.sql` | Which rule earns the most once review costs are counted? |

## Key results

**Fraud is rare and concentrated.** 7,506 of 1,296,675 transactions are fraud (about 0.58%). Accuracy would be meaningless here, since a rule that flags nothing is 99%+ "accurate", so rules are judged on precision, recall and dollars.

- **Hour:** from 10 pm to 3:59 am, fraud runs at 1.4-2.9%, against about 0.1% the rest of the day. That window holds about 85% of all fraud.
- **Amount:** under $250 the fraud rate is 0.01-0.24%. From $250 up it is 8.6-24.1%. Transactions of $250 or more are about 3% of volume and hold about 75% of fraud transactions.
- **Category:** shopping_net, misc_net, grocery_pos and shopping_pos hold about 93% of fraud dollars.

**Six rules compared** (night = 10 pm to 3:59 am; risky category = the four categories above):

| Rule | Alerts | Precision | Recall |
|---|---|---|---|
| A: amount >= 250 | 38,459 | 14.6% | 74.7% |
| B: night | 304,882 | 2.1% | 84.8% |
| C: amount >= 250 AND night | 12,073 | 39.4% | 63.4% |
| D: amount >= 250 OR night | 331,268 | 2.2% | 96.1% |
| E: night AND risky category | 112,993 | 3.9% | 58.9% |
| F: amount >= 250 AND risky category | 23,079 | 22.6% | 69.4% |

Broad rules (B, D) catch the most fraud but flood reviewers, with roughly 46-48 alerts per real fraud. Tight rules (C, F) are cleaner but miss more.

**Dollars change the picture.** Rule A catches 74.7% of fraud transactions but 98.3% of fraud dollars ($3.92M of $3.99M), because what it misses is mostly many small transactions.

**Net benefit** (fraud dollars caught minus review cost, in $M):

| Rule | $2 per alert | $5 per alert | $15 per alert |
|---|---|---|---|
| A: amount >= 250 | 3.84 | 3.73 | 3.34 |
| F: amount >= 250 AND risky category | 3.68 | 3.61 | 3.38 |
| C: amount >= 250 AND night | 3.29 | 3.25 | 3.13 |
| D: amount >= 250 OR night | 3.32 | 2.32 | -0.99 |
| E: night AND risky category | 2.92 | 2.58 | 1.45 |
| B: night | 2.76 | 1.84 | -1.21 |

## Recommendation

Start with the simple $250 rule (A). It has the best net benefit unless each review costs more than about $13, where adding the risky-category filter (F) pays off. The night-only and amount-OR-night rules are not worth running, because their false alarms cost more than the fraud they catch.

## Assumptions and limitations

- The review costs ($2, $5, $15 per alert) are assumptions, not values from the data.
- Net benefit assumes every flagged fraud is fully stopped, so real returns would be lower. It also ignores the customer friction caused by false alerts.
- The $250 cutoff, the night window and the risky-category list were chosen from the same data they were scored on, so the results are probably optimistic. A fair test would score them on the later-period `fraudTest.csv`.
- The data is simulated.

## Next steps

- Score the same rules on `fraudTest.csv` as a holdout.
- Build a Python model (logistic regression with class weights, evaluated with precision, recall and PR-AUC on a time-based split) and compare it to the best rule.
