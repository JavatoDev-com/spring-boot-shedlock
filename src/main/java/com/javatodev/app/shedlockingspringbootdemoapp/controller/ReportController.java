package com.javatodev.app.shedlockingspringbootdemoapp.controller;

import com.javatodev.app.shedlockingspringbootdemoapp.model.dto.ReportData;
import com.javatodev.app.shedlockingspringbootdemoapp.model.entity.ReportDataEntity;
import com.javatodev.app.shedlockingspringbootdemoapp.repository.ReportDataRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/reports")
public class ReportController {
    
    @Autowired
    private ReportDataRepository reportDataRepository;
    
    @GetMapping
    public ResponseEntity<List<ReportData>> getAllReports() {
        List<ReportDataEntity> entities = reportDataRepository.findAll();
        List<ReportData> reports = entities.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(reports);
    }
    
    @GetMapping("/status/{status}")
    public ResponseEntity<List<ReportData>> getReportsByStatus(@PathVariable String status) {
        List<ReportDataEntity> entities = reportDataRepository.findByStatus(status.toUpperCase());
        List<ReportData> reports = entities.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(reports);
    }
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<ReportData>> getReportsByUser(@PathVariable String userId) {
        List<ReportDataEntity> entities = reportDataRepository.findByUserId(userId);
        List<ReportData> reports = entities.stream()
                .map(this::convertToDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(reports);
    }
    
    @GetMapping("/stats")
    public ResponseEntity<ReportStats> getReportStats() {
        long totalReports = reportDataRepository.count();
        long pendingReports = reportDataRepository.findByStatus("PENDING").size();
        long processingReports = reportDataRepository.countProcessingReports();
        long completedReports = reportDataRepository.findByStatus("COMPLETED").size();
        long failedReports = reportDataRepository.findByStatus("FAILED").size();
        
        ReportStats stats = new ReportStats(totalReports, pendingReports, processingReports, completedReports, failedReports);
        return ResponseEntity.ok(stats);
    }
    
    private ReportData convertToDto(ReportDataEntity entity) {
        ReportData dto = new ReportData();
        dto.setId(entity.getId());
        dto.setUserId(entity.getUserId());
        dto.setReportType(entity.getReportType());
        dto.setReportData(entity.getReportData());
        dto.setStatus(entity.getStatus());
        dto.setCreatedAt(entity.getCreatedAt());
        dto.setUpdatedAt(entity.getUpdatedAt());
        dto.setProcessedAt(entity.getProcessedAt());
        return dto;
    }
    
    public static class ReportStats {
        private long totalReports;
        private long pendingReports;
        private long processingReports;
        private long completedReports;
        private long failedReports;
        
        public ReportStats(long totalReports, long pendingReports, long processingReports, 
                          long completedReports, long failedReports) {
            this.totalReports = totalReports;
            this.pendingReports = pendingReports;
            this.processingReports = processingReports;
            this.completedReports = completedReports;
            this.failedReports = failedReports;
        }
        
        // Getters
        public long getTotalReports() { return totalReports; }
        public long getPendingReports() { return pendingReports; }
        public long getProcessingReports() { return processingReports; }
        public long getCompletedReports() { return completedReports; }
        public long getFailedReports() { return failedReports; }
    }
}
