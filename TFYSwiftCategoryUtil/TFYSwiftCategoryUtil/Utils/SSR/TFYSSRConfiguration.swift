//
//  TFYSSRConfiguration.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation

// 在文件顶部添加 CommonCrypto 常量定义
private enum CryptoConstants {
    // AES 密钥大小
    static let kCCKeySizeAES128 = 16
    static let kCCKeySizeAES192 = 24
    static let kCCKeySizeAES256 = 32
    
    // 块大小
    static let kCCBlockSizeAES128 = 16
    static let kCCBlockSizeBlowfish = 8
    static let kCCBlockSizeCAST = 8
    static let kCCBlockSizeDES = 8
    static let kCCBlockSizeRC2 = 8
    
    // 其他密钥大小
    static let kCCKeySizeBlowfish = 16
    static let kCCKeySizeCAST = 16
    static let kCCKeySizeDES = 8
    static let kCCKeySizeRC2 = 16
}

/// SSR配置模型
/// 用于存储和管理SSR代理服务器的所有配置参数
public struct TFYSSRConfiguration: Codable {
    // MARK: - 基本配置属性
    
    /// 服务器地址
    /// - 可以是IP地址或域名
    public let serverAddress: String
    
    /// 服务器端口
    /// - 远程SSR服务器监听的端口
    public let serverPort: Int
    
    /// 本地端口
    /// - 本地SOCKS5代理服务器监听的端口
    public let localPort: Int
    
    /// 密码
    /// - 用于加密通信的密码
    public let password: String
    
    /// 加密方法
    /// - 数据加密使用的算法
    public let method: SSREncryptMethod
    
    /// 协议
    /// - 通信协议类型
    public let `protocol`: SSRProtocol
    
    /// 协议参数
    /// - 可选的协议附加参数
    public let protocolParam: String?
    
    /// 混淆
    /// - 流量混淆方式
    public let obfs: SSRObfs
    
    /// 混淆参数
    /// - 可选的混淆附加参数
    public let obfsParam: String?
    
    /// 备注
    /// - 配置的说明信息
    public let remarks: String?
    
    // MARK: - 初始化方法
    
    /// 创建SSR配置
    /// - Parameters:
    ///   - serverAddress: 服务器地址
    ///   - serverPort: 服务器端口
    ///   - localPort: 本地端口，默认1080
    ///   - password: 密码
    ///   - method: 加密方法
    ///   - protocol: 协议类型
    ///   - protocolParam: 协议参数，可选
    ///   - obfs: 混淆方式
    ///   - obfsParam: 混淆参数，可选
    ///   - remarks: 备
    public init(serverAddress: String,
                serverPort: Int,
                localPort: Int = 1080,
                password: String,
                method: SSREncryptMethod,
                protocol: SSRProtocol,
                protocolParam: String? = nil,
                obfs: SSRObfs,
                obfsParam: String? = nil,
                remarks: String? = nil) {
        self.serverAddress = serverAddress
        self.serverPort = serverPort
        self.localPort = localPort
        self.password = password
        self.method = method
        self.protocol = `protocol`
        self.protocolParam = protocolParam
        self.obfs = obfs
        self.obfsParam = obfsParam
        self.remarks = remarks
    }
}

/// SSR加密方法
public enum SSREncryptMethod: String, Codable {
    case none = "none"
    case table = "table"
    case rc4 = "rc4"
    case rc4_md5 = "rc4-md5"
    case aes_128_cfb = "aes-128-cfb"
    case aes_192_cfb = "aes-192-cfb"
    case aes_256_cfb = "aes-256-cfb"
    case bf_cfb = "bf-cfb"
    case camellia_128_cfb = "camellia-128-cfb"
    case camellia_192_cfb = "camellia-192-cfb"
    case camellia_256_cfb = "camellia-256-cfb"
    case cast5_cfb = "cast5-cfb"
    case des_cfb = "des-cfb"
    case idea_cfb = "idea-cfb"
    case rc2_cfb = "rc2-cfb"
    case seed_cfb = "seed-cfb"
    case salsa20 = "salsa20"
    case chacha20 = "chacha20"
    case chacha20_ietf = "chacha20-ietf"
}

/// SSR协议类型
public enum SSRProtocol: String, Codable {
    case origin = "origin"
    case verify_simple = "verify_simple"
    case verify_sha1 = "verify_sha1"
    case auth_sha1 = "auth_sha1"
    case auth_sha1_v2 = "auth_sha1_v2"
    case auth_sha1_v4 = "auth_sha1_v4"
    case auth_aes128_md5 = "auth_aes128_md5"
    case auth_aes128_sha1 = "auth_aes128_sha1"
    case auth_chain_a = "auth_chain_a"
    case auth_chain_b = "auth_chain_b"
}

/// SSR混淆类型
public enum SSRObfs: String, Codable {
    case plain = "plain"
    case http_simple = "http_simple"
    case http_post = "http_post"
    case tls1_2_ticket_auth = "tls1.2_ticket_auth"
}

/// 代理类型
public enum ProxyType: String, Codable {
    case http = "HTTP"
    case socks5 = "SOCKS5"
    case none = "NONE"
}

// 扩展 SSREncryptMethod 添加密钥长度和IV长度属性
extension SSREncryptMethod {
    /// 获取密钥长度
    var keyLength: Int {
        switch self {
        case .aes_128_cfb:
            return CryptoConstants.kCCKeySizeAES128
        case .aes_192_cfb:
            return CryptoConstants.kCCKeySizeAES192
        case .aes_256_cfb:
            return CryptoConstants.kCCKeySizeAES256
        case .chacha20, .chacha20_ietf:
            return 32
        case .rc4, .rc4_md5:
            return 16
        case .salsa20:
            return 32
        case .bf_cfb:
            return CryptoConstants.kCCKeySizeBlowfish
        case .camellia_128_cfb:
            return 16
        case .camellia_192_cfb:
            return 24
        case .camellia_256_cfb:
            return 32
        case .cast5_cfb:
            return CryptoConstants.kCCKeySizeCAST
        case .des_cfb:
            return CryptoConstants.kCCKeySizeDES
        case .idea_cfb:
            return 16
        case .rc2_cfb:
            return CryptoConstants.kCCKeySizeRC2
        case .seed_cfb:
            return 16
        case .table, .none:
            return 0
        }
    }
    
    /// 获取初始化向量长度
    var ivLength: Int {
        switch self {
        case .aes_128_cfb, .aes_192_cfb, .aes_256_cfb:
            return CryptoConstants.kCCBlockSizeAES128
        case .chacha20:
            return 8
        case .chacha20_ietf:
            return 12
        case .rc4, .rc4_md5:
            return 16
        case .salsa20:
            return 8
        case .bf_cfb:
            return CryptoConstants.kCCBlockSizeBlowfish
        case .camellia_128_cfb, .camellia_192_cfb, .camellia_256_cfb:
            return 16
        case .cast5_cfb:
            return CryptoConstants.kCCBlockSizeCAST
        case .des_cfb:
            return CryptoConstants.kCCBlockSizeDES
        case .idea_cfb:
            return 8
        case .rc2_cfb:
            return CryptoConstants.kCCBlockSizeRC2
        case .seed_cfb:
            return 16
        case .table, .none:
            return 0
        }
    }
    
    /// 获取推荐的缓冲区大小
    var recommendedBufferSize: Int {
        switch self {
        case .aes_128_cfb, .aes_192_cfb, .aes_256_cfb:
            return 16384  // 16KB
        case .chacha20, .chacha20_ietf:
            return 65536  // 64KB
        case .rc4, .rc4_md5:
            return 8192   // 8KB
        default:
            return 16384  // 默认16KB
        }
    }
}

