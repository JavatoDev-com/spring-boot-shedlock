package com.javatodev.app.shedlockingspringbootdemoapp.repository;

import com.javatodev.app.shedlockingspringbootdemoapp.model.entity.ReportDataEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReportDataRepository extends JpaRepository<ReportDataEntity, Long> {
    
    List<ReportDataEntity> findByStatus(String status);
    
    List<ReportDataEntity> findByUserId(String userId);
    
    @Query("SELECT r FROM ReportDataEntity r WHERE r.status = 'PENDING' ORDER BY r.createdAt ASC")
    List<ReportDataEntity> findPendingReportsOrderByCreatedAt();
    
    @Query("SELECT COUNT(r) FROM ReportDataEntity r WHERE r.status = 'PROCESSING'")
    long countProcessingReports();
}
