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
    
    /// 对数据进行混淆
    /// - Parameter data: 原始数据
    /// - Returns: 混淆后的数据
    func obfuscate(_ data: Data) -> Data {
        switch config.obfs {
        case .plain:
            return data
        case .http_simple:
            return obfuscateHTTPSimple(data)
        case .http_post:
            return obfuscateHTTPPost(data)
        case .tls1_2_ticket_auth:
            return obfuscateTLS12(data)
        }
    }
    
    /// 对混淆数据进行解混淆
    /// - Parameter data: 混淆数据
    /// - Returns: 解混淆后的原始数据
    func deobfuscate(_ data: Data) -> Data {
        switch config.obfs {
        case .plain:
            return data
        case .http_simple:
            return deobfuscateHTTPSimple(data)
        case .http_post:
            return deobfuscateHTTPPost(data)
        case .tls1_2_ticket_auth:
            return deobfuscateTLS12(data)
        }
    }
    
    // MARK: - 私有方法
    
    /// HTTP Simple混淆
    private func obfuscateHTTPSimple(_ data: Data) -> Data {
        var result = Data()
        
        // 构建HTTP GET请求
        let host = config.obfsParam ?? config.serverAddress
        let path = generateRandomPath()
        let headers = """
        GET /\(path) HTTP/1.1\r
        Host: \(host)\r
        User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36\r
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r
        Accept-Language: en-US,en;q=0.8\r
        Accept-Encoding: gzip, deflate\r
        Connection: keep-alive\r
        \r\n
        """
        
        // 添加请求头
        result.append(headers.data(using: .utf8)!)
        
        // 对数据进行Base64编码并添加到URL参数中
        let encodedData = data.base64EncodedString()
        result.append(encodedData.data(using: .utf8)!)
        
        return result
    }
    
    /// HTTP Simple解混淆
    private func deobfuscateHTTPSimple(_ data: Data) -> Data {
        guard let str = String(data: data, encoding: .utf8) else {
            return data
        }
        
        // 查找Base64编码的数据部分
        if let range = str.range(of: "\r\n\r\n") {
            // 获取Base64编码的部分
            let encodedPart = str[range.upperBound...]
            // 解码Base64数据
            if let decodedData = Data(base64Encoded: String(encodedPart)) {
                return decodedData
            }
        }
        
        return data
    }
    
    /// HTTP POST混淆
    private func obfuscateHTTPPost(_ data: Data) -> Data {
        var result = Data()
        
        // 构建HTTP POST请求
        let host = config.obfsParam ?? config.serverAddress
        let path = generateRandomPath()
        let contentLength = data.count
        let headers = """
        POST /\(path) HTTP/1.1\r
        Host: \(host)\r
        User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36\r
        Content-Type: application/x-www-form-urlencoded\r
        Content-Length: \(contentLength)\r
        Connection: keep-alive\r
        \r\n
        """
        
        // 添加请求头和数据
        result.append(headers.data(using: .utf8)!)
        result.append(data)
        
        return result
    }
    
    /// HTTP POST解混淆
    private func deobfuscateHTTPPost(_ data: Data) -> Data {
        guard let str = String(data: data, encoding: .utf8) else {
            return data
        }
        
        // 查找请求体部分
        if let range = str.range(of: "\r\n\r\n") {
            // 计算数据中的实际偏移量
            let headerLength = str.distance(from: str.startIndex, to: range.upperBound)
            // 提取请求体部分
            return data.subdata(in: headerLength..<data.count)
        }
        
        return data
    }
    
    /// TLS 1.2 Ticket Auth混淆
    private func obfuscateTLS12(_ data: Data) -> Data {
        var result = Data()
        
        if sendCounter == 0 {
            // 首次发送，构建TLS ClientHello
            result.append(buildTLSClientHello())
            sendCounter += 1
        }
        
        // 构建TLS Application Data
        result.append(buildTLSApplicationData(data))
        sendCounter += 1
        
        return result
    }
    
    /// TLS 1.2 Ticket Auth解混淆
    private func deobfuscateTLS12(_ data: Data) -> Data {
        guard data.count >= 5 else { return data }
        
        if receiveCounter == 0 {
            // 首次接收，跳过TLS ServerHello
            receiveCounter += 1
            return Data()
        }
        
        // 解析TLS记录层
        let contentType = data[0]
        let length = UInt16(data[3]) << 8 | UInt16(data[4])
        
        guard contentType == 0x17, // Application Data
              data.count >= Int(length) + 5 else {
            return data
        }
        
        // 提取应用数据
        let applicationData = data.subdata(in: 5..<(Int(length) + 5))
        receiveCounter += 1
        
        return applicationData
    }
    
    /// 生成随机路径
    private func generateRandomPath() -> String {
        let length = Int.random(in: 8...16)
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }
    
    /// 构建TLS ClientHello
    private func buildTLSClientHello() -> Data {
        var hello = Data()
        
        // Record Layer
        hello.append(0x16) // Content Type: Handshake
        hello.append(0x03) // Version: TLS 1.0
        hello.append(0x03)
        
        // 后续添加长度和具体的ClientHello内容
        // 这里简化处理，实际应该构建完整的TLS握手包
        
        return hello
    }
    
    /// 构建TLS Application Data
    private func buildTLSApplicationData(_ data: Data) -> Data {
        var result = Data()
        
        // Record Layer
        result.append(0x17) // Content Type: Application Data
        result.append(0x03) // Version: TLS 1.2
        result.append(0x03)
        
        // Length
        let length = UInt16(data.count)
        result.append(UInt8(length >> 8))
        result.append(UInt8(length & 0xFF))
        
        // Data
        result.append(data)
        
        return result
    }
}
