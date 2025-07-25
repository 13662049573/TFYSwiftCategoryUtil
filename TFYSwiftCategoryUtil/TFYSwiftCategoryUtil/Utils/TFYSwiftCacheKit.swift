//
//  TFYSwiftCacheKit.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/12/19.
//  用途：缓存管理工具，支持内存缓存、磁盘缓存、图片缓存等功能。
//

import Foundation
import UIKit

/// 缓存错误类型
public enum TFYCacheError: Error {
    case invalidKey
    case dataNotFound
    case saveFailed(Error)
    case loadFailed(Error)
    case invalidData
    case cacheFull
    
    var localizedDescription: String {
        switch self {
        case .invalidKey:
            return "无效的缓存键"
        case .dataNotFound:
            return "缓存数据未找到"
        case .saveFailed(let error):
            return "保存失败: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "加载失败: \(error.localizedDescription)"
        case .invalidData:
            return "无效的数据"
        case .cacheFull:
            return "缓存已满"
        }
    }
}

/// 缓存配置
public struct TFYCacheConfig {
    /// 内存缓存大小限制 (MB)
    public var memoryCacheSize: Int = 50
    /// 磁盘缓存大小限制 (MB)
    public var diskCacheSize: Int = 100
    /// 缓存过期时间 (秒)
    public var expirationInterval: TimeInterval = 7 * 24 * 60 * 60 // 7天
    /// 是否启用压缩
    public var enableCompression: Bool = true
    /// 是否启用加密
    public var enableEncryption: Bool = false
    
    public init() {}
}

/// 缓存项
public struct TFYCacheItem<T> {
    public let key: String
    public let value: T
    public let timestamp: Date
    public let size: Int
    
    public init(key: String, value: T, size: Int = 0) {
        self.key = key
        self.value = value
        self.timestamp = Date()
        self.size = size
    }
    
    public var isExpired: Bool {
        return Date().timeIntervalSince(timestamp) > TFYSwiftCacheKit.shared.config.expirationInterval
    }
}

/// 缓存管理工具类
public class TFYSwiftCacheKit: NSObject {
    
    // MARK: - 单例
    public static let shared = TFYSwiftCacheKit()
    
    // MARK: - 属性
    public var config = TFYCacheConfig()
    
    /// 内存缓存
    private let memoryCache = NSCache<NSString, AnyObject>()
    
    /// 磁盘缓存目录
    private let diskCachePath: String
    
    /// 缓存队列
    private let cacheQueue = DispatchQueue(label: "com.tfy.cache", qos: .utility)
    
    /// 文件管理器
    private let fileManager = FileManager.default
    
    // MARK: - 初始化
    private override init() {
        let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        diskCachePath = (cacheDir as NSString).appendingPathComponent("TFYCache")
        
        super.init()
        
        setupMemoryCache()
        setupDiskCache()
    }
    
    // MARK: - 设置
    private func setupMemoryCache() {
        memoryCache.totalCostLimit = config.memoryCacheSize * 1024 * 1024
        memoryCache.countLimit = 100
    }
    
    private func setupDiskCache() {
        if !fileManager.fileExists(atPath: diskCachePath) {
            try? fileManager.createDirectory(atPath: diskCachePath, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - 内存缓存
    
    /// 设置内存缓存
    /// - Parameters:
    ///   - value: 缓存值
    ///   - key: 缓存键
    public func setMemoryCache<T>(_ value: T, forKey key: String) {
        let nsKey = key as NSString
        memoryCache.setObject(value as AnyObject, forKey: nsKey)
    }
    
    /// 获取内存缓存
    /// - Parameter key: 缓存键
    /// - Returns: 缓存值
    public func getMemoryCache<T>(forKey key: String) -> T? {
        let nsKey = key as NSString
        return memoryCache.object(forKey: nsKey) as? T
    }
    
    /// 移除内存缓存
    /// - Parameter key: 缓存键
    public func removeMemoryCache(forKey key: String) {
        let nsKey = key as NSString
        memoryCache.removeObject(forKey: nsKey)
    }
    
    /// 清空内存缓存
    public func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
    
    // MARK: - 磁盘缓存
    
    /// 设置磁盘缓存
    /// - Parameters:
    ///   - data: 缓存数据
    ///   - key: 缓存键
    ///   - completion: 完成回调（主线程）
    public func setDiskCache(_ data: Data, forKey key: String, completion: @escaping (Result<Void, TFYCacheError>) -> Void) {
        cacheQueue.async {
            self.cleanDiskIfNeeded()
            do {
                let filePath = self.diskCachePath(forKey: key)
                try data.write(to: URL(fileURLWithPath: filePath))
                DispatchQueue.main.async { completion(.success(())) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.saveFailed(error))) }
            }
        }
    }
    
    /// 获取磁盘缓存
    /// - Parameters:
    ///   - key: 缓存键
    ///   - completion: 完成回调（主线程）
    public func getDiskCache(forKey key: String, completion: @escaping (Result<Data, TFYCacheError>) -> Void) {
        cacheQueue.async {
            self.cleanExpiredCacheIfNeeded()
            let filePath = self.diskCachePath(forKey: key)
            
            guard self.fileManager.fileExists(atPath: filePath) else {
                DispatchQueue.main.async { completion(.failure(.dataNotFound)) }
                return
            }
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                DispatchQueue.main.async { completion(.success(data)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.loadFailed(error))) }
            }
        }
    }
    
    /// 移除磁盘缓存
    /// - Parameters:
    ///   - key: 缓存键
    ///   - completion: 完成回调
    public func removeDiskCache(forKey key: String, completion: @escaping (Result<Void, TFYCacheError>) -> Void) {
        cacheQueue.async {
            let filePath = self.diskCachePath(forKey: key)
            
            do {
                if self.fileManager.fileExists(atPath: filePath) {
                    try self.fileManager.removeItem(atPath: filePath)
                }
                completion(.success(()))
            } catch {
                completion(.failure(.saveFailed(error)))
            }
        }
    }
    
    /// 清空磁盘缓存
    /// - Parameter completion: 完成回调
    public func clearDiskCache(completion: @escaping (Result<Void, TFYCacheError>) -> Void) {
        cacheQueue.async {
            do {
                let contents = try self.fileManager.contentsOfDirectory(atPath: self.diskCachePath)
                for file in contents {
                    let filePath = (self.diskCachePath as NSString).appendingPathComponent(file)
                    try self.fileManager.removeItem(atPath: filePath)
                }
                completion(.success(()))
            } catch {
                completion(.failure(.saveFailed(error)))
            }
        }
    }
    
    // MARK: - 通用缓存
    
    /// 设置缓存
    /// - Parameters:
    ///   - value: 缓存值
    ///   - key: 缓存键
    ///   - completion: 完成回调
    public func setCache<T: Codable>(_ value: T, forKey key: String, completion: @escaping (Result<Void, TFYCacheError>) -> Void) {
        // 设置内存缓存
        setMemoryCache(value, forKey: key)
        
        // 设置磁盘缓存
        do {
            let data = try JSONEncoder().encode(value)
            setDiskCache(data, forKey: key, completion: completion)
        } catch {
            completion(.failure(.saveFailed(error)))
        }
    }
    
    /// 获取缓存（自动清理过期，主线程回调）
    public func getCache<T: Codable>(_ type: T.Type, forKey key: String, completion: @escaping (Result<T, TFYCacheError>) -> Void) {
        // 先尝试从内存缓存获取
        if let memoryValue: T = getMemoryCache(forKey: key) {
            DispatchQueue.main.async { completion(.success(memoryValue)) }
            return
        }
        // 从磁盘缓存获取
        getDiskCache(forKey: key) { result in
            switch result {
            case .success(let data):
                do {
                    let value = try JSONDecoder().decode(type, from: data)
                    // 设置到内存缓存
                    self.setMemoryCache(value, forKey: key)
                    completion(.success(value))
                } catch {
                    completion(.failure(.loadFailed(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 图片缓存
    
    /// 缓存图片
    /// - Parameters:
    ///   - image: 图片
    ///   - key: 缓存键
    ///   - completion: 完成回调
    public func cacheImage(_ image: UIImage, forKey key: String, completion: @escaping (Result<Void, TFYCacheError>) -> Void) {
        // 设置内存缓存
        setMemoryCache(image, forKey: key)
        
        // 设置磁盘缓存
        cacheQueue.async {
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                completion(.failure(.invalidData))
                return
            }
            
            self.setDiskCache(data, forKey: key, completion: completion)
        }
    }
    
    /// 获取缓存图片
    /// - Parameters:
    ///   - key: 缓存键
    ///   - completion: 完成回调
    public func getCachedImage(forKey key: String, completion: @escaping (Result<UIImage, TFYCacheError>) -> Void) {
        // 先尝试从内存缓存获取
        if let image: UIImage = getMemoryCache(forKey: key) {
            completion(.success(image))
            return
        }
        
        // 从磁盘缓存获取
        getDiskCache(forKey: key) { result in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    // 设置到内存缓存
                    self.setMemoryCache(image, forKey: key)
                    completion(.success(image))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 缓存管理
    
    /// 获取缓存大小
    /// - Parameter completion: 完成回调
    public func getCacheSize(completion: @escaping (Result<Int, TFYCacheError>) -> Void) {
        cacheQueue.async {
            do {
                let contents = try self.fileManager.contentsOfDirectory(atPath: self.diskCachePath)
                var totalSize = 0
                
                for file in contents {
                    let filePath = (self.diskCachePath as NSString).appendingPathComponent(file)
                    let attributes = try self.fileManager.attributesOfItem(atPath: filePath)
                    if let size = attributes[.size] as? Int {
                        totalSize += size
                    }
                }
                
                DispatchQueue.main.async {
                    completion(.success(totalSize))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.loadFailed(error)))
                }
            }
        }
    }
    
    /// 清理过期缓存
    /// - Parameter completion: 完成回调
    public func cleanExpiredCache(completion: @escaping (Result<Void, TFYCacheError>) -> Void) {
        cacheQueue.async {
            do {
                let contents = try self.fileManager.contentsOfDirectory(atPath: self.diskCachePath)
                let expirationDate = Date().addingTimeInterval(-self.config.expirationInterval)
                
                for file in contents {
                    let filePath = (self.diskCachePath as NSString).appendingPathComponent(file)
                    let attributes = try self.fileManager.attributesOfItem(atPath: filePath)
                    
                    if let modificationDate = attributes[.modificationDate] as? Date,
                       modificationDate < expirationDate {
                        try self.fileManager.removeItem(atPath: filePath)
                    }
                }
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.saveFailed(error)))
                }
            }
        }
    }
    
    // MARK: - 私有方法
    
    private func diskCachePath(forKey key: String) -> String {
        let fileName = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? key
        return (diskCachePath as NSString).appendingPathComponent(fileName)
    }
    
    /// 自动清理过期缓存（仅内部调用，非主线程）
    private func cleanExpiredCacheIfNeeded() {
        do {
            let contents = try self.fileManager.contentsOfDirectory(atPath: self.diskCachePath)
            let expirationDate = Date().addingTimeInterval(-self.config.expirationInterval)
            for file in contents {
                let filePath = (self.diskCachePath as NSString).appendingPathComponent(file)
                let attributes = try self.fileManager.attributesOfItem(atPath: filePath)
                if let modificationDate = attributes[.modificationDate] as? Date,
                   modificationDate < expirationDate {
                    try? self.fileManager.removeItem(atPath: filePath)
                }
            }
        } catch {
            // 忽略清理错误
        }
    }
    
    /// 检查磁盘缓存大小，超限时自动清理最早的缓存文件
    private func cleanDiskIfNeeded() {
        do {
            let contents = try self.fileManager.contentsOfDirectory(atPath: self.diskCachePath)
            var fileInfos: [(path: String, date: Date, size: Int)] = []
            var totalSize = 0
            for file in contents {
                let filePath = (self.diskCachePath as NSString).appendingPathComponent(file)
                let attributes = try self.fileManager.attributesOfItem(atPath: filePath)
                let size = attributes[.size] as? Int ?? 0
                let date = attributes[.modificationDate] as? Date ?? Date.distantPast
                fileInfos.append((filePath, date, size))
                totalSize += size
            }
            let maxSize = self.config.diskCacheSize * 1024 * 1024
            if totalSize > maxSize {
                // 按最早时间排序，依次删除
                let sorted = fileInfos.sorted { $0.date < $1.date }
                var sizeToFree = totalSize - maxSize
                for info in sorted {
                    try? self.fileManager.removeItem(atPath: info.path)
                    sizeToFree -= info.size
                    if sizeToFree <= 0 { break }
                }
            }
        } catch {
            // 忽略清理错误
        }
    }
}

// MARK: - 便利扩展
public extension TFYSwiftCacheKit {
    /// 同步设置缓存
    func setCacheSync<T: Codable>(_ value: T, forKey key: String) -> Result<Void, TFYCacheError> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<Void, TFYCacheError>!
        let work = {
            self.setCache(value, forKey: key) { res in
                result = res
                semaphore.signal()
            }
        }
        if Thread.isMainThread {
            DispatchQueue.global(qos: .userInitiated).async(execute: work)
            semaphore.wait()
        } else {
            work()
            semaphore.wait()
        }
        return result
    }
    
    /// 同步获取缓存
    func getCacheSync<T: Codable>(_ type: T.Type, forKey key: String) -> Result<T, TFYCacheError> {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<T, TFYCacheError>!
        let work = {
            self.getCache(type, forKey: key) { res in
                result = res
                semaphore.signal()
            }
        }
        if Thread.isMainThread {
            DispatchQueue.global(qos: .userInitiated).async(execute: work)
            semaphore.wait()
        } else {
            work()
            semaphore.wait()
        }
        return result
    }
} 

// MARK: - 缓存工具用法示例
/*
// 1. 缓存基本类型
TFYSwiftCacheKit.shared.setCache("Hello, Cache!", forKey: "stringKey") { result in
    switch result {
    case .success:
        print("字符串缓存成功")
    case .failure(let error):
        print("缓存失败: \(error.localizedDescription)")
    }
}

TFYSwiftCacheKit.shared.getCache(String.self, forKey: "stringKey") { result in
    switch result {
    case .success(let value):
        print("获取到字符串缓存: \(value)")
    case .failure(let error):
        print("获取失败: \(error.localizedDescription)")
    }
}

// 2. 缓存自定义模型
struct User: Codable {
    let id: Int
    let name: String
}
let user = User(id: 1, name: "张三")
TFYSwiftCacheKit.shared.setCache(user, forKey: "userKey") { result in
    if case .success = result {
        print("模型缓存成功")
    }
}
TFYSwiftCacheKit.shared.getCache(User.self, forKey: "userKey") { result in
    if case .success(let user) = result {
        print("获取到模型: \(user)")
    }
}

// 3. 缓存图片
if let image = UIImage(named: "AppIcon") {
    TFYSwiftCacheKit.shared.cacheImage(image, forKey: "icon") { result in
        if case .success = result {
            print("图片缓存成功")
        }
    }
    TFYSwiftCacheKit.shared.getCachedImage(forKey: "icon") { result in
        if case .success(let img) = result {
            print("获取到图片，尺寸: \(img.size)")
        }
    }
}

// 4. 同步缓存用法
let syncResult = TFYSwiftCacheKit.shared.setCacheSync(user, forKey: "userSyncKey")
if case .success = syncResult {
    print("同步缓存成功")
}
let syncGet = TFYSwiftCacheKit.shared.getCacheSync(User.self, forKey: "userSyncKey")
if case .success(let user) = syncGet {
    print("同步获取到模型: \(user)")
}

// 5. 清理与管理
TFYSwiftCacheKit.shared.clearMemoryCache()
TFYSwiftCacheKit.shared.clearDiskCache { _ in print("磁盘缓存已清空") }
TFYSwiftCacheKit.shared.cleanExpiredCache { _ in print("过期缓存已清理") }
TFYSwiftCacheKit.shared.getCacheSize { result in
    if case .success(let size) = result {
        print("当前缓存大小: \(size) 字节")
    }
}
*/ 