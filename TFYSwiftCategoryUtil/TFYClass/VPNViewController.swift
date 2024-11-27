//
//  VPNViewController.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/11/18.
//

import Foundation
import UIKit
import NetworkExtension

class VPNViewController: UIViewController {
    
    // MARK: - UI Elements
    private let connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("连接VPN", for: .normal)
        button.setTitle("断开VPN", for: .selected)
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
    
    // MARK: - Properties
    private let vpnManager = TFYVPNAccelerator.shared
    private var updateTimer: Timer?/// 停止本地服务器
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupVPN()
        setupObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateTimer?.invalidate()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // 设置UI布局
        view.backgroundColor = .white
        
        view.addSubview(connectButton)
        view.addSubview(statusLabel)
        view.addSubview(trafficLabel)
        
        // 添加按钮事件
        connectButton.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
        
        // 设置自动布局约束
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        trafficLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: connectButton.topAnchor, constant: -20),
            
            trafficLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trafficLabel.topAnchor.constraint(equalTo: connectButton.bottomAnchor, constant: 20),
            trafficLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            trafficLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupVPN() {
        // 配置VPN
        let config = VPNConfiguration(
            vpnName: "My VPN",
            serverAddress: "115.236.101.106",
            port: 18989, method: SSREncryptMethod.chacha20_ietf,
            password: "kedang@123",
            ssrProtocol: SSRProtocol.origin,
            obfs: SSRObfs.plain)
        
        vpnManager.configure(with: config) { result in
            switch result {
            case .success:
                print("VPN配置成功")
            case .failure(let error):
                self.showAlert(title: "配置失败", message: error.localizedDescription)
            }
        }
        
        // 设置代理
        vpnManager.delegate = self
        
        // 启动网络监控
        TFYVPNMonitor.shared.startMonitoring()
        
        // 开始定时更新流量统计
        startTrafficUpdates()
    }
    
    private func setupObservers() {
        // 监听网络状态变化
        TFYVPNMonitor.shared.networkStatusChanged = { [weak self] isAvailable, networkType in
            DispatchQueue.main.async {
                self?.updateNetworkStatus(isAvailable: isAvailable, type: networkType)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func connectButtonTapped() {
        if vpnManager.currentStatus.isConnected {
            vpnManager.disconnect()
        } else {
            vpnManager.connect()
        }
    }
    
    // MARK: - Updates
    
    private func startTrafficUpdates() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTrafficStats()
        }
    }
    
    private func updateTrafficStats() {
        let stats = vpnManager.trafficManager.currentStats
        trafficLabel.text = stats.formattedStats
    }
    
    private func updateNetworkStatus(isAvailable: Bool, type: NetworkType) {
        let statusText = isAvailable ? "网络可用 (\(type.rawValue))" : "网络不可用"
        statusLabel.text = statusText
    }
    
    private func updateConnectionStatus(_ status: VPNStatus) {
        connectButton.isSelected = status.isConnected
        statusLabel.text = status.description
    }
    
    // MARK: - Helpers
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TFYVPNAcceleratorDelegate

extension VPNViewController: TFYVPNAcceleratorDelegate {
    
    func vpnDidUpdateLatency(_ latency: TimeInterval) {
        
    }
    
    func vpnStatusDidChange(_ status: VPNStatus) {
        DispatchQueue.main.async {
            self.updateConnectionStatus(status)
        }
    }
    
    func vpnDidFail(with error: VPNError) {
        DispatchQueue.main.async {
            self.showAlert(title: "VPN错误", message: error.localizedDescription)
        }
    }
    
    func vpnDidConnect() {
        DispatchQueue.main.async {
            self.showAlert(title: "连接成功", message: "VPN已成功连接")
        }
    }
    
    func vpnDidDisconnect() {
        DispatchQueue.main.async {
            self.showAlert(title: "已断开", message: "VPN连接已断开")
        }
    }
    
    func vpnWillReconnect(attempt: Int, maxAttempts: Int) {
        DispatchQueue.main.async {
            self.statusLabel.text = "正在重连 (\(attempt)/\(maxAttempts))"
        }
    }
    
    func vpnDidUpdateTraffic(received: Int64, sent: Int64) {
        DispatchQueue.main.async {
            let stats = TFYVPNTrafficStats(received: received, sent: sent)
            self.trafficLabel.text = stats.formattedStats
        }
    }
}
