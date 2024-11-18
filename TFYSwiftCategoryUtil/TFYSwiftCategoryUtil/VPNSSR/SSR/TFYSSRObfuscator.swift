//
//  TFYSSRObfuscator.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation
import CommonCrypto

/// SSR混淆器
/// 负责处理SSR的流量混淆和解混淆操作
public class TFYSSRObfuscator {
    
    // MARK: - 属性
    
    /// SSR配置信息
    private let config: TFYSSRConfiguration
    
    /// 混淆密钥
    private let key: Data
    
    /// 随机IV
    private var iv: Data
    
    /// 发送计数器
    private var sendCounter: UInt64 = 0
    
    /// 接收计数器
    private var receiveCounter: UInt64 = 0
    
    // MARK: - 初始化方法
    
    /// 初始化混淆器
    /// - Parameter config: SSR配置信息
    init(config: TFYSSRConfiguration) {
        self.config = config
        
        // 生成混淆密钥
        let obfsParam = config.obfsParam ?? ""
        let keyData = (config.password + obfsParam).data(using: .utf8) ?? Data()
        self.key = keyData.md5()
        
        // 生成随机IV
        self.iv = Data.randomBytes(length: 16)
    }
    
    // MARK: - 公共方法
    
    /// 对数据进行混��
    /// - Parameter data: 原始数据
    /// - Returns: 混淆后的数据
    /// - Throws: 混淆过程中的错误
    func obfuscate(_ data: Data) throws -> Data {
        switch config.obfs {
        case .plain:
            return data
        case .http_simple:
            return try httpSimpleObfuscate(data)
        case .http_post:
            return try httpPostObfuscate(data)
        case .tls1_2_ticket_auth:
            return try tlsTicketAuthObfuscate(data)
        }
    }
    
    /// 对混淆数据进行解混淆
    /// - Parameter data: 混淆数据
    /// - Returns: 解混淆后的原始数据
    /// - Throws: 解混淆过程中的错误
    func deobfuscate(_ data: Data) throws -> Data {
        switch config.obfs {
        case .plain:
            return data
        case .http_simple:
            return try httpSimpleDeobfuscate(data)
        case .http_post:
            return try httpPostDeobfuscate(data)
        case .tls1_2_ticket_auth:
            return try tlsTicketAuthDeobfuscate(data)
        }
    }
    
    // MARK: - 私有方法
    
    /// HTTP Simple混淆
    private func httpSimpleObfuscate(_ data: Data) throws -> Data {
        var result = Data()
        
        // 添加 HTTP 请求头
        let httpHeader = """
        GET / HTTP/1.1\r
        Host: \(config.serverAddress)\r
        User-Agent: Mozilla/5.0\r
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r
        Accept-Language: en-US,en;q=0.8\r
        Accept-Encoding: gzip, deflate\r
        Connection: keep-alive\r
        \r\n
        """
        
        result.append(httpHeader.data(using: .utf8)!)
        result.append(data)
        return result
    }
    
    /// HTTP Simple解混淆
    private func httpSimpleDeobfuscate(_ data: Data) throws -> Data {
        // 查找HTTP头部结束位置
        guard let range = data.range(of: "\r\n\r\n".data(using: .utf8)!) else {
            throw SSRError.invalidProtocol
        }
        
        // 返回HTTP头部之后的数据
        return data.subdata(in: range.upperBound..<data.count)
    }
    
    /// HTTP POST混淆
    private func httpPostObfuscate(_ data: Data) throws -> Data {
        var result = Data()
        
        // 添加 HTTP POST 请求头
        let httpHeader = """
        POST / HTTP/1.1\r
        Host: \(config.serverAddress)\r
        User-Agent: Mozilla/5.0\r
        Content-Type: application/x-www-form-urlencoded\r
        Content-Length: \(data.count)\r
        Connection: keep-alive\r
        \r\n
        """
        
        result.append(httpHeader.data(using: .utf8)!)
        result.append(data)
        return result
    }
    
    /// HTTP POST解混淆
    private func httpPostDeobfuscate(_ data: Data) throws -> Data {
        // 类似 httpSimpleDeobfuscate
        guard let range = data.range(of: "\r\n\r\n".data(using: .utf8)!) else {
            throw SSRError.invalidProtocol
        }
        return data.subdata(in: range.upperBound..<data.count)
    }
    
    /// TLS 1.2 Ticket Auth混淆
    private func tlsTicketAuthObfuscate(_ data: Data) throws -> Data {
        // TLS 1.2 ticket auth 混淆实现
        // 这里需要实现完整的 TLS 1.2 握手过程
        throw SSRError.unsupportedObfs
    }
    
    /// TLS 1.2 Ticket Auth解混淆
    private func tlsTicketAuthDeobfuscate(_ data: Data) throws -> Data {
        // TLS 1.2 ticket auth 解混淆实现
        throw SSRError.unsupportedObfs
    }
}
