//
//  SSRVPNDemoViewController.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/11/18.
//

import Foundation
import UIKit
import NetworkExtension

class SSRVPNDemoViewController: UIViewController {
    
    // MARK: - UI Components
    private lazy var statusView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("连接", for: .normal)
        button.setTitle("断开", for: .selected)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.text = "未连接"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var trafficLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    // MARK: - Properties
    private let vpnAccelerator = TFYVPNAccelerator.shared
    private let trafficManager = TFYVPNTrafficManager.shared
    private let sessionManager = VPNSessionManager.shared
    private let monitor = TFYVPNMonitor.shared
    
    // SSR 相关组件
    private var ssrAccelerator: TFYSSRAccelerator?
    private var ssrProtocolHandler: TFYSSRProtocolHandler?
    private var localServer: TFYSSRLocalServer?
    private let cipherConfigManager = TFYSSRCipherConfigManager.shared
    private let memoryOptimizer = TFYSSRMemoryOptimizer.shared
    private let performanceAnalyzer = TFYSSRPerformanceAnalyzer.shared
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupVPN()
        setupMonitoring()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add subviews and setup constraints
        view.addSubview(statusView)
        statusView.addSubview(statusLabel)
        statusView.addSubview(trafficLabel)
        view.addSubview(connectButton)
        
        // Setup layout constraints...
    }
    
    private func setupVPN() {
        // 配置VPN
        let vpnConfig = VPNConfiguration(
            vpnName: "My VPN",
            serverAddress: "your.vpn.server",
            port: 443, method: SSREncryptMethod.aes_256_cfb,
            password: "your_password",
            ssrProtocol: SSRProtocol.origin,
            obfs: SSRObfs.http_post,
            dnsSettings: DNSSettings(
                servers: ["8.8.8.8", "8.8.4.4"],
                searchDomains: ["example.com"],
                useSplitDNS: true),
            autoReconnect: true,
            autoReconnectDelay: 3.0,
            connectionTimeout: 15.0)
        
        // 配置VPN
        vpnAccelerator.configure(with: vpnConfig) { [weak self] result in
            switch result {
            case .success:
                VPNLogger.log("VPN配置成功", level: .info)
            case .failure(let error):
                self?.showAlert(title: "配置错误", message: error.localizedDescription)
            }
        }
        
        // 设置代理
        vpnAccelerator.delegate = self
    }
    
    private func setupMonitoring() {
        // 设置网络监控
        monitor.networkStatusChanged = { [weak self] isAvailable, networkType in
            self?.handleNetworkChange(isAvailable: isAvailable, type: networkType)
        }
        monitor.startMonitoring()
    }
    
    private func setupSSR() {
        // 1. 配置SSR
        let ssrConfig = TFYSSRConfiguration(
            serverAddress: "your.ssr.server",
            serverPort: 8388,
            localPort: 1080,
            password: "your_password",
            method: .aes_256_cfb,
            protocol: .auth_chain_a,
            protocolParam: "protocolParam",
            obfs: .tls1_2_ticket_auth,
            obfsParam: "obfs.domain.com",
            remarks: "My SSR Server"
        )
        
        // 2. 初始化SSR协议处理器
        ssrProtocolHandler = TFYSSRProtocolHandler(config: ssrConfig)
        
        // 3. 配置加密参数
        let cipherConfig = TFYSSRCipherConfigManager.CipherConfig(
            blockSize: 32 * 1024,
            useParallel: true,
            enableCache: true,
            maxCacheSize: 100 * 1024 * 1024,
            useHardwareAcceleration: true,
            timeout: 30,
            maxRetries: 3
        )
        cipherConfigManager.updateConfig(cipherConfig)
        
        // 4. 初始化本地服务器
        localServer = TFYSSRLocalServer(config: ssrConfig)
        
        // 5. 配置SSR加速器
        TFYSSRAccelerator.shared.configure(with: ssrConfig) { [weak self] result in
            switch result {
            case .success:
                self?.startSSR()
            case .failure(let error):
                self?.handleSSRError(error)
            }
        }
            
        // 5. 设置代理
        TFYSSRAccelerator.shared.delegate = self
        // 6. 设置代理
        ssrAccelerator?.delegate = self
        
        // 7. 启动内存优化
        memoryOptimizer.start()
        
        // 8. 开始性能监控
        startPerformanceMonitoring()
    }
    
    private func startSSR() {
        guard let ssrAccelerator = ssrAccelerator else { return }
        
        // 1. 启动本地服务器
        localServer?.start { [weak self] result in
            switch result {
            case .success:
                // 2. 启动SSR加速
                ssrAccelerator.start { result in
                    switch result {
                    case .success:
                        self?.startVPNTunnel()
                    case .failure(let error):
                        self?.handleSSRError(error)
                    }
                }
            case .failure(let error):
                self?.handleSSRError(error as! SSRError)
            }
        }
    }
    
    private func startVPNTunnel() {
        guard let localPort = localServer?.config.localPort else { return }
        
        // 创建VPN配置
        let vpnConfig = VPNConfiguration(
            vpnName: "SSR VPN",
            serverAddress: "127.0.0.1", // 使用本地SSR服务
            port: localPort,            // 使用SSR本地端口
            method: ssrProtocolHandler?.config.method ?? .aes_256_cfb,
            password: ssrProtocolHandler?.config.password ?? "",
            ssrProtocol: .auth_chain_a,
            obfs: .plain,
            dnsSettings: DNSSettings(
                servers: ["8.8.8.8", "8.8.4.4"],
                searchDomains: ["example.com"],
                useSplitDNS: true
            ),
            mtu: 1500,
            enableCompression: true,
            maxReconnectAttempts: 3,
            autoReconnect: true,
            autoReconnectDelay: 3.0,
            connectionTimeout: 15.0
        )
        
        // 配置VPN
        vpnAccelerator.configure(with: vpnConfig) { [weak self] result in
            switch result {
            case .success:
                self?.vpnAccelerator.connect()
            case .failure(let error):
                self?.handleVPNError(error)
            }
        }
    }
    
    private func stopSSR() {
        // 1. 停止VPN
        vpnAccelerator.disconnect()
        
        // 2. 停止SSR加速器
        ssrAccelerator?.stop()
        
        // 3. 停止本地服务器
        localServer?.stop{
            
        }
        
        // 4. 停止性能监控
        performanceAnalyzer.stopMonitoring()
        
        // 5. 保存性能报告
        savePerformanceReport()
    }
    
    // MARK: - Performance Monitoring
    
    private func startPerformanceMonitoring() {
        // 监控SSR性能
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.updatePerformanceMetrics()
        }
    }
    
    private func updatePerformanceMetrics() {
        guard let method = ssrProtocolHandler?.config.method else { return }
        
        let metrics = performanceAnalyzer.getMetrics(for: method)
        
        // 更新UI显示性能指标
        DispatchQueue.main.async { [weak self] in
            self?.updatePerformanceUI(with: metrics)
        }
        
        // 检查是否需要优化
        if metrics.cpuUsage > 80 || metrics.memoryUsage > 500_000_000 {
            memoryOptimizer.optimize()
        }
    }
    
    private func savePerformanceReport() {
        guard let method = ssrProtocolHandler?.config.method else { return }
        
        let report = performanceAnalyzer.getPerformanceReport()
        VPNLogger.log("SSR性能报告:\n\(report)", level: .info)
        
        // 保存性能数据
        let metrics = performanceAnalyzer.getMetrics(for: method)
        sessionManager.updateCurrentSession(
            cpuUsage: metrics.cpuUsage,
            memoryUsage: metrics.memoryUsage,
            averageLatency: metrics.averageLatency
        )
    }
    
    // MARK: - Actions
    
    @objc private func connectButtonTapped() {
        if vpnAccelerator.currentStatus.isConnected {
            stopVPN()
        } else {
            startVPN()
        }
    }
    
    private func startVPN() {
        guard monitor.isNetworkAvailable else {
            showAlert(title: "错误", message: "网络不可用")
            return
        }
        
        // 开始新会话
        sessionManager.startSession(
            serverAddress: vpnAccelerator.configuration?.serverAddress ?? "",
            connectionType: monitor.currentNetworkType.rawValue
        )
        
        // 重置流量统计
        trafficManager.reset()
        
        // 连接VPN
        vpnAccelerator.connect()
        updateUI(status: .connecting)
    }
    
    private func stopVPN() {
        // 结束会话
        let trafficDiff = trafficManager.getTotalTrafficDiff()
        sessionManager.endSession(
            bytesReceived: trafficDiff.received,
            bytesSent: trafficDiff.sent
        )
        
        // 断开VPN
        vpnAccelerator.disconnect()
        updateUI(status: .disconnecting)
    }
    
    // MARK: - Updates
    
    private func startUpdates() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStats()
        }
    }
    
    private func stopUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func updateStats() {
        let stats = trafficManager.currentStats
        let diff = trafficManager.getTrafficDiff()
        
        trafficLabel.text = """
            实时速率:
            ↑ \(diff.speedString(timeInterval: 1.0))
            ↓ \(diff.speedString(timeInterval: 1.0))
            
            总流量:
            上传: \(stats.formattedSent)
            下载: \(stats.formattedReceived)
            """
    }
    
    private func updateUI(status: VPNStatus) {
        statusLabel.text = status.description
        connectButton.isSelected = status.isConnected
        
        switch status {
        case .connected:
            startUpdates()
            connectButton.backgroundColor = .systemGreen
        case .connecting:
            connectButton.backgroundColor = .systemOrange
        case .disconnecting:
            connectButton.backgroundColor = .systemOrange
        case .disconnected, .invalid:
            stopUpdates()
            connectButton.backgroundColor = .systemBlue
            trafficLabel.text = "未连接"
        }
    }
    
    // MARK: - Network Handling
    
    private func handleNetworkChange(isAvailable: Bool, type: NetworkType) {
        if !isAvailable && vpnAccelerator.currentStatus.isConnected {
            stopVPN()
            showAlert(title: "网络错误", message: "网络连接已断开")
        }
    }
    
    // MARK: - Helpers
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Error Handling
    
    /// 处理 VPN 错误
    private func handleVPNError(_ error: VPNError) {
        DispatchQueue.main.async { [weak self] in
            let message: String
            switch error {
            case .networkUnavailable:
                message = "网络不可用"
            case .configurationError(let reason):
                message = "配置错误: \(reason)"
            case .connectionError(let reason):
                message = "连接错误: \(reason)"
            case .authenticationError(let reason):
                message = "认证错误: \(reason)"
            case .protocolError(let reason):
                message = "协议错误: \(reason)"
            }
            
            self?.showAlert(title: "VPN错误", message: message)
            self?.updateUI(status: .disconnected)
            VPNLogger.log("VPN错误: \(message)", level: .error)
        }
    }
    
    /// 处理 SSR 错误
    private func handleSSRError(_ error: SSRError) {
        DispatchQueue.main.async { [weak self] in
            let message: String
            switch error {
            case .configurationError:
                message = "SSR配置错误"
            case .connectionFailed(let reason):
                message = "SSR连接失败: \(reason)"
            case .invalidProtocol:
                message = "无效的SSR协议"
            case .unsupportedMethod:
                message = "不支持的加密方法"
            case .unsupportedObfs:
                message = "不支持的混淆方式"
            case .timeout:
                message = "SSR连接超时"
            case .alreadyRunning:
                message = "SSR服务已在运行"
            case .notRunning:
                message = "SSR服务未运行"
            case .internalError(let reason):
                message = "SSR内部错误: \(reason)"
            }
            
            self?.showAlert(title: "SSR错误", message: message)
            self?.updateUI(status: .disconnected)
            VPNLogger.log("SSR错误: \(message)", level: .error)
        }
    }
    
    /// 通用错误处理
    private func handleError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            switch error {
            case let vpnError as VPNError:
                self?.handleVPNError(vpnError)
            case let ssrError as SSRError:
                self?.handleSSRError(ssrError)
            default:
                self?.showAlert(
                    title: "错误",
                    message: error.localizedDescription
                )
                VPNLogger.log("未知错误: \(error)", level: .error)
            }
        }
    }
}

// MARK: - VPNAcceleratorDelegate

extension SSRVPNDemoViewController: TFYVPNAcceleratorDelegate {
    func vpnStatusDidChange(_ status: VPNStatus) {
        DispatchQueue.main.async { [weak self] in
            self?.updateUI(status: status)
        }
    }
    
    func vpnDidUpdateTraffic(received: Int64, sent: Int64) {
        trafficManager.updateStats(received: received, sent: sent)
    }
    
    func vpnDidFail(with error: VPNError) {
        handleVPNError(error)
    }
    
    func vpnDidConnect() {
        
    }
    
    func vpnDidDisconnect() {
        
    }
    
    func vpnWillReconnect(attempt: Int, maxAttempts: Int) {
        
    }
}

// MARK: - SSRAcceleratorDelegate

extension SSRVPNDemoViewController: SSRAcceleratorDelegate {
    func ssrStatusDidChange(_ status: SSRStatus) {
        DispatchQueue.main.async { [weak self] in
            switch status {
            case .connected:
                self?.updateUI(status: .connected)
            case .disconnected:
                self?.updateUI(status: .disconnected)
            case .connecting:
                self?.updateUI(status: .connecting)
            case .disconnecting:
                self?.updateUI(status: .disconnecting)
            case .error(let error):
                self?.handleSSRError(error)
            }
        }
    }
    
    func ssrDidUpdateTraffic(received: Int64, sent: Int64) {
        performanceAnalyzer.recordTraffic(received: received, sent: sent)
        trafficManager.updateStats(received: received, sent: sent)
    }
    
    func ssrDidFail(with error: SSRError) {
        handleSSRError(error)
    }
}

