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
public enum SSRError: Error {
    case invalidProtocol
    case invalidAddress
    case invalidAddressType
    case invalidPort
    case invalidParameter(String)
    case connectionFailed
    case unsupportedCommand
    case unsupportedMethod
    case unsupportedObfs
    case operationFailed(String)
    case timeout
    
    public var localizedDescription: String {
        switch self {
        case .invalidProtocol:
            return "无效的协议"
        case .invalidAddress:
            return "无效的地址"
        case .invalidAddressType:
            return "无效的地址类型"
        case .invalidPort:
            return "无效的端口号"
        case .invalidParameter(let msg):
            return "无效的参数: \(msg)"
        case .connectionFailed:
            return "连接失败"
        case .unsupportedCommand:
            return "不支持的命令"
        case .unsupportedMethod:
            return "不支持的加密方法"
        case .unsupportedObfs:
            return "不支持的混淆方式"
        case .operationFailed(let msg):
            return "操作失败: \(msg)"
        case .timeout:
            return "操作超时"
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

