//
//  TFYVPNTrafficStats.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation

/// VPN流量统计结构体
public struct TFYVPNTrafficStats: Codable {
    /// 接收字节数
    public var bytesReceived: Int64
    /// 发送字节数
    public var bytesSent: Int64
    /// 上次更新时间
    public var lastUpdated: Date
    /// 连接持续时间(秒)
    public var duration: TimeInterval
    
    /// 初始化方法
    public init(bytesReceived: Int64 = 0,
                bytesSent: Int64 = 0,
                lastUpdated: Date = Date(),
                duration: TimeInterval = 0) {
        self.bytesReceived = bytesReceived
        self.bytesSent = bytesSent
        self.lastUpdated = lastUpdated
        self.duration = duration
    }
    
    /// 计算速率
    public var speed: (download: Double, upload: Double) {
        let interval = Date().timeIntervalSince(lastUpdated)
        guard interval > 0 else { return (0, 0) }
        return (Double(bytesReceived) / interval,
                Double(bytesSent) / interval)
    }
    
    /// 格式化流量数据
    public var formattedStats: (received: String, sent: String) {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return (formatter.string(fromByteCount: bytesReceived),
                formatter.string(fromByteCount: bytesSent))
    }
}

/// 流量统计管理器
public class TFYVPNTrafficManager {
    /// 单例
    public static let shared = TFYVPNTrafficManager()
    
    /// 当前统计数据
    private var currentStats = TFYVPNTrafficStats()
    
    /// 上次统计数据
    private var lastStats = TFYVPNTrafficStats()
    
    /// 开始时间
    private var startTime: Date?
    
    private init() {}
    
    /// 更新流量统计
    /// - Parameters:
    ///   - received: 接收字节数
    ///   - sent: 发送字节数
    /// - Returns: 当前统计数据
    public func updateStats(received: Int64, sent: Int64) -> TFYVPNTrafficStats {
        let now = Date()
        
        if startTime == nil {
            startTime = now
        }
        
        lastStats = currentStats
        currentStats = TFYVPNTrafficStats(
            bytesReceived: received,
            bytesSent: sent,
            lastUpdated: now,
            duration: now.timeIntervalSince(startTime ?? now)
        )
        
        return currentStats
    }
    
    /// 获取流量差值
    /// - Returns: (接收差值, 发送差值)
    public func getTrafficDiff() -> (received: Int64, sent: Int64) {
        return (
            currentStats.bytesReceived - lastStats.bytesReceived,
            currentStats.bytesSent - lastStats.bytesSent
        )
    }
    
    /// 重置统计
    public func reset() {
        currentStats = TFYVPNTrafficStats()
        lastStats = TFYVPNTrafficStats()
        startTime = nil
    }
} 