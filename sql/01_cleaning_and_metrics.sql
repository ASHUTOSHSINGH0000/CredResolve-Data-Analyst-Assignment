
CREATE OR REPLACE VIEW analytics.golden_payments AS
WITH ranked AS (
  SELECT p.*,
         ROW_NUMBER() OVER (
           PARTITION BY account_id, borrower_id, event_at, payment_reference, amount,
                        payment_status, payment_method, provider_id
           ORDER BY payment_id
         ) AS rn
  FROM raw.payments p
)
SELECT * FROM ranked WHERE rn = 1;


CREATE OR REPLACE VIEW analytics.golden_calls AS
WITH ranked AS (
  SELECT c.*,
         COUNT(*) OVER (PARTITION BY call_id) AS call_id_versions,
         ROW_NUMBER() OVER (PARTITION BY call_id ORDER BY event_at DESC) AS rn
  FROM raw.calls c
)
SELECT * FROM ranked WHERE rn = 1;


CREATE OR REPLACE VIEW analytics.account_borrower_resolution AS
WITH b AS (SELECT borrower_id, COUNT(*) AS n FROM raw.borrowers GROUP BY borrower_id)
SELECT a.account_id, a.borrower_id,
       CASE WHEN a.borrower_id IS NULL THEN 'MISSING'
            WHEN b.borrower_id IS NULL THEN 'INVALID'
            WHEN b.n = 1 THEN 'UNIQUE'
            ELSE 'AMBIGUOUS' END AS borrower_resolution
FROM raw.accounts a LEFT JOIN b USING (borrower_id);


CREATE OR REPLACE VIEW analytics.monthly_recovery AS
WITH payments AS (
  SELECT date_trunc('month', event_at)::date AS month, account_id, payment_id, amount
  FROM analytics.golden_payments
  WHERE payment_status = 'SUCCESS'
),
targets AS (
  SELECT date_trunc('month', target_date)::date AS month, COUNT(DISTINCT account_id) AS targeted_accounts
  FROM raw.daily_targeting GROUP BY 1
)
SELECT p.month, SUM(p.amount) AS cash_recovered, COUNT(DISTINCT p.account_id) AS recovered_accounts,
       COUNT(DISTINCT p.payment_id) AS successful_transactions, t.targeted_accounts,
       COUNT(DISTINCT p.account_id)::numeric / NULLIF(t.targeted_accounts,0) AS recovery_account_rate,
       SUM(p.amount) / NULLIF(t.targeted_accounts,0) AS recovery_per_targeted_account
FROM payments p JOIN targets t USING (month)
GROUP BY p.month,t.targeted_accounts;


WITH targets AS (
  SELECT t.target_id,t.account_id,t.target_date,c.target_definition,c.strategy_version,t.recommended_channel
  FROM raw.daily_targeting t JOIN raw.campaigns c USING (campaign_id)
),
payments AS (
  SELECT account_id,event_at,amount FROM analytics.golden_payments WHERE payment_status='SUCCESS'
),
matched AS (
  SELECT t.*, p.event_at AS payment_at, p.amount,
         ROW_NUMBER() OVER (PARTITION BY t.target_id ORDER BY p.event_at) AS rn
  FROM targets t LEFT JOIN payments p
    ON p.account_id=t.account_id
   AND p.event_at >= t.target_date
   AND p.event_at < t.target_date + INTERVAL '7 days'
)
SELECT recommended_channel, COUNT(*) AS targets,
       COUNT(*) FILTER (WHERE amount IS NOT NULL AND rn=1) AS paid_7d,
       SUM(amount) FILTER (WHERE rn=1) AS recovery_7d
FROM matched WHERE rn=1 OR rn IS NULL GROUP BY 1;


SELECT vendor_id, COUNT(DISTINCT call_id) AS calls,
       AVG((call_status='ANSWERED')::int)::numeric AS answer_rate
FROM analytics.golden_calls GROUP BY vendor_id ORDER BY answer_rate DESC;
