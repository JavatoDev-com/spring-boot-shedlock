-- Basic SQL Script to generate 10,000 report records
-- This version uses the most compatible approach for all MySQL versions

-- Clear existing data (optional - comment out if you want to keep existing data)
-- DELETE FROM user_report_data;

-- Create a stored procedure to generate the data
DELIMITER $$

CREATE PROCEDURE GenerateReportData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE user_id_val VARCHAR(20);
    DECLARE report_type_val VARCHAR(50);
    DECLARE report_data_val TEXT;
    DECLARE status_val VARCHAR(20);
    DECLARE created_at_val DATETIME;
    DECLARE processed_at_val DATETIME;
    
    -- Start transaction for better performance
    START TRANSACTION;
    
    WHILE i <= 10000 DO
        -- Generate user ID
        SET user_id_val = CONCAT('user_', LPAD(i, 6, '0'));
        
        -- Generate report type (10 different types)
        SET report_type_val = CASE 
            WHEN i % 10 = 0 THEN 'MONTHLY_SALES'
            WHEN i % 10 = 1 THEN 'WEEKLY_ANALYTICS'
            WHEN i % 10 = 2 THEN 'DAILY_METRICS'
            WHEN i % 10 = 3 THEN 'QUARTERLY_SUMMARY'
            WHEN i % 10 = 4 THEN 'ANNUAL_REPORT'
            WHEN i % 10 = 5 THEN 'CUSTOMER_ANALYSIS'
            WHEN i % 10 = 6 THEN 'PRODUCT_PERFORMANCE'
            WHEN i % 10 = 7 THEN 'MARKETING_CAMPAIGN'
            WHEN i % 10 = 8 THEN 'FINANCIAL_REPORT'
            ELSE 'OPERATIONAL_METRICS'
        END;
        
        -- Generate report data
        SET report_data_val = CONCAT(
            'Report data for record ', i, 
            ' - Generated on ', DATE_FORMAT(NOW() - INTERVAL (i % 30) DAY, '%Y-%m-%d'),
            ' - Sales: $', ROUND(RAND() * 100000, 2),
            ' - Customers: ', FLOOR(RAND() * 1000),
            ' - Status: ', 
            CASE 
                WHEN i % 100 < 60 THEN 'PENDING'
                WHEN i % 100 < 85 THEN 'COMPLETED'
                WHEN i % 100 < 95 THEN 'PROCESSING'
                ELSE 'FAILED'
            END
        );
        
        -- Generate status (60% PENDING, 25% COMPLETED, 10% PROCESSING, 5% FAILED)
        SET status_val = CASE 
            WHEN i % 100 < 60 THEN 'PENDING'
            WHEN i % 100 < 85 THEN 'COMPLETED'
            WHEN i % 100 < 95 THEN 'PROCESSING'
            ELSE 'FAILED'
        END;
        
        -- Generate created_at timestamp (spread over last 90 days)
        SET created_at_val = NOW() - INTERVAL (i % 90) DAY - INTERVAL (i % 24) HOUR - INTERVAL (i % 60) MINUTE;
        
        -- Generate processed_at timestamp (only for non-PENDING reports)
        SET processed_at_val = CASE 
            WHEN i % 100 < 60 THEN NULL  -- PENDING reports have no processed_at
            WHEN i % 100 < 85 THEN NOW() - INTERVAL (i % 30) DAY - INTERVAL (i % 12) HOUR  -- COMPLETED reports
            WHEN i % 100 < 95 THEN NOW() - INTERVAL (i % 7) DAY - INTERVAL (i % 6) HOUR    -- PROCESSING reports
            ELSE NOW() - INTERVAL (i % 14) DAY - INTERVAL (i % 8) HOUR                      -- FAILED reports
        END;
        
        -- Insert the record
        INSERT INTO user_report_data (user_id, report_type, report_data, status, created_at, updated_at, processed_at)
        VALUES (user_id_val, report_type_val, report_data_val, status_val, created_at_val, created_at_val, processed_at_val);
        
        -- Increment counter
        SET i = i + 1;
        
        -- Commit every 1000 records for better performance
        IF i % 1000 = 0 THEN
            COMMIT;
            START TRANSACTION;
        END IF;
    END WHILE;
    
    -- Final commit
    COMMIT;
END$$

DELIMITER ;

-- Execute the stored procedure
CALL GenerateReportData();

-- Drop the stored procedure after use
DROP PROCEDURE GenerateReportData;

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
