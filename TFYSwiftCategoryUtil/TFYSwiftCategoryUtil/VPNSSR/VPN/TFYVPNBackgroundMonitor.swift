import Foundation
import BackgroundTasks
import NetworkExtension

/// VPN 后台监控管理器
public class TFYVPNBackgroundMonitor {
    
    // 使用静态属性和 dispatch_once 语义确保线程安全的单例初始化
    public static let shared: TFYVPNBackgroundMonitor = {
        let instance = TFYVPNBackgroundMonitor()
        return instance
    }()
    
    private let backgroundTaskIdentifier = "com.yourapp.vpn.monitoring"
    private let minimumBackgroundFetchInterval: TimeInterval = 15 * 60 // 15分钟
    
    /// 后台会话数据
    private var backgroundSessions: [String: VPNSessionData] = [:]
    
    private init() {
        // 将 loadMonitoringData 移到 configure 方法中
    }
    
    /// 配置并注册后台任务 - 需要在 application didFinishLaunchingWithOptions 中调用
    public func configure() {
        registerBackgroundTask()
        loadMonitoringData()  // 移到这里
    }
    
    /// 注册后台任务
    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { [weak self] task in
            self?.handleBackgroundTask(task as! BGProcessingTask)
        }
    }
    
    /// 处理后台任务
    private func handleBackgroundTask(_ task: BGProcessingTask) {
        // 设置任务过期处理
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // 执行后台监控
        performBackgroundMonitoring { success in
            task.setTaskCompleted(success: success)
            self.scheduleNextBackgroundTask()
        }
    }
    
    /// 执行后台监控
    private func performBackgroundMonitoring(completion: @escaping (Bool) -> Void) {
        guard let currentSession = getCurrentSession() else {
            completion(false)
            return
        }
        
        // 更新会话数据
        updateSessionData(currentSession)
        
        // 保存监控数据
        saveMonitoringData()
        
        completion(true)
    }
    
    /// 获取当前VPN会话
    private func getCurrentSession() -> VPNSessionData? {
        return TFYVPNAccelerator.shared.getCurrentSessionStatus()
    }
    
    /// 更新会话数据
    private func updateSessionData(_ session: VPNSessionData) {
        let stats = TFYVPNAccelerator.shared.trafficManager.currentStats
        let updatedSession = VPNSessionData(
            id: session.id,
            startTime: session.startTime,
            endTime: Date(),
            serverAddress: session.serverAddress,
            connectionType: session.connectionType,
            bytesReceived: stats.received,
            bytesSent: stats.sent,
            cpuUsage: session.cpuUsage,
            memoryUsage: session.memoryUsage,
            averageLatency: session.averageLatency
        )
        backgroundSessions[session.id] = updatedSession
    }
    
    /// 保存监控数据
    private func saveMonitoringData() {
        guard let containerURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.tfy.TFYSwiftCategoryUtil") else {
            return
        }
        let monitoringURL = containerURL.appendingPathComponent("vpn_monitoring.data")
        
        let storage = VPNSessionStorage(sessions: backgroundSessions)
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: storage, requiringSecureCoding: true)
            try data.write(to: monitoringURL)
        } catch {
            VPNLogger.log("保存监控数据失败: \(error)", level: .error)
        }
    }
    
    /// 加载监控数据
    private func loadMonitoringData() {
        guard let containerURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.tfy.TFYSwiftCategoryUtil") else {
            return
        }
        let monitoringURL = containerURL.appendingPathComponent("vpn_monitoring.data")
        
        do {
            let data = try Data(contentsOf: monitoringURL)
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            unarchiver.requiresSecureCoding = true
            
            if let storage = unarchiver.decodeObject(of: VPNSessionStorage.self, forKey: NSKeyedArchiveRootObjectKey) {
                backgroundSessions = storage.getSessions()
            }
        } catch {
            VPNLogger.log("加载监控数据失败: \(error)", level: .error)
        }
    }
    
    /// 调度下一次后台任务
    private func scheduleNextBackgroundTask() {
        let request = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            VPNLogger.log("调度后台任务失败: \(error)", level: .error)
        }
    }
}


