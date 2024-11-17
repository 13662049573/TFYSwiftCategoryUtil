////
////  PerformanceReportGenerator.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import Foundation
//import UIKit
//
//// MARK: - 性能报告生成器
//final class PerformanceReportGenerator {
//    
//    // MARK: - 报告类型
//    enum ReportType {
//        case summary
//        case detailed
//        case custom([ReportSection])
//    }
//    
//    // MARK: - 报告部分
//    enum ReportSection {
//        case overview
//        case cpu
//        case memory
//        case fps
//        case network
//        case analysis
//        case recommendations
//    }
//    
//    // MARK: - 报告生成
//    func generateReport(for profile: PerformanceProfile, type: ReportType = .detailed) -> String {
//        let sections: [ReportSection]
//        
//        switch type {
//        case .summary:
//            sections = [.overview, .analysis]
//        case .detailed:
//            sections = [.overview, .cpu, .memory, .fps, .network, .analysis, .recommendations]
//        case .custom(let customSections):
//            sections = customSections
//        }
//        
//        return sections.map { generateSection($0, for: profile) }.joined(separator: "\n\n")
//    }
//    
//    // MARK: - 部分生成
//    private func generateSection(_ section: ReportSection, for profile: PerformanceProfile) -> String {
//        switch section {
//        case .overview:
//            return generateOverview(for: profile)
//        case .cpu:
//            return generateCPUSection(for: profile)
//        case .memory:
//            return generateMemorySection(for: profile)
//        case .fps:
//            return generateFPSSection(for: profile)
//        case .network:
//            return generateNetworkSection(for: profile)
//        case .analysis:
//            return generateAnalysis(for: profile)
//        case .recommendations:
//            return generateRecommendations(for: profile)
//        }
//    }
//    
//    private func generateOverview(for profile: PerformanceProfile) -> String {
//        return """
//        Performance Report Overview
//        -------------------------
//        Profile Name: \(profile.name)
//        Duration: \(MetricsFormatter.formatDuration(profile.duration))
//        Start Time: \(formatDate(profile.startTime))
//        End Time: \(formatDate(profile.endTime))
//        
//        Overall Status: \(determineOverallStatus(for: profile))
//        """
//    }
//    
//    private func generateCPUSection(for profile: PerformanceProfile) -> String {
//        let metrics = profile.metrics
//        return """
//        CPU Usage
//        ---------
//        Average: \(MetricsFormatter.formatCPU(metrics.cpuUsage))
//        Peak: \(MetricsFormatter.formatCPU(metrics.peakCPUUsage))
//        Time Above Warning Threshold: \(formatPercentage(metrics.cpuWarningTime))
//        Time Above Critical Threshold: \(formatPercentage(metrics.cpuCriticalTime))
//        """
//    }
//    
//    private func generateMemorySection(for profile: PerformanceProfile) -> String {
//        let metrics = profile.metrics
//        return """
//        Memory Usage
//        ------------
//        Average: \(MetricsFormatter.formatMemory(metrics.memoryUsage))
//        Peak: \(MetricsFormatter.formatMemory(metrics.peakMemoryUsage))
//        Allocations: \(metrics.memoryAllocations)
//        Deallocations: \(metrics.memoryDeallocations)
//        Potential Leaks: \(metrics.potentialMemoryLeaks)
//        """
//    }
//    
//    private func generateFPSSection(for profile: PerformanceProfile) -> String {
//        let metrics = profile.metrics
//        return """
//        Frame Rate
//        ----------
//        Average FPS: \(MetricsFormatter.formatFPS(metrics.fps))
//        Minimum FPS: \(MetricsFormatter.formatFPS(metrics.minFPS))
//        Frame Drops: \(metrics.frameDrops)
//        Time Below Target FPS: \(formatPercentage(metrics.lowFPSTime))
//        """
//    }
//    
//    private func generateNetworkSection(for profile: PerformanceProfile) -> String {
//        let metrics = profile.metrics
//        return """
//        Network Performance
//        ------------------
//        Average Throughput: \(MetricsFormatter.formatNetwork(metrics.networkThroughput))
//        Total Data Transferred: \(MetricsFormatter.formatMemory(metrics.totalDataTransferred))
//        Requests: \(metrics.networkRequests)
//        Failed Requests: \(metrics.failedRequests)
//        Average Response Time: \(MetricsFormatter.formatDuration(metrics.averageResponseTime))
//        """
//    }
//    
//    private func generateAnalysis(for profile: PerformanceProfile) -> String {
//        let analyzer = PerformanceAnalyzer()
//        let analysis = analyzer.analyze(profile)
//        
//        let analysisText = analysis.map { item in
//            "[\(item.severity.icon)] \(item.message)"
//        }.joined(separator: "\n")
//        
//        return """
//        Performance Analysis
//        -------------------
//        \(analysisText)
//        """
//    }
//    
//    private func generateRecommendations(for profile: PerformanceProfile) -> String {
//        let analyzer = PerformanceAnalyzer()
//        let analysis = analyzer.analyze(profile)
//        
//        let recommendations = analysis.compactMap { item in
//            item.recommendation
//        }.joined(separator: "\n")
//        
//        return """
//        Recommendations
//        ---------------
//        \(recommendations.isEmpty ? "No specific recommendations at this time." : recommendations)
//        """
//    }
//    
//    // MARK: - 辅助方法
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        return formatter.string(from: date)
//    }
//    
//    private func formatPercentage(_ value: Double) -> String {
//        return String(format: "%.1f%%", value * 100)
//    }
//    
//    private func determineOverallStatus(for profile: PerformanceProfile) -> String {
//        let metrics = profile.metrics
//        
//        if metrics.cpuUsage >= PerformanceThresholds.cpuCritical ||
//           metrics.memoryUsage >= PerformanceThresholds.memoryCritical ||
//           metrics.fps <= PerformanceThresholds.fpsCritical {
//            return "⛔️ Critical Issues Detected"
//        } else if metrics.cpuUsage >= PerformanceThresholds.cpuWarning ||
//                  metrics.memoryUsage >= PerformanceThresholds.memoryWarning ||
//                  metrics.fps <= PerformanceThresholds.fpsWarning {
//            return "⚠️ Performance Warnings"
//        } else {
//            return "✅ Good"
//        }
//    }
//}
