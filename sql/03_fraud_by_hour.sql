-- Fraud rate by hour of day: is fraud concentrated at certain times?
SELECT
  EXTRACT(HOUR FROM trans_date_trans_time)::int AS hour_of_day,
  COUNT(*) AS total_txns,
  SUM(is_fraud) AS fraud_txns,
  ROUND(SUM(is_fraud)::numeric / COUNT(*) * 100, 2) AS fraud_rate_pct
FROM transactions_raw
GROUP BY EXTRACT(HOUR FROM trans_date_trans_time)
ORDER BY hour_of_day;
