//
//  TFYVPNMonitor.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation
import Network

/// VPN网络监控器
public class TFYVPNMonitor {
    
    /// 单例
    public static let shared = TFYVPNMonitor()
    
    /// 网络状态监听器
    private let monitor = NWPathMonitor()
    
    /// 当前是否有网络连接
    public private(set) var isNetworkAvailable = false
    
    /// 当前网络类型
    public private(set) var networkType: NetworkType = .unknown
    
    /// 网络状态变化回调
    public var networkStatusChanged: ((Bool, NetworkType) -> Void)?
    
    /// 网络类型枚举
    public enum NetworkType {
        case wifi
        case cellular
        case ethernet
        case unknown
        
        /// 网络类型描述
        public var description: String {
            switch self {
            case .wifi: return "WiFi"
            case .cellular: return "蜂窝网络"
            case .ethernet: return "以太网"
            case .unknown: return "未知"
            }
        }
    }
    
    private init() {
        setupNetworkMonitor()
    }
    
    /// 设置网络监控
    private func setupNetworkMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            self.isNetworkAvailable = path.status == .satisfied
            
            // 确定网络类型
            if path.usesInterfaceType(.wifi) {
                self.networkType = .wifi
            } else if path.usesInterfaceType(.cellular) {
                self.networkType = .cellular
            } else if path.usesInterfaceType(.wiredEthernet) {
                self.networkType = .ethernet
            } else {
                self.networkType = .unknown
            }
            
            // 触发回调
            self.networkStatusChanged?(self.isNetworkAvailable, self.networkType)
            
            // 记录日志
            VPNLogger.log("网络状态变化: \(self.isNetworkAvailable ? "可用" : "不可用"), 类型: \(self.networkType.description)")
        }
        
        // 在全局队列中启动监控
        monitor.start(queue: DispatchQueue.global())
    }
    
    /// 停止监控
    public func stopMonitoring() {
        monitor.cancel()
        VPNLogger.log("网络监控已停止")
    }
    
    /// 获取当前网络信息
    /// - Returns: 网络信息元组 (是否可用, 网络类型)
    public func getCurrentNetworkInfo() -> (isAvailable: Bool, type: NetworkType) {
        return (isNetworkAvailable, networkType)
    }
} 