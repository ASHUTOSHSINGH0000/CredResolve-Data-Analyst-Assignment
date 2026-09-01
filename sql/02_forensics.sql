
SELECT account_id,payment_reference,event_at,amount,payment_status,COUNT(*) AS rows
FROM raw.payments
GROUP BY 1,2,3,4,5 HAVING COUNT(*)>1;

SELECT payment_reference,COUNT(DISTINCT account_id) AS accounts
FROM raw.payments WHERE payment_reference IS NOT NULL
GROUP BY 1 HAVING COUNT(DISTINCT account_id)>1;


SELECT COUNT(*) AS mismatches
FROM raw.calls c JOIN raw.accounts a USING(account_id)
WHERE c.borrower_id IS DISTINCT FROM a.borrower_id;


SELECT COUNT(*) AS recorded_before_event
FROM raw.account_status_history
WHERE recorded_at < event_at;


SELECT employee_code,COUNT(DISTINCT agent_id) AS agent_ids
FROM raw.agents GROUP BY 1 HAVING COUNT(DISTINCT agent_id)>1;


WITH broken AS (SELECT DISTINCT account_id,event_at FROM raw.promises_to_pay WHERE status='BROKEN')
SELECT COUNT(*) FILTER (WHERE b.account_id IS NULL) AS promise_targets_without_prior_break
FROM raw.daily_targeting t JOIN raw.campaigns c USING(campaign_id)
LEFT JOIN LATERAL (SELECT account_id FROM broken b WHERE b.account_id=t.account_id AND b.event_at < t.target_date ORDER BY b.event_at DESC LIMIT 1) b ON TRUE
WHERE c.target_definition='PROMISE_BROKEN';
