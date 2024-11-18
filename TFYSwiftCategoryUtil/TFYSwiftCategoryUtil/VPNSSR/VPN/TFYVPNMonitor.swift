//
//  TFYVPNMonitor.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation
import Network

/// 网络类型
public enum NetworkType: String {
    case wifi = "WiFi"
    case cellular = "Cellular"
    case ethernet = "Ethernet"
    case unknown = "Unknown"
}

/// VPN网络监控器
public class TFYVPNMonitor {
    
    /// 单例
    public static let shared = TFYVPNMonitor()
    
    /// 网络状态监听器
    private let monitor: NWPathMonitor
    
    /// 网络状态变化回调
    public var networkStatusChanged: ((Bool, NetworkType) -> Void)?
    
    /// 当前网络类型
    public private(set) var currentNetworkType: NetworkType = .unknown {
        didSet {
            VPNLogger.log("网络类型变化: \(currentNetworkType.rawValue)")
        }
    }
    
    /// 网络是否可用
    public private(set) var isNetworkAvailable: Bool = false {
        didSet {
            VPNLogger.log("网络状态变化: \(isNetworkAvailable ? "可用" : "不可用")")
        }
    }
    
    private init() {
        monitor = NWPathMonitor()
        setupMonitor()
    }
    
    deinit {
        stopMonitoring()
    }
    
    /// 开始监控
    public func startMonitoring() {
        monitor.start(queue: DispatchQueue.global())
        VPNLogger.log("开始网络监控")
    }
    
    /// 停止监控
    public func stopMonitoring() {
        monitor.cancel()
        VPNLogger.log("停止网络监控")
    }
    
    private func setupMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            let isAvailable = path.status == .satisfied
            let networkType = self.determineNetworkType(path)
            
            DispatchQueue.main.async {
                self.isNetworkAvailable = isAvailable
                self.currentNetworkType = networkType
                self.networkStatusChanged?(isAvailable, networkType)
            }
        }
    }
    
    private func determineNetworkType(_ path: NWPath) -> NetworkType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }
} 