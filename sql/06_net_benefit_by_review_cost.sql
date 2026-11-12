-- Net dollar benefit of each rule at three ASSUMED review costs per alert ($2, $5, $15).
-- net benefit = fraud dollars caught - (alerts x review cost).
-- Assumes every flagged fraud is fully stopped, so real returns would be lower.
WITH base AS (
  SELECT
    is_fraud,
    amt,
    (amt >= 250) AS big_amt,
    (EXTRACT(HOUR FROM trans_date_trans_time) IN (22,23,0,1,2,3)) AS night,
    (category IN ('shopping_net','misc_net','grocery_pos','shopping_pos')) AS risky_cat
  FROM transactions_raw
),
rules AS (
  SELECT 'A: amount >= 250' AS rule, is_fraud, amt, big_amt AS flagged FROM base
  UNION ALL SELECT 'B: night (22:00-03:59)', is_fraud, amt, night FROM base
  UNION ALL SELECT 'C: amount >= 250 AND night', is_fraud, amt, (big_amt AND night) FROM base
  UNION ALL SELECT 'D: amount >= 250 OR night', is_fraud, amt, (big_amt OR night) FROM base
  UNION ALL SELECT 'E: night AND risky category', is_fraud, amt, (night AND risky_cat) FROM base
  UNION ALL SELECT 'F: amount >= 250 AND risky category', is_fraud, amt, (big_amt AND risky_cat) FROM base
),
rule_totals AS (
  SELECT
    rule,
    COUNT(*) FILTER (WHERE flagged) AS alerts,
    COALESCE(SUM(amt) FILTER (WHERE flagged AND is_fraud = 1), 0) AS fraud_dollars_caught,
    COALESCE(SUM(amt) FILTER (WHERE NOT flagged AND is_fraud = 1), 0) AS fraud_dollars_missed
  FROM rules
  GROUP BY rule
),
costs(review_cost) AS (
  VALUES (2), (5), (15)
)
SELECT
  rule,
  LEFT(rule, 1) AS rule_code,
  review_cost,
  alerts,
  ROUND(fraud_dollars_caught) AS fraud_dollars_caught,
  ROUND(fraud_dollars_missed) AS fraud_dollars_missed,
  ROUND(alerts * review_cost) AS total_review_cost,
  ROUND(fraud_dollars_caught - alerts * review_cost) AS net_benefit
FROM rule_totals
CROSS JOIN costs
ORDER BY review_cost, net_benefit DESC;
