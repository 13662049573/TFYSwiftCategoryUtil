//
//  TFYSSRPerformanceMonitor.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation
import Darwin

/// SSR性能监控器 - 用于监控CPU、内存和网络延迟
public class TFYSSRPerformanceMonitor {
    /// 单例实例
    public static let shared = TFYSSRPerformanceMonitor()
    
    /// 存储性能指标数据的字典
    private var metrics: [String: Any] = [:]
    
    /// 专用于性能监控的串行队列
    private let queue = DispatchQueue(label: "com.tfy.ssr.monitor")
    
    /// 定时器，用于定期收集性能数据
    private var monitorTimer: Timer?
    
    /// 监控开始时间
    private var startTime: Date?
    
    /// 上一次的CPU使用数据，用于计算使用率变化
    private var lastCPUInfo: processor_info_array_t?
    private var lastCPUInfoSize: mach_msg_type_number_t = 0
    
    /// 性能数据更新回调
    public var metricsUpdated: (([String: Any]) -> Void)?
    
    /// 私有初始化方法
    private init() {}
    
    // MARK: - 公共方法
    
    /// 开始性能监控
    public func start() {
        queue.async { [weak self] in
            self?.startTime = Date()
            self?.metrics.removeAll()
            self?.startCollectingMetrics()
        }
    }
    
    /// 停止性能监控
    public func stop() {
        queue.async { [weak self] in
            self?.stopCollectingMetrics()
            self?.generateReport()
        }
    }
    
    // MARK: - 私有方法 - 数据收集
    
    /// 启动性能数据收集
    private func startCollectingMetrics() {
        // 停止现有定时器
        monitorTimer?.invalidate()
        
        // 创建新定时器，每秒更新一次性能数据
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.queue.async {
                self?.updateCPUUsage()    // 更新CPU使用率
                self?.updateMemoryUsage() // 更新内存使用情况
                self?.updateNetworkLatency() // 更新网络延迟
            }
        }
        
        // 确保定时器在主运行循环中运行
        RunLoop.current.add(monitorTimer!, forMode: .common)
    }
    
    /// 停止性能数据收集
    private func stopCollectingMetrics() {
        // 停止并清理定时器
        monitorTimer?.invalidate()
        monitorTimer = nil
        
        // 释放CPU信息相关资源
        if let lastInfo = lastCPUInfo {
            let size = Int(lastCPUInfoSize)
            vm_deallocate(mach_task_self_,
                         vm_address_t(UnsafePointer(lastInfo).pointee),
                         vm_size_t(size * Int(MemoryLayout<integer_t>.size)))
            lastCPUInfo = nil
            lastCPUInfoSize = 0
        }
    }
    
    /// 生成性能报告
    private func generateReport() {
        guard let startTime = startTime else { return }
        
        // 计算监控持续时间
        let duration = Date().timeIntervalSince(startTime)
        metrics["duration"] = duration
        
        // 生成报告文本
        var report = "SSR性能报告:\n"
        report += "运行时长: \(String(format: "%.2f", duration))秒\n"
        
        // 添加CPU使用率
        if let cpuUsage = metrics["cpu_usage"] as? Double {
            report += "CPU使用率: \(String(format: "%.1f", cpuUsage))%\n"
        }
        
        // 添加内存使用情况
        if let memoryUsage = metrics["memory_usage"] as? Double {
            report += "内存使用: \(String(format: "%.1f", memoryUsage))MB\n"
        }
        
        // 添加内存使用百分比
        if let memoryPercentage = metrics["memory_percentage"] as? Double {
            report += "内存使用率: \(String(format: "%.1f", memoryPercentage))%\n"
        }
        
        // 添加网络延迟
        if let latency = metrics["network_latency"] as? Double {
            report += "网络延迟: \(String(format: "%.1f", latency))ms\n"
        }
        
        // 记录报告
        VPNLogger.log(report)
        
        // 触发回调
        if let callback = metricsUpdated {
            DispatchQueue.main.async {
                callback(self.metrics)
            }
        }
    }
}

// MARK: - CPU使用率监控
private extension TFYSSRPerformanceMonitor {
    /// 获取CPU使用率
    func getCPUUsage() -> Double {
        var totalUsage: Double = 0
        var numCPU: uint = 0
        var numCpuInfo: natural_t = 0
        var cpuLoad: natural_t = 0
        
        // 1. 获取CPU核心数
        var mibKeys: [Int32] = [CTL_HW, HW_NCPU]
        var sizeOfNumCPU = MemoryLayout<uint>.size
        let status = sysctl(&mibKeys, 2, &numCPU, &sizeOfNumCPU, nil, 0)
        
        if status != 0 { return 0 }
        
        // 2. 获取CPU负载信息
        var cpuInfo: processor_info_array_t? = nil
        cpuLoad = UInt32(CPU_STATE_MAX * Int32(numCPU))
        let result = host_processor_info(mach_host_self(),
                                       PROCESSOR_CPU_LOAD_INFO,
                                       &cpuLoad,
                                       &cpuInfo,
                                       &numCpuInfo)
        
        guard result == KERN_SUCCESS, let info = cpuInfo else { return 0 }
        
        // 3. 确保资源释放
        defer {
            vm_deallocate(mach_task_self_,
                         vm_address_t(UnsafePointer(info).pointee),
                         vm_size_t(cpuLoad * UInt32(MemoryLayout<integer_t>.stride)))
        }
        
        // 4. 计算每个CPU核心的使用率
        for i in 0..<Int(numCPU) {
            let cpuStateMax = Int(CPU_STATE_MAX)
            let offset = cpuStateMax * i
            
            // 获取各种CPU状态的时间
            let inUser = Int(info[offset + Int(CPU_STATE_USER)])    // 用户态时间
            let inSystem = Int(info[offset + Int(CPU_STATE_SYSTEM)])  // 系统态时间
            let inIdle = Int(info[offset + Int(CPU_STATE_IDLE)])    // 空闲时间
            let inNice = Int(info[offset + Int(CPU_STATE_NICE)])    // 优先级调度时间
            
            // 计算总时间和使用率
            let total = Double(inUser + inSystem + inIdle + inNice)
            let usage = Double(inUser + inSystem + inNice) / total * 100.0
            totalUsage += usage
        }
        
        // 5. 返回平均CPU使用率
        return totalUsage / Double(numCPU)
    }
    
    /// 更新CPU使用率
    func updateCPUUsage() {
        let usage = getCPUUsage()
        metrics["cpu_usage"] = usage
        
        // 通知观察者
        if let callback = metricsUpdated {
            DispatchQueue.main.async {
                callback(["cpu_usage": usage])
            }
        }
    }
}

// MARK: - 内存使用监控
private extension TFYSSRPerformanceMonitor {
    /// 获取内存使用情况
    func getMemoryUsage() -> (used: Double, total: Double, percentage: Double) {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        // 获取任务内存信息
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else { return (0, 0, 0) }
        
        // 计算内存使用情况（转换为MB）
        let usedMemory = Double(info.resident_size) / (1024 * 1024)
        let totalMemory = Double(ProcessInfo.processInfo.physicalMemory) / (1024 * 1024)
        let percentage = (usedMemory / totalMemory) * 100
        
        return (usedMemory, totalMemory, percentage)
    }
    
    /// 更新内存使用情况
    func updateMemoryUsage() {
        let memoryInfo = getMemoryUsage()
        
        // 更新metrics
        metrics["memory_usage"] = memoryInfo.used
        metrics["total_memory"] = memoryInfo.total
        metrics["memory_percentage"] = memoryInfo.percentage
        
        // 通知观察者
        if let callback = metricsUpdated {
            DispatchQueue.main.async {
                callback([
                    "memory_usage": memoryInfo.used,
                    "total_memory": memoryInfo.total,
                    "memory_percentage": memoryInfo.percentage
                ])
            }
        }
    }
}

// MARK: - 网络延迟监控
private extension TFYSSRPerformanceMonitor {
    /// 更新网络延迟
    func updateNetworkLatency() {
        guard let serverAddress = TFYSSRAccelerator.shared.serverAddress else { return }
        
        testNetworkLatency(to: serverAddress) { [weak self] latency in
            guard let self = self, let latency = latency else { return }
            
            // 更新metrics
            self.metrics["network_latency"] = latency
            
            // 通知观察者
            if let callback = self.metricsUpdated {
                DispatchQueue.main.async {
                    callback(["network_latency": latency])
                }
            }
        }
    }
    
    /// 测试网络延迟
    func testNetworkLatency(to host: String, completion: @escaping (Double?) -> Void) {
        DispatchQueue.global(qos: .utility).async {
            let startTime = Date()
            
            // 创建网络请求
            var request = URLRequest(url: URL(string: "https://\(host)")!)
            request.timeoutInterval = 1 // 设置超时时间为1秒
            
            // 发起请求并计算延迟
            let task = URLSession.shared.dataTask(with: request) { _, _, _ in
                let latency = Date().timeIntervalSince(startTime) * 1000 // 转换为毫秒
                completion(latency)
            }
            
            task.resume()
        }
    }
} 