//
//  TFYVPNAccelerator.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation
import NetworkExtension
import Darwin

/// VPN加速器代理协议
public protocol TFYVPNAcceleratorDelegate: AnyObject {
    /// 状态变化回调
    func vpnStatusDidChange(_ status: VPNStatus)
    /// 错误回调
    func vpnDidFail(with error: VPNError)
    /// 连接成功回调
    func vpnDidConnect()
    /// 断开连接回调
    func vpnDidDisconnect()
    /// 重连尝试回调
    func vpnWillReconnect(attempt: Int, maxAttempts: Int)
    /// 流量统计回调
    func vpnDidUpdateTraffic(received: Int64, sent: Int64)
    /// 延迟更新回调
    func vpnDidUpdateLatency(_ latency: TimeInterval)
}

/// VPN加速器主类
public class TFYVPNAccelerator {
    
    // MARK: - Properties
    private var pingStartTimes: [UInt16: Date] = [:]
    private var pingFailureCount: Int = 0
    private let maxPingFailures = 5
    private var latencyHistory: [TimeInterval] = []
    private let maxLatencyHistoryCount = 10
    /// 单例
    public static let shared = TFYVPNAccelerator()
    
    /// 代理
    public weak var delegate: TFYVPNAcceleratorDelegate?
    
    /// 当前状态
    public private(set) var currentStatus: VPNStatus = .disconnected {
        didSet {
            delegate?.vpnStatusDidChange(currentStatus)
            VPNLogger.log("VPN状态变化: \(currentStatus.description)")
        }
    }
    
    /// VPN管理器
    private var manager: NETunnelProviderManager?
    
    /// 配置信息
    public private(set) var configuration: VPNConfiguration?
    
    /// 流量统计管理器
    public let trafficManager = TFYVPNTrafficManager.shared
    
    /// 后台监控管理器
    private let backgroundMonitor = TFYVPNBackgroundMonitor.shared
    
    /// Ping工具
    private var pinger: SimplePing?
    
    /// 重连相关
    private var reconnectAttempts = 0
    private var reconnectTimer: Timer?
    private var connectionTimeoutTimer: Timer?
    
    /// 流量统计定时器
    private var trafficStatsTimer: Timer?
    
    // MARK: - Initialization
    
    private init() {
        setupVPNStatusObserver()
        setupNetworkMonitor()
        setupPingMonitor()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Public Methods
    
    /// 配置VPN
    /// - Parameters:
    ///   - config: VPN配置信息
    ///   - completion: 完成回调
    public func configure(with config: VPNConfiguration, completion: @escaping (Result<Void, VPNError>) -> Void) {
        self.configuration = config
        
        // 保存配置到钥匙串
        saveConfigurationToKeychain()
        
        // 加载VPN配置
        loadVPNConfiguration { [weak self] result in
            switch result {
            case .success(let manager):
                self?.manager = manager
                VPNLogger.log("VPN配置成功")
                completion(.success(()))
                
            case .failure(let error):
                VPNLogger.log("VPN配置失败: \(error.localizedDescription)", level: .error)
                completion(.failure(error))
            }
        }
    }
    
    /// 连接VPN
    public func connect() {
        // 检查当前是否已经处于活动状态
        guard !currentStatus.isActive else {
            VPNLogger.log("VPN已经处于活动状态", level: .warning)
            return
        }
        
        guard let manager = manager else {
            let error = VPNError.configurationError("VPN未配置")
            delegate?.vpnDidFail(with: error)
            VPNLogger.log("VPN连接失败: 未配置", level: .error)
            return
        }
        
        // 检查网络状���
        guard TFYVPNMonitor.shared.isNetworkAvailable else {
            let error = VPNError.networkUnavailable
            delegate?.vpnDidFail(with: error)
            VPNLogger.log("VPN连接失败: 网络不可用", level: .error)
            return
        }
        
        // 确保VPN配置已启用
        manager.isEnabled = true
        
        // 保存并加载最新配置
        manager.saveToPreferences { [weak self] error in
            if let error = error {
                self?.delegate?.vpnDidFail(with: .configurationError(error.localizedDescription))
                return
            }
            
            do {
                try manager.connection.startVPNTunnel()
                self?.startConnectionTimeoutTimer()
                VPNLogger.log("开始VPN连接")
                self?.currentStatus = .connecting
            } catch {
                self?.delegate?.vpnDidFail(with: .connectionError(error.localizedDescription))
                VPNLogger.log("VPN连接失败: \(error.localizedDescription)", level: .error)
            }
        }
    }
    
    /// 断开VPN
    public func disconnect() {
        // 只有在活动状态时才需要断开
        guard currentStatus.isActive else {
            VPNLogger.log("VPN未处于活动状态", level: .warning)
            return
        }
        
        stopAllTimers()
        manager?.connection.stopVPNTunnel()
        currentStatus = .disconnecting
        VPNLogger.log("断开VPN连接")
    }
    
    // MARK: - Private Methods
    
    private func setupVPNStatusObserver() {
        NotificationCenter.default.addObserver(
            forName: .NEVPNStatusDidChange,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let connection = notification.object as? NEVPNConnection else { return }
            self?.handleVPNStatusChange(connection.status)
        }
    }
    
    private func setupNetworkMonitor() {
        TFYVPNMonitor.shared.networkStatusChanged = { [weak self] isAvailable, networkType in
            if !isAvailable {
                self?.handleNetworkLoss()
            } else {
                self?.handleNetworkRestore()
            }
        }
    }
    
    private func setupPingMonitor() {
        guard let serverAddress = configuration?.serverAddress else { return }
        
        pinger = SimplePing(hostName: serverAddress)
        pinger?.delegate = self
        
        // 开始定时ping
        startPingTimer()
    }
    
    private func startPingTimer() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.pinger?.send(with: nil)
        }
    }
    
    private func handleVPNStatusChange(_ status: NEVPNStatus) {
        switch status {
        case .connected:
            handleConnected()
        case .disconnected:
            handleDisconnected()
        case .connecting:
            currentStatus = .connecting
        case .disconnecting:
            currentStatus = .disconnecting
        case .reasserting:
            currentStatus = .reasserting
        case .invalid:
            currentStatus = .invalid
            handleError(.protocolError("VPN状态无效"))
        @unknown default:
            currentStatus = .invalid
        }
    }
    
    private func handleConnected() {
        currentStatus = .connected
        reconnectAttempts = 0
        stopConnectionTimeoutTimer()
        startTrafficStatsTimer()
        delegate?.vpnDidConnect()
    }
    
    private func handleDisconnected() {
        currentStatus = .disconnected
        stopTrafficStatsTimer()
        delegate?.vpnDidDisconnect()
        
        // 检查是否需要自动重连
        if configuration?.autoReconnect == true {
            handleReconnect()
        }
    }
    
    private func handleNetworkLoss() {
        if currentStatus.isActive {
            disconnect()
            delegate?.vpnDidFail(with: .networkUnavailable)
            VPNLogger.log("网络丢失，断开VPN连接", level: .warning)
        }
    }
    
    private func handleNetworkRestore() {
        guard let config = configuration,
              config.autoReconnect,
              currentStatus == .disconnected else {
            return
        }
        
        reconnectAttempts = 0
        VPNLogger.log("网络恢复，尝试重新连接VPN")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + config.autoReconnectDelay) { [weak self] in
            self?.connect()
        }
    }
    
    private func handleError(_ error: VPNError) {
        VPNLogger.log("VPN错误: \(error.localizedDescription)", level: .error)
        delegate?.vpnDidFail(with: error)
        
        switch error {
        case .networkUnavailable, .connectionError, .timeoutError:
            if configuration?.autoReconnect == true {
                handleReconnect()
            }
        default:
            break
        }
    }
    
    private func handleReconnect() {
        guard let config = configuration,
              config.autoReconnect,
              reconnectAttempts < config.maxReconnectAttempts else {
            handleError(.maxReconnectAttemptsReached)
            return
        }
        
        reconnectAttempts += 1
        delegate?.vpnWillReconnect(attempt: reconnectAttempts, maxAttempts: config.maxReconnectAttempts)
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: config.autoReconnectDelay, repeats: false) { [weak self] _ in
            self?.connect()
        }
    }
    
    private func startConnectionTimeoutTimer() {
        stopConnectionTimeoutTimer()
        
        guard let config = configuration else { return }
        
        connectionTimeoutTimer = Timer.scheduledTimer(withTimeInterval: config.connectionTimeout, repeats: false) { [weak self] _ in
            self?.handleConnectionTimeout()
        }
    }
    
    private func handleConnectionTimeout() {
        VPNLogger.log("VPN连接超时", level: .error)
        disconnect()
        delegate?.vpnDidFail(with: .timeoutError)
        
        if configuration?.autoReconnect == true {
            handleReconnect()
        }
    }
    
    private func startTrafficStatsTimer() {
        stopTrafficStatsTimer()
        
        trafficStatsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTrafficStats()
        }
    }
    
    private func updateTrafficStats() {
        let stats = getNetworkInterfaceStats()
        let updatedStats = trafficManager.updateStats(
            received: stats.received,
            sent: stats.sent
        )
        
        delegate?.vpnDidUpdateTraffic(
            received: updatedStats.received,
            sent: updatedStats.sent
        )
    }
    
    private func getNetworkInterfaceStats() -> (received: Int64, sent: Int64) {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else {
            return (0, 0)
        }
        defer { freeifaddrs(ifaddr) }
        
        var receivedBytes: Int64 = 0
        var sentBytes: Int64 = 0
        
        var pointer = ifaddr
        while pointer != nil {
            guard let interface = pointer?.pointee,
                  let data = interface.ifa_data?.assumingMemoryBound(to: if_data.self),
                  interface.ifa_addr.pointee.sa_family == AF_LINK else {
                pointer = pointer?.pointee.ifa_next
                continue
            }
            
            let name = String(cString: interface.ifa_name)
            if name.hasPrefix("utun") || name.hasPrefix("tun") {
                receivedBytes += Int64(data.pointee.ifi_ibytes)
                sentBytes += Int64(data.pointee.ifi_obytes)
            }
            
            pointer = interface.ifa_next
        }
        
        return (receivedBytes, sentBytes)
    }
    
    private func stopAllTimers() {
        stopReconnectTimer()
        stopConnectionTimeoutTimer()
        stopTrafficStatsTimer()
    }
    
    private func stopReconnectTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
    
    private func stopConnectionTimeoutTimer() {
        connectionTimeoutTimer?.invalidate()
        connectionTimeoutTimer = nil
    }
    
    private func stopTrafficStatsTimer() {
        trafficStatsTimer?.invalidate()
        trafficStatsTimer = nil
    }
    
    private func cleanup() {
        stopAllTimers()
        NotificationCenter.default.removeObserver(self)
        TFYVPNMonitor.shared.stopMonitoring()
    }
}

// MARK: - SimplePingDelegate

extension TFYVPNAccelerator: SimplePingDelegate {
    
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        VPNLogger.log("开始Ping服务器: \(configuration?.serverAddress ?? "")")
        // 启动Ping监控
        startPingMonitoring()
    }
    
    func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        VPNLogger.log("Ping失败: \(error.localizedDescription)", level: .error)
        
        // 记录失败次数
        pingFailureCount += 1
        
        // 如果连续失��次数过多,可能需要重连
        if pingFailureCount >= maxPingFailures && currentStatus.isConnected {
            VPNLogger.log("Ping连续失败次数过多,尝试重连", level: .warning)
            handleConnectionInstability()
        }
    }
    
    func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16) {
        // 记录发送时间
        pingStartTimes[sequenceNumber] = Date()
        VPNLogger.log("发送Ping包 #\(sequenceNumber)")
    }
    
    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {
        VPNLogger.log("Ping包发送失败 #\(sequenceNumber): \(error.localizedDescription)", level: .error)
        pingStartTimes.removeValue(forKey: sequenceNumber)
        
        // 记录发送失败
        pingFailureCount += 1
        checkConnectionStability()
    }
    
    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        // 计算延迟
        if let startTime = pingStartTimes[sequenceNumber] {
            let latency = Date().timeIntervalSince(startTime)
            updateLatencyStats(latency)
            
            // 清除开始时间记录
            pingStartTimes.removeValue(forKey: sequenceNumber)
            
            // 重置失败计数
            pingFailureCount = 0
            
            VPNLogger.log("收到Ping响应 #\(sequenceNumber), 延迟: \(String(format: "%.2f", latency))ms")
        }
    }
    
    // MARK: - Private Ping Methods
    private func startPingMonitoring() {
        // 清除历史数据
        pingStartTimes.removeAll()
        pingFailureCount = 0
        latencyHistory.removeAll()
        
        // 开始定时Ping
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.pinger?.send(with: nil)
        }
    }
    
    private func updateLatencyStats(_ latency: TimeInterval) {
        // 更新延迟历史
        latencyHistory.append(latency)
        if latencyHistory.count > maxLatencyHistoryCount {
            latencyHistory.removeFirst()
        }
        
        // 计算平均延迟
        let averageLatency = latencyHistory.reduce(0, +) / Double(latencyHistory.count)
        
        // 通知代理
        delegate?.vpnDidUpdateLatency(averageLatency)
        
        // 检查延迟是否过高
        checkLatencyThreshold(averageLatency)
    }
    
    private func checkLatencyThreshold(_ latency: TimeInterval) {
        let highLatencyThreshold: TimeInterval = 1.0 // 1秒
        
        if latency > highLatencyThreshold {
            VPNLogger.log("检测到高延迟: \(String(format: "%.2f", latency))秒", level: .warning)
            handleHighLatency(latency)
        }
    }
    
    private func handleHighLatency(_ latency: TimeInterval) {
        // 如果延迟持续过高,可以考虑:
        // 1. 通知用户
        // 2. 尝试重连
        // 3. 切换到备用服务器
        
        if latency > 2.0 { // 如果延迟超过2秒
            VPNLogger.log("延迟过高,考虑重连", level: .warning)
            handleConnectionInstability()
        }
    }
    
    private func checkConnectionStability() {
        if pingFailureCount >= maxPingFailures {
            handleConnectionInstability()
        }
    }
    
    private func handleConnectionInstability() {
        guard currentStatus.isConnected,
              let config = configuration,
              config.autoReconnect else {
            return
        }
        
        VPNLogger.log("检测到连接不稳定,尝试重连", level: .warning)
        
        // 断开当前连接
        disconnect()
        
        // 延迟一段时间后重连
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.connect()
        }
    }
}

// MARK: - Persistence
extension TFYVPNAccelerator {
    
    /// 保存VPN配置到钥匙串
    private func saveConfigurationToKeychain() {
        guard let config = configuration,
              let data = try? JSONEncoder().encode(config) else {
            return
        }
        
        _ = KeychainHelper.save(data, forKey: "VPNConfiguration")
    }
    
    /// 从钥匙串加载VPN配置
    private func loadConfigurationFromKeychain() -> VPNConfiguration? {
        guard let data = KeychainHelper.load(forKey: "VPNConfiguration"),
              let config = try? JSONDecoder().decode(VPNConfiguration.self, from: data) else {
            return nil
        }
        return config
    }
}

// MARK: - VPN Configuration
extension TFYVPNAccelerator {
    
    /// 加载VPN配置
    private func loadVPNConfiguration(completion: @escaping (Result<NETunnelProviderManager, VPNError>) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(.configurationError(error.localizedDescription)))
                return
            }
            
            let manager: NETunnelProviderManager
            if let existingManager = managers?.first {
                manager = existingManager
            } else {
                manager = NETunnelProviderManager()
            }
            
            // 配置VPN
            self.configureVPN(manager: manager, completion: completion)
        }
    }
    
    /// 配置VPN设置
    private func configureVPN(manager: NETunnelProviderManager, completion: @escaping (Result<NETunnelProviderManager, VPNError>) -> Void) {
        guard let config = configuration else {
            completion(.failure(.configurationError("配置信息缺失")))
            return
        }
        
        // 创建VPN协议配置
        let tunnelProtocol = NETunnelProviderProtocol()
        tunnelProtocol.serverAddress = config.serverAddress
        
        // 设置VPN配置
        var providerConfiguration: [String: Any] = [
            "serverAddress": config.serverAddress,
            "port": config.port,
            "method": config.method.rawValue,
            "password": config.password,
            "protocol": config.ssrProtocol.rawValue,
            "obfs": config.obfs.rawValue
        ]
        
        // 添加混淆参数
        if let obfsParam = config.obfsParam {
            providerConfiguration["obfsParam"] = obfsParam
        }
        
        // 添加DNS设置
        if let dnsSettings = config.dnsSettings {
            providerConfiguration["dnsServers"] = dnsSettings.servers
            if let searchDomains = dnsSettings.searchDomains {
                providerConfiguration["searchDomains"] = searchDomains
            }
            providerConfiguration["useSplitDNS"] = dnsSettings.useSplitDNS
        }
        
        // 添加路由设置
        providerConfiguration["includedRoutes"] = ["0.0.0.0/0"]  // 所有流量走VPN
        providerConfiguration["excludedRoutes"] = []  // 不排除任何路由
        
        // 添加代理设置
        if let proxySettings = config.proxySettings {
            providerConfiguration["proxyServer"] = proxySettings.server
            providerConfiguration["proxyPort"] = proxySettings.port
            providerConfiguration["proxyUsername"] = proxySettings.username
            providerConfiguration["proxyPassword"] = proxySettings.password
            providerConfiguration["proxyType"] = proxySettings.type.rawValue
        }
        
        // 添加其他设置
        if let mtu = config.mtu {
            providerConfiguration["mtu"] = mtu
        }
        providerConfiguration["enableCompression"] = config.enableCompression
        
        tunnelProtocol.providerConfiguration = providerConfiguration
        tunnelProtocol.providerBundleIdentifier = "com.tfy.TFYSwiftCategoryUtil.tunnel"
        tunnelProtocol.disconnectOnSleep = false
        
        manager.protocolConfiguration = tunnelProtocol
        manager.localizedDescription = config.vpnName
        manager.isEnabled = true
        manager.isOnDemandEnabled = true
        
        // 保存配置前先移除现有配置
        manager.removeFromPreferences { removeError in
            // 保存新配置
            manager.saveToPreferences { error in
                if let error = error {
                    completion(.failure(.configurationError(error.localizedDescription)))
                    return
                }
                
                // 加载新配置
                manager.loadFromPreferences { loadError in
                    if let loadError = loadError {
                        completion(.failure(.configurationError(loadError.localizedDescription)))
                        return
                    }
                    completion(.success(manager))
                }
            }
        }
    }
}

// MARK: - Session Management
extension TFYVPNAccelerator {
    
    /// 获取当前VPN会话状态
    public func getCurrentSessionStatus() -> VPNSessionData? {
        // 检查VPN是否已连接
        guard currentStatus == .connected else {
            return nil
        }
        
        let sessionId = UUID().uuidString
        let currentStats = trafficManager.currentStats
        let averageLatency = latencyHistory.isEmpty ? 0 : latencyHistory.reduce(0, +) / Double(latencyHistory.count)
        
        return VPNSessionData(
            id: sessionId,
            startTime: Date(),
            endTime: Date(),
            serverAddress: configuration?.serverAddress ?? "",
            connectionType: TFYVPNMonitor.shared.currentNetworkType.rawValue,
            bytesReceived: currentStats.received,
            bytesSent: currentStats.sent,
            cpuUsage: getCPUUsage(),
            memoryUsage: getMemoryUsage(),
            averageLatency: averageLatency
        )
    }
    
    /// 获取CPU使用率
    private func getCPUUsage() -> Double {
        var totalUsageOfCPU: Double = 0.0
        var thread_list: thread_act_array_t?
        var thread_count: mach_msg_type_number_t = 0
        
        if task_threads(mach_task_self_, &thread_list, &thread_count) == KERN_SUCCESS {
            if let thread_list = thread_list {
                for index in 0..<Int(thread_count) {
                    var thread_info_count = mach_msg_type_number_t(THREAD_INFO_MAX)
                    // 创建一个新的局部变量来存储线程信息
                    var threadInfo = thread_basic_info_data_t()
                    
                    _ = MemoryLayout<thread_basic_info_data_t>.size / MemoryLayout<integer_t>.size
                    
                    let result = withUnsafeMutablePointer(to: &threadInfo) { infoPointer in
                        thread_info(
                            thread_list[index],
                            thread_flavor_t(THREAD_BASIC_INFO),
                            UnsafeMutableRawPointer(infoPointer).assumingMemoryBound(to: integer_t.self),
                            &thread_info_count
                        )
                    }
                    
                    if result == KERN_SUCCESS {
                        if threadInfo.flags & TH_FLAGS_IDLE == 0 {
                            totalUsageOfCPU = (Double(threadInfo.cpu_usage) / Double(TH_USAGE_SCALE)) * 100.0
                        }
                    }
                }
                
                // 释放线程列表
                vm_deallocate(
                    mach_task_self_,
                    vm_address_t(UInt(bitPattern: thread_list)),
                    vm_size_t(Int(thread_count) * MemoryLayout<thread_t>.stride)
                )
            }
        }
        
        return totalUsageOfCPU
    }
    
    /// 获取内存使用量
    private func getMemoryUsage() -> Int64 {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size)
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else {
            return 0
        }
        
        return Int64(info.phys_footprint)
    }
} 
