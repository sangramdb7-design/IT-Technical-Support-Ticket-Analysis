USE service_desk_analytics;
SELECT * FROM tickets_enriched LIMIT 10;

-- 1. Find the total number of tickets for each ticket status (open, in_progress, on_hold, resolved, closed_no_action).
CREATE OR REPLACE VIEW ticket_volume_by_status AS
SELECT 
    status AS ticket_status,
    COUNT(*) AS total_tickets
FROM tickets_enriched
GROUP BY status
ORDER BY total_tickets DESC;

-- 2. Count the total tickets and calculate the average resolution time (in hours) for each priority level (low, medium, high, urgent).
CREATE OR REPLACE VIEW resolution_time_by_priority AS
SELECT 
    priority AS priority_level,
    COUNT(*) AS total_tickets,
    ROUND(AVG(resolution_time_hours), 2) AS avg_resolution_hours
FROM tickets_enriched
GROUP BY priority
ORDER BY total_tickets DESC;

-- 3. Find the total number of tickets, breached tickets, and SLA breach percentage for each shift (Morning, Afternoon, Night).
CREATE OR REPLACE VIEW sla_performance_by_shift AS
SELECT 
    shift_name,
    COUNT(ticket_id) AS total_tickets,
    SUM(sla_breached) AS breached_tickets,
    ROUND((SUM(sla_breached) / COUNT(ticket_id)) * 100, 2) AS sla_breach_pct
FROM tickets_enriched
GROUP BY shift_name;

-- 4. List the top 5 product areas with the highest number of SLA-breached tickets.
CREATE OR REPLACE VIEW top_5_sla_breached_products AS
SELECT 
    product_area,
    SUM(sla_breached) AS breached_tickets,
    COUNT(ticket_id) AS total_tickets,
    ROUND((SUM(sla_breached) / COUNT(ticket_id)) * 100, 2) AS sla_breach_pct
FROM tickets_enriched
GROUP BY product_area
ORDER BY breached_tickets DESC
LIMIT 5;

-- 5. Find the First-Contact Resolution (FCR) rate for each support channel (email, chat, phone, web_form).
CREATE OR REPLACE VIEW fcr_rate_by_channel AS
SELECT 
    channel AS support_channel,
    SUM(is_fcr) AS fcr_tickets,
    COUNT(*) AS total_tickets,
    ROUND(SUM(is_fcr) * 100.0 / COUNT(*), 2) AS fcr_rate_pct
FROM tickets_enriched
GROUP BY channel
ORDER BY fcr_tickets DESC;

-- 6. Compare the average resolution time of reopened tickets (reopened = 1) versus tickets solved on the first try (reopened = 0).
CREATE OR REPLACE VIEW resolution_time_by_reopen_status AS
SELECT 
    CASE 
        WHEN reopened = 1 THEN 'Reopened'
        ELSE 'Did Not Reopen'
    END AS reopen_status,
    ROUND(AVG(resolution_time_hours), 2) AS avg_resolution_hours
FROM tickets_enriched
GROUP BY reopen_status;

-- 7. Compare the average customer satisfaction score (csat_score) for SLA-compliant tickets versus SLA-breached tickets.
CREATE OR REPLACE VIEW csat_score_by_sla_status AS
SELECT 
    CASE 
        WHEN sla_breached = 0 THEN 'SLA - Compliant'
        ELSE 'SLA - Non-Compliant'
    END AS sla_compliance_status,
    ROUND(AVG(csat_score), 2) AS avg_csat_score
FROM tickets_enriched
GROUP BY sla_compliance_status;

-- 8. Count how many tickets include attachments (has_attachment = 1) versus no attachments, and compare their average resolution times.
CREATE OR REPLACE VIEW resolution_time_by_attachment_status AS
SELECT 
    CASE 
        WHEN has_attachment = 1 THEN 'Attachment Included'
        ELSE 'No Attachment'
    END AS attachment_status,
    ROUND(AVG(resolution_time_hours), 2) AS avg_resolution_hours
FROM tickets_enriched
GROUP BY attachment_status;

-- 9. List the top 10 enterprise customers (customer_id) who raised the highest number of tickets.
CREATE OR REPLACE VIEW top_10_customers_by_ticket_volume AS
SELECT 
    customer_id,
    COUNT(customer_id) AS total_tickets_raised
FROM tickets_enriched
GROUP BY customer_id
ORDER BY total_tickets_raised DESC
LIMIT 10;

-- 10. Find the total number of tickets and SLA breaches for each region (NA, EU, APAC, LATAM, MEA).
CREATE OR REPLACE VIEW sla_breaches_by_region AS
SELECT 
    region,
    COUNT(*) AS total_tickets,
    SUM(sla_breached) AS breached_tickets
FROM tickets_enriched
GROUP BY region
ORDER BY total_tickets DESC;

-- 11. Group tickets into common problem types using CASE WHEN and LIKE on initial_message, and find which problem type has the most SLA breaches and lowest average csat_score.
CREATE OR REPLACE VIEW sla_and_csat_by_problem_type AS
SELECT 
    CASE 
        WHEN LOWER(initial_message) LIKE '%login%' OR LOWER(initial_message) LIKE '%password%' OR LOWER(initial_message) LIKE '%auth%' OR LOWER(initial_message) LIKE '%sign in%' OR LOWER(initial_message) LIKE '%account%' THEN 'Login/Auth'
        WHEN LOWER(initial_message) LIKE '%bill%' OR LOWER(initial_message) LIKE '%payment%' OR LOWER(initial_message) LIKE '%invoice%' OR LOWER(initial_message) LIKE '%charge%' OR LOWER(initial_message) LIKE '%refund%' OR LOWER(initial_message) LIKE '%subscription%' THEN 'Billing'
        WHEN LOWER(initial_message) LIKE '%slow%' OR LOWER(initial_message) LIKE '%lag%' OR LOWER(initial_message) LIKE '%loading%' OR LOWER(initial_message) LIKE '%latency%' OR LOWER(initial_message) LIKE '%timeout%' OR LOWER(initial_message) LIKE '%delay%' THEN 'Slow Performance'
        WHEN LOWER(initial_message) LIKE '%crash%' OR LOWER(initial_message) LIKE '%freeze%' OR LOWER(initial_message) LIKE '%error%' OR LOWER(initial_message) LIKE '%bug%' OR LOWER(initial_message) LIKE '%close%' OR LOWER(initial_message) LIKE '%broken%' THEN 'App Crash'
        ELSE 'Others'
    END AS problem_category,
    COUNT(*) AS total_tickets,
    SUM(sla_breached) AS breached_tickets,
    ROUND(AVG(csat_score), 2) AS avg_csat_score
FROM tickets_enriched
GROUP BY problem_category
ORDER BY breached_tickets DESC;

-- 12. Find the top 5 busiest hours of the day by ticket volume and calculate the SLA breach percentage for each hour.
CREATE OR REPLACE VIEW top_5_busiest_hours_sla AS
SELECT 
    HOUR(created_at) AS hour_of_day,
    COUNT(*) AS total_tickets,
    ROUND((SUM(sla_breached) / COUNT(*)) * 100, 2) AS sla_breach_pct
FROM tickets_enriched
GROUP BY hour_of_day
ORDER BY total_tickets DESC
LIMIT 5;

-- 13. Compare total tickets, SLA breach percentage, and average resolution time across each SLA plan and platform.
CREATE OR REPLACE VIEW performance_by_sla_plan_and_platform AS
SELECT 
    sla_plan,
    platform,
    COUNT(*) AS total_tickets,
    SUM(sla_breached) AS breached_tickets,
    ROUND((SUM(sla_breached) / COUNT(*)) * 100, 2) AS sla_breach_pct,
    ROUND(AVG(resolution_time_hours), 2) AS avg_resolution_hours
FROM tickets_enriched
GROUP BY sla_plan, platform
ORDER BY sla_plan, sla_breach_pct DESC;

-- 14. Calculate monthly and yearly ticket volume and SLA breach percentage (2022–2025) to identify whether overall SLA performance improved or declined over time.
CREATE OR REPLACE VIEW monthly_sla_performance_trend AS
SELECT 
    YEAR(created_at) AS ticket_year,
    MONTH(created_at) AS ticket_month,
    COUNT(*) AS total_tickets,
    ROUND((SUM(sla_breached) / COUNT(*)) * 100, 2) AS sla_breach_pct
FROM tickets_enriched
GROUP BY ticket_year, ticket_month
ORDER BY ticket_year, ticket_month;

-- ============================================================================
-- CALL ALL VIEWS
-- ============================================================================

SELECT * FROM ticket_volume_by_status;
SELECT * FROM resolution_time_by_priority;
SELECT * FROM sla_performance_by_shift;
SELECT * FROM top_5_sla_breached_products;
SELECT * FROM fcr_rate_by_channel;
SELECT * FROM resolution_time_by_reopen_status;
SELECT * FROM csat_score_by_sla_status;
SELECT * FROM resolution_time_by_attachment_status;
SELECT * FROM top_10_customers_by_ticket_volume;
SELECT * FROM sla_breaches_by_region;
SELECT * FROM sla_and_csat_by_problem_type;
SELECT * FROM top_5_busiest_hours_sla;
SELECT * FROM performance_by_sla_plan_and_platform;
SELECT * FROM monthly_sla_performance_trend;