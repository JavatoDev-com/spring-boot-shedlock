-- Simple SQL Script to generate 10,000 report records
-- This is a more straightforward approach using a recursive CTE

-- Clear existing data (optional - comment out if you want to keep existing data)
-- DELETE FROM user_report_data;

-- Generate 10,000 records using a recursive CTE
WITH RECURSIVE number_sequence AS (
    SELECT 1 as n
    UNION ALL
    SELECT n + 1 FROM number_sequence WHERE n < 10000
)
INSERT INTO user_report_data (user_id, report_type, report_data, status, created_at, updated_at, processed_at)
SELECT 
    CONCAT('user_', LPAD(n, 6, '0')) as user_id,
    ELT((n % 10) + 1, 
        'MONTHLY_SALES', 'WEEKLY_ANALYTICS', 'DAILY_METRICS', 'QUARTERLY_SUMMARY', 
        'ANNUAL_REPORT', 'CUSTOMER_ANALYSIS', 'PRODUCT_PERFORMANCE', 'MARKETING_CAMPAIGN', 
        'FINANCIAL_REPORT', 'OPERATIONAL_METRICS'
    ) as report_type,
    CONCAT(
        'Report data for record ', n, 
        ' - Generated on ', DATE_FORMAT(NOW() - INTERVAL (n % 30) DAY, '%Y-%m-%d'),
        ' - Sales: $', ROUND(RAND() * 100000, 2),
        ' - Customers: ', FLOOR(RAND() * 1000),
        ' - Status: ', 
        CASE 
            WHEN n % 100 < 60 THEN 'PENDING'
            WHEN n % 100 < 85 THEN 'COMPLETED'
            WHEN n % 100 < 95 THEN 'PROCESSING'
            ELSE 'FAILED'
        END
    ) as report_data,
    CASE 
        WHEN n % 100 < 60 THEN 'PENDING'      -- 60% pending
        WHEN n % 100 < 85 THEN 'COMPLETED'     -- 25% completed
        WHEN n % 100 < 95 THEN 'PROCESSING'    -- 10% processing
        ELSE 'FAILED'                          -- 5% failed
    END as status,
    NOW() - INTERVAL (n % 90) DAY - INTERVAL (n % 24) HOUR - INTERVAL (n % 60) MINUTE as created_at,
    NOW() - INTERVAL (n % 90) DAY - INTERVAL (n % 24) HOUR - INTERVAL (n % 60) MINUTE as updated_at,
    CASE 
        WHEN n % 100 < 60 THEN NULL  -- PENDING reports have no processed_at
        WHEN n % 100 < 85 THEN NOW() - INTERVAL (n % 30) DAY - INTERVAL (n % 12) HOUR  -- COMPLETED reports
        WHEN n % 100 < 95 THEN NOW() - INTERVAL (n % 7) DAY - INTERVAL (n % 6) HOUR    -- PROCESSING reports
        ELSE NOW() - INTERVAL (n % 14) DAY - INTERVAL (n % 8) HOUR                      -- FAILED reports
    END as processed_at
FROM number_sequence;

-- Display summary statistics
SELECT 
    'Status Distribution' as category,
    status as value,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_report_data), 2) as percentage
FROM user_report_data 
GROUP BY status

UNION ALL

SELECT 
    'Report Type Distribution' as category,
    report_type as value,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_report_data), 2) as percentage
FROM user_report_data 
GROUP BY report_type

ORDER BY category, count DESC;

-- Display total count and date range
SELECT 
    'Summary' as info,
    COUNT(*) as total_records,
    MIN(created_at) as earliest_record,
    MAX(created_at) as latest_record
FROM user_report_data;
