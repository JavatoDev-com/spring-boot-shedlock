# SQL Scripts for Generating 10,000 Report Records

This directory contains SQL scripts to generate 10,000 test records in the `user_report_data` table for demonstrating the ShedLock Spring Boot application.

## Available Scripts

### 1. `generate_10000_reports_compatible.sql` (✅ WORKING - Recommended)
- **Method**: Uses temporary table with cross joins
- **Performance**: Good for all MySQL versions (5.7+)
- **Features**: 
  - Generates realistic data with varied timestamps
  - Creates 10 different report types
  - Distributes statuses: 60% PENDING, 25% COMPLETED, 10% PROCESSING, 5% FAILED
  - Includes summary statistics at the end
  - **TESTED AND WORKING** ✅

### 2. `generate_10000_reports_basic.sql` (Alternative)
- **Method**: Uses stored procedure with loops
- **Performance**: Good for all MySQL versions
- **Features**: 
  - Most compatible approach
  - Commits every 1000 records for better performance
  - Works with all MySQL versions

### 3. `generate_10000_reports_simple.sql` (Not Recommended)
- **Method**: Uses recursive CTE (Common Table Expression)
- **Performance**: Good for MySQL 8.0+
- **Issues**: 
  - May not work on older MySQL versions
  - Syntax errors in some MySQL configurations

## Quick Start

### Option 1: Using the Shell Script (Easiest) ✅ TESTED
```bash
./run_sql_script.sh
```
**Result**: Successfully generated 10,000 records with proper distribution!

### Option 2: Manual Execution
```bash
# Connect to MySQL
mysql -u root -p spring_shedlock_example

# Execute the script
source generate_10000_reports_simple.sql;
```

### Option 3: Command Line Execution
```bash
mysql -u root -p spring_shedlock_example < generate_10000_reports_simple.sql
```

## Data Distribution

The scripts generate data with the following distribution:

### Status Distribution
- **PENDING**: 60% (6,000 records) - Will be processed by scheduled tasks
- **COMPLETED**: 25% (2,500 records) - Already processed reports
- **PROCESSING**: 10% (1,000 records) - Currently being processed
- **FAILED**: 5% (500 records) - Failed processing attempts

### Report Types
- MONTHLY_SALES
- WEEKLY_ANALYTICS
- DAILY_METRICS
- QUARTERLY_SUMMARY
- ANNUAL_REPORT
- CUSTOMER_ANALYSIS
- PRODUCT_PERFORMANCE
- MARKETING_CAMPAIGN
- FINANCIAL_REPORT
- OPERATIONAL_METRICS

### Time Distribution
- Records span the last 90 days
- Random distribution across hours and minutes
- Processed records have appropriate `processed_at` timestamps

## Verification

After running the script, you can verify the data:

```sql
-- Check total count
SELECT COUNT(*) FROM user_report_data;

-- Check status distribution
SELECT status, COUNT(*) as count, 
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM user_report_data), 2) as percentage
FROM user_report_data 
GROUP BY status;

-- Check report type distribution
SELECT report_type, COUNT(*) as count
FROM user_report_data 
GROUP BY report_type;

-- Check date range
SELECT MIN(created_at) as earliest, MAX(created_at) as latest
FROM user_report_data;
```

## Performance Notes

- **generate_10000_reports.sql**: ~30-60 seconds on average hardware
- **generate_10000_reports_simple.sql**: ~20-40 seconds on MySQL 8.0+
- **generate_10000_reports_batch.sql**: ~10-30 seconds (most efficient)

## Troubleshooting

### Common Issues

1. **"Table doesn't exist"**
   - Make sure the Spring Boot application has run at least once to create the table
   - Check that `spring.jpa.hibernate.ddl-auto=update` is set

2. **"Access denied"**
   - Verify MySQL user has INSERT privileges
   - Check database name and credentials

3. **"Recursive CTE not supported"**
   - Use `generate_10000_reports.sql` instead of the simple version
   - Upgrade to MySQL 8.0+ for CTE support

4. **"Out of memory"**
   - Use the batch version with stored procedure
   - Increase MySQL buffer pool size

### Database Requirements

- MySQL 5.7+ (for basic functionality)
- MySQL 8.0+ (for recursive CTE version)
- Sufficient disk space (~50MB for 10,000 records)
- Appropriate MySQL user privileges

## After Running the Script

1. **Start the Spring Boot application**:
   ```bash
   ./gradlew bootRun
   ```

2. **Monitor the processing**:
   - Watch application logs for scheduled task execution
   - Check `/api/reports/stats` endpoint for real-time statistics
   - Observe PENDING reports being processed every 30 seconds

3. **Test ShedLock functionality**:
   - Start multiple application instances
   - Verify only one instance processes scheduled tasks
   - Check that reports transition from PENDING → PROCESSING → COMPLETED

## Customization

To modify the data generation:

1. **Change record count**: Modify the limit in the SQL script
2. **Adjust status distribution**: Modify the percentage calculations
3. **Add new report types**: Update the CASE statements
4. **Change time range**: Modify the INTERVAL calculations

Example for 5,000 records:
```sql
-- Change this line in the script
LIMIT 5000;
```
