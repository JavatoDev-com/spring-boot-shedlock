-- Compatible SQL Script to generate 10,000 report records
-- This version works with MySQL 5.7+ without using recursive CTEs

-- Clear existing data (optional - comment out if you want to keep existing data)
-- DELETE FROM user_report_data;

-- Create a temporary table to generate sequential numbers
CREATE TEMPORARY TABLE temp_numbers (n INT);

-- Insert numbers 1 to 10000 using cross joins (works in all MySQL versions)
INSERT INTO temp_numbers (n)
SELECT @row := @row + 1 as n
FROM (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
     (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
     (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t3,
     (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t4,
     (SELECT @row := 0) r
LIMIT 10000;

-- Insert 10,000 report records
INSERT INTO user_report_data (user_id, report_type, report_data, status, created_at, updated_at, processed_at)
SELECT 
    CONCAT('user_', LPAD(n, 6, '0')) as user_id,
    CASE 
        WHEN n % 10 = 0 THEN 'MONTHLY_SALES'
        WHEN n % 10 = 1 THEN 'WEEKLY_ANALYTICS'
        WHEN n % 10 = 2 THEN 'DAILY_METRICS'
        WHEN n % 10 = 3 THEN 'QUARTERLY_SUMMARY'
        WHEN n % 10 = 4 THEN 'ANNUAL_REPORT'
        WHEN n % 10 = 5 THEN 'CUSTOMER_ANALYSIS'
        WHEN n % 10 = 6 THEN 'PRODUCT_PERFORMANCE'
        WHEN n % 10 = 7 THEN 'MARKETING_CAMPAIGN'
        WHEN n % 10 = 8 THEN 'FINANCIAL_REPORT'
        ELSE 'OPERATIONAL_METRICS'
    END as report_type,
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
FROM temp_numbers
ORDER BY n;

-- Clean up temporary table
DROP TEMPORARY TABLE temp_numbers;

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
