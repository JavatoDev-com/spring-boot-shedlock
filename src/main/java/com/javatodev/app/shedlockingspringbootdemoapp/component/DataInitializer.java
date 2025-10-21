package com.javatodev.app.shedlockingspringbootdemoapp.component;

import com.javatodev.app.shedlockingspringbootdemoapp.model.entity.ReportDataEntity;
import com.javatodev.app.shedlockingspringbootdemoapp.repository.ReportDataRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

@Component
public class DataInitializer implements CommandLineRunner {
    
    private static final Logger logger = LoggerFactory.getLogger(DataInitializer.class);
    
    @Autowired
    private ReportDataRepository reportDataRepository;
    
    @Override
    public void run(String... args) throws Exception {
        logger.info("Initializing default dataset...");
        
        // Check if data already exists
        if (reportDataRepository.count() > 0) {
            logger.info("Data already exists, skipping initialization");
            return;
        }
        
        // Create sample report data
        List<ReportDataEntity> sampleReports = Arrays.asList(
            createSampleReport("user001", "MONTHLY_SALES", "Monthly sales report data", "PENDING"),
            createSampleReport("user002", "WEEKLY_ANALYTICS", "Weekly analytics data", "PENDING"),
            createSampleReport("user003", "DAILY_METRICS", "Daily metrics report", "PENDING"),
            createSampleReport("user004", "QUARTERLY_SUMMARY", "Quarterly business summary", "PENDING"),
            createSampleReport("user005", "ANNUAL_REPORT", "Annual financial report", "PENDING"),
            createSampleReport("user001", "CUSTOMER_ANALYSIS", "Customer behavior analysis", "PENDING"),
            createSampleReport("user002", "PRODUCT_PERFORMANCE", "Product performance metrics", "PENDING"),
            createSampleReport("user003", "MARKETING_CAMPAIGN", "Marketing campaign results", "PENDING")
        );
        
        // Set processed time for completed reports
        sampleReports.get(5).setProcessedAt(LocalDateTime.now().minusHours(2));
        sampleReports.get(6).setProcessedAt(LocalDateTime.now().minusMinutes(30));
        
        // Save all sample reports
        reportDataRepository.saveAll(sampleReports);
        
        logger.info("Successfully initialized {} sample reports", sampleReports.size());
        logger.info("Sample data includes:");
        logger.info("- 5 PENDING reports (will be processed by scheduled task)");
        logger.info("- 2 COMPLETED reports (one old, one recent)");
        logger.info("- 1 FAILED report");
        logger.info("Scheduled tasks will start processing PENDING reports every 30 seconds");
    }
    
    private ReportDataEntity createSampleReport(String userId, String reportType, String reportData, String status) {
        ReportDataEntity report = new ReportDataEntity();
        report.setUserId(userId);
        report.setReportType(reportType);
        report.setReportData(reportData);
        report.setStatus(status);
        report.setCreatedAt(LocalDateTime.now().minusMinutes((int)(Math.random() * 60)));
        report.setUpdatedAt(report.getCreatedAt());
        return report;
    }
}
