CREATE DATABASE IF NOT EXISTS service_desk_analytics;
USE service_desk_analytics;

DROP TABLE IF EXISTS tickets_raw;

CREATE TABLE tickets_raw (
    ticket_id VARCHAR(20) PRIMARY KEY,
    date DATE NOT NULL,
    time TIME NOT NULL,
    customer_id VARCHAR(20),
    customer_segment VARCHAR(30),
    channel VARCHAR(30),
    product_area VARCHAR(50),
    issue_type VARCHAR(50),
    priority VARCHAR(20),
    status VARCHAR(30),
    sla_plan VARCHAR(20),
    initial_message TEXT,
    agent_first_reply TEXT,
    resolution_summary TEXT,
    resolution_time_hours DECIMAL(10, 2) NULL,
    reopened TINYINT,
    customer_sentiment VARCHAR(30),
    csat_score DECIMAL(4, 2) NULL,
    has_attachment TINYINT,
    platform VARCHAR(30),
    region VARCHAR(20)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'D:/Data Analysis/Projects/IT-Support-Tickets/Clean_Data.csv'
INTO TABLE tickets_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    ticket_id, date, time, customer_id, customer_segment, channel,
    product_area, issue_type, priority, status, sla_plan,
    initial_message, agent_first_reply, resolution_summary,
    @resolution_time_hours, reopened, customer_sentiment,
    @csat_score, has_attachment, platform, region
)
SET
    resolution_time_hours = NULLIF(TRIM(@resolution_time_hours), ''),
    csat_score = NULLIF(TRIM(@csat_score), '');
    
    
CREATE OR REPLACE VIEW tickets_enriched AS
WITH base_metrics AS (
    SELECT
        *,
        TIMESTAMP(date, time) AS created_at,
        MAX(TIMESTAMP(date, time)) OVER () AS dataset_snapshot_time,
        CASE
            WHEN HOUR(time) BETWEEN 6 AND 13 THEN 'Morning'
            WHEN HOUR(time) BETWEEN 14 AND 21 THEN 'Afternoon'
            ELSE 'Night'
        END AS shift_name,
        CASE
            WHEN sla_plan = 'platinum' AND priority = 'urgent' THEN 2
            WHEN sla_plan = 'platinum' AND priority = 'high'   THEN 4
            WHEN sla_plan = 'platinum' AND priority = 'medium' THEN 8
            WHEN sla_plan = 'platinum' AND priority = 'low'    THEN 16
            WHEN sla_plan = 'gold'     AND priority = 'urgent' THEN 4
            WHEN sla_plan = 'gold'     AND priority = 'high'   THEN 8
            WHEN sla_plan = 'gold'     AND priority = 'medium' THEN 16
            WHEN sla_plan = 'gold'     AND priority = 'low'    THEN 24
            WHEN sla_plan = 'standard' AND priority = 'urgent' THEN 8
            WHEN sla_plan = 'standard' AND priority = 'high'   THEN 16
            WHEN sla_plan = 'standard' AND priority = 'medium' THEN 24
            ELSE 48
        END AS sla_target_hours,
        CASE
            WHEN status = 'resolved' AND reopened = 0 THEN 1
            ELSE 0
        END AS is_fcr,
        CASE
            WHEN reopened = 1 OR (priority = 'urgent' AND has_attachment = 1) THEN 'L3 Engineering'
            WHEN priority IN ('high', 'urgent') OR has_attachment = 1 THEN 'L2 Technical Specialist'
            ELSE 'L1 Generalist'
        END AS agent_tier
    FROM tickets_raw
)
SELECT
    ticket_id,
    created_at,
    date,
    time,
    customer_id,
    customer_segment,
    channel,
    product_area,
    issue_type,
    priority,
    status,
    sla_plan,
    initial_message,
    agent_first_reply,
    resolution_summary,
    resolution_time_hours,
    reopened,
    customer_sentiment,
    csat_score,
    has_attachment,
    platform,
    region,
    shift_name,
    sla_target_hours,
    CASE
        WHEN resolution_time_hours > sla_target_hours THEN 1
        WHEN resolution_time_hours IS NULL
             AND status IN ('open', 'in_progress', 'on_hold')
             AND (TIMESTAMPDIFF(SECOND, created_at, dataset_snapshot_time) / 3600.0) > sla_target_hours THEN 1
        ELSE 0
    END AS sla_breached,
    is_fcr,
    agent_tier
FROM base_metrics;