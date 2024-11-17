//
//  TFYSOCKS5Handler.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation
import Network

/// SOCKS5协议处理器
/// 用于处理SOCKS5代理协议的握手、请求和响应过程
class TFYSOCKS5Handler {
    // MARK: - 常量定义
    
    /// SOCKS5协议版本号
    private static let SOCKS_VERSION: UInt8 = 0x05
    
    /// SOCKS5命令类型枚举
    private enum Command: UInt8 {
        case connect = 0x01      // TCP连接
        case bind = 0x02         // TCP端口监听
        case udpAssociate = 0x03 // UDP转发
    }
    
    /// SOCKS5地址类型枚举
    private enum AddressType: UInt8 {
        case ipv4 = 0x01   // IPv4地址
        case domain = 0x03  // 域名
        case ipv6 = 0x04   // IPv6地址
    }
    
    // MARK: - 协议处理方法
    
    /// 处理SOCKS5握手请求
    /// - Parameters:
    ///   - data: 客户端发送的握手数据
    ///   - connection: 网络连接对象
    ///   - completion: 处理完成的回调，返回成功或错误
    static func handleHandshake(data: Data, 
                              connection: NWConnection, 
                              completion: @escaping (Result<Void, Error>) -> Void) {
        // 验证协议版本和数据长度
        guard data.count >= 2,
              data[0] == SOCKS_VERSION else {
            completion(.failure(SSRError.invalidProtocol))
            return
        }
        
        // 构建认证响应（不需要认证）
        let response: [UInt8] = [
            SOCKS_VERSION,  // SOCKS5版本
            0x00           // 无需认证
        ]
        
        // 发送认证响应
        connection.send(content: Data(response), completion: .contentProcessed { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        })
    }
    
    /// 处理SOCKS5连接请求
    /// - Parameters:
    ///   - data: 客户端发送的请求数据
    ///   - completion: 处理完成的回调，返回目标主机和端口信息或错误
    static func handleRequest(data: Data, 
                            completion: @escaping (Result<(host: String, port: Int), Error>) -> Void) {
        // 验证协议版本和命令类型
        guard data.count >= 4,
              data[0] == SOCKS_VERSION,
              let command = Command(rawValue: data[1]) else {
            completion(.failure(SSRError.invalidProtocol))
            return
        }
        
        // 检查是否为CONNECT命令
        guard command == .connect else {
            completion(.failure(SSRError.unsupportedCommand))
            return
        }
        
        // 解析地址类型
        guard let addressType = AddressType(rawValue: data[3]) else {
            completion(.failure(SSRError.invalidAddressType))
            return
        }
        
        // 解析目标地址
        var index = 4
        var host = ""
        
        switch addressType {
        case .ipv4:
            // 解析IPv4地址
            guard data.count >= index + 4 else {
                completion(.failure(SSRError.invalidAddress))
                return
            }
            let addr = data.subdata(in: index..<index+4)
            host = addr.map { String($0) }.joined(separator: ".")
            index += 4
            
        case .domain:
            // 解析域名
            guard data.count >= index + 1 else {
                completion(.failure(SSRError.invalidAddress))
                return
            }
            let length = Int(data[index])
            index += 1
            guard data.count >= index + length else {
                completion(.failure(SSRError.invalidAddress))
                return
            }
            host = String(data: data.subdata(in: index..<index+length), encoding: .utf8) ?? ""
            index += length
            
        case .ipv6:
            // 解析IPv6地址
            guard data.count >= index + 16 else {
                completion(.failure(SSRError.invalidAddress))
                return
            }
            let addr = data.subdata(in: index..<index+16)
            host = addr.map { String(format: "%02x", $0) }.joined(separator: ":")
            index += 16
        }
        
        // 解析端口号
        guard data.count >= index + 2 else {
            completion(.failure(SSRError.invalidPort))
            return
        }
        let port = (Int(data[index]) << 8) | Int(data[index + 1])
        
        completion(.success((host: host, port: port)))
    }
    
    /// 发送SOCKS5响应
    /// - Parameters:
    ///   - connection: 网络连接对象
    ///   - reply: 响应代码
    ///   - completion: 发送完成的回调，返回可能的错误
    static func sendResponse(to connection: NWConnection, 
                           reply: UInt8, 
                           completion: @escaping (Error?) -> Void) {
        // 构建响应数据包
        let response: [UInt8] = [
            SOCKS_VERSION,        // SOCKS5版本
            reply,                // 响应状态码
            0x00,                 // 保留字段
            0x01,                 // 地址类型(IPv4)
            0x00, 0x00, 0x00, 0x00,  // 绑定地址(0.0.0.0)
            0x00, 0x00              // 绑定端口(0)
        ]
        
        // 发送响应
        connection.send(content: Data(response), completion: .contentProcessed { error in
            completion(error)
        })
    }
} 