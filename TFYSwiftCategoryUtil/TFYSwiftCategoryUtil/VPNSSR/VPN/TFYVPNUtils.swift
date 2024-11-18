//
//  TFYVPNUtils.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation

// 日志记录器
public class VPNLogger {
    /// 共享实例
    public static let shared = VPNLogger()
    
    /// 日志文件URL
    private var logFileURL: URL? {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsPath.appendingPathComponent("vpn.log")
    }
    
    /// 记录日志
    public static func log(_ message: String, level: VPNLogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        // 检查是否启用日志
        if TFYVPNAccelerator.shared.configuration?.enableLogging == true {
            let logMessage = formatLogMessage(message, level: level, file: file, function: function, line: line)
            shared.writeToLogFile(logMessage, level: level)
        }
    }
    
    /// 格式化日志消息
    private static func formatLogMessage(_ message: String, level: VPNLogLevel, file: String, function: String, line: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = dateFormatter.string(from: Date())
        let fileName = (file as NSString).lastPathComponent
        
        return "[\(timestamp)] [\(level.rawValue)] [\(fileName):\(line)] \(function): \(message)"
    }
    
    /// 写入日志文件
    private func writeToLogFile(_ message: String, level: VPNLogLevel) {
        guard let logFileURL = logFileURL,
              let config = TFYVPNAccelerator.shared.configuration,
              config.logLevel.shouldLog(level: level) else {
            return
        }
        
        let logMessage = message + "\n"
        
        if let data = logMessage.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logFileURL.path) {
                if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                }
            } else {
                try? data.write(to: logFileURL, options: .atomicWrite)
            }
        }
        
        // 清理旧日志
        cleanOldLogs()
    }
    
    /// 清理旧日志
    private func cleanOldLogs() {
        guard let config = TFYVPNAccelerator.shared.configuration,
              let logFileURL = logFileURL,
              let attributes = try? FileManager.default.attributesOfItem(atPath: logFileURL.path),
              let creationDate = attributes[.creationDate] as? Date else {
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        if let difference = calendar.dateComponents([.day], from: creationDate, to: now).day,
           difference > config.logRetentionDays {
            try? FileManager.default.removeItem(at: logFileURL)
        }
    }
}

/// 钥匙串工具类
internal struct KeychainHelper {
    
    /// 保存数据到钥匙串
    /// - Parameters:
    ///   - data: 要保存的数据
    ///   - key: 键值
    /// - Returns: 是否保存成功
    static func save(_ data: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// 从钥匙串加载数据
    /// - Parameter key: 键值
    /// - Returns: 保存的数据
    static func load(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return status == errSecSuccess ? result as? Data : nil
    }
    
    /// 从钥匙串删除数据
    /// - Parameter key: 键值
    /// - Returns: 是否删除成功
    static func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
} 

// MARK: - 辅助扩展
extension String {
    // 格式化流量数据
    static func formatTraffic(_ bytes: Int64) -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var value = Double(bytes)
        var unitIndex = 0
        
        while value > 1024 && unitIndex < units.count - 1 {
            value /= 1024
            unitIndex += 1
        }
        return String(format: "%.2f %@", value, units[unitIndex])
    }
}

