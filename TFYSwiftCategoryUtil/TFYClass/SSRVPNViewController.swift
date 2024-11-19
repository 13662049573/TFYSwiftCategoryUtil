//
//  SSRVPNViewController.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/11/18.
//

import Foundation
import UIKit
import Network

class SSRVPNViewController: UIViewController {
    
    // MARK: - UI Elements
    private let connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("连接SSR", for: .normal)
        button.setTitle("断开SSR", for: .selected)
        return button
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "未连接"
        return label
    }()
    
    private let trafficLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private let performanceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    // MARK: - Properties
    private var localServer: TFYSSRLocalServer?
    private let protocolHandler: TFYSSRProtocolHandler
    private let performanceAnalyzer = TFYSSRPerformanceAnalyzer.shared
    private let memoryOptimizer = TFYSSRMemoryOptimizer.shared
    private var updateTimer: Timer?
    // 创建SSR配置
    let ssrConfig =  TFYSSRConfiguration(
        serverAddress: "your.ssr.server",
        serverPort: 8388,
        password: "your_password",
        method: .aes_256_cfb,
        protocol: .auth_chain_a,
        obfs: .tls1_2_ticket_auth,
        obfsParam: "your.domain.com")
    // MARK: - Initialization
    
    init() {
        // 初始化协议处理器
        self.protocolHandler = TFYSSRProtocolHandler(config: ssrConfig)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSSR()
        setupObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateTimer?.invalidate()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 添加UI元素
        view.addSubview(connectButton)
        view.addSubview(statusLabel)
        view.addSubview(trafficLabel)
        view.addSubview(performanceLabel)
        
        // 设置自动布局
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        trafficLabel.translatesAutoresizingMaskIntoConstraints = false
        performanceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: connectButton.topAnchor, constant: -20),
            
            trafficLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trafficLabel.topAnchor.constraint(equalTo: connectButton.bottomAnchor, constant: 20),
            trafficLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            trafficLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            performanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            performanceLabel.topAnchor.constraint(equalTo: trafficLabel.bottomAnchor, constant: 20),
            performanceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            performanceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // 添加按钮事件
        connectButton.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
    }
    
    private func setupSSR() {
        // 配置加密器
        let cipherConfig = TFYSSRCipherConfigManager.CipherConfig(
            blockSize: 32 * 1024,
            useParallel: true,
            enableCache: true,
            maxCacheSize: 100 * 1024 * 1024,
            useHardwareAcceleration: true,
            timeout: 30,
            maxRetries: 3
        )
        TFYSSRCipherConfigManager.shared.updateConfig(cipherConfig)
        
        // 配置内存优化器
        let memoryConfig = MemoryConfig(
            warningThreshold: 0.8,
            criticalThreshold: 0.9,
            maxCacheSize: 100 * 1024 * 1024,
            maxBufferSize: 32 * 1024,
            enableAutoReclaim: true,
            reclaimInterval: 60,
            enableCompression: true
        )
        TFYSSRMemoryOptimizer.shared.updateConfig(memoryConfig)
        
        // 启动性能监控
        startPerformanceMonitoring()
    }
    
    private func setupObservers() {
        // 监听内存警告
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    
    @objc private func connectButtonTapped() {
        if localServer != nil {
            stopSSR()
        } else {
            startSSR()
        }
    }
    
    @objc private func handleMemoryWarning() {
        memoryOptimizer.forceMemoryReclaim()
    }
    
    // MARK: - SSR Control
    
    private func startSSR() {
        // 创建本地服务器
        localServer = TFYSSRLocalServer(config: ssrConfig)
        
        // 重置流量统计
        localServer?.resetTrafficStats()
        
        // 启动服务器
        localServer?.start { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.connectButton.isSelected = true
                    self?.statusLabel.text = "已连接"
                    self?.startUpdates()
                case .failure(let error):
                    self?.showAlert(title: "连接失败", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func stopSSR() {
        // 保存最终流量统计
        if let stats = localServer?.getTrafficStats() {
            VPNLogger.log("""
                SSR会话统计:
                上传: \(formatBytes(stats.sent))
                下载: \(formatBytes(stats.received))
                总计: \(formatBytes(stats.total))
                """, level: .info)
        }
        
        localServer?.stop {
            /// 停止本地服务器
        }
        localServer = nil
        
        connectButton.isSelected = false
        statusLabel.text = "未连接"
        updateTimer?.invalidate()
        
        // 重置性能指标
        performanceAnalyzer.resetMetrics()
    }
    
    // MARK: - Updates
    
    private func startUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStats()
        }
    }
    
    private func updateStats() {
        // 更新流量统计
        if let server = localServer {
            let stats = server.getTrafficStats()
            trafficLabel.text = """
                上传: \(formatBytes(stats.sent))
                下载: \(formatBytes(stats.received))
                总计: \(formatBytes(stats.total))
                速率: \(stats.speedString(timeInterval: 1.0))
                """
        }
        
        // 更新性能指标
        let metrics = performanceAnalyzer.getMetrics(for: .aes_256_cfb)
        performanceLabel.text = """
            CPU: \(String(format: "%.1f%%", metrics.cpuUsage))
            内存: \(formatBytes(metrics.memoryUsage))
            延迟: \(String(format: "%.3fs", metrics.averageLatency))
            吞吐量: \(String(format: "%.2f MB/s", metrics.throughput / 1_000_000))
            """
    }
    
    private func startPerformanceMonitoring() {
        // 每30秒生成一次性能报告
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            let report = self?.performanceAnalyzer.getPerformanceReport()
            VPNLogger.log("性能报告:\n\(report ?? "")", level: .info)
        }
    }
    
    // MARK: - Helpers
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
