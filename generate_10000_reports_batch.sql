-- Batch SQL Script to generate 10,000 report records
-- This version uses multiple INSERT statements for better performance

-- Clear existing data (optional - comment out if you want to keep existing data)
-- DELETE FROM user_report_data;

-- Insert 10,000 records in batches of 1000
INSERT INTO user_report_data (user_id, report_type, report_data, status, created_at, updated_at, processed_at)
VALUES
-- Batch 1 (Records 1-1000)
('user_000001', 'MONTHLY_SALES', 'Monthly sales report data for user_000001 - Generated on 2024-01-15 - Sales: $45230.50 - Customers: 234', 'PENDING', '2024-01-15 10:30:00', '2024-01-15 10:30:00', NULL),
('user_000002', 'WEEKLY_ANALYTICS', 'Weekly analytics report data for user_000002 - Generated on 2024-01-16 - Sales: $32150.75 - Customers: 156', 'PENDING', '2024-01-16 11:45:00', '2024-01-16 11:45:00', NULL),
('user_000003', 'DAILY_METRICS', 'Daily metrics report data for user_000003 - Generated on 2024-01-17 - Sales: $8750.25 - Customers: 89', 'PENDING', '2024-01-17 09:15:00', '2024-01-17 09:15:00', NULL),
('user_000004', 'QUARTERLY_SUMMARY', 'Quarterly summary report data for user_000004 - Generated on 2024-01-18 - Sales: $125430.00 - Customers: 567', 'PENDING', '2024-01-18 14:20:00', '2024-01-18 14:20:00', NULL),
('user_000005', 'ANNUAL_REPORT', 'Annual report data for user_000005 - Generated on 2024-01-19 - Sales: $456780.50 - Customers: 1234', 'PENDING', '2024-01-19 16:30:00', '2024-01-19 16:30:00', NULL);

-- Note: This is a template showing the pattern
-- For a complete 10,000 record script, you would need to:
-- 1. Generate all 10,000 records programmatically
-- 2. Split them into batches of 1000 records each
-- 3. Execute each batch separately

-- Alternative approach: Use a stored procedure
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
    
    WHILE i <= 10000 DO
        SET user_id_val = CONCAT('user_', LPAD(i, 6, '0'));
        
        SET report_type_val = ELT((i % 10) + 1, 
            'MONTHLY_SALES', 'WEEKLY_ANALYTICS', 'DAILY_METRICS', 'QUARTERLY_SUMMARY', 
            'ANNUAL_REPORT', 'CUSTOMER_ANALYSIS', 'PRODUCT_PERFORMANCE', 'MARKETING_CAMPAIGN', 
            'FINANCIAL_REPORT', 'OPERATIONAL_METRICS'
        );
        
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
        
        SET status_val = CASE 
            WHEN i % 100 < 60 THEN 'PENDING'
            WHEN i % 100 < 85 THEN 'COMPLETED'
            WHEN i % 100 < 95 THEN 'PROCESSING'
            ELSE 'FAILED'
        END;
        
        SET created_at_val = NOW() - INTERVAL (i % 90) DAY - INTERVAL (i % 24) HOUR - INTERVAL (i % 60) MINUTE;
        
        SET processed_at_val = CASE 
            WHEN i % 100 < 60 THEN NULL
            WHEN i % 100 < 85 THEN NOW() - INTERVAL (i % 30) DAY - INTERVAL (i % 12) HOUR
            WHEN i % 100 < 95 THEN NOW() - INTERVAL (i % 7) DAY - INTERVAL (i % 6) HOUR
            ELSE NOW() - INTERVAL (i % 14) DAY - INTERVAL (i % 8) HOUR
        END;
        
        INSERT INTO user_report_data (user_id, report_type, report_data, status, created_at, updated_at, processed_at)
        VALUES (user_id_val, report_type_val, report_data_val, status_val, created_at_val, created_at_val, processed_at_val);
        
        SET i = i + 1;
        
        -- Commit every 1000 records for better performance
        IF i % 1000 = 0 THEN
            COMMIT;
        END IF;
    END WHILE;
    
    COMMIT;
END$$

DELIMITER ;

-- Execute the stored procedure
CALL GenerateReportData();

-- Drop the stored procedure after use
DROP PROCEDURE GenerateReportData;

-- Display summary statistics
SELECT 
    status,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_report_data), 2) as percentage
FROM user_report_data 
GROUP BY status
ORDER BY count DESC;

-- Display total count
SELECT COUNT(*) as total_records FROM user_report_data;
