//
//  TFYVPNTrafficStats.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation

/// VPN流量统计
public struct TFYVPNTrafficStats {
    /// 接收字节数
    public let received: Int64
    
    /// 发送字节数
    public let sent: Int64
    
    /// 总字节数
    public var total: Int64 {
        return received + sent
    }
    
    /// 初始化
    public init(received: Int64 = 0, sent: Int64 = 0) {
        self.received = received
        self.sent = sent
    }
    
    /// 格式化统计信息
    public var formattedStats: String {
        return """
        接收: \(formattedReceived)
        发送: \(formattedSent)
        总计: \(formattedTotal)
        """
    }
    
    /// 格式化接收流量
    public var formattedReceived: String {
        return formatBytes(received)
    }
    
    /// 格式化发送流量
    public var formattedSent: String {
        return formatBytes(sent)
    }
    
    /// 格式化总流量
    public var formattedTotal: String {
        return formatBytes(total)
    }
    
    /// 格式化字节数
    private func formatBytes(_ bytes: Int64) -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var value = Double(bytes)
        var unitIndex = 0
        
        while value > 1024 && unitIndex < units.count - 1 {
            value /= 1024
            unitIndex += 1
        }
        
        return String(format: "%.2f %@", value, units[unitIndex])
    }
    
    /// 获取速率字符串
    public func speedString(timeInterval: TimeInterval) -> String {
        guard timeInterval > 0 else { return "0 B/s" }
        
        let bytesPerSecond = Int64(Double(total) / timeInterval)
        return "\(formatBytes(bytesPerSecond))/s"
    }
}

/// VPN流量统计管理器
public class TFYVPNTrafficManager {
    public static let shared = TFYVPNTrafficManager()
    
    /// 当前统计数据
    public private(set) var currentStats = TFYVPNTrafficStats()
    
    /// 上次统计数据
    private var lastStats = TFYVPNTrafficStats()
    
    /// 初始统计数据
    private var initialStats = TFYVPNTrafficStats()
    
    private init() {}
    
    /// 更新统计数据
    /// - Parameters:
    ///   - received: 接收字节数
    ///   - sent: 发送字节数
    /// - Returns: 更新后的统计数据
    @discardableResult
    public func updateStats(received: Int64, sent: Int64) -> TFYVPNTrafficStats {
        lastStats = currentStats
        currentStats = TFYVPNTrafficStats(received: received, sent: sent)
        
        if initialStats.received == 0 && initialStats.sent == 0 {
            initialStats = currentStats
        }
        
        return currentStats
    }
    
    /// 获取流量差值
    /// - Returns: 与上次更新的流量差值
    public func getTrafficDiff() -> TFYVPNTrafficStats {
        return TFYVPNTrafficStats(
            received: currentStats.received - lastStats.received,
            sent: currentStats.sent - lastStats.sent
        )
    }
    
    /// 获取总流量差值
    /// - Returns: 与初始状态的流量差值
    public func getTotalTrafficDiff() -> TFYVPNTrafficStats {
        return TFYVPNTrafficStats(
            received: currentStats.received - initialStats.received,
            sent: currentStats.sent - initialStats.sent
        )
    }
    
    /// 重置统计数据
    public func reset() {
        initialStats = TFYVPNTrafficStats()
        lastStats = TFYVPNTrafficStats()
        currentStats = TFYVPNTrafficStats()
    }
} 
