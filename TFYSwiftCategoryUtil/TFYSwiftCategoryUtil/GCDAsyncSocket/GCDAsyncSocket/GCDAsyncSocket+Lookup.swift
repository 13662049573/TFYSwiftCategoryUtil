import Foundation
import Darwin

// MARK: - DNS Lookup & Connection

extension GCDAsyncSocket {
    
    /// Handle successful DNS lookup result
    internal func lookup(stateIndex: Int, didSucceedWithAddress4 address4: Data?, address6: Data?) {
        // 确保状态索引匹配
        guard stateMatches(stateIndex) else { return }
        
        // 检查是否已经开始连接
        guard flags.contains(.started) else { return }
        
        // 检查是否已经连接
        guard !flags.contains(.connected) else { return }
        
        // 检查是否有可用地址
        guard address4 != nil || address6 != nil else {
            closeWithError(badConfigError("No valid addresses found"))
            return
        }
        
        // 根据配置和可用地址选择连接策略
        let isIPv4Disabled = config.contains(.IPv4Disabled)
        let isIPv6Disabled = config.contains(.IPv6Disabled)
        let preferIPv6 = config.contains(.preferIPv6)
        
        let shouldTryIPv4 = !isIPv4Disabled && address4 != nil
        let shouldTryIPv6 = !isIPv6Disabled && address6 != nil
        
        if shouldTryIPv4 && shouldTryIPv6 {
            if preferIPv6 {
                // 先尝试 IPv6
                connectSocket(withAddress: address6!, socket: &socket6FD)
                
                // 如果设置了延迟时间，等待一段时间后再尝试 IPv4
                if alternateAddressDelay > 0 {
                    let delayTime = DispatchTime.now() + alternateAddressDelay
                    socketQueue.asyncAfter(deadline: delayTime) { [weak self] in
                        guard let self = self else { return }
                        if !self.flags.contains(.connected) {
                            self.connectSocket(withAddress: address4!, socket: &self.socket4FD)
                        }
                    }
                } else {
                    // 立即尝试 IPv4
                    connectSocket(withAddress: address4!, socket: &socket4FD)
                }
            } else {
                // 先尝试 IPv4
                connectSocket(withAddress: address4!, socket: &socket4FD)
                
                // 如果设置了延迟时间，等待一段时间后再尝试 IPv6
                if alternateAddressDelay > 0 {
                    let delayTime = DispatchTime.now() + alternateAddressDelay
                    socketQueue.asyncAfter(deadline: delayTime) { [weak self] in
                        guard let self = self else { return }
                        if !self.flags.contains(.connected) {
                            self.connectSocket(withAddress: address6!, socket: &self.socket6FD)
                        }
                    }
                } else {
                    // 立即尝试 IPv6
                    connectSocket(withAddress: address6!, socket: &socket6FD)
                }
            }
        } else if shouldTryIPv6 {
            // 只尝试 IPv6
            connectSocket(withAddress: address6!, socket: &socket6FD)
        } else if shouldTryIPv4 {
            // 只尝试 IPv4
            connectSocket(withAddress: address4!, socket: &socket4FD)
        } else {
            closeWithError(badConfigError("No available protocols"))
        }
    }
    
    /// Handle DNS lookup failure
    internal func lookup(stateIndex: Int, didFail error: Error) {
        // 确保状态索引匹配
        guard stateMatches(stateIndex) else { return }
        
        closeWithError(error)
    }
    
    /// Connect socket with given address
    private func connectSocket(withAddress address: Data, socket: inout Int32) {
        // 创建socket
        let domain = address.withUnsafeBytes { ptr -> Int32 in
            let addr = ptr.baseAddress!.assumingMemoryBound(to: sockaddr.self)
            return Int32(addr.pointee.sa_family)
        }
        
        socket = Darwin.socket(domain, SOCK_STREAM, 0)
        guard socket != -1 else {
            closeWithError(socketError(withErrno: errno, reason: "Error in socket() function"))
            return
        }
        
        // 设置非阻塞模式
        var flags = Darwin.fcntl(socket, F_GETFL, 0)
        guard flags != -1 else {
            closeWithError(socketError(withErrno: errno, reason: "Error in fcntl(F_GETFL) function"))
            return
        }
        
        flags = Darwin.fcntl(socket, F_SETFL, flags | O_NONBLOCK)
        guard flags != -1 else {
            closeWithError(socketError(withErrno: errno, reason: "Error in fcntl(F_SETFL) function"))
            return
        }
        
        // 如果指定了接口，绑定到该接口
        if let interface = connectInterface4, domain == AF_INET {
            let result = interface.withUnsafeBytes { ptr in
                Darwin.bind(socket, ptr.baseAddress!.assumingMemoryBound(to: sockaddr.self), socklen_t(interface.count))
            }
            guard result == 0 else {
                closeWithError(socketError(withErrno: errno, reason: "Error in bind() function"))
                return
            }
        } else if let interface = connectInterface6, domain == AF_INET6 {
            let result = interface.withUnsafeBytes { ptr in
                Darwin.bind(socket, ptr.baseAddress!.assumingMemoryBound(to: sockaddr.self), socklen_t(interface.count))
            }
            guard result == 0 else {
                closeWithError(socketError(withErrno: errno, reason: "Error in bind() function"))
                return
            }
        }
        
        // 开始连接
        let result = address.withUnsafeBytes { ptr in
            Darwin.connect(socket, ptr.baseAddress!.assumingMemoryBound(to: sockaddr.self), socklen_t(address.count))
        }
        
        if result == 0 {
            // 连接立即成功
            didConnect(socket)
        } else if errno == EINPROGRESS {
            // 连接正在进行中
            self.flags.insert(.connecting)
            
            // Store the socket file descriptor in a local variable
            let socketFD = socket
            
            // 添加写事件监听，等待连接完成
            let source = DispatchSource.makeWriteSource(fileDescriptor: socketFD, queue: socketQueue)
            source.setEventHandler { [weak self] in
                self?.didConnect(socketFD)
            }
            source.resume()
        } else {
            closeWithError(socketError(withErrno: errno, reason: "Error in connect() function"))
        }
    }
    
    /// Called when socket successfully connects
    private func didConnect(_ socket: Int32) {
        flags.remove(.connecting)
        flags.insert(.connected)
        
        // 通知代理
        if let delegate = delegate {
            var host: String?
            var port: UInt16 = 0
            
            if socket == socket4FD {
                host = connectedHost(fromSocket4: socket)
                port = connectedPort(fromSocket4: socket)
            } else if socket == socket6FD {
                host = connectedHost(fromSocket6: socket)
                port = connectedPort(fromSocket6: socket)
            }
            
            if let host = host {
                delegateQueue?.async { [weak self] in
                    guard let self = self else { return }
                    delegate.socket(self, didConnectToHost: host, port: port)
                }
            }
        }
    }
} 
