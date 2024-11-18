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
    
    private var isRunning = false

    public weak var delegate: SSRAcceleratorDelegate?
    // MARK: - 公开属性
    
    /// 获取服务器地址
    public var serverAddress: String? {
        return configuration?.serverAddress
    }
    
    /// 流量统计回调 (接收字节数, 发送字节数)
    public var trafficUpdated: ((Int64, Int64) -> Void)?
    
    // MARK: - 初始化方法
    
    /// 私有初始化方法，确保单例模式
    private init() {}
    
    // MARK: - 公开方法
    
    /// 配置SSR
    /// - Parameter config: SSR配置信息
    public func configure(with config: TFYSSRConfiguration, completion: @escaping (Result<Void, SSRError>) -> Void) {
        self.configuration = config
        self.localServer = TFYSSRLocalServer(config: config)
         completion(.success(()))
    }
    
    /// 启动SSR服务
    public func start(completion: @escaping (Result<Void, SSRError>) -> Void) {
        guard let localServer = localServer, !isRunning else {
            completion(.failure(.alreadyRunning))
            return
        }
       // 启动本地服务器
        localServer.start { [weak self] result in
            switch result {
            case .success:
                self?.isRunning = true
                self?.delegate?.ssrStatusDidChange(.connected)
                self?.startTrafficMonitor()
                completion(.success(()))
            case .failure(let error):
                self?.delegate?.ssrDidFail(with: error as! SSRError)
                completion(.failure(error as! SSRError))
            }
        }
    }
    
    /// 停止SSR加速
    public func stop() {
        guard isRunning else { return }
        localServer?.stop {
            self.isRunning = false
            self.delegate?.ssrStatusDidChange(.disconnected)
            self.stopTrafficMonitor()
        }
    }
    
    // MARK: - 私有方法
    
    /// 启动流量监控
    private func startTrafficMonitor() {
        // 停止现有定时器
        trafficTimer?.invalidate()
        
        // 创建新的定时器，每秒更新一次流量统计
        trafficTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self,!isRunning else {
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
     /// 重新加载配置
    public func reloadConfiguration(completion: @escaping (Result<Void, SSRError>) -> Void) {
        stop()
        
        guard let config = configuration else {
            completion(.failure(.configurationError))
            return
        }
        
        configure(with: config) { [weak self] result in
            switch result {
            case .success:
                self?.start(completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// 获取当前状态
    public var status: SSRStatus {
        return isRunning ? .connected : .disconnected
    }
}

// MARK: - SSRAcceleratorDelegate
public protocol SSRAcceleratorDelegate: AnyObject {
    func ssrStatusDidChange(_ status: SSRStatus)
    func ssrDidUpdateTraffic(received: Int64, sent: Int64)
    func ssrDidFail(with error: SSRError)
}

// MARK: - SSRStatus
public enum SSRStatus {
    case connecting
    case connected
    case disconnecting
    case disconnected
    case error(SSRError)
    
    public var description: String {
        switch self {
        case .connecting:     return "正在连接"
        case .connected:      return "已连接"
        case .disconnecting:  return "正在断开"
        case .disconnected:   return "已断开"
        case .error(let e):   return "错误: \(e.localizedDescription)"
        }
    }
}
