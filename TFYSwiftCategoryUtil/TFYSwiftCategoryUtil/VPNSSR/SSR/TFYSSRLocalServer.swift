//
//  TFYSSRLocalServer.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation
import Network

/// SSR本地服务器
/// 负责监听本地端口，处理客户端连接和数据转发
class TFYSSRLocalServer {
    
    // MARK: - 属性
    
    /// SSR配置信息
    private let config: TFYSSRConfiguration
    
    /// 网络监听器
    private var listener: NWListener?
    
    /// 活动连接集合
    private var connections: Set<ConnectionWrapper> = []
    
    /// 连接池
    private let connectionPool: TFYSSRConnectionPool
    
    /// 协议处理器
    private let protocolHandler: TFYSSRProtocolHandler
    
    /// 流量统计
    private var trafficStats = TFYVPNTrafficStats()
    
    /// 流量统计锁
    private let statsLock = NSLock()
    
    // MARK: - 连接包装器
    private class ConnectionWrapper: Hashable {
        let connection: NWConnection
        let id: UUID
        
        init(_ connection: NWConnection) {
            self.connection = connection
            self.id = UUID()
        }
        
        static func == (lhs: ConnectionWrapper, rhs: ConnectionWrapper) -> Bool {
            return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    // MARK: - 初始化方法
    
    /// 初始化本地服务器
    /// - Parameter config: SSR配置信息
    init(config: TFYSSRConfiguration) {
        self.config = config
        self.connectionPool = TFYSSRConnectionPool()
        self.protocolHandler = TFYSSRProtocolHandler(config: config)
    }
    
    // MARK: - 公共方法
    
    /// 启动本地服务器
    /// - Parameter completion: 启动完成回调，返回成功或错误
    func start(completion: @escaping (Result<Void, Error>) -> Void) {
        // 创建TCP参数配置
        let parameters = NWParameters.tcp
        
        do {
            // 创建本地端口监听器
            listener = try NWListener(using: parameters, 
                                   on: NWEndpoint.Port(integerLiteral: UInt16(config.localPort)))
            
            // 设置监听器状态处理
            listener?.stateUpdateHandler = { [weak self] state in
                switch state {
                case .ready:
                    VPNLogger.log("本地服务器启动成功，监听端口: \(self?.config.localPort ?? 0)")
                    completion(.success(()))
                case .failed(let error):
                    VPNLogger.log("本地服务器启动失败: \(error.localizedDescription)", level: .error)
                    completion(.failure(error))
                default:
                    break
                }
            }
            
            // 设置新连接处理
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleNewConnection(connection)
            }
            
            // 启动监听器
            listener?.start(queue: .global())
            
        } catch {
            VPNLogger.log("创建监听器失败: \(error.localizedDescription)", level: .error)
            completion(.failure(error))
        }
    }
    
    /// 停止本地服务器
    /// - Parameter completion: 停止完成回调
    func stop(completion: @escaping () -> Void) {
        // 关闭所有活动连接
        connections.forEach { $0.connection.cancel() }
        connections.removeAll()
        
        // 停止监听器
        listener?.cancel()
        listener = nil
        
        // 清理连接池
        connectionPool.cleanup()
        
        VPNLogger.log("本地服务器已停止")
        completion()
    }
    
    /// 获取流量统计
    public func getTrafficStats() -> TFYVPNTrafficStats {
        statsLock.lock()
        defer { statsLock.unlock() }
        return trafficStats
    }
    
    /// 更新流量统计
    private func updateTrafficStats(received: Int64, sent: Int64) {
        statsLock.lock()
        defer { statsLock.unlock() }
        trafficStats = TFYVPNTrafficStats(received: trafficStats.received + received,
                                        sent: trafficStats.sent + sent)
    }
    
    /// 重置流量统计
    public func resetTrafficStats() {
        statsLock.lock()
        defer { statsLock.unlock() }
        trafficStats = TFYVPNTrafficStats()
    }
    
    // MARK: - 私有方法
    
    /// 处理新的客户端连接
    /// - Parameter connection: 新建立的连接
    private func handleNewConnection(_ connection: NWConnection) {
        let wrapper = ConnectionWrapper(connection)
        connections.insert(wrapper)
        
        // 设置连接状态处理
        connection.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                VPNLogger.log("新客户端连接已就绪")
                self?.startReading(connection)
            case .failed(let error):
                VPNLogger.log("客户端连接失败: \(error)", level: .error)
                self?.connections.remove(wrapper)
            case .cancelled:
                VPNLogger.log("客户端连接已取消")
                self?.connections.remove(wrapper)
            default:
                break
            }
        }
        
        // 启动连接
        connection.start(queue: .global())
    }
    
    /// 开始从连接读取数据
    /// - Parameter connection: 要读取的连接
    private func startReading(_ connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65535) { [weak self] content, _, isComplete, error in
            if let data = content {
                // 处理接收到的数据
                self?.handleReceivedData(data, from: connection)
            }
            
            if let error = error {
                VPNLogger.log("读取数据错误: \(error)", level: .error)
            }
            
            // 如果连接未完成且无错误，继续读取
            if error == nil && !isComplete {
                self?.startReading(connection)
            }
        }
    }
    
    /// 处理接收到的数据
    /// - Parameters:
    ///   - data: 接收到的数据
    ///   - connection: 数据来源的连接
    private func handleReceivedData(_ data: Data, from connection: NWConnection) {
        // 使用协议处理器处理数据
        protocolHandler.handleClientData(data) { [weak self] result in
            switch result {
            case .success(let processedData):
                // 转发处理后的数据
                self?.forwardData(processedData, to: connection)
            case .failure(let error):
                VPNLogger.log("数据处理错误: \(error)", level: .error)
            }
        }
    }
    
    /// 转发数据到远程服务器
    /// - Parameters:
    ///   - data: 要转发的数据
    ///   - clientConnection: 客户端连接
    private func forwardData(_ data: Data, to clientConnection: NWConnection) {
        let endpoint = NWEndpoint.hostPort(
            host: .init(config.serverAddress),
            port: .init(integerLiteral: UInt16(config.serverPort))
        )
        
        connectionPool.getConnection(to: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let serverConnection):
                // 2. 发送数据到服务器
                serverConnection.send(content: data, completion: .contentProcessed { error in
                    if let error = error {
                        VPNLogger.log("发送数据到服务器失败: \(error.localizedDescription)", level: .error)
                        return
                    }
                    
                    // 3. 开始双向数据转发
                    self.startBidirectionalForwarding(
                        clientConnection: clientConnection,
                        serverConnection: serverConnection
                    )
                })
                
            case .failure(let error):
                VPNLogger.log("获取服务器连接失败: \(error.localizedDescription)", level: .error)
                clientConnection.cancel()
            }
        }
    }
    
    /// 开始双向数据转发
    /// - Parameters:
    ///   - clientConnection: 客户端连接
    ///   - serverConnection: 服务器连接
    private func startBidirectionalForwarding(clientConnection: NWConnection, 
                                            serverConnection: NWConnection) {
        // 客户端 -> 服务器
        forwardDataStream(from: clientConnection, 
                         to: serverConnection, 
                         encrypt: true)
        
        // 服务器 -> 客户端
        forwardDataStream(from: serverConnection, 
                         to: clientConnection, 
                         encrypt: false)
    }
    
    /// 转发数据流
    /// - Parameters:
    ///   - source: 源连接
    ///   - destination: 目标连接
    ///   - encrypt: 是否需要加密
    private func forwardDataStream(from source: NWConnection, 
                                 to destination: NWConnection, 
                                 encrypt: Bool) {
        source.receive(minimumIncompleteLength: 1, maximumLength: 16384) { [weak self] content, _, isComplete, error in
            guard let self = self else { return }
            
            if let error = error {
                VPNLogger.log("接收数据错误: \(error.localizedDescription)", level: .error)
                return
            }
            
            if let data = content {
                // 更新流量统计
                if encrypt {
                    self.updateTrafficStats(received: 0, sent: Int64(data.count))
                } else {
                    self.updateTrafficStats(received: Int64(data.count), sent: 0)
                }
                
                // 处理数据（加密或解密）
                self.protocolHandler.handleClientData(data) { result in
                    switch result {
                    case .success(let processedData):
                        // 发送处理后的数据
                        destination.send(content: processedData, 
                                      completion: .contentProcessed { error in
                            if let error = error {
                                VPNLogger.log("发送数据错误: \(error.localizedDescription)", 
                                            level: .error)
                                return
                            }
                            
                            // 继续接收数据
                            if !isComplete {
                                self.forwardDataStream(from: source, 
                                                     to: destination, 
                                                     encrypt: encrypt)
                            }
                        })
                        
                    case .failure(let error):
                        VPNLogger.log("数据处理错误: \(error.localizedDescription)", 
                                    level: .error)
                    }
                }
            }
            
            // 如果连接完成或出错，清理资源
            if isComplete || error != nil {
                source.cancel()
                destination.cancel()
            }
        }
    }
} 
