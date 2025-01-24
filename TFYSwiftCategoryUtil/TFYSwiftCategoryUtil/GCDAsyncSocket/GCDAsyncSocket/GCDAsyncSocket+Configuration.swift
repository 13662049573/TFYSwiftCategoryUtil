import Foundation
import Security
import CFNetwork

// MARK: - SSL/TLS Constants

extension GCDAsyncSocket {
    // CFStream SSL/TLS Constants
    public static let kCFStreamSSLPeerName = "kCFStreamSSLPeerName"
    public static let kCFStreamSSLCertificates = "kCFStreamSSLCertificates"
    public static let kCFStreamSSLIsServer = "kCFStreamSSLIsServer"
    public static let kCFStreamSSLLevel = "kCFStreamSSLLevel"
    
    // GCDAsyncSocket SSL/TLS Constants
    public static let SSLManuallyEvaluateTrust = "GCDAsyncSocketManuallyEvaluateTrust"
    public static let SSLPeerID = "GCDAsyncSocketSSLPeerID"
    public static let SSLProtocolVersionMin = "GCDAsyncSocketSSLProtocolVersionMin"
    public static let SSLProtocolVersionMax = "GCDAsyncSocketSSLProtocolVersionMax"
    public static let SSLSessionOptionFalseStart = "GCDAsyncSocketSSLSessionOptionFalseStart"
    public static let SSLSessionOptionSendOneByteRecord = "GCDAsyncSocketSSLSessionOptionSendOneByteRecord"
    public static let SSLCipherSuites = "GCDAsyncSocketSSLCipherSuites"
    public static let SSLALPN = "GCDAsyncSocketSSLALPN"
    
    #if !os(iOS)
    public static let SSLDiffieHellmanParameters = "GCDAsyncSocketSSLDiffieHellmanParameters"
    #endif
}

// MARK: - SSL/TLS Configuration

extension GCDAsyncSocket {
    
    /// SSL/TLS Configuration options for secure socket connections
    public struct SSLSettings {
        
        /// Supported SSL/TLS protocol versions for minimum protocol setting
        ///
        /// - sslProtocol3: SSL 3.0 (Deprecated, not recommended)
        /// - tlsProtocol1: TLS 1.0 (Deprecated, not recommended)
        /// - tlsProtocol11: TLS 1.1 (Deprecated, not recommended)
        /// - tlsProtocol12: TLS 1.2 (Recommended minimum)
        /// - tlsProtocol13: TLS 1.3 (Recommended)
        public enum ProtocolMin: Int {
            /// SSL 3.0 (Deprecated, not recommended)
            case sslProtocol3 = 3
            /// TLS 1.0 (Deprecated, not recommended)
            case tlsProtocol1 = 4
            /// TLS 1.1 (Deprecated, not recommended)
            case tlsProtocol11 = 7
            /// TLS 1.2 (Recommended minimum)
            case tlsProtocol12 = 8
            /// TLS 1.3 (Recommended)
            case tlsProtocol13 = 10
            
            /// Convert to SecureTransport SSLProtocol value
            var secureTransportValue: SSLProtocol {
                return SSLProtocol(rawValue: Int32(self.rawValue))!
            }
        }
        
        /// Supported SSL/TLS protocol versions for maximum protocol setting
        ///
        /// - sslProtocol3: SSL 3.0 (Deprecated, not recommended)
        /// - tlsProtocol1: TLS 1.0 (Deprecated, not recommended)
        /// - tlsProtocol11: TLS 1.1 (Deprecated, not recommended)
        /// - tlsProtocol12: TLS 1.2 (Widely supported)
        /// - tlsProtocol13: TLS 1.3 (Recommended)
        public enum ProtocolMax: Int {
            /// SSL 3.0 (Deprecated, not recommended)
            case sslProtocol3 = 3
            /// TLS 1.0 (Deprecated, not recommended)
            case tlsProtocol1 = 4
            /// TLS 1.1 (Deprecated, not recommended)
            case tlsProtocol11 = 7
            /// TLS 1.2 (Widely supported)
            case tlsProtocol12 = 8
            /// TLS 1.3 (Recommended)
            case tlsProtocol13 = 10
            
            /// Convert to SecureTransport SSLProtocol value
            var secureTransportValue: SSLProtocol {
                return SSLProtocol(rawValue: Int32(self.rawValue))!
            }
        }
        
        /// Builder class for configuring SSL/TLS settings
        ///
        /// Use this builder to configure various SSL/TLS options in a type-safe way.
        /// Example:
        /// ```swift
        /// let settings = SSLSettings.Builder()
        ///     .isServer(false)
        ///     .minimumProtocolVersion(.tlsProtocol12)
        ///     .maximumProtocolVersion(.tlsProtocol13)
        ///     .build()
        /// ```
        public class Builder {
            /// Internal storage for SSL/TLS settings
            private var settings: [String: Any] = [:]
            
            /// Initialize a new SSL/TLS settings builder
            public init() {}
            
            /// Set whether to manually evaluate trust
            ///
            /// - Parameter value: If true, the delegate will be called to evaluate server trust
            /// - Returns: Builder instance for chaining
            @discardableResult
            public func manuallyEvaluateTrust(_ value: Bool) -> Builder {
                settings[GCDAsyncSocket.SSLManuallyEvaluateTrust] = value
                return self
            }
            
            /// Set the peer name for certificate validation
            ///
            /// - Parameter value: The expected name in the peer's certificate
            /// - Returns: Builder instance for chaining
            @discardableResult
            public func peerName(_ value: String) -> Builder {
                settings[kCFStreamSSLPeerName as String] = value
                return self
            }
            
            /// Set the certificates for the SSL/TLS connection
            ///
            /// - Parameter value: Array of certificates to use
            /// - Returns: Builder instance for chaining
            @discardableResult
            public func certificates(_ value: [SecCertificate]) -> Builder {
                settings[kCFStreamSSLCertificates as String] = value
                return self
            }
            
            /// Set whether this is a server socket
            ///
            /// - Parameter value: true for server socket, false for client socket
            /// - Returns: Builder instance for chaining
            @discardableResult
            public func isServer(_ value: Bool) -> Builder {
                settings[kCFStreamSSLIsServer as String] = value
                return self
            }
            
            /// Set the peer ID for session resumption
            ///
            /// - Parameter value: Peer ID data for session caching
            /// - Returns: Builder instance for chaining
            @discardableResult
            public func peerID(_ value: Data) -> Builder {
                settings[GCDAsyncSocket.SSLPeerID] = value
                return self
            }
            
            /// Set the minimum protocol version
            ///
            /// - Parameter value: Minimum SSL/TLS protocol version to accept
            /// - Returns: Builder instance for chaining
            @discardableResult
            public func minimumProtocolVersion(_ value: ProtocolMin) -> Builder {
                settings[GCDAsyncSocket.SSLProtocolVersionMin] = value.rawValue
                return self
            }
            
            /// Set the maximum protocol version
            ///
            /// - Parameter value: Maximum SSL/TLS protocol version to use
            /// - Returns: Builder instance for chaining
            @discardableResult
            public func maximumProtocolVersion(_ value: ProtocolMax) -> Builder {
                settings[GCDAsyncSocket.SSLProtocolVersionMax] = value.rawValue
                return self
            }
            
            /// Enable/disable TLS false start
            ///
            /// - Parameter value: true to enable false start
            /// - Returns: Builder instance for chaining
            /// - Note: False start can improve handshake performance but may not be supported by all servers
            @discardableResult
            public func allowFalseStart(_ value: Bool) -> Builder {
                settings[GCDAsyncSocket.SSLSessionOptionFalseStart] = value
                return self
            }
            
            /// Enable/disable one byte record layer
            ///
            /// - Parameter value: true to enable one byte records
            /// - Returns: Builder instance for chaining
            /// - Note: Can help with certain compatibility issues but impacts performance
            @discardableResult
            public func sendOneByteRecord(_ value: Bool) -> Builder {
                settings[GCDAsyncSocket.SSLSessionOptionSendOneByteRecord] = value
                return self
            }
            
            /// Set the allowed cipher suites
            ///
            /// - Parameter value: Array of allowed SSL/TLS cipher suites
            /// - Returns: Builder instance for chaining
            /// - Note: Order matters - earlier suites are preferred
            @discardableResult
            public func cipherSuites(_ value: [SSLCipherSuite]) -> Builder {
                settings[GCDAsyncSocket.SSLCipherSuites] = value
                return self
            }
            
            /// Set the ALPN protocols
            ///
            /// - Parameter value: Array of protocol names (e.g. ["h2", "http/1.1"])
            /// - Returns: Builder instance for chaining
            /// - Note: Order matters - earlier protocols are preferred
            @discardableResult
            public func alpnProtocols(_ value: [String]) -> Builder {
                settings[GCDAsyncSocket.SSLALPN] = value
                return self
            }
            
            #if !os(iOS)
            /// Set the Diffie-Hellman parameters (macOS only)
            ///
            /// - Parameter value: DH parameters data
            /// - Returns: Builder instance for chaining
            @discardableResult
            public func diffieHellmanParameters(_ value: Data) -> Builder {
                settings[GCDAsyncSocket.SSLDiffieHellmanParameters] = value
                return self
            }
            #endif
            
            /// Build the final settings dictionary
            ///
            /// - Returns: Dictionary containing all configured SSL/TLS settings
            public func build() -> [String: Any] {
                return settings
            }
        }
    }
}

// MARK: - SSL/TLS Configuration Extensions

extension GCDAsyncSocket {
    
    /// Start TLS with builder pattern configuration
    ///
    /// - Parameter configure: Configuration closure that receives a builder instance
    /// Example:
    /// ```swift
    /// socket.startTLS { builder in
    ///     builder.isServer(false)
    ///           .minimumProtocolVersion(.tlsProtocol12)
    ///           .maximumProtocolVersion(.tlsProtocol13)
    /// }
    /// ```
    public func startTLS(configure: (SSLSettings.Builder) -> Void) {
        let builder = SSLSettings.Builder()
        configure(builder)
        startTLS(builder.build())
    }
    
    /// Common TLS configurations for typical use cases
    public struct TLSConfig {
        /// Default client configuration with modern security settings
        ///
        /// Uses:
        /// - TLS 1.2 minimum
        /// - TLS 1.3 maximum
        /// - Client mode
        public static func clientConfig() -> [String: Any] {
            return SSLSettings.Builder()
                .isServer(false)
                .minimumProtocolVersion(.tlsProtocol12)
                .maximumProtocolVersion(.tlsProtocol13)
                .build()
        }
        
        /// Default server configuration with provided certificates
        ///
        /// Uses:
        /// - TLS 1.2 minimum
        /// - TLS 1.3 maximum
        /// - Server mode
        /// - Provided certificates
        ///
        /// - Parameter certs: Array of server certificates
        public static func serverConfig(withCertificates certs: [SecCertificate]) -> [String: Any] {
            return SSLSettings.Builder()
                .isServer(true)
                .certificates(certs)
                .minimumProtocolVersion(.tlsProtocol12)
                .maximumProtocolVersion(.tlsProtocol13)
                .build()
        }
        
        /// Configuration for manual trust evaluation
        ///
        /// Uses:
        /// - Manual trust evaluation
        /// - TLS 1.2 minimum
        /// - TLS 1.3 maximum
        public static func manualTrustConfig() -> [String: Any] {
            return SSLSettings.Builder()
                .manuallyEvaluateTrust(true)
                .minimumProtocolVersion(.tlsProtocol12)
                .maximumProtocolVersion(.tlsProtocol13)
                .build()
        }
        
        /// Configuration with ALPN support
        ///
        /// Uses:
        /// - TLS 1.2 minimum
        /// - TLS 1.3 maximum
        /// - Specified ALPN protocols
        ///
        /// - Parameter protocols: Array of ALPN protocol names
        public static func alpnConfig(protocols: [String]) -> [String: Any] {
            return SSLSettings.Builder()
                .minimumProtocolVersion(.tlsProtocol12)
                .maximumProtocolVersion(.tlsProtocol13)
                .alpnProtocols(protocols)
                .build()
        }
    }
}

// MARK: - SSL/TLS Usage Examples

extension GCDAsyncSocket {
    
    /// SSL/TLS Configuration Examples and Best Practices
    public struct SSLExamples {
        
        /// Basic HTTPS client configuration example
        ///
        /// Use this configuration when connecting to standard HTTPS servers
        /// ```swift
        /// socket.startTLS { builder in
        ///     builder.peerName("api.example.com")  // Must match server's certificate
        ///           .minimumProtocolVersion(.tlsProtocol12)
        ///           .maximumProtocolVersion(.tlsProtocol13)
        /// }
        /// ```
        public static var httpsClient: [String: Any] {
            return SSLSettings.Builder()
                .isServer(false)
                .minimumProtocolVersion(.tlsProtocol12)
                .maximumProtocolVersion(.tlsProtocol13)
                .build()
        }
        
        /// HTTPS server configuration example
        ///
        /// Use this configuration when implementing an HTTPS server
        /// ```swift
        /// // Load your certificate and private key
        /// let certificate = // ... load certificate
        /// let privateKey = // ... load private key
        ///
        /// socket.startTLS { builder in
        ///     builder.isServer(true)
        ///           .certificates([certificate])
        ///           .minimumProtocolVersion(.tlsProtocol12)
        ///           .alpnProtocols(["http/1.1", "h2"])
        /// }
        /// ```
        public static func httpsServer(withCertificate cert: SecCertificate) -> [String: Any] {
            return SSLSettings.Builder()
                .isServer(true)
                .certificates([cert])
                .minimumProtocolVersion(.tlsProtocol12)
                .maximumProtocolVersion(.tlsProtocol13)
                .alpnProtocols(["http/1.1", "h2"])
                .build()
        }
        
        /// Configuration for pinned certificates
        ///
        /// Use this when you want to restrict connections to specific certificates
        /// ```swift
        /// // Load your pinned certificates
        /// let pinnedCerts = // ... load certificates
        ///
        /// socket.startTLS { builder in
        ///     builder.manuallyEvaluateTrust(true)
        ///           .minimumProtocolVersion(.tlsProtocol12)
        /// }
        ///
        /// // In your delegate:
        /// func socket(_ sock: GCDAsyncSocket, didReceiveTrust trust: SecTrust, 
        ///            completionHandler: @escaping (Bool) -> Void) {
        ///     // Verify the server's certificate chain against your pinned certs
        ///     let result = // ... verify certificates
        ///     completionHandler(result)
        /// }
        /// ```
        public static func certificatePinning(pinnedCertificates: [SecCertificate]) -> [String: Any] {
            return SSLSettings.Builder()
                .manuallyEvaluateTrust(true)
                .minimumProtocolVersion(.tlsProtocol12)
                .maximumProtocolVersion(.tlsProtocol13)
                .build()
        }
        
        /// Configuration for high performance
        ///
        /// Use this configuration when optimizing for performance
        /// Note: These settings might not be supported by all servers
        /// ```swift
        /// socket.startTLS { builder in
        ///     builder.allowFalseStart(true)
        ///           .minimumProtocolVersion(.tlsProtocol13) // TLS 1.3 is faster
        ///           .cipherSuites([
        ///               // Prefer AES-GCM ciphers for better performance
        ///               TLS_AES_128_GCM_SHA256,
        ///               TLS_AES_256_GCM_SHA384
        ///           ])
        /// }
        /// ```
        public static var highPerformance: [String: Any] {
            return SSLSettings.Builder()
                .minimumProtocolVersion(.tlsProtocol13)
                .maximumProtocolVersion(.tlsProtocol13)
                .allowFalseStart(true)
                .build()
        }
        
        /// Configuration for maximum compatibility
        ///
        /// Use this configuration when you need to support older servers
        /// Warning: This configuration is less secure but more compatible
        /// ```swift
        /// socket.startTLS { builder in
        ///     builder.minimumProtocolVersion(.tlsProtocol1)  // Support older protocols
        ///           .maximumProtocolVersion(.tlsProtocol13)
        ///           .sendOneByteRecord(true)  // Help with problematic firewalls
        /// }
        /// ```
        public static var maximumCompatibility: [String: Any] {
            return SSLSettings.Builder()
                .minimumProtocolVersion(.tlsProtocol1)
                .maximumProtocolVersion(.tlsProtocol13)
                .sendOneByteRecord(true)
                .build()
        }
        
        /// Configuration for WebSocket over TLS (WSS)
        ///
        /// Use this configuration for secure WebSocket connections
        /// ```swift
        /// socket.startTLS { builder in
        ///     builder.peerName("ws.example.com")
        ///           .minimumProtocolVersion(.tlsProtocol12)
        ///           .alpnProtocols(["http/1.1"])  // WebSocket uses HTTP/1.1
        /// }
        /// ```
        public static func webSocket(host: String) -> [String: Any] {
            return SSLSettings.Builder()
                .peerName(host)
                .minimumProtocolVersion(.tlsProtocol12)
                .maximumProtocolVersion(.tlsProtocol13)
                .alpnProtocols(["http/1.1"])
                .build()
        }
    }
}

// MARK: - SSL/TLS Security Guidelines

extension GCDAsyncSocket {
    
    /// Security recommendations for SSL/TLS usage
    public struct SSLGuidelines {
        /// Recommended minimum TLS version for secure communications
        public static let minimumSecureProtocol: SSLSettings.ProtocolMin = .tlsProtocol12
        
        /// Recommended TLS version for optimal security
        public static let optimalSecureProtocol: SSLSettings.ProtocolMax = .tlsProtocol13
        
        /// Recommended cipher suites in order of preference
        public static let recommendedCipherSuites: [SSLCipherSuite] = [
            // TLS 1.3 ciphers
            TLS_AES_256_GCM_SHA384,
            TLS_AES_128_GCM_SHA256,
            // TLS 1.2 ciphers
            TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
            TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
        ]
        
        /// Security checklist for SSL/TLS configuration
        public static let securityChecklist = """
        SSL/TLS Security Checklist:
        ✓ Use TLS 1.2 or later (1.3 preferred)
        ✓ Verify server certificates
        ✓ Use strong cipher suites
        ✓ Enable certificate pinning for sensitive applications
        ✓ Keep certificates and trust stores up to date
        ✓ Handle certificate errors appropriately
        ✓ Test with various TLS versions and cipher suites
        """
    }
}

// MARK: - SSL/TLS Quick Start Guide

extension GCDAsyncSocket {
    
    /// Quick start guide for common SSL/TLS scenarios
    public struct SSLQuickStart {
        
        /// Quick configuration guide based on usage scenario
        public enum Scenario {
            /// Standard HTTPS client (e.g. REST API client)
            case httpsClient(host: String)
            /// HTTPS server
            case httpsServer(certificate: SecCertificate)
            /// Mobile banking/payment app
            case secureBanking
            /// Chat/messaging app
            case messaging
            /// Legacy system integration
            case legacySystem
            /// IoT device
            case iotDevice(deviceId: String)
            /// Internal enterprise system
            case enterprise(customCerts: [SecCertificate])
            
            /// Get recommended configuration for the scenario
            public var recommendedConfig: [String: Any] {
                let builder = SSLSettings.Builder()
                
                switch self {
                case .httpsClient(let host):
                    return builder
                        .peerName(host)
                        .minimumProtocolVersion(.tlsProtocol12)
                        .maximumProtocolVersion(.tlsProtocol13)
                        .build()
                    
                case .httpsServer(let cert):
                    return builder
                        .isServer(true)
                        .certificates([cert])
                        .minimumProtocolVersion(.tlsProtocol12)
                        .maximumProtocolVersion(.tlsProtocol13)
                        .alpnProtocols(["http/1.1", "h2"])
                        .build()
                    
                case .secureBanking:
                    // 高安全性配置，适用于金融场景
                    return builder
                        .manuallyEvaluateTrust(true)  // 强制证书验证
                        .minimumProtocolVersion(.tlsProtocol12)
                        .maximumProtocolVersion(.tlsProtocol13)
                        .cipherSuites(SSLGuidelines.recommendedCipherSuites)
                        .sendOneByteRecord(false)  // 优先安全性
                        .build()
                    
                case .messaging:
                    // 平衡性能和安全性的配置
                    return builder
                        .minimumProtocolVersion(.tlsProtocol12)
                        .maximumProtocolVersion(.tlsProtocol13)
                        .allowFalseStart(true)  // 提升性能
                        .build()
                    
                case .legacySystem:
                    // 兼容性配置
                    return builder
                        .minimumProtocolVersion(.tlsProtocol1)  // 持旧协议
                        .maximumProtocolVersion(.tlsProtocol13)
                        .sendOneByteRecord(true)  // 提高兼容性
                        .build()
                    
                case .iotDevice(let deviceId):
                    // IoT设备配置
                    return builder
                        .minimumProtocolVersion(.tlsProtocol12)
                        .maximumProtocolVersion(.tlsProtocol13)
                        .peerID(deviceId.data(using: .utf8)!)  // 用于会话恢复
                        .build()
                    
                case .enterprise(let customCerts):
                    // 企业内部系统配置
                    return builder
                        .certificates(customCerts)
                        .minimumProtocolVersion(.tlsProtocol12)
                        .maximumProtocolVersion(.tlsProtocol13)
                        .build()
                }
            }
            
            /// Usage notes and recommendations for the scenario
            public var notes: String {
                switch self {
                case .httpsClient:
                    return """
                    HTTPS Client Notes:
                    • 验证服务器证书是否匹配主机名
                    • 使用系统信任存储
                    • 考虑实现证书透明度(CT)检查
                    """
                    
                case .httpsServer:
                    return """
                    HTTPS Server Notes:
                    • 确保证书链完整
                    • 配置合适的密码套件
                    • 启用 ALPN 以支持 HTTP/2
                    • 定期更新证书
                    """
                    
                case .secureBanking:
                    return """
                    Secure Banking Notes:
                    • 强制证书验证
                    • 使用证书固定
                    • 只使用强密码套件
                    • 记录所有TLS相关错误
                    • 实现证书透明度(CT)检查
                    """
                    
                case .messaging:
                    return """
                    Messaging Notes:
                    • 平衡性能和安全性
                    • 考虑使用会话恢复
                    • 可以启用 False Start
                    • 监控连接质量
                    """
                    
                case .legacySystem:
                    return """
                    Legacy System Notes:
                    ⚠️ 警告此配置降低了安全性以提高兼容性
                    • 记录使用旧协议的连接
                    • 计划升级策略
                    • 考虑使用反向代理
                    """
                    
                case .iotDevice:
                    return """
                    IoT Device Notes:
                    • 使用唯一设备标识符
                    • 启用会话恢复以节省资源
                    • 考虑证书轮换策略
                    • 监控资源使用
                    """
                    
                case .enterprise:
                    return """
                    Enterprise Notes:
                    • 维护内部CA和证书
                    • 实现证书更新机制
                    • 考虑使用 OCSP
                    • 监控证书有效期
                    """
                }
            }
        }
        
        /// Quick start example for a given scenario
        public static func example(for scenario: Scenario) -> String {
            switch scenario {
            case .httpsClient(let host):
                return """
                // HTTPS 客户端示例
                socket.startTLS { builder in
                    builder.peerName("\(host)")
                           .minimumProtocolVersion(.tlsProtocol12)
                }
                
                // 实现代理方法
                func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
                    print("Connected to \\(host):\\(port)")
                }
                """
                
            case .secureBanking:
                return """
                // 安全金融应用示例
                let config = SSLQuickStart.Scenario.secureBanking.recommendedConfig
                socket.startTLS(config)
                
                // 实现证书验证
                func socket(_ sock: GCDAsyncSocket, didReceiveTrust trust: SecTrust,
                          completionHandler: @escaping (Bool) -> Void) {
                    // 执行额外的证书验证
                    let result = validateCertificateChain(trust)
                    completionHandler(result)
                }
                """
                
            // 其他场景的示例代码...
            default:
                return "// 查看具体场景的 recommendedConfig 和 notes"
            }
        }
    }
}

