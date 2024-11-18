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
}

/// VPN加速器主类
public class TFYVPNAccelerator {
    
    // MARK: - Properties
    
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
    public internal(set) var configuration: VPNConfiguration?
    
    /// 重连计数器
    private var reconnectAttempts = 0
    
    /// 重连定时器
    private var reconnectTimer: Timer?
    
    /// 连接超时定时器
    private var connectionTimeoutTimer: Timer?
    
    /// 流量统计定时器
    private var trafficStatsTimer: Timer?
    
    /// 流量统计管理器
    private let trafficManager = TFYVPNTrafficManager.shared
    
    // MARK: - Initialization
    
    private init() {
        setupVPNStatusObserver()
        setupNetworkMonitor()
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
        if let configData = try? JSONEncoder().encode(config) {
            _ = KeychainHelper.save(configData, forKey: "VPNConfiguration")
        }
        
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
        
        // 检查网络状态
        guard TFYVPNMonitor.shared.isNetworkAvailable else {
            let error = VPNError.networkUnavailable
            delegate?.vpnDidFail(with: error)
            VPNLogger.log("VPN连接失败: 网络不可用", level: .error)
            return
        }
        
        do {
            try manager.connection.startVPNTunnel()
            startConnectionTimeoutTimer()
            VPNLogger.log("开始VPN连接")
        } catch {
            let vpnError = VPNError.connectionError(error.localizedDescription)
            delegate?.vpnDidFail(with: vpnError)
            VPNLogger.log("VPN连接失败: \(error.localizedDescription)", level: .error)
        }
    }
    
    /// 断开VPN
    public func disconnect() {
        // 只有在活动状态时才需要断开
        guard currentStatus.isActive else {
            VPNLogger.log("VPN未处于活动状态", level: .warning)
            return
        }
        
        stopReconnectTimer()
        stopConnectionTimeoutTimer()
        stopTrafficStatsTimer()
        manager?.connection.stopVPNTunnel()
        VPNLogger.log("断开VPN连接")
    }
    
    /// 重新加载VPN配置
    public func reloadConfiguration(completion: @escaping (Result<Void, VPNError>) -> Void) {
        guard let config = configuration else {
            let error = VPNError.configurationError("配置信息缺失")
            completion(.failure(error))
            return
        }
        
        configure(with: config, completion: completion)
    }
    
    /// 重置流量统计
    public func resetTrafficStats() {
        trafficManager.reset()
        VPNLogger.log("流量统计已重置")
    }
    
    // MARK: - Private Methods
    
    /// 清理资源
    private func cleanup() {
        stopReconnectTimer()
        stopConnectionTimeoutTimer()
        stopTrafficStatsTimer()
        NotificationCenter.default.removeObserver(self)
        TFYVPNMonitor.shared.stopMonitoring()
    }
    
    /// 设置VPN状态观察者
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
    
    /// 设置网络监控
    private func setupNetworkMonitor() {
        TFYVPNMonitor.shared.networkStatusChanged = { [weak self] isAvailable, networkType in
            if !isAvailable {
                self?.handleNetworkLoss()
            } else {
                self?.handleNetworkRestore()
            }
        }
    }
    
    /// 处理VPN状态变化
    private func handleVPNStatusChange(_ status: NEVPNStatus) {
        let vpnStatus: VPNStatus
        switch status {
        case .disconnected:
            vpnStatus = .disconnected
            stopTrafficStatsTimer()
            delegate?.vpnDidDisconnect()
        case .connecting:
            vpnStatus = .connecting
        case .connected:
            vpnStatus = .connected
            reconnectAttempts = 0
            stopConnectionTimeoutTimer()
            startTrafficStatsTimer()
            delegate?.vpnDidConnect()
        case .disconnecting:
            vpnStatus = .disconnecting
        case .reasserting:
            vpnStatus = .reasserting
        case .invalid:
            vpnStatus = .invalid
        @unknown default:
            vpnStatus = .invalid
        }
        
        currentStatus = vpnStatus
    }
    
    /// 处理网络丢失
    private func handleNetworkLoss() {
        if currentStatus.isActive {
            disconnect()
            delegate?.vpnDidFail(with: .networkUnavailable)
            VPNLogger.log("网络丢失，断开VPN连接", level: .warning)
        }
    }
    
    /// 处理网络恢复
    private func handleNetworkRestore() {
        guard let config = configuration,
              config.autoReconnect,
              currentStatus == .disconnected else {
            return
        }
        
        reconnectAttempts = 0
        VPNLogger.log("网络恢复，尝试重新连接VPN")
        
        // 使用配置的延迟时间
        DispatchQueue.main.asyncAfter(deadline: .now() + config.autoReconnectDelay) { [weak self] in
            self?.connect()
        }
    }
    
    /// 启动连接超时计时器
    private func startConnectionTimeoutTimer() {
        stopConnectionTimeoutTimer()
        
        guard let config = configuration else { return }
        
        connectionTimeoutTimer = Timer.scheduledTimer(withTimeInterval: config.connectionTimeout, repeats: false) { [weak self] _ in
            self?.handleConnectionTimeout()
        }
    }
    
    /// 停止连接超时计时器
    private func stopConnectionTimeoutTimer() {
        connectionTimeoutTimer?.invalidate()
        connectionTimeoutTimer = nil
    }
    
    /// 处理连接超时
    private func handleConnectionTimeout() {
        VPNLogger.log("VPN连接超时", level: .error)
        
        // 停止当前连接
        disconnect()
        
        // 通知代理
        delegate?.vpnDidFail(with: .timeoutError)
        
        // 如果配置了自动重连，尝试重连
        if let config = configuration, config.autoReconnect {
            startReconnectTimer()
        }
    }
    
    /// 处理重连
    private func handleReconnect() {
        guard let config = configuration,
              config.autoReconnect,
              reconnectAttempts < config.maxReconnectAttempts else {
            delegate?.vpnDidFail(with: .maxReconnectAttemptsReached)
            VPNLogger.log("达到最大重连次数", level: .warning)
            return
        }
        
        reconnectAttempts += 1
        delegate?.vpnWillReconnect(attempt: reconnectAttempts, maxAttempts: config.maxReconnectAttempts)
        VPNLogger.log("尝试重连 (\(reconnectAttempts)/\(config.maxReconnectAttempts))")
        
        // 使用配置中的重连延迟
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: config.autoReconnectDelay, repeats: false) { [weak self] _ in
            self?.connect()
        }
    }
    
    /// 停止重连定时器
    private func stopReconnectTimer() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
    }
    
    /// 启动流量统计定时器
    private func startTrafficStatsTimer() {
        stopTrafficStatsTimer()
        
        trafficStatsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTrafficStats()
        }
    }
    
    /// 停止流量统计定时器
    private func stopTrafficStatsTimer() {
        trafficStatsTimer?.invalidate()
        trafficStatsTimer = nil
    }
    
    /// 更新流量统计
    private func updateTrafficStats() {
        guard let manager = manager,
              manager.connection.status == .connected else {
            return
        }
        
        // 使用系统网络接口统计流量
        let networkStats = getNetworkInterfaceStats()
        let updatedStats = trafficManager.updateStats(
            received: networkStats.received,
            sent: networkStats.sent
        )
        
        // 获取流量差值
        let diff = trafficManager.getTrafficDiff()
        
        // 触发回调
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.vpnDidUpdateTraffic(
                received: diff.received,
                sent: diff.sent
            )
        }
        
        // 记录日志
        let formatted = updatedStats.formattedStats
        VPNLogger.log("VPN流量统计 - 下载: \(formatted.received), 上传: \(formatted.sent)")
    }
    
    /// 获取网络接口流量统计
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
            
            // 统计所有活动网络接口的流量
            if name.hasPrefix("en") || name.hasPrefix("pdp_ip") {
                receivedBytes += Int64(data.pointee.ifi_ibytes)
                sentBytes += Int64(data.pointee.ifi_obytes)
            }
            
            pointer = interface.ifa_next
        }
        
        return (receivedBytes, sentBytes)
    }
    
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
            "method": config.method,
            "password": config.password
        ]
        
        // 添加DNS设置
        if let dnsSettings = config.dnsSettings {
            providerConfiguration["dnsServers"] = dnsSettings.servers
            if let searchDomains = dnsSettings.searchDomains {
                providerConfiguration["searchDomains"] = searchDomains
            }
            providerConfiguration["useSplitDNS"] = dnsSettings.useSplitDNS
        }
        
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
        
        manager.protocolConfiguration = tunnelProtocol
        manager.localizedDescription = config.vpnName
        manager.isEnabled = true
        
        // 保存配置
        manager.saveToPreferences { error in
            if let error = error {
                completion(.failure(.configurationError(error.localizedDescription)))
                return
            }
            
            completion(.success(manager))
        }
    }
    
    /// 启动重连定时器
    private func startReconnectTimer() {
        guard let config = configuration,
              config.autoReconnect,
              reconnectAttempts < config.maxReconnectAttempts else {
            return
        }
        
        reconnectAttempts += 1
        VPNLogger.log("开始第 \(reconnectAttempts) 次重连尝试（最大 \(config.maxReconnectAttempts) 次）")
        
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: config.autoReconnectDelay, repeats: false) { [weak self] _ in
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
