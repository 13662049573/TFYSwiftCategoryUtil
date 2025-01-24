import Foundation
import Security
import Darwin

// MARK: - Type Aliases

typealias OSStatus = Int32
typealias SSLReadFunc = @convention(c) (UnsafeRawPointer, UnsafeMutableRawPointer, UnsafeMutablePointer<Int>) -> OSStatus
typealias SSLWriteFunc = @convention(c) (UnsafeRawPointer, UnsafeRawPointer, UnsafeMutablePointer<Int>) -> OSStatus

// MARK: - Network Security Types

extension GCDAsyncSocket {
    
    /// Security Context type that abstracts different implementations
    class SecurityContext {
        private let isServer: Bool
        private let settings: [String: Any]
        private var legacyContext: LegacySecurityContext?
        private var modernContext: ModernSecurityContext?
        
        init(isServer: Bool, settings: [String: Any]) {
            self.isServer = isServer
            self.settings = settings
            setupContext()
        }
        
        private func setupContext() {
            if #available(iOS 13.0, macOS 10.15, *) {
                modernContext = ModernSecurityContext(isServer: isServer, settings: settings)
            } else {
                legacyContext = LegacySecurityContext(isServer: isServer, settings: settings)
            }
        }
        
        func setIOCallbacks(_ read: @escaping SSLReadFunc, _ write: @escaping SSLWriteFunc) {
            legacyContext?.setIOCallbacks(read, write)
        }
        
        func setConnection(_ connection: UnsafeMutableRawPointer) {
            legacyContext?.setConnection(connection)
        }
        
        func handshake() -> OSStatus {
            return legacyContext?.handshake() ?? errSecParam
        }
        
        var sslContext: SSLContext? {
            return legacyContext?.sslContext
        }
    }
    
    /// Legacy Security Context using SecureTransport
    private class LegacySecurityContext {
        fileprivate var sslContext: SSLContext?
        private let isServer: Bool
        private let settings: [String: Any]
        
        init(isServer: Bool, settings: [String: Any]) {
            self.isServer = isServer
            self.settings = settings
            setupContext()
        }
        
        private func setupContext() {
            let protocolSide = isServer ? SSLProtocolSide(rawValue: 2)! : SSLProtocolSide(rawValue: 1)!
            sslContext = SSLCreateContext(kCFAllocatorDefault, protocolSide, .streamType)
            configureContext()
        }
        
        private func configureContext() {
            guard let ctx = sslContext else { return }
            
            // Configure certificates
            if let certificates = settings[GCDAsyncSocket.kCFStreamSSLCertificates] as? [Any] {
                _ = SSLSetCertificate(ctx, certificates as CFArray)
            }
            
            // Configure peer name
            if !isServer, let peerName = settings[GCDAsyncSocket.kCFStreamSSLPeerName] as? String {
                _ = SSLSetPeerDomainName(ctx, peerName, peerName.lengthOfBytes(using: .utf8))
            }
            
            // Configure protocol versions
            if let minProtocol = settings[GCDAsyncSocket.SSLProtocolVersionMin] as? Int {
                _ = SSLSetProtocolVersionMin(ctx, SSLProtocol(rawValue: Int32(minProtocol))!)
            }
            
            if let maxProtocol = settings[GCDAsyncSocket.SSLProtocolVersionMax] as? Int {
                _ = SSLSetProtocolVersionMax(ctx, SSLProtocol(rawValue: Int32(maxProtocol))!)
            }
            
            // Configure trust validation
            if !isServer, let shouldValidate = settings[GCDAsyncSocket.SSLManuallyEvaluateTrust] as? Bool,
               shouldValidate {
                _ = SSLSetSessionOption(ctx, SSLSessionOption(rawValue: 2)!, true)
            }
        }
        
        func setIOCallbacks(_ read: @escaping SSLReadFunc, _ write: @escaping SSLWriteFunc) {
            guard let ctx = sslContext else { return }
            _ = SSLSetIOFuncs(ctx, read, write)
        }
        
        func setConnection(_ connection: UnsafeMutableRawPointer) {
            guard let ctx = sslContext else { return }
            _ = SSLSetConnection(ctx, connection)
        }
        
        func handshake() -> OSStatus {
            guard let ctx = sslContext else { return errSecParam }
            return SSLHandshake(ctx)
        }
        
        deinit {
            if let ctx = sslContext {
                let unmanagedContext = Unmanaged.passUnretained(ctx as AnyObject)
                unmanagedContext.release()
            }
        }
    }
    
    /// Modern Security Context using Network.framework
    @available(iOS 13.0, macOS 10.15, *)
    private class ModernSecurityContext {
        private let isServer: Bool
        private let settings: [String: Any]
        
        init(isServer: Bool, settings: [String: Any]) {
            self.isServer = isServer
            self.settings = settings
            // TODO: Implement Network.framework based security
        }
    }
} 