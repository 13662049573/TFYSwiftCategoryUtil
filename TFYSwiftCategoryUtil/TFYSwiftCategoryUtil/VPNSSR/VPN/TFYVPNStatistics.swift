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


/// VPN 会话数据模型
@objc(TFYVPNSessionData)
public class VPNSessionData: NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
    
    @objc let id: String
    @objc let startTime: Date
    @objc let endTime: Date
    @objc let serverAddress: String
    @objc let connectionType: String
    @objc let bytesReceived: Int64
    @objc let bytesSent: Int64
    @objc let cpuUsage: Double
    @objc let memoryUsage: Int64
    @objc let averageLatency: TimeInterval
    
    /// 会话时长
    public var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case startTime
        case endTime
        case serverAddress
        case connectionType
        case bytesReceived
        case bytesSent
        case cpuUsage
        case memoryUsage
        case averageLatency
    }
    
    init(id: String, startTime: Date, endTime: Date, serverAddress: String, connectionType: String, bytesReceived: Int64, bytesSent: Int64, cpuUsage: Double, memoryUsage: Int64, averageLatency: TimeInterval) {
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
        super.init()
    }
    
    // NSSecureCoding
    public func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(startTime, forKey: "startTime")
        coder.encode(endTime, forKey: "endTime")
        coder.encode(serverAddress, forKey: "serverAddress")
        coder.encode(connectionType, forKey: "connectionType")
        coder.encode(bytesReceived, forKey: "bytesReceived")
        coder.encode(bytesSent, forKey: "bytesSent")
        coder.encode(cpuUsage, forKey: "cpuUsage")
        coder.encode(memoryUsage, forKey: "memoryUsage")
        coder.encode(averageLatency, forKey: "averageLatency")
    }
    
    public required init?(coder: NSCoder) {
        guard let id = coder.decodeObject(of: NSString.self, forKey: "id") as String?,
              let startTime = coder.decodeObject(of: NSDate.self, forKey: "startTime") as Date?,
              let endTime = coder.decodeObject(of: NSDate.self, forKey: "endTime") as Date?,
              let serverAddress = coder.decodeObject(of: NSString.self, forKey: "serverAddress") as String?,
              let connectionType = coder.decodeObject(of: NSString.self, forKey: "connectionType") as String? else {
            return nil
        }
        
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.serverAddress = serverAddress
        self.connectionType = connectionType
        self.bytesReceived = coder.decodeInt64(forKey: "bytesReceived")
        self.bytesSent = coder.decodeInt64(forKey: "bytesSent")
        self.cpuUsage = coder.decodeDouble(forKey: "cpuUsage")
        self.memoryUsage = coder.decodeInt64(forKey: "memoryUsage")
        self.averageLatency = coder.decodeDouble(forKey: "averageLatency")
        super.init()
    }
    
    // Codable
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        serverAddress = try container.decode(String.self, forKey: .serverAddress)
        connectionType = try container.decode(String.self, forKey: .connectionType)
        bytesReceived = try container.decode(Int64.self, forKey: .bytesReceived)
        bytesSent = try container.decode(Int64.self, forKey: .bytesSent)
        cpuUsage = try container.decode(Double.self, forKey: .cpuUsage)
        memoryUsage = try container.decode(Int64.self, forKey: .memoryUsage)
        averageLatency = try container.decode(TimeInterval.self, forKey: .averageLatency)
        super.init()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(serverAddress, forKey: .serverAddress)
        try container.encode(connectionType, forKey: .connectionType)
        try container.encode(bytesReceived, forKey: .bytesReceived)
        try container.encode(bytesSent, forKey: .bytesSent)
        try container.encode(cpuUsage, forKey: .cpuUsage)
        try container.encode(memoryUsage, forKey: .memoryUsage)
        try container.encode(averageLatency, forKey: .averageLatency)
    }
}

/// VPN会话存储容器
@objc(TFYVPNSessionStorage)
public class VPNSessionStorage: NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
    
    private var sessions: [String: VPNSessionData]
    
    public init(sessions: [String: VPNSessionData]) {
        self.sessions = sessions
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        // 将字典转换为两个数组分别编码
        let keys = Array(sessions.keys)
        let values = Array(sessions.values)
        coder.encode(keys, forKey: "keys")
        coder.encode(values, forKey: "values")
    }
    
    public required init?(coder: NSCoder) {
        guard let keys = coder.decodeObject(of: [NSString.self], forKey: "keys") as? [String],
              let values = coder.decodeObject(of: [VPNSessionData.self], forKey: "values") as? [VPNSessionData],
              keys.count == values.count else {
            return nil
        }
        
        self.sessions = Dictionary(uniqueKeysWithValues: zip(keys, values))
        super.init()
    }
    
    public func getSessions() -> [String: VPNSessionData] {
        return sessions
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
        guard var session = currentSession else { return }
        session = VPNSessionData(
            id: session.id,
            startTime: Date(),
            endTime: Date(),
            serverAddress: serverAddress,
            connectionType: connectionType,
            bytesReceived: 0,
            bytesSent: 0,
            cpuUsage: session.cpuUsage,
            memoryUsage: session.memoryUsage,
            averageLatency: session.averageLatency
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
            bytesSent: bytesSent,
            cpuUsage: session.cpuUsage,
            memoryUsage: session.memoryUsage,
            averageLatency: session.averageLatency
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
        guard let session = currentSession else { return }
        
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
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.tfy.TFYSwiftCategoryUtil") else {
            return
        }
        
        let sessionsURL = containerURL.appendingPathComponent("vpn_sessions.data")
        let storage = VPNSessionStorage(sessions: Dictionary(uniqueKeysWithValues: historySessions.map { ($0.id, $0) }))
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: storage, requiringSecureCoding: true)
            try data.write(to: sessionsURL)
        } catch {
            VPNLogger.log("保存会话记录失败: \(error)", level: .error)
        }
    }
    
    private func loadSessions() {
        guard let containerURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.tfy.TFYSwiftCategoryUtil") else {
            return
        }
        
        let sessionsURL = containerURL.appendingPathComponent("vpn_sessions.data")
        
        do {
            let data = try Data(contentsOf: sessionsURL)
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            unarchiver.requiresSecureCoding = true
            
            if let storage = unarchiver.decodeObject(of: VPNSessionStorage.self, forKey: NSKeyedArchiveRootObjectKey) {
                historySessions = Array(storage.getSessions().values)
            }
        } catch {
            VPNLogger.log("加载会话记录失败: \(error)", level: .error)
        }
    }
} 
