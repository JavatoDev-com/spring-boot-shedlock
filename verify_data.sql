-- Quick verification script to check the generated data

-- Check total count
SELECT 'Total Records' as metric, COUNT(*) as value FROM user_report_data;

-- Check status distribution
SELECT 'Status Distribution' as category, status, COUNT(*) as count, 
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_report_data), 2) as percentage
FROM user_report_data 
GROUP BY status
ORDER BY count DESC;

-- Check report type distribution
SELECT 'Report Type Distribution' as category, report_type, COUNT(*) as count
FROM user_report_data 
GROUP BY report_type
ORDER BY count DESC;

-- Check date range
SELECT 'Date Range' as metric, 
       MIN(created_at) as earliest_record, 
       MAX(created_at) as latest_record 
FROM user_report_data;

-- Sample of PENDING reports (these will be processed by scheduled tasks)
SELECT 'Sample PENDING Reports' as info, id, user_id, report_type, created_at
FROM user_report_data 
WHERE status = 'PENDING' 
ORDER BY created_at 
LIMIT 5;

-- Sample of COMPLETED reports
SELECT 'Sample COMPLETED Reports' as info, id, user_id, report_type, created_at, processed_at
FROM user_report_data 
WHERE status = 'COMPLETED' 
ORDER BY processed_at DESC 
LIMIT 5;
