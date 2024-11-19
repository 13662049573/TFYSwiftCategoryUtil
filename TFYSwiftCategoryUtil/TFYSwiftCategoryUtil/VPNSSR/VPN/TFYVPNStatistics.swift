import Foundation

/// VPN 使用统计
public struct VPNStatistics {
    /// 总会话数
    public let totalSessions: Int
    
    /// 总使用时长（秒）
    public let totalDuration: TimeInterval
    
    /// 总接收字节数
    public let totalBytesReceived: Int64
    
    /// 总发送字节数
    public let totalBytesSent: Int64
    
    /// 平均会话时长（秒）
    public let averageSessionDuration: TimeInterval
    
    /// 会话记录
    public let sessions: [VPNSessionData]
    
    /// 初始化
    public init(sessions: [VPNSessionData] = []) {
        self.sessions = sessions
        self.totalSessions = sessions.count
        self.totalDuration = sessions.reduce(0) { $0 + $1.duration }
        self.totalBytesReceived = sessions.reduce(0) { $0 + $1.bytesReceived }
        self.totalBytesSent = sessions.reduce(0) { $0 + $1.bytesSent }
        self.averageSessionDuration = totalSessions > 0 ? totalDuration / Double(totalSessions) : 0
    }
    
    /// 获取格式化的统计信息
    public var formattedStats: String {
        let duration = formatDuration(totalDuration)
        let received = formatBytes(totalBytesReceived)
        let sent = formatBytes(totalBytesSent)
        let avgDuration = formatDuration(averageSessionDuration)
        
        return """
        总会话数: \(totalSessions)
        总时长: \(duration)
        总下载: \(received)
        总上传: \(sent)
        平均时长: \(avgDuration)
        """
    }
    
    /// 格式化时长
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d时%02d分%02d秒", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%d分%02d秒", minutes, seconds)
        } else {
            return String(format: "%d秒", seconds)
        }
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
}

/// VPN 会话数据
public struct VPNSessionData: Codable {
    /// 会话ID
    public let id: String
    
    /// 开始时间
    public let startTime: Date
    
    /// 结束时间
    public let endTime: Date
    
    /// 服务器地址
    public let serverAddress: String
    
    /// 连接类型
    public let connectionType: String
    
    /// 接收字节数
    public let bytesReceived: Int64
    
    /// 发送字节数
    public let bytesSent: Int64
    
    /// CPU使用率
    public let cpuUsage: Double
    
    /// 内存使用量
    public let memoryUsage: Int64
    
    /// 平均延迟
    public let averageLatency: TimeInterval
    
    /// 会话时长
    public var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    /// 初始化
    public init(id: String = UUID().uuidString,
               startTime: Date,
               endTime: Date,
               serverAddress: String,
               connectionType: String,
               bytesReceived: Int64,
               bytesSent: Int64,
               cpuUsage: Double = 0,
               memoryUsage: Int64 = 0,
               averageLatency: TimeInterval = 0) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.serverAddress = serverAddress
        self.connectionType = connectionType
        self.bytesReceived = bytesReceived
        self.bytesSent = bytesSent
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.averageLatency = averageLatency
    }
}

/// VPN 会话管理器
public class VPNSessionManager {
    /// 单例
    public static let shared = VPNSessionManager()
    
    /// 当前会话
    private var currentSession: VPNSessionData?
    
    /// 历史会话
    private var historySessions: [VPNSessionData] = []
    
    private init() {
        loadSessions()
    }
    
    /// 开始新会话
    public func startSession(serverAddress: String, connectionType: String) {
        currentSession = VPNSessionData(
            startTime: Date(),
            endTime: Date(),
            serverAddress: serverAddress,
            connectionType: connectionType,
            bytesReceived: 0,
            bytesSent: 0
        )
    }
    
    /// 结束当前会话
    public func endSession(bytesReceived: Int64, bytesSent: Int64) {
        guard var session = currentSession else { return }
        
        // 更新会话数据
        session = VPNSessionData(
            id: session.id,
            startTime: session.startTime,
            endTime: Date(),
            serverAddress: session.serverAddress,
            connectionType: session.connectionType,
            bytesReceived: bytesReceived,
            bytesSent: bytesSent
        )
        
        // 保存会话
        historySessions.append(session)
        saveSessions()
        
        currentSession = nil
    }
    
    /// 获取统计信息
    public func getStatistics() -> VPNStatistics {
        return VPNStatistics(sessions: historySessions)
    }
    
    /// 清除历史记录
    public func clearHistory() {
        historySessions.removeAll()
        saveSessions()
    }
    
    /// 更新当前会话性能指标
    public func updateCurrentSession(cpuUsage: Double, memoryUsage: Int64, averageLatency: TimeInterval) {
        guard var session = currentSession else { return }
        
        // 更新会话数据，保持其他属性不变
        currentSession = VPNSessionData(
            id: session.id,
            startTime: session.startTime,
            endTime: session.endTime,
            serverAddress: session.serverAddress,
            connectionType: session.connectionType,
            bytesReceived: session.bytesReceived,
            bytesSent: session.bytesSent,
            cpuUsage: cpuUsage,
            memoryUsage: memoryUsage,
            averageLatency: averageLatency
        )
    }
    
    // MARK: - Private Methods
    
    private func saveSessions() {
        guard let containerURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.yourapp") else {
            return
        }
        
        let sessionsURL = containerURL.appendingPathComponent("vpn_sessions.json")
        
        do {
            let data = try JSONEncoder().encode(historySessions)
            try data.write(to: sessionsURL)
        } catch {
            VPNLogger.log("保存会话记录失败: \(error)", level: .error)
        }
    }
    
    private func loadSessions() {
        guard let containerURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.yourapp") else {
            return
        }
        
        let sessionsURL = containerURL.appendingPathComponent("vpn_sessions.json")
        
        do {
            let data = try Data(contentsOf: sessionsURL)
            historySessions = try JSONDecoder().decode([VPNSessionData].self, from: data)
        } catch {
            VPNLogger.log("加载会话记录失败: \(error)", level: .error)
        }
    }
} 