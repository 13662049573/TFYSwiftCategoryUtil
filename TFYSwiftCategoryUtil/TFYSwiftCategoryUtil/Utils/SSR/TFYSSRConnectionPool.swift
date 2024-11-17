//
//  TFYSSRConnectionPool.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation
import Network

/// SSR连接池
/// 管理和复用网络连接
public class TFYSSRConnectionPool {
    
    // MARK: - 类型定义
    
    /// 连接错误类型
    enum ConnectionError: Error {
        case connectionFailed(String)
        case timeout
        case invalidEndpoint
    }
    
    // MARK: - 属性
    
    /// 活动连接缓存
    private var activeConnections: [String: [NWConnection]] = [:]
    
    /// 连接队列
    private let queue = DispatchQueue(label: "com.tfy.ssr.connectionpool")
    
    /// 连接超时时间
    private let timeout: TimeInterval = 30
    
    // MARK: - 初始化方法
    
    public init() {}
    
    // MARK: - 公共方法
    
    /// 获取或创建连接
    /// - Parameters:
    ///   - endpoint: 目标端点
    ///   - completion: 完成回调，返回连接或错误
    func getConnection(to endpoint: NWEndpoint, completion: @escaping (Result<NWConnection, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let key = self.endpointKey(from: endpoint)
            
            // 1. 尝试复用现有连接
            if let connection = self.getIdleConnection(for: key) {
                completion(.success(connection))
                return
            }
            
            // 2. 创建新连接
            self.createNewConnection(to: endpoint, key: key, completion: completion)
        }
    }
    
    /// 清理连接池
    func cleanup() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // 取消所有连接
            for connections in self.activeConnections.values {
                connections.forEach { $0.cancel() }
            }
            
            // 清空连接池
            self.activeConnections.removeAll()
        }
    }
    
    // MARK: - 私有方法
    
    /// 获取空闲连接
    private func getIdleConnection(for key: String) -> NWConnection? {
        if let connections = activeConnections[key], !connections.isEmpty {
            // 获取第一个可用连接
            let connection = connections[0]
            activeConnections[key]?.removeFirst()
            return connection
        }
        return nil
    }
    
    /// 创建新连接
    private func createNewConnection(to endpoint: NWEndpoint, 
                                   key: String, 
                                   completion: @escaping (Result<NWConnection, Error>) -> Void) {
        // 创建TCP连接
        let connection = NWConnection(to: endpoint, using: .tcp)
        
        // 设置状态处理
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                // 连接成功，添加到连接池
                self?.addConnection(connection, for: key)
                completion(.success(connection))
                
            case .failed(let error):
                completion(.failure(ConnectionError.connectionFailed(error.localizedDescription)))
                
            case .cancelled:
                self?.removeConnection(connection, for: key)
                
            default:
                break
            }
        }
        
        // 设置超时
        let timeoutWork = DispatchWorkItem { [weak connection] in
            connection?.cancel()
            completion(.failure(ConnectionError.timeout))
        }
        queue.asyncAfter(deadline: .now() + timeout, execute: timeoutWork)
        
        // 启动连接
        connection.start(queue: queue)
    }
    
    /// 添加连接到连接池
    private func addConnection(_ connection: NWConnection, for key: String) {
        if activeConnections[key] == nil {
            activeConnections[key] = []
        }
        activeConnections[key]?.append(connection)
    }
    
    /// 从连接池移除连接
    private func removeConnection(_ connection: NWConnection, for key: String) {
        activeConnections[key]?.removeAll { $0 === connection }
        if activeConnections[key]?.isEmpty == true {
            activeConnections.removeValue(forKey: key)
        }
    }
    
    /// 生成端点的唯一键
    private func endpointKey(from endpoint: NWEndpoint) -> String {
        switch endpoint {
        case .hostPort(let host, let port):
            return "\(host):\(port)"
        case .unix(let path):
            return path
        default:
            fatalError("Invalid endpoint format")
        }
    }
} 