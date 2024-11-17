////
////  TrafficManager.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import Foundation
//
//
//// MARK: - 流量统计管理器
//final class TrafficManager {
//    static let shared = TrafficManager()
//    
//    // MARK: - 属性
//    private let queue = DispatchQueue(label: "com.tfy.ssr.traffic", qos: .utility)
//    private let storage = TrafficStorage()
//    private var timer: Timer?
//    private var currentStats: TrafficStats
//    private var observers: [UUID: TrafficObserver] = [:]
//    
//    // MARK: - 初始化
//    private init() {
//        self.currentStats = TrafficStats()
//        setupTimer()
//    }
//    
//    // MARK: - 公共方法
//    func startMonitoring() {
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
//            self?.updateStats()
//        }
//    }
//    
//    func stopMonitoring() {
//        timer?.invalidate()
//        timer = nil
//    }
//    
//    func addTraffic(_ bytes: Int64, type: TrafficType) {
//        queue.async {
//            switch type {
//            case .upload:
//                self.currentStats.uploadBytes += bytes
//            case .download:
//                self.currentStats.downloadBytes += bytes
//            }
//            self.notifyObservers()
//        }
//    }
//    
//    func resetStats() {
//        queue.async {
//            self.currentStats = TrafficStats()
//            self.notifyObservers()
//        }
//    }
//    
//    func getCurrentStats() -> TrafficStats {
//        queue.sync { currentStats }
//    }
//    
//    func getHistoricalStats(for period: StatsPeriod) -> [TrafficStats] {
//        storage.getStats(for: period)
//    }
//    
//    @discardableResult
//    func addObserver(_ handler: @escaping (TrafficStats) -> Void) -> UUID {
//        let id = UUID()
//        queue.async {
//            self.observers[id] = TrafficObserver(handler: handler)
//            handler(self.currentStats)
//        }
//        return id
//    }
//    
//    func removeObserver(_ id: UUID) {
//        queue.async {
//            self.observers.removeValue(forKey: id)
//        }
//    }
//    
//    // MARK: - 私有方法
//    private func setupTimer() {
//        startMonitoring()
//    }
//    
//    private func updateStats() {
//        queue.async {
//            // 计算速率
//            self.currentStats.uploadSpeed = self.calculateSpeed(self.currentStats.uploadBytes, previousBytes: self.currentStats.previousUploadBytes)
//            self.currentStats.downloadSpeed = self.calculateSpeed(self.currentStats.downloadBytes, previousBytes: self.currentStats.previousDownloadBytes)
//            
//            // 更新历史字节数
//            self.currentStats.previousUploadBytes = self.currentStats.uploadBytes
//            self.currentStats.previousDownloadBytes = self.currentStats.downloadBytes
//            
//            // 保存统计数据
//            self.storage.saveStats(self.currentStats)
//            
//            // 通知观察者
//            self.notifyObservers()
//        }
//    }
//    
//    private func calculateSpeed(_ currentBytes: Int64, previousBytes: Int64) -> Double {
//        Double(currentBytes - previousBytes)
//    }
//    
//    private func notifyObservers() {
//        observers.values.forEach { observer in
//            DispatchQueue.main.async {
//                observer.handler(self.currentStats)
//            }
//        }
//    }
//}
//
//// MARK: - 性能监控管理器
//final class PerformanceManager {
//    static let shared = PerformanceManager()
//    
//    // MARK: - 属性
//    private let queue = DispatchQueue(label: "com.tfy.ssr.performance", qos: .utility)
//    private var timer: Timer?
//    private var currentMetrics: PerformanceMetrics
//    private var observers: [UUID: PerformanceObserver] = [:]
//    
//    // MARK: - 初始化
//    private init() {
//        self.currentMetrics = PerformanceMetrics()
//        setupTimer()
//    }
//    
//    // MARK: - 公共方法
//    func startMonitoring() {
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
//            self?.updateMetrics()
//        }
//    }
//    
//    func stopMonitoring() {
//        timer?.invalidate()
//        timer = nil
//    }
//    
//    func getCurrentMetrics() -> PerformanceMetrics {
//        queue.sync { currentMetrics }
//    }
//    
//    @discardableResult
//    func addObserver(_ handler: @escaping (PerformanceMetrics) -> Void) -> UUID {
//        let id = UUID()
//        queue.async {
//            self.observers[id] = PerformanceObserver(handler: handler)
//            handler(self.currentMetrics)
//        }
//        return id
//    }
//    
//    func removeObserver(_ id: UUID) {
//        queue.async {
//            self.observers.removeValue(forKey: id)
//        }
//    }
//    
//    // MARK: - 私有方法
//    private func setupTimer() {
//        startMonitoring()
//    }
//    
//    private func updateMetrics() {
//        queue.async {
//            // 更新CPU使用率
//            self.currentMetrics.cpuUsage = self.getCPUUsage()
//            
//            // 更新内存使用情况
//            self.currentMetrics.memoryUsage = self.getMemoryUsage()
//            
//            // 更新网络延迟
//            self.currentMetrics.networkLatency = self.getNetworkLatency()
//            
//            // 更新连接数
//            self.currentMetrics.connectionCount = self.getConnectionCount()
//            
//            // 通知观察者
//            self.notifyObservers()
//        }
//    }
//    
//    private func getCPUUsage() -> Double {
//        // 实现CPU使用率计算
//        var totalUsageOfCPU: Double = 0.0
//        var thread_list: thread_act_array_t?
//        var thread_count: mach_msg_type_number_t = 0
//        let thread_info_count = THREAD_INFO_MAX
//        let thread_basic_info_count = mach_msg_type_number_t(THREAD_BASIC_INFO_COUNT)
//        var thread_basic_info_data: thread_basic_info = thread_basic_info()
//        
//        let task = mach_task_self_
//        
//        if task_threads(task, &thread_list, &thread_count) == KERN_SUCCESS {
//            if let thread_list = thread_list {
//                for i in 0 ..< Int(thread_count) {
//                    var thread_info_count = thread_info_count
//                    
//                    if thread_info(thread_list[i], thread_flavor_t(THREAD_BASIC_INFO),
//                                 &thread_basic_info_data as UnsafeMutablePointer<thread_basic_info>,
//                                 &thread_basic_info_count) == KERN_SUCCESS {
//                        let threadBasicInfo = thread_basic_info_data
//                        
//                        if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
//                            totalUsageOfCPU = (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)) * 100.0
//                        }
//                    }
//                }
//            }
//            
//            vm_deallocate(task, vm_address_t(UInt(bitPattern: thread_list)), vm_size_t(thread_count * UInt32(MemoryLayout<thread_t>.size)))
//        }
//        
//        return totalUsageOfCPU
//    }
//    
//    private func getMemoryUsage() -> UInt64 {
//        var taskInfo = task_vm_info_data_t()
//        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
//        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
//            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
//                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
//            }
//        }
//        
//        if result == KERN_SUCCESS {
//            return taskInfo.phys_footprint
//        }
//        
//        return 0
//    }
//    
//    private func getNetworkLatency() -> TimeInterval {
//        // 实现网络延迟测量
//        return 0.0
//    }
//    
//    private func getConnectionCount() -> Int {
//        // 实现连接数统计
//        return 0
//    }
//    
//    private func notifyObservers() {
//        observers.values.forEach { observer in
//            DispatchQueue.main.async {
//                observer.handler(self.currentMetrics)
//            }
//        }
//    }
//}
//
//// MARK: - 数据模型
//struct TrafficStats: Codable {
//    var uploadBytes: Int64 = 0
//    var downloadBytes: Int64 = 0
//    var uploadSpeed: Double = 0
//    var downloadSpeed: Double = 0
//    var previousUploadBytes: Int64 = 0
//    var previousDownloadBytes: Int64 = 0
//    var timestamp: Date = Date()
//}
//
//struct PerformanceMetrics {
//    var cpuUsage: Double = 0
//    var memoryUsage: UInt64 = 0
//    var networkLatency: TimeInterval = 0
//    var connectionCount: Int = 0
//    var timestamp: Date = Date()
//}
//
//enum TrafficType {
//    case upload
//    case download
//}
//
//enum StatsPeriod {
//    case hour
//    case day
//    case week
//    case month
//}
//
//// MARK: - 观察者类型
//struct TrafficObserver {
//    let handler: (TrafficStats) -> Void
//}
//
//struct PerformanceObserver {
//    let handler: (PerformanceMetrics) -> Void
//}
