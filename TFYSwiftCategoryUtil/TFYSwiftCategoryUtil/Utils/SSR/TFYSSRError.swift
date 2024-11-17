//
//  TFYSSRError.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation
import CommonCrypto
import Security  // 添加这行
import UIKit

/// SSR错误类型
public enum SSRError: LocalizedError {
    /// 配置无效
    case invalidConfiguration
    /// 协议无效
    case invalidProtocol
    /// 不支持的命令
    case unsupportedCommand
    /// 地址类型无效
    case invalidAddressType
    /// 地址无效
    case invalidAddress
    /// 端口无效
    case invalidPort
    /// 加密失败
    case encryptionFailed
    /// 解密失败
    case decryptionFailed
    /// 连接失败
    case connectionFailed(String)
    /// 连接超时
    case connectionTimeout
    /// 连接数过多
    case tooManyConnections
    /// 网络不可用
    case networkUnavailable
    /// 服务器错误
    case serverError(String)
    /// 未知错误
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "SSR配置无效"
        case .invalidProtocol:
            return "协议无效"
        case .unsupportedCommand:
            return "不支持的命令"
        case .invalidAddressType:
            return "地址类型无效"
        case .invalidAddress:
            return "地址无效"
        case .invalidPort:
            return "端口无效"
        case .encryptionFailed:
            return "加密失败"
        case .decryptionFailed:
            return "解密失败"
        case .connectionFailed(let reason):
            return "连接失败: \(reason)"
        case .connectionTimeout:
            return "连接超时"
        case .tooManyConnections:
            return "连接数过多"
        case .networkUnavailable:
            return "网络不可用"
        case .serverError(let message):
            return "服务器错误: \(message)"
        case .unknown:
            return "未知错误"
        }
    }
} 

// 扩展Data以添加加密相关的便利方法
extension Data {
    
    func encrypt(using method: SSREncryptMethod,
                password: String) throws -> Data {
        let crypto = TFYSSRCrypto(method: method, password: password)
        return try crypto.encrypt(self)
    }
    
    func decrypt(using method: SSREncryptMethod,
                password: String) throws -> Data {
        let crypto = TFYSSRCrypto(method: method, password: password)
        return try crypto.decrypt(self)
    }
    
    var hexString: String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
    func xor(with other: Data) -> Data {
        let length = Swift.min(count, other.count)
        var result = Data(count: length)
        for i in 0..<length {
            result[i] = self[i] ^ other[i]
        }
        return result
    }
    
    /// 计算 MD5 哈希值
    func md5() -> Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        withUnsafeBytes { buffer in
            _ = CC_MD5(buffer.baseAddress, CC_LONG(buffer.count), &digest)
        }
        return Data(digest)
    }
    
    /// 生成指定长度的随机字节
    static func randomBytes(length: Int) -> Data {
        var data = Data(count: length)
        let result = data.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, length, bytes.baseAddress!)
        }
        
        guard result == errSecSuccess else {
            // 如果安全随机数生成失败，使用备用方案
            var bytes = [UInt8](repeating: 0, count: length)
            for i in 0..<length {
                bytes[i] = UInt8.random(in: 0...255)
            }
            return Data(bytes)
        }
        
        return data
    }
}

