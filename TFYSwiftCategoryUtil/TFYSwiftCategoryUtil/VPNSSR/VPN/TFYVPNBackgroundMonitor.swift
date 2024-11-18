import Foundation
import BackgroundTasks
import NetworkExtension

/// VPN 后台监控管理器
public class TFYVPNBackgroundMonitor {
    
    static let shared = TFYVPNBackgroundMonitor()
    
    private let backgroundTaskIdentifier = "com.yourapp.vpn.monitoring"
    private let minimumBackgroundFetchInterval: TimeInterval = 15 * 60 // 15分钟
    
    /// 后台会话数据
    private var backgroundSessions: [String: VPNSessionData] = [:]
    
    private init() {
        registerBackgroundTask()
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
        guard let manager = TFYVPNAccelerator.shared.manager,
              manager.connection.status == .connected else {
            return nil
        }
        
        let sessionId = UUID().uuidString
        let currentStats = TFYVPNAccelerator.shared.trafficManager.currentStats
        
        return VPNSessionData(
            id: sessionId,
            startTime: Date(),
            endTime: Date(),
            serverAddress: TFYVPNAccelerator.shared.configuration?.serverAddress ?? "",
            connectionType: TFYVPNMonitor.shared.currentNetworkType.rawValue,
            bytesReceived: currentStats.received,
            bytesSent: currentStats.sent
        )
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
            bytesSent: stats.sent
        )
        backgroundSessions[session.id] = updatedSession
    }
    
    /// 保存监控数据
    private func saveMonitoringData() {
        guard let containerURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.yourapp") else {
            return
        }
        let monitoringURL = containerURL.appendingPathComponent("vpn_monitoring.json")
        do {
            let data = try JSONEncoder().encode(backgroundSessions)
            try data.write(to: monitoringURL)
        } catch {
            VPNLogger.log("保存监控数据失败: \(error)", level: .error)
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
