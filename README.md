# ShedLock Spring Boot Demo Application

This application demonstrates the usage of ShedLock with Spring Boot for distributed task scheduling. ShedLock ensures that scheduled tasks run only once across multiple application instances in a distributed environment.

## Features

- **ReportDataEntity**: JPA entity for storing report data with status tracking
- **Scheduled Tasks**: Three different scheduled tasks demonstrating ShedLock usage:
  - `processPendingReports`: Processes pending reports every 30 seconds
  - `generateSampleReports`: Generates sample reports every 2 minutes
  - `cleanupOldReports`: Cleans up old completed reports every 5 minutes
- **REST API**: Endpoints to monitor and query report data
- **Data Initialization**: Automatically creates sample data on startup

## Prerequisites

- Java 21
- MySQL database
- Gradle

## Database Setup

1. Create a MySQL database named `spring_shedlock_example`
2. Update database credentials in `application.properties` if needed

## Running the Application

1. Start MySQL database
2. Run the application:
   ```bash
   ./gradlew bootRun
   ```

## API Endpoints

- `GET /api/reports` - Get all reports
- `GET /api/reports/status/{status}` - Get reports by status (PENDING, PROCESSING, COMPLETED, FAILED)
- `GET /api/reports/user/{userId}` - Get reports by user ID
- `GET /api/reports/stats` - Get report statistics

## ShedLock Configuration

The application uses ShedLock with MySQL as the lock provider. The lock table will be automatically created as `shedlock` in the database.

### Scheduled Tasks

1. **Process Pending Reports** (every 30 seconds)
   - Lock name: `processPendingReports`
   - Processes all PENDING reports and marks them as COMPLETED
   - Simulates 2-second processing time per report

2. **Generate Sample Reports** (every 2 minutes)
   - Lock name: `generateSampleReports`
   - Creates new sample reports with PENDING status

3. **Cleanup Old Reports** (every 5 minutes)
   - Lock name: `cleanupOldReports`
   - Removes COMPLETED reports older than 1 hour

## Sample Data

On startup, the application creates 8 sample reports:
- 5 PENDING reports (will be processed by scheduled tasks)
- 2 COMPLETED reports (one old, one recent)
- 1 FAILED report

## Monitoring

Watch the application logs to see ShedLock in action:
- Scheduled tasks will log their execution
- Only one instance of each task will run at a time
- Reports will be processed and status updated automatically

## Testing ShedLock

To test ShedLock's distributed locking:
1. Start multiple instances of the application
2. Observe that scheduled tasks run only on one instance
3. If one instance fails, another will take over the task execution
