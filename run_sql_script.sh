#!/bin/bash

# Script to execute the SQL script for generating 10,000 report records
# Make sure MySQL is running and the database exists

# Database configuration
DB_HOST="127.0.0.1"
DB_PORT="3306"
DB_NAME="spring_shedlock_example"
DB_USER="root"
DB_PASSWORD="password"

# SQL script file
SQL_SCRIPT="generate_10000_reports_compatible.sql"

echo "Starting to generate 10,000 report records..."
echo "Database: $DB_NAME"
echo "Host: $DB_HOST:$DB_PORT"
echo "User: $DB_USER"
echo "Password: $DB_PASSWORD"
echo ""

# Check if MySQL is available
if ! command -v mysql &> /dev/null; then
    echo "Error: MySQL client is not installed or not in PATH"
    exit 1
fi

# Execute the SQL script
echo "Executing SQL script: $SQL_SCRIPT"
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME < $SQL_SCRIPT

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully generated 10,000 report records!"
    echo ""
    echo "You can now:"
    echo "1. Start your Spring Boot application"
    echo "2. Check the /api/reports/stats endpoint to see the data distribution"
    echo "3. Watch the scheduled tasks process the PENDING reports"
else
    echo ""
    echo "❌ Error occurred while executing the SQL script"
    echo "Please check:"
    echo "1. MySQL is running"
    echo "2. Database '$DB_NAME' exists"
    echo "3. User '$DB_USER' has proper permissions"
    echo "4. Password is correct"
fi
