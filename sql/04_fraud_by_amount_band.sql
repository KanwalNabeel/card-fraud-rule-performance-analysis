-- Fraud rate by transaction amount band (CASE inside a CTE).
-- The numbered prefixes keep the bands sorted in the right order.
WITH banded AS (
  SELECT
    CASE
      WHEN amt < 50    THEN '1) under 50'
      WHEN amt < 100   THEN '2) 50-100'
      WHEN amt < 250   THEN '3) 100-250'
      WHEN amt < 500   THEN '4) 250-500'
      WHEN amt < 1000  THEN '5) 500-1000'
      ELSE                  '6) 1000+'
    END AS amount_band,
    is_fraud
  FROM transactions_raw
)
SELECT
  amount_band,
  COUNT(*) AS total_txns,
  SUM(is_fraud) AS fraud_txns,
  ROUND(SUM(is_fraud)::numeric / COUNT(*) * 100, 2) AS fraud_rate_pct
FROM banded
GROUP BY amount_band
ORDER BY amount_band;
