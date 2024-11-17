////
////  PerformanceManager.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import Foundation
//import UIKit
//
//// MARK: - 性能监控管理器
//final class PerformanceManager {
//    static let shared = PerformanceManager()
//    
//    // MARK: - 属性
//    private let queue = DispatchQueue(label: "com.tfy.ssr.performance", qos: .utility)
//    private var observers: [UUID: PerformanceObserver] = [:]
//    private var timer: Timer?
//    private var isMonitoring = false
//    
//    private var currentMetrics = PerformanceMetrics()
//    private let memoryInfo = ProcessInfo.processInfo
//    private let cpuInfo = host_processor_info()
//    
//    // MARK: - 初始化
//    private init() {}
//    
//    // MARK: - 公共方法
//    func startMonitoring() {
//        guard !isMonitoring else { return }
//        isMonitoring = true
//        
//        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
//            self?.updateMetrics()
//        }
//    }
//    
//    func stopMonitoring() {
//        isMonitoring = false
//        timer?.invalidate()
//        timer = nil
//    }
//    
//    @discardableResult
//    func addObserver(_ handler: @escaping (PerformanceMetrics) -> Void) -> UUID {
//        let id = UUID()
//        queue.async {
//            self.observers[id] = PerformanceObserver(handler: handler)
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
//    private func updateMetrics() {
//        queue.async {
//            self.currentMetrics = PerformanceMetrics(
//                cpuUsage: self.getCPUUsage(),
//                memoryUsage: self.getMemoryUsage(),
//                fps: self.getFPS(),
//                networkThroughput: self.getNetworkThroughput(),
//                timestamp: Date()
//            )
//            self.notifyObservers()
//        }
//    }
//    
//    private func getCPUUsage() -> Double {
//        var totalUsageOfCPU: Double = 0.0
//        var threadList: thread_act_array_t?
//        var threadCount: mach_msg_type_number_t = 0
//        let threadResult = task_threads(mach_task_self_, &threadList, &threadCount)
//        
//        if threadResult == KERN_SUCCESS, let threadList = threadList {
//            for index in 0..<threadCount {
//                var threadInfo = thread_basic_info()
//                var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
//                let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
//                    $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
//                        thread_info(threadList[Int(index)],
//                                  thread_flavor_t(THREAD_BASIC_INFO),
//                                  $0,
//                                  &threadInfoCount)
//                    }
//                }
//                
//                if infoResult == KERN_SUCCESS {
//                    let threadBasicInfo = threadInfo
//                    if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
//                        totalUsageOfCPU = (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE)) * 100.0
//                    }
//                }
//            }
//            
//            vm_deallocate(mach_task_self_,
//                         vm_address_t(UInt(bitPattern: threadList)),
//                         vm_size_t(Int(threadCount) * MemoryLayout<thread_t>.stride))
//        }
//        
//        return totalUsageOfCPU
//    }
//    
//    private func getMemoryUsage() -> UInt64 {
//        var taskInfo = task_vm_info_data_t()
//        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size / MemoryLayout<natural_t>.size)
//        let result = withUnsafeMutablePointer(to: &taskInfo) {
//            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
//                task_info(mach_task_self_,
//                         task_flavor_t(TASK_VM_INFO),
//                         $0,
//                         &count)
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
//    private func getFPS() -> Double {
//        // 使用CADisplayLink实现FPS计算
//        return DisplayLinkManager.shared.fps
//    }
//    
//    private func getNetworkThroughput() -> Double {
//        // 从NetworkDebugger获取网络吞吐量
//        return NetworkDebugger.shared.currentThroughput
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
//// MARK: - 显示链接管理器
//final class DisplayLinkManager {
//    static let shared = DisplayLinkManager()
//    
//    private var displayLink: CADisplayLink?
//    private var lastTimestamp: CFTimeInterval = 0
//    private var frameCount = 0
//    private(set) var fps: Double = 0
//    
//    private init() {
//        setupDisplayLink()
//    }
//    
//    private func setupDisplayLink() {
//        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTick))
//        displayLink?.add(to: .main, forMode: .common)
//    }
//    
//    @objc private func displayLinkTick(displayLink: CADisplayLink) {
//        if lastTimestamp == 0 {
//            lastTimestamp = displayLink.timestamp
//            return
//        }
//        
//        frameCount += 1
//        let elapsed = displayLink.timestamp - lastTimestamp
//        
//        if elapsed >= 1.0 {
//            fps = Double(frameCount) / elapsed
//            frameCount = 0
//            lastTimestamp = displayLink.timestamp
//        }
//    }
//}
//
//// MARK: - 性能指标模型
//struct PerformanceMetrics {
//    let cpuUsage: Double
//    let memoryUsage: UInt64
//    let fps: Double
//    let networkThroughput: Double
//    let timestamp: Date
//    
//    var formattedCPUUsage: String {
//        return String(format: "%.1f%%", cpuUsage)
//    }
//    
//    var formattedMemoryUsage: String {
//        return ByteCountFormatter.string(fromByteCount: Int64(memoryUsage), countStyle: .memory)
//    }
//    
//    var formattedFPS: String {
//        return String(format: "%.1f FPS", fps)
//    }
//    
//    var formattedNetworkThroughput: String {
//        return ByteCountFormatter.string(fromByteCount: Int64(networkThroughput), countStyle: .binary) + "/s"
//    }
//}
//
//// MARK: - 性能观察者
//struct PerformanceObserver {
//    let handler: (PerformanceMetrics) -> Void
//}
