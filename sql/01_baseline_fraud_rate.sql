-- Baseline fraud rate: shows the class imbalance (fraud is well under 1% of transactions),
-- which is why accuracy is a useless metric here.
SELECT
  COUNT(*) AS total_txns,
  SUM(is_fraud) AS fraud_txns,
  ROUND(SUM(is_fraud)::numeric / COUNT(*) * 100, 3) AS fraud_rate_pct
FROM transactions_raw;
