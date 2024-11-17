////
////  PerformanceAnalyzer.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//import Foundation
//
//// MARK: - 性能分析器
//final class PerformanceAnalyzer {
//    
//    // MARK: - 分析项严重程度
//    enum Severity {
//        case info
//        case warning
//        case critical
//        
//        var icon: String {
//            switch self {
//            case .info: return "ℹ️"
//            case .warning: return "⚠️"
//            case .critical: return "🚨"
//            }
//        }
//        
//        var color: UIColor {
//            switch self {
//            case .info: return .systemBlue
//            case .warning: return .systemYellow
//            case .critical: return .systemRed
//            }
//        }
//    }
//    
//    // MARK: - 分析项
//    struct AnalysisItem {
//        let severity: Severity
//        let message: String
//        let recommendation: String?
//        
//        init(severity: Severity, message: String, recommendation: String? = nil) {
//            self.severity = severity
//            self.message = message
//            self.recommendation = recommendation
//        }
//    }
//    
//    // MARK: - 阈值常量
//    private struct Threshold {
//        static let cpuWarning: Double = 70.0
//        static let cpuCritical: Double = 90.0
//        
//        static let memoryWarning: UInt64 = 500_000_000  // 500MB
//        static let memoryCritical: UInt64 = 1_000_000_000  // 1GB
//        
//        static let fpsWarning: Double = 45.0
//        static let fpsCritical: Double = 30.0
//        
//        static let networkWarning: Double = 5_000_000  // 5MB/s
//        static let networkCritical: Double = 10_000_000  // 10MB/s
//        
//        static let durationWarning: TimeInterval = 5.0
//        static let durationCritical: TimeInterval = 10.0
//    }
//    
//    // MARK: - 分析方法
//    func analyze(_ profile: PerformanceProfile) -> [AnalysisItem] {
//        var items: [AnalysisItem] = []
//        
//        // 分析CPU使用率
//        analyzeCPU(profile.metrics.cpuUsage, items: &items)
//        
//        // 分析内存使用
//        analyzeMemory(profile.metrics.memoryUsage, items: &items)
//        
//        // 分析FPS
//        analyzeFPS(profile.metrics.fps, items: &items)
//        
//        // 分析网络吞吐量
//        analyzeNetwork(profile.metrics.networkThroughput, items: &items)
//        
//        // 分析执行时间
//        analyzeDuration(profile.duration, items: &items)
//        
//        return items
//    }
//    
//    // MARK: - 具体分析方法
//    private func analyzeCPU(_ usage: Double, items: inout [AnalysisItem]) {
//        if usage >= Threshold.cpuCritical {
//            items.append(AnalysisItem(
//                severity: .critical,
//                message: "CPU usage is extremely high (\(String(format: "%.1f%%", usage)))",
//                recommendation: "Consider optimizing heavy computations or moving them to background threads"
//            ))
//        } else if usage >= Threshold.cpuWarning {
//            items.append(AnalysisItem(
//                severity: .warning,
//                message: "CPU usage is high (\(String(format: "%.1f%%", usage)))",
//                recommendation: "Monitor CPU-intensive tasks and consider optimization"
//            ))
//        }
//    }
//    
//    private func analyzeMemory(_ usage: UInt64, items: inout [AnalysisItem]) {
//        if usage >= Threshold.memoryCritical {
//            items.append(AnalysisItem(
//                severity: .critical,
//                message: "Memory usage is extremely high (\(ByteCountFormatter.string(fromByteCount: Int64(usage), countStyle: .memory)))",
//                recommendation: "Check for memory leaks and reduce cache sizes"
//            ))
//        } else if usage >= Threshold.memoryWarning {
//            items.append(AnalysisItem(
//                severity: .warning,
//                message: "Memory usage is high (\(ByteCountFormatter.string(fromByteCount: Int64(usage), countStyle: .memory)))",
//                recommendation: "Consider implementing memory optimization techniques"
//            ))
//        }
//    }
//    
//    private func analyzeFPS(_ fps: Double, items: inout [AnalysisItem]) {
//        if fps <= Threshold.fpsCritical {
//            items.append(AnalysisItem(
//                severity: .critical,
//                message: "Frame rate is very low (\(String(format: "%.1f FPS", fps)))",
//                recommendation: "Look for UI thread blockage or heavy drawing operations"
//            ))
//        } else if fps <= Threshold.fpsWarning {
//            items.append(AnalysisItem(
//                severity: .warning,
//                message: "Frame rate is below optimal (\(String(format: "%.1f FPS", fps)))",
//                recommendation: "Consider optimizing UI updates and animations"
//            ))
//        }
//    }
//    
//    private func analyzeNetwork(_ throughput: Double, items: inout [AnalysisItem]) {
//        if throughput >= Threshold.networkCritical {
//            items.append(AnalysisItem(
//                severity: .critical,
//                message: "Network usage is extremely high (\(ByteCountFormatter.string(fromByteCount: Int64(throughput), countStyle: .binary))/s)",
//                recommendation: "Implement data compression and optimize API calls"
//            ))
//        } else if throughput >= Threshold.networkWarning {
//            items.append(AnalysisItem(
//                severity: .warning,
//                message: "Network usage is high (\(ByteCountFormatter.string(fromByteCount: Int64(throughput), countStyle: .binary))/s)",
//                recommendation: "Consider implementing data caching strategies"
//            ))
//        }
//    }
//    
//    private func analyzeDuration(_ duration: TimeInterval, items: inout [AnalysisItem]) {
//        if duration >= Threshold.durationCritical {
//            items.append(AnalysisItem(
//                severity: .critical,
//                message: "Operation took too long (\(String(format: "%.2fs", duration)))",
//                recommendation: "Consider breaking down the operation or moving it to background"
//            ))
//        } else if duration >= Threshold.durationWarning {
//            items.append(AnalysisItem(
//                severity: .warning,
//                message: "Operation duration is longer than expected (\(String(format: "%.2fs", duration)))",
//                recommendation: "Look for optimization opportunities"
//            ))
//        }
//    }
//}
