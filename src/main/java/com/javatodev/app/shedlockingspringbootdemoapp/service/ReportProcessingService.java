package com.javatodev.app.shedlockingspringbootdemoapp.service;

import com.javatodev.app.shedlockingspringbootdemoapp.model.entity.ReportDataEntity;
import com.javatodev.app.shedlockingspringbootdemoapp.repository.ReportDataRepository;
import net.javacrumbs.shedlock.spring.annotation.SchedulerLock;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ReportProcessingService {
    
    private static final Logger logger = LoggerFactory.getLogger(ReportProcessingService.class);
    
    @Autowired
    private ReportDataRepository reportDataRepository;
    
    /**
     * This method runs every 30 seconds and processes pending reports
     * The @SchedulerLock ensures that only one instance of this method runs at a time
     * across all application instances in a distributed environment
     */
    @Scheduled(fixedRate = 30000) // Run every 30 seconds
    @SchedulerLock(name = "processPendingReports", lockAtMostFor = "25s", lockAtLeastFor = "5s")
    public void processPendingReports() {
        logger.info("Starting to process pending reports at: {}", LocalDateTime.now());
        
        try {
            // Find all pending reports
            List<ReportDataEntity> pendingReports = reportDataRepository.findPendingReportsOrderByCreatedAt();
            
            if (pendingReports.isEmpty()) {
                logger.info("No pending reports found");
                return;
            }
            
            logger.info("Found {} pending reports to process", pendingReports.size());
            
            // Process each pending report
            for (ReportDataEntity report : pendingReports) {
                processReport(report);
            }
            
            logger.info("Completed processing pending reports at: {}", LocalDateTime.now());
            
        } catch (Exception e) {
            logger.error("Error occurred while processing pending reports", e);
        }
    }
    
    /**
     * This method runs every 2 minutes to generate sample reports
     * Demonstrates how ShedLock prevents duplicate report generation
     */
    @Scheduled(fixedRate = 120000) // Run every 2 minutes
    @SchedulerLock(name = "generateSampleReports", lockAtMostFor = "110s", lockAtLeastFor = "10s")
    public void generateSampleReports() {
        logger.info("Starting to generate sample reports at: {}", LocalDateTime.now());
        
        try {
            // Generate a sample report
            ReportDataEntity sampleReport = new ReportDataEntity();
            sampleReport.setUserId("user_" + System.currentTimeMillis());
            sampleReport.setReportType("SAMPLE_REPORT");
            sampleReport.setReportData("Sample report data generated at: " + LocalDateTime.now());
            sampleReport.setStatus("PENDING");
            
            reportDataRepository.save(sampleReport);
            
            logger.info("Generated sample report for user: {}", sampleReport.getUserId());
            
        } catch (Exception e) {
            logger.error("Error occurred while generating sample reports", e);
        }
    }
    
    /**
     * This method runs every 5 minutes to clean up completed reports older than 1 hour
     */
    @Scheduled(fixedRate = 300000) // Run every 5 minutes
    @SchedulerLock(name = "cleanupOldReports", lockAtMostFor = "290s", lockAtLeastFor = "10s")
    public void cleanupOldReports() {
        logger.info("Starting cleanup of old reports at: {}", LocalDateTime.now());
        
        try {
            LocalDateTime cutoffTime = LocalDateTime.now().minusHours(1);
            
            // Find completed reports older than 1 hour
            List<ReportDataEntity> oldReports = reportDataRepository.findAll().stream()
                    .filter(report -> "COMPLETED".equals(report.getStatus()) && 
                            report.getProcessedAt() != null && 
                            report.getProcessedAt().isBefore(cutoffTime))
                    .toList();
            
            if (!oldReports.isEmpty()) {
                reportDataRepository.deleteAll(oldReports);
                logger.info("Cleaned up {} old completed reports", oldReports.size());
            } else {
                logger.info("No old reports found for cleanup");
            }
            
        } catch (Exception e) {
            logger.error("Error occurred while cleaning up old reports", e);
        }
    }
    
    private void processReport(ReportDataEntity report) {
        try {
            logger.info("Processing report ID: {} for user: {}", report.getId(), report.getUserId());
            
            // Update status to PROCESSING
            report.setStatus("PROCESSING");
            reportDataRepository.save(report);
            
            // Simulate report processing time
            Thread.sleep(2000); // 2 seconds
            
            // Update report data with processed content
            report.setReportData("Processed: " + report.getReportData() + " | Processed at: " + LocalDateTime.now());
            report.setStatus("COMPLETED");
            report.setProcessedAt(LocalDateTime.now());
            
            reportDataRepository.save(report);
            
            logger.info("Successfully processed report ID: {}", report.getId());
            
        } catch (Exception e) {
            logger.error("Error processing report ID: {}", report.getId(), e);
            
            // Mark report as failed
            report.setStatus("FAILED");
            reportDataRepository.save(report);
        }
    }
}
