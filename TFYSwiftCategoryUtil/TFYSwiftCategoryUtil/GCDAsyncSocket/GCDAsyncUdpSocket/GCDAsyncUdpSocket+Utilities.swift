import Foundation

// MARK: - Address Utilities
extension GCDAsyncUdpSocket {
    
    public class func host(fromAddress address: Data) -> String? {
        var host: String?
        _ = getHost(&host, port: nil, family: nil, fromAddress: address)
        return host
    }
    
    public class func port(fromAddress address: Data) -> UInt16 {
        var port: UInt16 = 0
        _ = getHost(nil, port: &port, family: nil, fromAddress: address)
        return port
    }
    
    public class func family(fromAddress address: Data) -> Int32 {
        var af: Int32 = AF_UNSPEC
        _ = getHost(nil, port: nil, family: &af, fromAddress: address)
        return af
    }
    
    public class func isIPv4Address(_ address: Data) -> Bool {
        return family(fromAddress: address) == AF_INET
    }
    
    public class func isIPv6Address(_ address: Data) -> Bool {
        return family(fromAddress: address) == AF_INET6
    }
    
    public class func getHost(_ hostPtr: UnsafeMutablePointer<String?>?,
                            port portPtr: UnsafeMutablePointer<UInt16>?,
                            family afPtr: UnsafeMutablePointer<Int32>?,
                            fromAddress address: Data) -> Bool {
        
        guard address.count >= MemoryLayout<sockaddr>.size else {
            return false
        }
        
        return address.withUnsafeBytes { rawBuffer in
            let addrX = rawBuffer.bindMemory(to: sockaddr.self)[0]
            
            if addrX.sa_family == AF_INET {
                guard address.count >= MemoryLayout<sockaddr_in>.size else {
                    return false
                }
                
                let addr4 = rawBuffer.bindMemory(to: sockaddr_in.self)[0]
                
                if let hostPtr = hostPtr {
                    hostPtr.pointee = host(fromSockaddr4: addr4)
                }
                if let portPtr = portPtr {
                    portPtr.pointee = port(fromSockaddr4: addr4)
                }
                if let afPtr = afPtr {
                    afPtr.pointee = AF_INET
                }
                return true
                
            } else if addrX.sa_family == AF_INET6 {
                guard address.count >= MemoryLayout<sockaddr_in6>.size else {
                    return false
                }
                
                let addr6 = rawBuffer.bindMemory(to: sockaddr_in6.self)[0]
                
                if let hostPtr = hostPtr {
                    hostPtr.pointee = host(fromSockaddr6: addr6)
                }
                if let portPtr = portPtr {
                    portPtr.pointee = port(fromSockaddr6: addr6)
                }
                if let afPtr = afPtr {
                    afPtr.pointee = AF_INET6
                }
                return true
            }
            
            return false
        }
    }
    
    private class func host(fromSockaddr4 sockaddr4: sockaddr_in) -> String? {
        var addr = sockaddr4.sin_addr
        var buffer = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
        
        guard let str = inet_ntop(AF_INET, &addr, &buffer, socklen_t(INET_ADDRSTRLEN)) else {
            return nil
        }
        
        return String(cString: str)
    }
    
    private class func host(fromSockaddr6 sockaddr6: sockaddr_in6) -> String? {
        var addr = sockaddr6.sin6_addr
        var buffer = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
        
        guard let str = inet_ntop(AF_INET6, &addr, &buffer, socklen_t(INET6_ADDRSTRLEN)) else {
            return nil
        }
        
        return String(cString: str)
    }
    
    private class func port(fromSockaddr4 sockaddr4: sockaddr_in) -> UInt16 {
        return UInt16(bigEndian: sockaddr4.sin_port)
    }
    
    private class func port(fromSockaddr6 sockaddr6: sockaddr_in6) -> UInt16 {
        return UInt16(bigEndian: sockaddr6.sin6_port)
    }
}

// MARK: - Error Utilities
extension GCDAsyncUdpSocket {
    
    internal func badConfigError(_ msg: String) -> NSError {
        return NSError(domain: GCDAsyncUdpSocketErrorDomain,
                      code: GCDAsyncUdpSocketError.badConfigError.rawValue,
                      userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    internal func badParamError(_ msg: String) -> NSError {
        return NSError(domain: GCDAsyncUdpSocketErrorDomain,
                      code: GCDAsyncUdpSocketError.badParamError.rawValue,
                      userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    internal func gaiError(_ error: Int32) -> NSError {
        let msg = String(cString: gai_strerror(error))
        return NSError(domain: "kCFStreamErrorDomainNetDB",
                      code: Int(error),
                      userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    internal func errnoError(_ reason: String? = nil) -> NSError {
        let msg = String(cString: strerror(errno))
        var userInfo: [String: Any] = [NSLocalizedDescriptionKey: msg]
        
        if let reason = reason {
            userInfo[NSLocalizedFailureReasonErrorKey] = reason
        }
        
        return NSError(domain: NSPOSIXErrorDomain,
                      code: Int(errno),
                      userInfo: userInfo)
    }
    
    internal func sendTimeoutError() -> NSError {
        let msg = "Send operation timed out"
        return NSError(domain: GCDAsyncUdpSocketErrorDomain,
                      code: GCDAsyncUdpSocketError.sendTimeoutError.rawValue,
                      userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    internal func socketClosedError() -> NSError {
        let msg = "Socket closed"
        return NSError(domain: GCDAsyncUdpSocketErrorDomain,
                      code: GCDAsyncUdpSocketError.closedError.rawValue,
                      userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    internal func otherError(_ msg: String) -> NSError {
        return NSError(domain: GCDAsyncUdpSocketErrorDomain,
                      code: GCDAsyncUdpSocketError.otherError.rawValue,
                      userInfo: [NSLocalizedDescriptionKey: msg])
    }
}

// MARK: - Interface Utilities
extension GCDAsyncUdpSocket {
    
    internal func convertInterfaceDescription(_ interface: String?,
                                        port: UInt16,
                                        intoAddress4 addr4Ptr: UnsafeMutablePointer<Data?>?,
                                        address6 addr6Ptr: UnsafeMutablePointer<Data?>?) {
    if interface == nil {
        // ANY address
        var sockaddr4 = sockaddr_in()
        sockaddr4.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        sockaddr4.sin_family = sa_family_t(AF_INET)
        sockaddr4.sin_port = UInt16(bigEndian: port)
        sockaddr4.sin_addr.s_addr = INADDR_ANY
        
        var sockaddr6 = sockaddr_in6()
        sockaddr6.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
        sockaddr6.sin6_family = sa_family_t(AF_INET6)
        sockaddr6.sin6_port = UInt16(bigEndian: port)
        sockaddr6.sin6_addr = in6addr_any
        
        addr4Ptr?.pointee = Data(bytes: &sockaddr4, count: MemoryLayout<sockaddr_in>.size)
        addr6Ptr?.pointee = Data(bytes: &sockaddr6, count: MemoryLayout<sockaddr_in6>.size)
        
    } else if interface == "localhost" || interface == "loopback" {
        // LOOPBACK address
        var sockaddr4 = sockaddr_in()
        sockaddr4.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        sockaddr4.sin_family = sa_family_t(AF_INET)
        sockaddr4.sin_port = UInt16(bigEndian: port)
        sockaddr4.sin_addr.s_addr = INADDR_LOOPBACK
        
        var sockaddr6 = sockaddr_in6()
        sockaddr6.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
        sockaddr6.sin6_family = sa_family_t(AF_INET6)
        sockaddr6.sin6_port = UInt16(bigEndian: port)
        sockaddr6.sin6_addr = in6addr_loopback
        
        addr4Ptr?.pointee = Data(bytes: &sockaddr4, count: MemoryLayout<sockaddr_in>.size)
        addr6Ptr?.pointee = Data(bytes: &sockaddr6, count: MemoryLayout<sockaddr_in6>.size)
        
    } else {
        // Look up interface by name or address
        var addrs: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&addrs) == 0 else {
            return
        }
        defer { freeifaddrs(addrs) }
        
        var cursor = addrs
        while cursor != nil {
            let addr = cursor!.pointee
            
            if addr4Ptr?.pointee == nil && addr.ifa_addr.pointee.sa_family == AF_INET {
                // IPv4
                let interfaceName = String(cString: addr.ifa_name)
                
                if interfaceName == interface {
                    // Name match
                    var nativeAddr4 = sockaddr_in()
                    withUnsafePointer(to: addr.ifa_addr.pointee) { ptr in
                        ptr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { sockaddrPtr in
                            nativeAddr4 = sockaddrPtr.pointee
                        }
                    }
                    nativeAddr4.sin_port = UInt16(bigEndian: port)
                    
                    addr4Ptr?.pointee = Data(bytes: &nativeAddr4, count: MemoryLayout<sockaddr_in>.size)
                } else {
                    // Try IP match
                    var ip = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
                    var addr4 = sockaddr_in()
                    withUnsafePointer(to: &addr.ifa_addr.pointee) { ptr in
                        ptr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { sockaddrPtr in
                            addr4 = sockaddrPtr.pointee
                        }
                    }
                    
                    if inet_ntop(AF_INET, &addr4.sin_addr, &ip, socklen_t(INET_ADDRSTRLEN)) != nil {
                        let ipStr = String(cString: ip)
                        if ipStr == interface {
                            var nativeAddr4 = addr4
                            nativeAddr4.sin_port = UInt16(bigEndian: port)
                            
                            addr4Ptr?.pointee = Data(bytes: &nativeAddr4, count: MemoryLayout<sockaddr_in>.size)
                        }
                    }
                }
                
            } else if addr6Ptr?.pointee == nil && addr.ifa_addr.pointee.sa_family == AF_INET6 {
                // IPv6
                let interfaceName = String(cString: addr.ifa_name)
                
                if interfaceName == interface {
                    // Name match
                    var nativeAddr6 = sockaddr_in6()
                    withUnsafePointer(to: addr.ifa_addr.pointee) { ptr in
                        ptr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { sockaddrPtr in
                            nativeAddr6 = sockaddrPtr.pointee
                        }
                    }
                    nativeAddr6.sin6_port = UInt16(bigEndian: port)
                    
                    addr6Ptr?.pointee = Data(bytes: &nativeAddr6, count: MemoryLayout<sockaddr_in6>.size)
                } else {
                    // Try IP match
                    var ip = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
                    var addr6 = sockaddr_in6()
                    withUnsafePointer(to: &addr.ifa_addr.pointee) { ptr in
                        ptr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { sockaddrPtr in
                            addr6 = sockaddrPtr.pointee
                        }
                    }
                    
                    if inet_ntop(AF_INET6, &addr6.sin6_addr, &ip, socklen_t(INET6_ADDRSTRLEN)) != nil {
                        let ipStr = String(cString: ip)
                        if ipStr == interface {
                            var nativeAddr6 = addr6
                            nativeAddr6.sin6_port = UInt16(bigEndian: port)
                            
                            addr6Ptr?.pointee = Data(bytes: &nativeAddr6, count: MemoryLayout<sockaddr_in6>.size)
                        }
                    }
                }
            }
            
            cursor = cursor!.pointee.ifa_next
        }
    }
  }
    
    internal func indexOfInterfaceAddr6(_ interfaceAddr6: Data) -> UInt32 {
        guard interfaceAddr6.count >= MemoryLayout<sockaddr_in6>.size else {
            return 0
        }
        
        var result: UInt32 = 0
        
        interfaceAddr6.withUnsafeBytes { rawBuffer in
            var addr6 = rawBuffer.bindMemory(to: sockaddr_in6.self)[0] // 创建可变副本
            
            var addrs: UnsafeMutablePointer<ifaddrs>?
            guard getifaddrs(&addrs) == 0 else {
                return
            }
            defer { freeifaddrs(addrs) }
            
            var cursor = addrs
            while cursor != nil {
                let addr = cursor!.pointee
                
                if addr.ifa_addr.pointee.sa_family == AF_INET6 {
                    var ifaceAddr = sockaddr_in6()
                    withUnsafePointer(to: &addr.ifa_addr.pointee) { ptr in
                        ptr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { sockaddrPtr in
                            ifaceAddr = sockaddrPtr.pointee
                        }
                    }
                    
                    if memcmp(&addr6.sin6_addr, &ifaceAddr.sin6_addr, MemoryLayout<in6_addr>.size) == 0 {
                        result = if_nametoindex(addr.ifa_name)
                        break
                    }
                }
                
                cursor = cursor!.pointee.ifa_next
            }
        }
        
        return result
    }
    
    internal func convertNumericHost(_ host: String, 
                                  port: UInt16,
                                   intoAddress4 addr4Ptr: UnsafeMutablePointer<Data?>?,
                                   address6 addr6Ptr: UnsafeMutablePointer<Data?>?) {
        // 创建 hints 结构体，指定查找条件
        var hints = addrinfo(
            ai_flags: AI_NUMERICHOST,     // 只接受数字形式的地址
            ai_family: AF_UNSPEC,         // 不指定地址族，同时支持 IPv4 和 IPv6
            ai_socktype: SOCK_DGRAM,      // UDP socket
            ai_protocol: IPPROTO_UDP,     // UDP 协议
            ai_addrlen: 0,
            ai_canonname: nil,
            ai_addr: nil,
            ai_next: nil
        )
        
        // 将端口号转换为字符串
        let portString = String(port)
        
        // 调用 getaddrinfo 进行地址解析
        var res: UnsafeMutablePointer<addrinfo>?
        let status = getaddrinfo(host, portString, &hints, &res)
        
        // 确保在函��返回时释放资源
        defer {
            if let res = res {
                freeaddrinfo(res)
            }
        }
        
        // 如果解析成功
        if status == 0 {
            var cursor = res
            while let info = cursor?.pointee {
                if info.ai_family == AF_INET && addr4Ptr != nil {
                    // IPv4 地址
                    let size = Int(info.ai_addrlen)
                    addr4Ptr?.pointee = Data(bytes: info.ai_addr, count: size)
                    
                } else if info.ai_family == AF_INET6 && addr6Ptr != nil {
                    // IPv6 地址
                    let size = Int(info.ai_addrlen)
                    addr6Ptr?.pointee = Data(bytes: info.ai_addr, count: size)
                }
                
                cursor = info.ai_next
            }
        }
    }
    
    internal func closeSocket4() {
        if socket4FD != SOCKET_NULL {
            Darwin.close(socket4FD)
            socket4FD = SOCKET_NULL
        }
        
        // 清理发送源
        if let source = send4Source {
            source.cancel()
            send4Source = nil
        }
        
        // 清理接收源
        if let source = receive4Source {
            source.cancel()
            receive4Source = nil
        }
    }
    
    internal func closeSocket6() {
        if socket6FD != SOCKET_NULL {
            Darwin.close(socket6FD)
            socket6FD = SOCKET_NULL
        }
        
        // 清理发送源
        if let source = send6Source {
            source.cancel()
            send6Source = nil
        }
        
        // 清理接收源
        if let source = receive6Source {
            source.cancel()
            receive6Source = nil
        }
    }
}

// MARK: - Connection Utilities
extension GCDAsyncUdpSocket {
    // MARK: - Connection Utilities
    
    internal func isConnectedToAddress4(_ address4: Data) -> Bool {
        guard let connectedAddress = cachedConnectedAddress,
              cachedConnectedFamily == AF_INET,
              address4.count >= MemoryLayout<sockaddr_in>.size,
              connectedAddress.count >= MemoryLayout<sockaddr_in>.size else {
            return false
        }
        
        return address4.withUnsafeBytes { addr4Buffer in
            connectedAddress.withUnsafeBytes { connBuffer in
                let addr4 = addr4Buffer.bindMemory(to: sockaddr_in.self)[0]
                let conn = connBuffer.bindMemory(to: sockaddr_in.self)[0]
                
                return (addr4.sin_addr.s_addr == conn.sin_addr.s_addr) &&
                       (addr4.sin_port == conn.sin_port)
            }
        }
    }
    
    internal func isConnectedToAddress6(_ address6: Data) -> Bool {
        guard let connectedAddress = cachedConnectedAddress,
              cachedConnectedFamily == AF_INET6,
              address6.count >= MemoryLayout<sockaddr_in6>.size,
              connectedAddress.count >= MemoryLayout<sockaddr_in6>.size else {
            return false
        }
        
        return address6.withUnsafeBytes { addr6Buffer in
            connectedAddress.withUnsafeBytes { connBuffer in
                var addr6 = addr6Buffer.bindMemory(to: sockaddr_in6.self)[0]
                var conn = connBuffer.bindMemory(to: sockaddr_in6.self)[0]
                
                return memcmp(&addr6.sin6_addr, &conn.sin6_addr, MemoryLayout<in6_addr>.size) == 0 &&
                       addr6.sin6_port == conn.sin6_port &&
                       addr6.sin6_scope_id == conn.sin6_scope_id
            }
        }
    }
    
    internal func notifyDidReceiveData(_ data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        guard let delegate = delegate, let delegateQueue = delegateQueue else {
            return
        }
        
        delegateQueue.async {
            delegate.udpSocket?(self, didReceiveData: data, fromAddress: address, withFilterContext: filterContext)
        }
    }
}

// MARK: - Host Resolution
extension GCDAsyncUdpSocket {
    // MARK: - Host Resolution
    
    internal func asyncResolveHost(_ host: String, 
                                 port: UInt16, 
                                 completion: @escaping (_ addresses: [Data]?, _ error: Error?) -> Void) {
        // 在全局并发队列中执行 DNS 解析
        DispatchQueue.global(qos: .default).async {
            var hints = addrinfo(
                ai_flags: 0,
                ai_family: AF_UNSPEC,      // 不指定地址族，同时支持 IPv4 和 IPv6
                ai_socktype: SOCK_DGRAM,   // UDP socket
                ai_protocol: IPPROTO_UDP,  // UDP 协议
                ai_addrlen: 0,
                ai_canonname: nil,
                ai_addr: nil,
                ai_next: nil
            )
            
            // 将端口号转换为字符串
            let portString = String(port)
            
            // 调用 getaddrinfo 进行地址解析
            var res: UnsafeMutablePointer<addrinfo>?
            let status = getaddrinfo(host, portString, &hints, &res)
            
            // 确保在函数返回时释放资源
            defer {
                if let res = res {
                    freeaddrinfo(res)
                }
            }
            
            // 检查解析结果
            if status != 0 {
                // 解析失败
                self.socketQueue.async {
                    completion(nil, self.gaiError(status))
                }
                return
            }
            
            // 收集所有解析到的地址
            var addresses = [Data]()
            var cursor = res
            
            while let info = cursor?.pointee {
                let size = Int(info.ai_addrlen)
                let address = Data(bytes: info.ai_addr, count: size)
                addresses.append(address)
                cursor = info.ai_next
            }
            
            // 根据配置对地址进行排序
            if !addresses.isEmpty {
                if self.config.contains(.preferIPv4) {
                    // 将 IPv4 地址排在前面
                    addresses.sort { addr1, addr2 in
                        return GCDAsyncUdpSocket.isIPv4Address(addr1) && !GCDAsyncUdpSocket.isIPv4Address(addr2)
                    }
                } else if self.config.contains(.preferIPv6) {
                    // 将 IPv6 地址排在前面
                    addresses.sort { addr1, addr2 in
                        return GCDAsyncUdpSocket.isIPv6Address(addr1) && !GCDAsyncUdpSocket.isIPv6Address(addr2)
                    }
                }
            }
            
            // 在 socket 队列中回调结果
            self.socketQueue.async {
                completion(addresses.isEmpty ? nil : addresses, nil)
            }
        }
    }
    
    internal func getAddress(from addresses: [Data]) throws -> (address: Data, family: Int32) {
        // 检查是否有可用的地址
        guard !addresses.isEmpty else {
            throw badParamError("No valid addresses found")
        }
        
        // 根据配置和可用性选择合适的地址
        if config.contains(.preferIPv4) {
            // 优先使用 IPv4
            if let addr = addresses.first(where: { GCDAsyncUdpSocket.isIPv4Address($0) }) {
                return (addr, AF_INET)
            }
            if let addr = addresses.first(where: { GCDAsyncUdpSocket.isIPv6Address($0) }) {
                return (addr, AF_INET6)
            }
        } else if config.contains(.preferIPv6) {
            // 优先使用 IPv6
            if let addr = addresses.first(where: { GCDAsyncUdpSocket.isIPv6Address($0) }) {
                return (addr, AF_INET6)
            }
            if let addr = addresses.first(where: { GCDAsyncUdpSocket.isIPv4Address($0) }) {
                return (addr, AF_INET)
            }
        }
        
        // 如果没有特殊偏好，使用第一个地址
        let firstAddr = addresses[0]
        let family = GCDAsyncUdpSocket.family(fromAddress: firstAddr)
        return (firstAddr, family)
    }
}
