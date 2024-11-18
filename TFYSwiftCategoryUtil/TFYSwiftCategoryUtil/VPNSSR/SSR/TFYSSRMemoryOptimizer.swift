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
    
    /// 内存使用阈值（字节）
    private let memoryThreshold: Int64 = 100 * 1024 * 1024 // 100MB
    
    /// 优化间隔（秒）
    private let optimizationInterval: TimeInterval = 30
    
    /// 优化定时器
    private var optimizationTimer: Timer?
    
    /// 是否正在运行
    private var isRunning = false
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    
    /// 启动内存优化
    public func start() {
        guard !isRunning else { return }
        
        isRunning = true
        startOptimizationTimer()
        VPNLogger.log("内存优化器已启动", level: .info)
    }
    
    /// 停止内存优化
    public func stop() {
        guard isRunning else { return }
        
        stopOptimizationTimer()
        isRunning = false
        VPNLogger.log("内存优化器已停止", level: .info)
    }
    
    /// 执行内存优化
    public func optimize() {
        autoreleasepool {
            // 1. 获取当前内存使用情况
            let currentMemoryUsage = getMemoryUsage()
            
            // 2. 检查是否需要优化
            guard currentMemoryUsage > memoryThreshold else {
                VPNLogger.log("当前内存使用正常，无需优化", level: .debug)
                return
            }
            
            VPNLogger.log("开始内存优化，当前使用: \(formatBytes(currentMemoryUsage))", level: .info)
            
            // 3. 执行优化操作
            performOptimization()
            
            // 4. 记录优化结果
            let optimizedMemoryUsage = getMemoryUsage()
            let savedMemory = currentMemoryUsage - optimizedMemoryUsage
            
            VPNLogger.log("""
                内存优化完成:
                优化前: \(formatBytes(currentMemoryUsage))
                优化后: \(formatBytes(optimizedMemoryUsage))
                节省: \(formatBytes(savedMemory))
                """, level: .info)
        }
    }
    
    // MARK: - Private Methods
    
    private func startOptimizationTimer() {
        stopOptimizationTimer()
        
        optimizationTimer = Timer.scheduledTimer(
            withTimeInterval: optimizationInterval,
            repeats: true
        ) { [weak self] _ in
            self?.optimize()
        }
    }
    
    private func stopOptimizationTimer() {
        optimizationTimer?.invalidate()
        optimizationTimer = nil
    }
    
    private func performOptimization() {
        // 1. 清理图像缓存
        URLCache.shared.removeAllCachedResponses()
        
        // 2. 清理临时文件
        clearTemporaryFiles()
        
        // 3. 强制垃圾回收
        autoreleasepool {
            _ = malloc_size(malloc(1))
            free(malloc(1))
        }
    }
    
    private func clearTemporaryFiles() {
        let fileManager = FileManager.default
        let tempPath = NSTemporaryDirectory()
        
        do {
            let tempFiles = try fileManager.contentsOfDirectory(
                atPath: tempPath
            )
            
            for file in tempFiles {
                let filePath = (tempPath as NSString).appendingPathComponent(file)
                try? fileManager.removeItem(atPath: filePath)
            }
        } catch {
            VPNLogger.log("清理临时文件失败: \(error)", level: .error)
        }
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
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Memory Warning Notification
extension TFYSSRMemoryOptimizer {
    /// 注册内存警告通知
    private func registerMemoryWarningNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc private func handleMemoryWarning() {
        VPNLogger.log("收到内存警告，执行紧急优化", level: .warning)
        optimize()
    }
}
