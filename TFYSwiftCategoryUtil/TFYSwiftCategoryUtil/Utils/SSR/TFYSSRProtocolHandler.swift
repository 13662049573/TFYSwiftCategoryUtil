//
//  TFYSSRProtocolHandler.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation
import Network

/// SSR协议处理器
/// 负责处理SSR协议的握手、加密、混淆等操作
public class TFYSSRProtocolHandler {
    // MARK: - 属性
    
    /// SSR配置信息
    private let config: TFYSSRConfiguration
    
    /// 加密处理器
    private let crypto: TFYSSRCrypto
    
    /// 连接池管理器
    private let connectionPool: TFYSSRConnectionPool
    
    /// 协议混淆器
    private let obfuscator: TFYSSRObfuscator
    
    // MARK: - 常量
    
    /// IPv4地址正则表达式
    private static let ipv4Pattern = "^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$"
    
    /// IPv6地址正则表达式
    private static let ipv6Pattern = "^(?:[A-F0-9]{1,4}:){7}[A-F0-9]{1,4}$"
    
    // MARK: - 初始化方法
    
    /// 初始化协议处理器
    /// - Parameter config: SSR配置信息
    init(config: TFYSSRConfiguration) {
        self.config = config
        self.crypto = TFYSSRCrypto(method: config.method, password: config.password)
        self.connectionPool = TFYSSRConnectionPool()
        self.obfuscator = TFYSSRObfuscator(config: config)
    }
    
    // MARK: - 公共方法
    
    /// 处理客户端连接
    /// - Parameters:
    ///   - clientConnection: 客户端连接对象
    ///   - completion: 完成回调，返回可能的错误
    func handleClientConnection(_ clientConnection: NWConnection, completion: @escaping (Error?) -> Void) {
        // 1. 处理SOCKS5握手
        handleSocks5Handshake(clientConnection) { [weak self] result in
            switch result {
            case .success(let targetInfo):
                // 2. 建立与远程服务器的连接
                self?.establishServerConnection(targetInfo: targetInfo, 
                                             clientConnection: clientConnection, 
                                             completion: completion)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    /// 处理客户端数据
    /// - Parameters:
    ///   - data: 原始数据
    ///   - completion: 完成回调，返回处理后的数据或错误
    func handleClientData(_ data: Data, completion: @escaping (Result<Data, Error>) -> Void) {
        // 处理数据的具体实现
        do {
            // 1. 解析数据
            // 2. 加/解密
            // 3. 处理协议
            let processedData = try processData(data)
            completion(.success(processedData))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - 私有方法
    
    /// 处理SOCKS5握手过程
    private func handleSocks5Handshake(_ connection: NWConnection, 
                                     completion: @escaping (Result<(host: String, port: Int), Error>) -> Void) {
        // 接收客户端握手请求
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1024) { [weak self] content, _, isComplete, error in
            guard let data = content, error == nil else {
                completion(.failure(SSRError.invalidProtocol))
                return
            }
            
            // 处理握手
            TFYSOCKS5Handler.handleHandshake(data: data, connection: connection) { result in
                switch result {
                case .success:
                    // 继续接收目标地址信息
                    self?.receiveTargetAddress(connection, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// 接收目标地址信息
    private func receiveTargetAddress(_ connection: NWConnection, 
                                    completion: @escaping (Result<(host: String, port: Int), Error>) -> Void) {
        connection.receive(minimumIncompleteLength: 4, maximumLength: 1024) { content, _, isComplete, error in
            guard let data = content, error == nil else {
                completion(.failure(SSRError.invalidAddress))
                return
            }
            
            // 解析目标地址
            TFYSOCKS5Handler.handleRequest(data: data, completion: completion)
        }
    }
    
    /// 建立与远程服务器的连接
    private func establishServerConnection(targetInfo: (host: String, port: Int), 
                                        clientConnection: NWConnection, 
                                        completion: @escaping (Error?) -> Void) {
        // 创建服务器端点
        let endpoint = NWEndpoint.hostPort(
            host: .init(config.serverAddress),
            port: .init(integerLiteral: UInt16(config.serverPort))
        )
        
        // 从连接池获取或创建新连接
        connectionPool.getConnection(to: endpoint) { [weak self] result in
            switch result {
            case .success(let serverConnection):
                // 开始数据转发
                self?.startDataForwarding(
                    clientConnection: clientConnection,
                    serverConnection: serverConnection,
                    targetInfo: targetInfo,
                    completion: completion
                )
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    /// 开始数据转发
    private func startDataForwarding(clientConnection: NWConnection,
                                   serverConnection: NWConnection,
                                   targetInfo: (host: String, port: Int),
                                   completion: @escaping (Error?) -> Void) {
        do {
            // 1. 构建SSR请求头
            let requestHeader = buildSSRRequestHeader(targetInfo: targetInfo)
            
            // 2. 加密并混淆请求头
            let encryptedHeader = try crypto.encrypt(requestHeader)
            let obfuscatedHeader = try obfuscator.obfuscate(encryptedHeader)
            
            // 3. 发送到服务器
            serverConnection.send(content: obfuscatedHeader, completion: .contentProcessed { [weak self] error in
                if let error = error {
                    completion(error)
                    return
                }
                
                // 4. 开始双向数据转发
                self?.startBidirectionalForwarding(
                    clientConnection: clientConnection,
                    serverConnection: serverConnection,
                    completion: completion
                )
            })
        } catch {
            completion(error)
        }
    }
    
    /// 构建SSR请求头
    private func buildSSRRequestHeader(targetInfo: (host: String, port: Int)) -> Data {
        var header = Data()
        
        // 添加地址类型和地址数据
        if targetInfo.host.matches(TFYSSRProtocolHandler.ipv4Pattern) {
            // IPv4地址
            header.append(0x01)
            header.append(contentsOf: targetInfo.host.split(separator: ".").compactMap { UInt8($0) })
        } else if targetInfo.host.matches(TFYSSRProtocolHandler.ipv6Pattern) {
            // IPv6地址
            header.append(0x04)
            let bytes = targetInfo.host.split(separator: ":").flatMap { hex -> [UInt8] in
                let paddedHex = hex.count == 1 ? "0\(hex)" : String(hex)
                return [UInt8(paddedHex.prefix(2), radix: 16)!, UInt8(paddedHex.suffix(2), radix: 16)!]
            }
            header.append(contentsOf: bytes)
        } else {
            // 域名
            header.append(0x03)
            let hostData = targetInfo.host.data(using: .utf8)!
            header.append(UInt8(hostData.count))
            header.append(hostData)
        }
        
        // 添加端口号（大端序）
        header.append(UInt8(targetInfo.port >> 8))
        header.append(UInt8(targetInfo.port & 0xFF))
        
        return header
    }
    
    /// 开始双向数据转发
    private func startBidirectionalForwarding(clientConnection: NWConnection,
                                            serverConnection: NWConnection,
                                            completion: @escaping (Error?) -> Void) {
        // 客户端 -> 服务器（加密方向）
        forwardData(from: clientConnection, to: serverConnection, encrypt: true)
        
        // 服务器 -> 客户端（解密方向）
        forwardData(from: serverConnection, to: clientConnection, encrypt: false)
        
        completion(nil)
    }
    
    /// 转发数据
    private func forwardData(from source: NWConnection,
                           to destination: NWConnection,
                           encrypt: Bool) {
        source.receive(minimumIncompleteLength: 1, maximumLength: 16384) { [weak self] content, _, isComplete, error in
            guard let self = self, let data = content, error == nil else {
                if let error = error {
                    VPNLogger.log("数据转发错误: \(error.localizedDescription)", level: .error)
                }
                return
            }
            
            do {
                // 处理数据（加密或解密）
                let processedData: Data
                if encrypt {
                    // 加密并混淆
                    let encryptedData = try self.crypto.encrypt(data)
                    processedData = try self.obfuscator.obfuscate(encryptedData)
                } else {
                    // 解混淆并解密
                    let deobfuscatedData = try self.obfuscator.deobfuscate(data)
                    processedData = try self.crypto.decrypt(deobfuscatedData)
                }
                
                // 发送处理后的数据
                destination.send(content: processedData, completion: .contentProcessed { [weak self] error in
                    if let error = error {
                        VPNLogger.log("数据发送错误: \(error.localizedDescription)", level: .error)
                        return
                    }
                    
                    // 继续接收数据
                    if !isComplete {
                        self?.forwardData(from: source, to: destination, encrypt: encrypt)
                    }
                })
            } catch {
                VPNLogger.log("数据处理错误: \(error.localizedDescription)", level: .error)
            }
        }
    }
    
    /// 处理数据
    private func processData(_ data: Data) throws -> Data {
        // 实现数据处理逻辑
        return data // 临时返回，需要实现实际的处理逻辑
    }
}

// MARK: - 辅助扩展

private extension String {
    /// 匹配正则表达式
    func matches(_ pattern: String) -> Bool {
        return range(of: pattern, options: .regularExpression) != nil
    }
} 