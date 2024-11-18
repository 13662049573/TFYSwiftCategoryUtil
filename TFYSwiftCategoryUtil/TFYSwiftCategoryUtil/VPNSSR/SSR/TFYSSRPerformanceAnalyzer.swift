//
//  TFYSSRPerformanceAnalyzer.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/11/17.
//

import Foundation
import UIKit

/// 性能分析器
public final class TFYSSRPerformanceAnalyzer {
    /// 单例
    public static let shared = TFYSSRPerformanceAnalyzer()
    
    /// 性能数据结构
    public struct PerformanceMetrics {
        /// 操作计数
        var operationCount: Int = 0
        /// 总处理时间
        var totalDuration: TimeInterval = 0
        /// 总数据大小
        var totalDataSize: Int64 = 0
        /// 平均延迟
        var averageLatency: TimeInterval = 0
        /// 吞吐量 (bytes/second)
        var throughput: Double = 0
        /// CPU使用率
        var cpuUsage: Double = 0
        /// 内存使用量
        var memoryUsage: Int64 = 0
        /// 错误计数
        var errorCount: Int = 0
    }
    
    /// 方法性能统计
    private var methodMetrics: [SSREncryptMethod: PerformanceMetrics] = [:]
    
    /// 性能数据访问队列
    private let queue = DispatchQueue(label: "com.tfy.ssr.performance",
                                    attributes: .concurrent)
    
    private init() {}
    
    /// 开始性能分析
    /// - Parameter method: 加密方法
    /// - Returns: 开始时间戳
    public func beginAnalysis(for method: SSREncryptMethod) -> CFAbsoluteTime {
        return CFAbsoluteTimeGetCurrent()
    }
    
    /// 结束性能分析
    /// - Parameters:
    ///   - method: 加密方法
    ///   - startTime: 开始时间戳
    ///   - dataSize: 数据大小
    public func endAnalysis(for method: SSREncryptMethod,
                          startTime: CFAbsoluteTime,
                          dataSize: Int) {
        queue.async(flags: .barrier) {
            let duration = CFAbsoluteTimeGetCurrent() - startTime
            self.updateMetrics(for: method,
                             duration: duration,
                             dataSize: Int64(dataSize))
        }
    }
    
    /// 记录错误
    /// - Parameter method: 加密方法
    public func recordError(for method: SSREncryptMethod) {
        queue.async(flags: .barrier) {
            var metrics = self.methodMetrics[method] ?? PerformanceMetrics()
            metrics.errorCount += 1
            self.methodMetrics[method] = metrics
        }
    }
    
    /// 获取性能指标
    /// - Parameter method: 加密方法
    /// - Returns: 性能指标
    public func getMetrics(for method: SSREncryptMethod) -> PerformanceMetrics {
        return queue.sync {
            return methodMetrics[method] ?? PerformanceMetrics()
        }
    }
    
    /// 获取性能报告
    /// - Returns: 性能报告字符串
    public func getPerformanceReport() -> String {
        return queue.sync {
            var report = "加密性能报告\n"
            report += "================\n\n"
            
            for (method, metrics) in methodMetrics {
                report += "方法: \(method.rawValue)\n"
                report += "操作次数: \(metrics.operationCount)\n"
                report += "平均延迟: \(String(format: "%.3f", metrics.averageLatency))s\n"
                report += "吞吐量: \(String(format: "%.2f", metrics.throughput / 1_000_000))MB/s\n"
                report += "CPU使用率: \(String(format: "%.1f", metrics.cpuUsage))%\n"
                report += "内存使用: \(ByteCountFormatter.string(fromByteCount: metrics.memoryUsage, countStyle: .file))\n"
                report += "错误次数: \(metrics.errorCount)\n\n"
            }
            
            return report
        }
    }
    
    /// 重置性能指标
    public func resetMetrics() {
        queue.async(flags: .barrier) {
            self.methodMetrics.removeAll()
        }
    }
    
    // MARK: - Private Methods
    
    private func updateMetrics(for method: SSREncryptMethod,
                             duration: TimeInterval,
                             dataSize: Int64) {
        var metrics = methodMetrics[method] ?? PerformanceMetrics()
        
        // 更新基本指标
        metrics.operationCount += 1
        metrics.totalDuration += duration
        metrics.totalDataSize += dataSize
        
        // 计算平均延迟
        metrics.averageLatency = metrics.totalDuration / Double(metrics.operationCount)
        
        // 计算吞吐量
        metrics.throughput = Double(metrics.totalDataSize) / metrics.totalDuration
        
        // 获取CPU使用率
        metrics.cpuUsage = getCPUUsage()
        
        // 获取内存使用量
        metrics.memoryUsage = getMemoryUsage()
        
        methodMetrics[method] = metrics
    }
    
    private func getCPUUsage() -> Double {
        var totalUsageOfCPU: Double = 0.0
        var threadList: thread_act_array_t?
        var threadCount: mach_msg_type_number_t = 0
        let threadResult = task_threads(mach_task_self_, &threadList, &threadCount)
        
        if threadResult == KERN_SUCCESS, let threadList = threadList {
            for index in 0..<threadCount {
                var threadInfo = thread_basic_info()
                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
                let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                        thread_info(threadList[Int(index)],
                                  thread_flavor_t(THREAD_BASIC_INFO),
                                  $0,
                                  &threadInfoCount)
                    }
                }
                
                if infoResult == KERN_SUCCESS {
                    let threadBasicInfo = threadInfo
                    if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                        totalUsageOfCPU = (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)) * 100.0
                    }
                }
            }
            
            vm_deallocate(mach_task_self_,
                         vm_address_t(UInt(bitPattern: threadList)),
                         vm_size_t(Int(threadCount) * MemoryLayout<thread_t>.stride))
        }
        
        return totalUsageOfCPU
    }
    
    private func getMemoryUsage() -> Int64 {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size / MemoryLayout<natural_t>.size)
        let result = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(TASK_VM_INFO),
                         $0,
                         &count)
            }
        }
        
        guard result == KERN_SUCCESS else { return 0 }
        return Int64(taskInfo.phys_footprint)
    }
}
