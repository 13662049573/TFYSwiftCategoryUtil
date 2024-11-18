//
//  TFYSSRCipherConfigManager.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/11/17.
//

import Foundation
import UIKit

/// 加密配置管理器
public class TFYSSRCipherConfigManager {
    
    /// 单例
    public static let shared = TFYSSRCipherConfigManager()
    
    /// 加密配置
    public struct CipherConfig: Codable {
        /// 块大小
        public var blockSize: Int
        /// 是否使用并行处理
        public var useParallel: Bool
        /// 是否启用缓存
        public var enableCache: Bool
        /// 缓存大小限制
        public var maxCacheSize: Int64
        /// 是否使用硬件加速
        public var useHardwareAcceleration: Bool
        /// 超时时间
        public var timeout: TimeInterval
        /// 重试次数
        public var maxRetries: Int
        
        public init(blockSize: Int = 32 * 1024,  // 32KB
                   useParallel: Bool = true,
                   enableCache: Bool = true,
                   maxCacheSize: Int64 = 100 * 1024 * 1024,  // 100MB
                   useHardwareAcceleration: Bool = true,
                   timeout: TimeInterval = 30,
                   maxRetries: Int = 3) {
            self.blockSize = blockSize
            self.useParallel = useParallel
            self.enableCache = enableCache
            self.maxCacheSize = maxCacheSize
            self.useHardwareAcceleration = useHardwareAcceleration
            self.timeout = timeout
            self.maxRetries = maxRetries
        }
        
        /// 默认配置
        public static let `default` = CipherConfig()
    }
    
    /// 当前配置
    private var currentConfig: CipherConfig = .default
    
    /// 配置访问队列
    private let queue = DispatchQueue(label: "com.tfy.cipher.config",
                                    attributes: .concurrent)
    
    private init() {
        loadConfig()
    }
    
    /// 获取当前配置
    public func getConfig() -> CipherConfig {
        queue.sync { currentConfig }
    }
    
    /// 更新配置
    public func updateConfig(_ config: CipherConfig) {
        queue.async(flags: .barrier) {
            self.currentConfig = config
            self.saveConfig()
            self.notifyConfigUpdate()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadConfig() {
        if let data = UserDefaults.standard.data(forKey: "com.tfy.cipher.config") {
            do {
                let decoder = JSONDecoder()
                currentConfig = try decoder.decode(CipherConfig.self, from: data)
            } catch {
                print("Failed to load cipher config: \(error)")
                currentConfig = .default
            }
        }
    }
    
    private func saveConfig() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(currentConfig)
            UserDefaults.standard.set(data, forKey: "com.tfy.cipher.config")
        } catch {
            print("Failed to save cipher config: \(error)")
        }
    }
    
    private func notifyConfigUpdate() {
        NotificationCenter.default.post(
            name: Notification.Name("CipherConfigDidUpdate"),
            object: nil,
            userInfo: ["config": currentConfig]
        )
    }
}

// MARK: - 便利扩展

extension TFYSSRCipherConfigManager {
    /// 配置更新通知名称
    public static let configDidUpdateNotification = Notification.Name("CipherConfigDidUpdate")
    
    /// 块大小
    public var blockSize: Int {
        queue.sync { currentConfig.blockSize }
    }
    
    /// 是否使用并行处理
    public var useParallel: Bool {
        queue.sync { currentConfig.useParallel }
    }
    
    /// 是否启用缓存
    public var enableCache: Bool {
        queue.sync { currentConfig.enableCache }
    }
    
    /// 缓存大小限制
    public var maxCacheSize: Int64 {
        queue.sync { currentConfig.maxCacheSize }
    }
    
    /// 是否使用硬件加速
    public var useHardwareAcceleration: Bool {
        queue.sync { currentConfig.useHardwareAcceleration }
    }
    
    /// 超时时间
    public var timeout: TimeInterval {
        queue.sync { currentConfig.timeout }
    }
    
    /// 重试次数
    public var maxRetries: Int {
        queue.sync { currentConfig.maxRetries }
    }
}
