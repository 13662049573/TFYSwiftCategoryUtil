//
//  TFYSSRMemoryOptimizer.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/11/17.
//

import Foundation
import UIKit
import WebKit  // 添加 WebKit 导入

/// SSR内存优化器
public final class TFYSSRMemoryOptimizer {
    /// 单例
    public static let shared = TFYSSRMemoryOptimizer()
    
    /// 内存配置
    public struct MemoryConfig {
        /// 内存警告阈值（默认80%）
        var warningThreshold: Double = 0.8
        /// 内存临界阈值（默认90%）
        var criticalThreshold: Double = 0.9
        /// 最大缓存大小
        var maxCacheSize: Int64 = 100 * 1024 * 1024  // 100MB
        /// 最大缓冲区大小
        var maxBufferSize: Int = 32 * 1024  // 32KB
        /// 是否启用自动内存回收
        var enableAutoReclaim: Bool = true
        /// 内存回收间隔（秒）
        var reclaimInterval: TimeInterval = 60
        /// 是否启用内存压缩
        var enableCompression: Bool = true
    }
    
    /// 内存使用统计
    public struct MemoryStats {
        /// 当前使用的物理内存
        var physicalMemoryUsed: Int64 = 0
        /// 虚拟内存使用量
        var virtualMemoryUsed: Int64 = 0
        /// 缓存使用量
        var cacheMemoryUsed: Int64 = 0
        /// 缓冲区使用量
        var bufferMemoryUsed: Int64 = 0
        /// 内存使用率
        var memoryUsageRatio: Double = 0
        /// 可用内存
        var availableMemory: Int64 = 0
    }
    
    /// 当前配置
    private var config: MemoryConfig
    
    /// 内存统计数据
    private var stats: MemoryStats = MemoryStats()
    
    /// 内存访问队列
    private let queue = DispatchQueue(label: "com.tfy.ssr.memory",
                                    attributes: .concurrent)
    
    /// 定时器
    private var timer: DispatchSourceTimer?
    
    private init() {
        self.config = MemoryConfig()
        setupTimer()
    }
    
    /// 更新配置
    /// - Parameter config: 新配置
    public func updateConfig(_ config: MemoryConfig) {
        queue.async(flags: .barrier) {
            self.config = config
        }
    }
    
    /// 获取内存统计
    /// - Returns: 内存统计数据
    public func getMemoryStats() -> MemoryStats {
        return queue.sync { stats }
    }
    
    /// 检查内存状态
    /// - Returns: 是否可以分配内存
    public func canAllocateMemory() -> Bool {
        return queue.sync { stats.memoryUsageRatio < config.criticalThreshold }
    }
    
    /// 分配内存
    /// - Parameter size: 需要的大小
    /// - Returns: 是否分配成功
    public func allocateMemory(size: Int) -> Bool {
        return queue.sync {
            guard canAllocateMemory() else { return false }
            let newUsage = stats.physicalMemoryUsed + Int64(size)
            let totalMemory = ProcessInfo.processInfo.physicalMemory
            let newRatio = Double(newUsage) / Double(totalMemory)
            return newRatio < config.criticalThreshold
        }
    }
    
    /// 释放内存
    /// - Parameter size: 释放的大小
    public func releaseMemory(size: Int) {
        queue.async(flags: .barrier) {
            self.stats.physicalMemoryUsed -= Int64(size)
            self.updateMemoryStats()
        }
    }
    
    /// 强制内存回收
    public func forceMemoryReclaim() {
        queue.async(flags: .barrier) {
            self.reclaimMemory()
        }
    }
    
    /// 优化内存使用
    /// - Parameter data: 要优化的数据
    /// - Returns: 优化后的数据
    public func optimizeMemoryUsage(for data: Data) -> Data {
        guard config.enableCompression else { return data }
        
        // 如果数据大小超过缓冲区大小限制，尝试压缩
        if data.count > config.maxBufferSize {
            return compressData(data)
        }
        
        return data
    }
    
    // MARK: - Private Methods
    
    private func setupTimer() {
        guard config.enableAutoReclaim else { return }
        
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now() + config.reclaimInterval,
                       repeating: config.reclaimInterval)
        timer?.setEventHandler { [weak self] in
            self?.reclaimMemory()
        }
        timer?.resume()
    }
    
    private func reclaimMemory() {
        // 更新内存统计
        updateMemoryStats()
        
        if stats.memoryUsageRatio > config.criticalThreshold {
            // 内存使用超过临界值，执行激进的回收
            aggressiveMemoryReclaim()
        } else if stats.memoryUsageRatio > config.warningThreshold {
            // 内存使用超过警告值，执行普通回收
            autoreleasepool {
                // 清理缓存
                clearUnusedCache()
                
                // 压缩内存
                if config.enableCompression {
                    compressMemory()
                }
                
                // 手动触发内存回收
                autoreleasepool {
                    #if os(iOS)
                    // 发送内存警告通知
                    NotificationCenter.default.post(
                        name: UIApplication.didReceiveMemoryWarningNotification,
                        object: nil
                    )
                    
                    // 主动调用垃圾回收
                    DispatchQueue.main.async {
                        autoreleasepool {
                            // 清理图片缓存
                            URLCache.shared.removeAllCachedResponses()
                            // 清理磁盘和内存缓存
                            URLSession.shared.configuration.urlCache?.removeAllCachedResponses()
                        }
                    }
                    #endif
                }
            }
        }
    }
    
    private func updateMemoryStats() {
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
        
        if result == KERN_SUCCESS {
            stats.physicalMemoryUsed = Int64(taskInfo.phys_footprint)
            stats.virtualMemoryUsed = Int64(taskInfo.virtual_size)
            
            let totalMemory = Int64(ProcessInfo.processInfo.physicalMemory)
            stats.memoryUsageRatio = Double(stats.physicalMemoryUsed) / Double(totalMemory)
            stats.availableMemory = totalMemory - stats.physicalMemoryUsed
        }
    }
    
    private func clearUnusedCache() {
        // 实现缓存清理逻辑
    }
    
    private func compressMemory() {
        // 实现内存压缩逻辑
    }
    
    private func compressData(_ data: Data) -> Data {
        // 这里可以实现具体的数据压缩算法
        // 示例使用简单的压缩
        guard let compressed = try? (data as NSData).compressed(using: .zlib) as Data else {
            return data
        }
        return compressed
    }
    
    /// 执行激进的内存回收
    private func aggressiveMemoryReclaim() {
        autoreleasepool {
            // 清理所有缓存
            clearAllCaches()
            
            // 清理 URL 缓存
            URLCache.shared.removeAllCachedResponses()
            
            // 清理 URL 会话缓存
            URLSession.shared.configuration.urlCache?.removeAllCachedResponses()
            
            // 强制垃圾回收
            autoreleasepool {
                // 触发内存警告
                #if os(iOS)
                NotificationCenter.default.post(
                    name: UIApplication.didReceiveMemoryWarningNotification,
                    object: nil
                )
                #endif
                
                // 清理内存
                removeAllObjects()
            }
        }
    }
    
    /// 清理所有对象
    private func removeAllObjects() {
        // 清理内存缓��
        NSCache<AnyObject, AnyObject>().removeAllObjects()
        
        // 清理 URL 缓存
        URLCache.shared.removeAllCachedResponses()
        
        // 清理 Web 缓存
        #if os(iOS)
        WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: Date.distantPast,  // 修改为 Date.distantPast
            completionHandler: {}
        )
        #endif
        
        // 清理图片缓存
        #if os(iOS)
        // 发送低内存警告通知，促使系统清理图片缓存
        NotificationCenter.default.post(
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        #endif
        
        // 清理 URL Session 缓存
        URLSession.shared.configuration.urlCache?.removeAllCachedResponses()
        
        // 使用 autoreleasepool 确保及时释放
        autoreleasepool {
            // 额外的内存清理
            clearImageCache()
        }
    }
    
    /// 清理图片缓存
    private func clearImageCache() {
        #if os(iOS)
        // 清理磁盘中的图片缓存
        if let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            let fileManager = FileManager.default
            let cacheDirectory = (cachePath as NSString).appendingPathComponent("ImageCache")
            
            if fileManager.fileExists(atPath: cacheDirectory) {
                try? fileManager.removeItem(atPath: cacheDirectory)
            }
        }
        #endif
    }
    
    /// 清理所有缓存
    private func clearAllCaches() {
        // 获取缓存目录
        let cachesPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        
        // 清理每个缓存目录
        for cachePath in cachesPaths {
            do {
                let contents = try FileManager.default.contentsOfDirectory(
                    at: cachePath,
                    includingPropertiesForKeys: nil,
                    options: .skipsHiddenFiles
                )
                
                for fileUrl in contents {
                    try? FileManager.default.removeItem(at: fileUrl)
                }
            } catch {
                print("Failed to clear cache directory: \(error)")
            }
        }
        
        // 清理临时文件
        let tempPath = NSTemporaryDirectory()
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                atPath: tempPath
            )
            for file in contents {
                let filePath = (tempPath as NSString).appendingPathComponent(file)
                try? FileManager.default.removeItem(atPath: filePath)
            }
        } catch {
            print("Failed to clear temp directory: \(error)")
        }
        
        // 清理其他系统缓存
        clearSystemCaches()
    }
    
    /// 清理系统缓存
    private func clearSystemCaches() {
        #if os(iOS)
        // 清理 WebKit 缓存
        let dataTypes = Set([
            WKWebsiteDataTypeDiskCache,
            WKWebsiteDataTypeMemoryCache,
            WKWebsiteDataTypeOfflineWebApplicationCache
        ])
        
        WKWebsiteDataStore.default().removeData(
            ofTypes: dataTypes,
            modifiedSince: Date.distantPast  // 修改为 Date.distantPast
        ) {}
        
        // 清理 URL 缓存
        let sharedCache = URLCache.shared
        sharedCache.removeAllCachedResponses()
        sharedCache.memoryCapacity = 0
        sharedCache.diskCapacity = 0
        #endif
    }
    
    deinit {
        timer?.cancel()
        timer = nil
    }
}
