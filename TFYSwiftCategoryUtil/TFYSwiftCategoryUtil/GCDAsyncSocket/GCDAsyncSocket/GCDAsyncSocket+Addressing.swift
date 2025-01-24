import Foundation

// MARK: - Socket Addressing

extension GCDAsyncSocket {
    
    /// Get host string from IPv4 socket address
    internal func connectedHost(fromSocket4 socketFD: Int32) -> String? {
        var addr = sockaddr_in()
        var addr_in = sockaddr()
        var len = socklen_t(MemoryLayout<sockaddr_in>.size)
        
        guard getpeername(socketFD, &addr_in, &len) == 0 else {
            return nil
        }
        
        addr = withUnsafePointer(to: addr_in) { ptr in
            ptr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { ptr in
                ptr.pointee
            }
        }
        
        var host = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
        guard inet_ntop(AF_INET, &addr.sin_addr, &host, socklen_t(INET_ADDRSTRLEN)) != nil else {
            return nil
        }
        
        return String(cString: host)
    }
    
    /// Get host string from IPv6 socket address
    internal func connectedHost(fromSocket6 socketFD: Int32) -> String? {
        var addr = sockaddr_in6()
        var addr_in = sockaddr()
        var len = socklen_t(MemoryLayout<sockaddr_in6>.size)
        
        guard getpeername(socketFD, &addr_in, &len) == 0 else {
            return nil
        }
        
        addr = withUnsafePointer(to: addr_in) { ptr in
            ptr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { ptr in
                ptr.pointee
            }
        }
        
        var host = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
        guard inet_ntop(AF_INET6, &addr.sin6_addr, &host, socklen_t(INET6_ADDRSTRLEN)) != nil else {
            return nil
        }
        
        return String(cString: host)
    }
    
    /// Get port number from IPv4 socket address
    internal func connectedPort(fromSocket4 socketFD: Int32) -> UInt16 {
        var addr = sockaddr_in()
        var addr_in = sockaddr()
        var len = socklen_t(MemoryLayout<sockaddr_in>.size)
        
        guard getpeername(socketFD, &addr_in, &len) == 0 else {
            return 0
        }
        
        addr = withUnsafePointer(to: addr_in) { ptr in
            ptr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { ptr in
                ptr.pointee
            }
        }
        
        return UInt16(bigEndian: addr.sin_port)
    }
    
    /// Get port number from IPv6 socket address
    internal func connectedPort(fromSocket6 socketFD: Int32) -> UInt16 {
        var addr = sockaddr_in6()
        var addr_in = sockaddr()
        var len = socklen_t(MemoryLayout<sockaddr_in6>.size)
        
        guard getpeername(socketFD, &addr_in, &len) == 0 else {
            return 0
        }
        
        addr = withUnsafePointer(to: addr_in) { ptr in
            ptr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { ptr in
                ptr.pointee
            }
        }
        
        return UInt16(bigEndian: addr.sin6_port)
    }
    
    /// Get local host string from IPv4 socket address
    internal func localHost(fromSocket4 socketFD: Int32) -> String? {
        var addr = sockaddr_in()
        var addr_in = sockaddr()
        var len = socklen_t(MemoryLayout<sockaddr_in>.size)
        
        guard getsockname(socketFD, &addr_in, &len) == 0 else {
            return nil
        }
        
        addr = withUnsafePointer(to: addr_in) { ptr in
            ptr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { ptr in
                ptr.pointee
            }
        }
        
        var host = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
        guard inet_ntop(AF_INET, &addr.sin_addr, &host, socklen_t(INET_ADDRSTRLEN)) != nil else {
            return nil
        }
        
        return String(cString: host)
    }
    
    /// Get local host string from IPv6 socket address
    internal func localHost(fromSocket6 socketFD: Int32) -> String? {
        var addr = sockaddr_in6()
        var addr_in = sockaddr()
        var len = socklen_t(MemoryLayout<sockaddr_in6>.size)
        
        guard getsockname(socketFD, &addr_in, &len) == 0 else {
            return nil
        }
        
        addr = withUnsafePointer(to: addr_in) { ptr in
            ptr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { ptr in
                ptr.pointee
            }
        }
        
        var host = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
        guard inet_ntop(AF_INET6, &addr.sin6_addr, &host, socklen_t(INET6_ADDRSTRLEN)) != nil else {
            return nil
        }
        
        return String(cString: host)
    }
    
    /// Get local port number from IPv4 socket address
    internal func localPort(fromSocket4 socketFD: Int32) -> UInt16 {
        var addr = sockaddr_in()
        var addr_in = sockaddr()
        var len = socklen_t(MemoryLayout<sockaddr_in>.size)
        
        guard getsockname(socketFD, &addr_in, &len) == 0 else {
            return 0
        }
        
        addr = withUnsafePointer(to: addr_in) { ptr in
            ptr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { ptr in
                ptr.pointee
            }
        }
        
        return UInt16(bigEndian: addr.sin_port)
    }
    
    /// Get local port number from IPv6 socket address
    internal func localPort(fromSocket6 socketFD: Int32) -> UInt16 {
        var addr = sockaddr_in6()
        var addr_in = sockaddr()
        var len = socklen_t(MemoryLayout<sockaddr_in6>.size)
        
        guard getsockname(socketFD, &addr_in, &len) == 0 else {
            return 0
        }
        
        addr = withUnsafePointer(to: addr_in) { ptr in
            ptr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { ptr in
                ptr.pointee
            }
        }
        
        return UInt16(bigEndian: addr.sin6_port)
    }
} 