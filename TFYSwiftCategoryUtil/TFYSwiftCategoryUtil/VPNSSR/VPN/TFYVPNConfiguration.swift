//
//  TFYVPNConfiguration.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2024/1/10.
//

import Foundation

/// VPN配置
public struct VPNConfiguration: Codable {
    /// VPN名称
    public let vpnName: String
    /// 服务器地址
    public let serverAddress: String
    /// 端口
    public let port: Int
    /// 加密方法
    public let method: SSREncryptMethod
    /// 密码
    public let password: String
    /// SSR协议
    public let ssrProtocol: SSRProtocol
    /// 混淆方式
    public let obfs: SSRObfs
    /// 混淆参数
    public let obfsParam: String?
    /// DNS设置
    public let dnsSettings: DNSSettings?
    /// 代理设置
    public let proxySettings: ProxySettings?
    /// MTU值
    public let mtu: Int?
    /// 是否启用压缩
    public let enableCompression: Bool
    /// 最大重连次数
    public let maxReconnectAttempts: Int
    /// 是否启用日志
    public let enableLogging: Bool
    /// 日志级别
    public let logLevel: VPNLogLevel
    /// 日志保留天数
    public let logRetentionDays: Int
    /// 是否自动重连
    public let autoReconnect: Bool
    /// 自动重连延迟（秒）
    public let autoReconnectDelay: TimeInterval
    /// 连接超时时间（秒）
    public let connectionTimeout: TimeInterval
    
    /// 初始化VPN配置
    public init(
        vpnName: String,
        serverAddress: String,
        port: Int,
        method: SSREncryptMethod,
        password: String,
        ssrProtocol: SSRProtocol,
        obfs: SSRObfs,
        obfsParam: String? = nil,
        dnsSettings: DNSSettings? = nil,
        proxySettings: ProxySettings? = nil,
        mtu: Int? = nil,
        enableCompression: Bool = true,
        maxReconnectAttempts: Int = 3,
        enableLogging: Bool = true,
        logLevel: VPNLogLevel = .info,
        logRetentionDays: Int = 7,
        autoReconnect: Bool = true,
        autoReconnectDelay: TimeInterval = 3.0,
        connectionTimeout: TimeInterval = 30.0
    ) {
        self.vpnName = vpnName
        self.serverAddress = serverAddress
        self.port = port
        self.method = method
        self.password = password
        self.ssrProtocol = ssrProtocol
        self.obfs = obfs
        self.obfsParam = obfsParam
        self.dnsSettings = dnsSettings
        self.proxySettings = proxySettings
        self.mtu = mtu
        self.enableCompression = enableCompression
        self.maxReconnectAttempts = maxReconnectAttempts
        self.enableLogging = enableLogging
        self.logLevel = logLevel
        self.logRetentionDays = logRetentionDays
        self.autoReconnect = autoReconnect
        self.autoReconnectDelay = autoReconnectDelay
        self.connectionTimeout = connectionTimeout
    }
}

/// DNS设置
public struct DNSSettings: Codable {
    /// DNS服务器列表
    public let servers: [String]
    /// 搜索域
    public let searchDomains: [String]?
    /// 是否使用分流DNS
    public let useSplitDNS: Bool
    
    public init(
        servers: [String],
        searchDomains: [String]? = nil,
        useSplitDNS: Bool = false
    ) {
        self.servers = servers
        self.searchDomains = searchDomains
        self.useSplitDNS = useSplitDNS
    }
}

/// 代理设置
public struct ProxySettings: Codable {
    /// 代理服务器
    public let server: String
    /// 代理端口
    public let port: Int
    /// 代理用户名
    public let username: String?
    /// 代理密码
    public let password: String?
    /// 代理类型
    public let type: ProxyType
    
    public init(
        server: String,
        port: Int,
        username: String? = nil,
        password: String? = nil,
        type: ProxyType = .http
    ) {
        self.server = server
        self.port = port
        self.username = username
        self.password = password
        self.type = type
    }
}

/// 日志级别
public enum VPNLogLevel: String, Codable {
    /// 调试信息
    case debug = "DEBUG"
    /// 普通信息
    case info = "INFO"
    /// 警告信息
    case warning = "WARNING"
    /// 错误信息
    case error = "ERROR"
    
    /// 是否应该记录该级别的日志
    func shouldLog(level: VPNLogLevel) -> Bool {
        switch self {
        case .debug:
            return true
        case .info:
            return level != .debug
        case .warning:
            return level != .debug && level != .info
        case .error:
            return level == .error
        }
    }
}

