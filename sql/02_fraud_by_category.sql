-- Fraud rate and fraud dollars by merchant category.
-- Rate and dollars can rank categories differently.
SELECT
  category,
  COUNT(*) AS total_txns,
  SUM(is_fraud) AS fraud_txns,
  ROUND(SUM(is_fraud)::numeric / COUNT(*) * 100, 2) AS fraud_rate_pct,
  ROUND(SUM(CASE WHEN is_fraud = 1 THEN amt ELSE 0 END), 0) AS fraud_amount
FROM transactions_raw
GROUP BY category
ORDER BY fraud_rate_pct DESC;
