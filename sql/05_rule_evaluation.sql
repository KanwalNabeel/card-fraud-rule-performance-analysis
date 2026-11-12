-- Compares six flagging rules on precision, recall and false positive rate.
-- Thresholds ($250, night = 22:00-03:59, four risky categories) were chosen
-- from queries 02-04 on this same data, so scores are likely optimistic.
WITH base AS (
  SELECT
    is_fraud,
    (amt >= 250) AS big_amt,
    (EXTRACT(HOUR FROM trans_date_trans_time) IN (22,23,0,1,2,3)) AS night,
    (category IN ('shopping_net','misc_net','grocery_pos','shopping_pos')) AS risky_cat
  FROM transactions_raw
),
rules AS (
  SELECT 'A: amount >= 250' AS rule, is_fraud, big_amt AS flagged FROM base
  UNION ALL SELECT 'B: night (22:00-03:59)', is_fraud, night FROM base
  UNION ALL SELECT 'C: amount >= 250 AND night', is_fraud, (big_amt AND night) FROM base
  UNION ALL SELECT 'D: amount >= 250 OR night', is_fraud, (big_amt OR night) FROM base
  UNION ALL SELECT 'E: night AND risky category', is_fraud, (night AND risky_cat) FROM base
  UNION ALL SELECT 'F: amount >= 250 AND risky category', is_fraud, (big_amt AND risky_cat) FROM base
)
SELECT
  rule,
  LEFT(rule, 1) AS rule_code,
  COUNT(*) FILTER (WHERE flagged) AS flagged_txns,
  COUNT(*) FILTER (WHERE flagged AND is_fraud = 1) AS fraud_caught,
  ROUND(COUNT(*) FILTER (WHERE flagged AND is_fraud = 1)::numeric
        / NULLIF(COUNT(*) FILTER (WHERE flagged), 0) * 100, 1) AS precision_pct,
  ROUND(COUNT(*) FILTER (WHERE flagged AND is_fraud = 1)::numeric
        / NULLIF(SUM(is_fraud), 0) * 100, 1) AS recall_pct,
  ROUND(COUNT(*) FILTER (WHERE flagged AND is_fraud = 0)::numeric
        / NULLIF(COUNT(*) FILTER (WHERE is_fraud = 0), 0) * 100, 2) AS false_positive_rate_pct
FROM rules
GROUP BY rule
ORDER BY rule;
