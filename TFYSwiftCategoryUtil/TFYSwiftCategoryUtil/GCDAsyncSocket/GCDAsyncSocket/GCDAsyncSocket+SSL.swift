import Foundation
import Security
import Darwin
import CoreFoundation

extension GCDAsyncSocket {
    
    private static let SSLReadFunction: SSLReadFunc = { context, data, dataLength in
        let sock = Unmanaged<GCDAsyncSocket>.fromOpaque(context).takeUnretainedValue()
        // 实现读取逻辑
        return noErr
    }
    
    private static let SSLWriteFunction: SSLWriteFunc = { context, data, dataLength in
        let sock = Unmanaged<GCDAsyncSocket>.fromOpaque(context).takeUnretainedValue()
        // 实现写入逻辑
        return noErr
    }
    
    private func ssl_startTLS() {
        LogVerbose("Starting TLS (via SecureTransport)...")
        
        let isServer = tlsSettings[GCDAsyncSocket.kCFStreamSSLIsServer] as? Bool ?? false
        let securityContext = SecurityContext(isServer: isServer, settings: tlsSettings)
        
        // 设置 IO 回调
        securityContext.setIOCallbacks(GCDAsyncSocket.SSLReadFunction, GCDAsyncSocket.SSLWriteFunction)
        securityContext.setConnection(Unmanaged.passUnretained(self).toOpaque())
        
        // 开始握手
        let result = securityContext.handshake()
        guard result == noErr else {
            closeWithError(sslError(result))
            return
        }
        
        // 配置手动信任评估
        if let shouldManuallyEvaluate = tlsSettings[GCDAsyncSocket.SSLManuallyEvaluateTrust] as? Bool,
           shouldManuallyEvaluate {
            
            guard !isServer else {
                closeWithError(otherError("Manual trust evaluation is not supported for server sockets"))
                return
            }
        }
        
        // 开始 SSL 握手
        ssl_continueSSLHandshake()
    }
    
    private func ssl_continueSSLHandshake() {
        guard let securityContext = securityContext else {
            closeWithError(otherError("Security context not found"))
            return
        }
        
        let result = securityContext.handshake()
        
        switch result {
        case noErr:
            // 握手完成
            flags.remove(.startingReadTLS)
            flags.remove(.startingWriteTLS)
            flags.insert(.socketSecure)
            
            // 通知代理
            if let delegate = delegate,
               delegate.responds(to: #selector(GCDAsyncSocketDelegate.socketDidSecure(_:))) {
                delegateQueue?.async { [weak self] in
                    guard let self = self else { return }
                    delegate.socketDidSecure?(self)
                }
            }
            
            // 继续读写操作
            endCurrentRead()
            endCurrentWrite()
            
            maybeDequeueRead()
            maybeDequeueWrite()
            
        case errSSLWouldBlock:
            // 握手需要继续
            // 等待更多数据或可以发送更多数据
            break
            
        case errSSLPeerAuthCompleted:
            // 服务器证书链有效，但需要客户端信任评估
            guard let ctx = securityContext.sslContext else { return }
            
            var secTrust: SecTrust?
            let copyResult = SSLCopyPeerTrust(ctx, &secTrust)
            guard copyResult == noErr else {
                closeWithError(sslError(copyResult))
                return
            }
            
            guard let trust = secTrust else { return }
            
            let stateIndex = self.stateIndex
            
            // 询问代理评估信任
            if let delegate = delegate,
               delegate.responds(to: #selector(GCDAsyncSocketDelegate.socket(_:didReceiveTrust:completionHandler:))) {
                delegateQueue?.async { [weak self] in
                    guard let self = self else { return }
                    delegate.socket?(self, didReceiveTrust: trust) { [weak self] shouldTrust in
                        guard let self = self else { return }
                        self.socketQueue.async {
                            self.ssl_shouldTrustPeer(shouldTrust, stateIndex: stateIndex)
                        }
                    }
                }
            } else {
                // 如果代理没有实现信任评估方法，默认信任
                ssl_shouldTrustPeer(true, stateIndex: stateIndex)
            }
            
        default:
            closeWithError(sslError(result))
        }
    }
        
    private func ssl_shouldTrustPeer(_ shouldTrust: Bool, stateIndex: Int) {
        guard stateIndex == self.stateIndex else { return }
        
        // 增加状态索引以确保完成处理程序只被调用一次
        self.stateIndex += 1
        
        if shouldTrust {
            ssl_continueSSLHandshake()
        } else {
            closeWithError(sslError(errSSLPeerBadCert))
        }
    }
    
}
