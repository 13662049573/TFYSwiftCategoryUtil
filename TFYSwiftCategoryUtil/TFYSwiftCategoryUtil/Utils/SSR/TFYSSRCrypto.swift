//
//  TFYSSRCrypto.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation
import CommonCrypto
import Security

// 在 TFYSSRCrypto 类之前添加加密器协议
protocol Cipher {
    func encrypt(_ data: Data) throws -> Data
    func decrypt(_ data: Data) throws -> Data
}

// 在文件顶部添加常量定义
private enum CryptoConstants {
    // AES 相关常量
    static let kCCAlgorithmAES = UInt32(0)
    static let kCCBlockSizeAES128 = 16
    
    // ChaCha20 相关常量
    static let KEY_SIZE = 32
    static let NONCE_SIZE = 12
    static let BLOCK_SIZE = 64
}

// AES 加密器实现
class AESCipher: Cipher {
    private let method: SSREncryptMethod
    private let key: Data
    private let iv: Data
    
    init(method: SSREncryptMethod, key: Data, iv: Data) {
        self.method = method
        self.key = key
        self.iv = iv
    }
    
    func encrypt(_ data: Data) throws -> Data {
        var outLength = Int(0)
        var outBytes = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
        
        let status = key.withUnsafeBytes { keyBytes in
            iv.withUnsafeBytes { ivBytes in
                data.withUnsafeBytes { dataBytes in
                    CCCrypt(CCOperation(kCCEncrypt),
                           CCAlgorithm(kCCAlgorithmAES),
                           CCOptions(kCCOptionPKCS7Padding),
                           keyBytes.baseAddress, key.count,
                           ivBytes.baseAddress,
                           dataBytes.baseAddress, data.count,
                           &outBytes, outBytes.count,
                           &outLength)
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw TFYSSRCrypto.SSRCryptoError.operationFailed("AES加密失败")
        }
        
        return Data(outBytes.prefix(outLength))
    }
    
    func decrypt(_ data: Data) throws -> Data {
        var outLength = Int(0)
        var outBytes = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
        
        let status = key.withUnsafeBytes { keyBytes in
            iv.withUnsafeBytes { ivBytes in
                data.withUnsafeBytes { dataBytes in
                    CCCrypt(CCOperation(kCCDecrypt),
                           CCAlgorithm(kCCAlgorithmAES),
                           CCOptions(kCCOptionPKCS7Padding),
                           keyBytes.baseAddress, key.count,
                           ivBytes.baseAddress,
                           dataBytes.baseAddress, data.count,
                           &outBytes, outBytes.count,
                           &outLength)
                }
            }
        }
        
        guard status == kCCSuccess else {
            throw TFYSSRCrypto.SSRCryptoError.operationFailed("AES解密失败")
        }
        
        return Data(outBytes.prefix(outLength))
    }
}

// ChaCha20 加密器实现
class ChaCha20Cipher: Cipher {
    private let key: Data
    private let iv: Data
    private var counter: UInt32 = 0
    
    init(method: SSREncryptMethod, key: Data, iv: Data) {
        self.key = key
        self.iv = iv
    }
    
    func encrypt(_ data: Data) throws -> Data {
        return try process(data, encrypt: true)
    }
    
    func decrypt(_ data: Data) throws -> Data {
        return try process(data, encrypt: false)
    }
    
    private func process(_ data: Data, encrypt: Bool) throws -> Data {
        var output = Data(count: data.count)
        
        // 确保密钥和IV长度正确
        guard key.count == CryptoConstants.KEY_SIZE else {
            throw TFYSSRCrypto.SSRCryptoError.invalidParameter("ChaCha20密钥长度错误")
        }
        
        guard iv.count >= CryptoConstants.NONCE_SIZE else {
            throw TFYSSRCrypto.SSRCryptoError.invalidParameter("ChaCha20 IV长度错误")
        }
        
        // 处理每个数据块
        let blockSize = CryptoConstants.BLOCK_SIZE
        var offset = 0
        
        while offset < data.count {
            let remainingBytes = data.count - offset
            let currentBlockSize = min(blockSize, remainingBytes)
            
            // 生成密钥流
            let keyStream = try generateKeyStream(counter: counter)
            
            // XOR操作
            for i in 0..<currentBlockSize {
                let dataIndex = offset + i
                output[dataIndex] = data[dataIndex] ^ keyStream[i]
            }
            
            offset += currentBlockSize
            counter += 1
        }
        
        return output
    }
    
    private func generateKeyStream(counter: UInt32) throws -> [UInt8] {
        var state = [UInt32](repeating: 0, count: 16)
        
        // 设置常量
        state[0] = 0x61707865 // "expa"
        state[1] = 0x3320646e // "nd 3"
        state[2] = 0x79622d32 // "2-by"
        state[3] = 0x6b206574 // "te k"
        
        // 设置密钥
        for i in 0..<8 {
            state[4 + i] = key.withUnsafeBytes { ptr in
                ptr.load(fromByteOffset: i * 4, as: UInt32.self).littleEndian
            }
        }
        
        // 设置计数器
        state[12] = counter
        
        // 设置nonce
        for i in 0..<3 {
            state[13 + i] = iv.withUnsafeBytes { ptr in
                ptr.load(fromByteOffset: i * 4, as: UInt32.self).littleEndian
            }
        }
        
        // ChaCha20 核心函数
        var working = state
        for _ in 0..<10 { // 20轮 = 10次双轮
            // 四分之一轮函数
            quarterRound(&working, 0, 4, 8, 12)
            quarterRound(&working, 1, 5, 9, 13)
            quarterRound(&working, 2, 6, 10, 14)
            quarterRound(&working, 3, 7, 11, 15)
            
            quarterRound(&working, 0, 5, 10, 15)
            quarterRound(&working, 1, 6, 11, 12)
            quarterRound(&working, 2, 7, 8, 13)
            quarterRound(&working, 3, 4, 9, 14)
        }
        
        // 添加工作状态到初始状态
        for i in 0..<16 {
            working[i] = working[i] &+ state[i]
        }
        
        // 转换为字节数组
        var keyStream = [UInt8](repeating: 0, count: 64)
        for i in 0..<16 {
            let value = working[i].littleEndian
            keyStream[i * 4 + 0] = UInt8((value >> 0) & 0xFF)
            keyStream[i * 4 + 1] = UInt8((value >> 8) & 0xFF)
            keyStream[i * 4 + 2] = UInt8((value >> 16) & 0xFF)
            keyStream[i * 4 + 3] = UInt8((value >> 24) & 0xFF)
        }
        
        return keyStream
    }
    
    private func quarterRound(_ state: inout [UInt32], _ a: Int, _ b: Int, _ c: Int, _ d: Int) {
        state[a] = state[a] &+ state[b]
        state[d] = rotateLeft(state[d] ^ state[a], by: 16)
        
        state[c] = state[c] &+ state[d]
        state[b] = rotateLeft(state[b] ^ state[c], by: 12)
        
        state[a] = state[a] &+ state[b]
        state[d] = rotateLeft(state[d] ^ state[a], by: 8)
        
        state[c] = state[c] &+ state[d]
        state[b] = rotateLeft(state[b] ^ state[c], by: 7)
    }
    
    private func rotateLeft(_ value: UInt32, by n: UInt32) -> UInt32 {
        return (value << n) | (value >> (32 - n))
    }
}

/// SSR加密器核心实现
public class TFYSSRCrypto {
    
    /// SSR加密错误类型
    public enum SSRCryptoError: Error {
        case invalidParameter(String)
        case operationFailed(String)
        case unsupportedMethod
        case operationTimeout
        
        var localizedDescription: String {
            switch self {
            case .invalidParameter(let msg): return "参数无效: \(msg)" 
            case .operationFailed(let msg): return "操作失败: \(msg)"
            case .unsupportedMethod: return "不支持的加密方法"
            case .operationTimeout: return "操作超时"
            }
        }
    }
    
    // MARK: - 属性
    private let method: SSREncryptMethod
    private let password: String
    private let key: Data
    private var iv: Data
    
    // MARK: - 初始化
    public init(method: SSREncryptMethod, password: String) {
        self.method = method
        self.password = password
        
        // 生成密钥
        let keyData = password.data(using: .utf8) ?? Data()
        self.key = keyData.md5().prefix(method.keyLength)
        
        // 生成初始化向量
        self.iv = Data.randomBytes(length: method.ivLength)
    }
    
    // MARK: - 公共方法
    
    /// 加密数据
    public func encrypt(_ data: Data) throws -> Data {
        try validateEncryptionParameters()
        
        switch method {
        case .aes_128_cfb, .aes_192_cfb, .aes_256_cfb:
            let cipher = AESCipher(method: method, key: key, iv: iv)
            return try cipher.encrypt(data)
        case .chacha20, .chacha20_ietf:
            let cipher = ChaCha20Cipher(method: method, key: key, iv: iv)
            return try cipher.encrypt(data)
        default:
            throw SSRCryptoError.unsupportedMethod
        }
    }
    
    /// 解密数据
    public func decrypt(_ data: Data) throws -> Data {
        try validateEncryptionParameters()
        
        switch method {
        case .aes_128_cfb, .aes_192_cfb, .aes_256_cfb:
            let cipher = AESCipher(method: method, key: key, iv: iv)
            return try cipher.decrypt(data)
        case .chacha20, .chacha20_ietf:
            let cipher = ChaCha20Cipher(method: method, key: key, iv: iv)
            return try cipher.decrypt(data)
        default:
            throw SSRCryptoError.unsupportedMethod
        }
    }
    
    // MARK: - 私有方法
    private func validateEncryptionParameters() throws {
        guard method != .none else {
            throw SSRCryptoError.invalidParameter("无效的加密方法")
        }
        
        guard !password.isEmpty else {
            throw SSRCryptoError.invalidParameter("密码不能为空")
        }
        
        guard key.count >= method.keyLength else {
            throw SSRCryptoError.invalidParameter("密钥长度不足")
        }
        
        guard iv.count >= method.ivLength else {
            throw SSRCryptoError.invalidParameter("IV长度不足")
        }
    }
}
