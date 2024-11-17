//
//  TFYSSRAccelerator.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation
import NetworkExtension

/// SSR加速器
/// 负责管理SSR代理服务的启动、停止和监控
public class TFYSSRAccelerator {
    
    // MARK: - 属性
    /// 单例实例
    public static let shared = TFYSSRAccelerator()
    
    /// SSR配置信息
    private var configuration: TFYSSRConfiguration?
    
    /// 本地代理服务器实例
    private var localServer: TFYSSRLocalServer?
    
    /// 流量监控定时器
    private var trafficTimer: Timer?
    
    /// 当前SSR状态
    public private(set) var status: SSRStatus = .stopped {
        didSet {
            statusChanged?(status)
        }
    }
    
    // MARK: - 公开属性
    
    /// 获取服务器地址
    public var serverAddress: String? {
        return configuration?.serverAddress
    }
    
    /// 状态变化回调
    public var statusChanged: ((SSRStatus) -> Void)?
    
    /// 流量统计回调 (接收字节数, 发送字节数)
    public var trafficUpdated: ((Int64, Int64) -> Void)?
    
    // MARK: - 初始化方法
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 公开方法
    
    /// 配置SSR
    /// - Parameter config: SSR配置信息
    public func configure(with config: TFYSSRConfiguration) {
        self.configuration = config
        self.localServer = TFYSSRLocalServer(config: config)
        VPNLogger.log("SSR配置已更新")
    }
    
    /// 启动SSR服务
    public func start() {
        guard let server = localServer else {
            VPNLogger.log("SSR未配置，请先进行配置", level: .error)
            status = .error
            return
        }
        
        // 更新状态为启动中
        status = .starting
        
        // 启动本地服务器
        server.start { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.status = .running
                self.startTrafficMonitor()
                VPNLogger.log("SSR启动成功")
                
            case .failure(let error):
                self.status = .error
                VPNLogger.log("SSR启动失败: \(error.localizedDescription)", level: .error)
            }
        }
    }
    
    /// 停止SSR服务
    public func stop() {
        guard let server = localServer else {
            VPNLogger.log("SSR未配置", level: .warning)
            return
        }
        
        // 更新状态为停止中
        status = .stopping
        
        // 停止本地服务器
        server.stop { [weak self] in
            guard let self = self else { return }
            
            self.status = .stopped
            self.stopTrafficMonitor()
            VPNLogger.log("SSR已停止")
        }
    }
    
    // MARK: - 私有方法
    
    /// 启动流量监控
    private func startTrafficMonitor() {
        // 停止现有定时器
        trafficTimer?.invalidate()
        
        // 创建新的定时器，每秒更新一次流量统计
        trafficTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self,
                  self.status == .running else {
                self?.stopTrafficMonitor()
                return
            }
            
            // 获取并更新流量统计
            let stats = self.getNetworkInterfaceStats()
            self.trafficUpdated?(stats.received, stats.sent)
        }
        
        // 确保定时器在主运行循环中运行
        RunLoop.main.add(trafficTimer!, forMode: .common)
    }
    
    /// 停止流量监控
    private func stopTrafficMonitor() {
        trafficTimer?.invalidate()
        trafficTimer = nil
    }
    
    /// 获取网络接口流量统计
    /// - Returns: 接收和发送的字节数元组
    private func getNetworkInterfaceStats() -> (received: Int64, sent: Int64) {
        // TODO: 实现网络接口流量统计
        // 可以通过系统API获取网络接口的流量数据
        return (0, 0)
    }
}

/// SSR服务状态枚举
public enum SSRStatus {
    case stopped    // 已停止
    case starting   // 启动中
    case running    // 运行中
    case stopping   // 停止中
    case error      // 错误状态
    
    /// 状态描述
    var description: String {
        switch self {
        case .stopped:  return "已停止"
        case .starting: return "启动中"
        case .running:  return "运行中"
        case .stopping: return "停止中"
        case .error:    return "错误"
        }
    }
} 
