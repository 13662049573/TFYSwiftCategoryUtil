import Foundation
import Darwin

// MARK: - Interface Address Management

extension GCDAsyncSocket {
    
    /// Get interface addresses from interface description
    internal func getInterfaceAddress(interface4: inout Data?, 
                                    address6: inout Data?, 
                                    fromDescription interface: String, 
                                    port: UInt16) {
        // 处理特殊情况
        if interface == "localhost" || interface == "loopback" {
            // IPv4 loopback
            var addr4 = sockaddr_in()
            addr4.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            addr4.sin_family = sa_family_t(AF_INET)
            addr4.sin_port = port.bigEndian
            addr4.sin_addr.s_addr = UInt32(INADDR_LOOPBACK).bigEndian
            
            interface4 = Data(bytes: &addr4, count: MemoryLayout<sockaddr_in>.size)
            
            // IPv6 loopback
            var addr6 = sockaddr_in6()
            addr6.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
            addr6.sin6_family = sa_family_t(AF_INET6)
            addr6.sin6_port = port.bigEndian
            addr6.sin6_addr = in6addr_loopback
            
            address6 = Data(bytes: &addr6, count: MemoryLayout<sockaddr_in6>.size)
            return
        }
        
        // 获取所有网络接口
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaces) == 0 else { return }
        defer { freeifaddrs(interfaces) }
        
        var interface4Found = false
        var interface6Found = false
        
        var cursor = interfaces
        while let info = cursor {
            let flags = Int32(info.pointee.ifa_flags)
            let name = String(cString: info.pointee.ifa_name)
            let family = info.pointee.ifa_addr.pointee.sa_family
            
            // 检查接口是否匹配
            if name == interface {
                // 检查接口是否启用且运行
                if (flags & IFF_UP) == IFF_UP && (flags & IFF_RUNNING) == IFF_RUNNING {
                    if !interface4Found && family == sa_family_t(AF_INET) {
                        // IPv4 地址
                        let addr = info.pointee.ifa_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee }
                        var addr4 = addr
                        addr4.sin_port = port.bigEndian
                        interface4 = Data(bytes: &addr4, count: MemoryLayout<sockaddr_in>.size)
                        interface4Found = true
                    }
                    else if !interface6Found && family == sa_family_t(AF_INET6) {
                        // IPv6 地址
                        let addr = info.pointee.ifa_addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { $0.pointee }
                        var addr6 = addr
                        addr6.sin6_port = port.bigEndian
                        address6 = Data(bytes: &addr6, count: MemoryLayout<sockaddr_in6>.size)
                        interface6Found = true
                    }
                }
            }
            
            cursor = info.pointee.ifa_next
        }
    }
    
    /// Check if interface is available
    internal func isInterface(_ interface: String) -> Bool {
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaces) == 0 else { return false }
        defer { freeifaddrs(interfaces) }
        
        var cursor = interfaces
        while let info = cursor {
            let name = String(cString: info.pointee.ifa_name)
            if name == interface {
                let flags = Int32(info.pointee.ifa_flags)
                return (flags & IFF_UP) == IFF_UP && (flags & IFF_RUNNING) == IFF_RUNNING
            }
            cursor = info.pointee.ifa_next
        }
        
        return false
    }
    
    /// Get all available network interfaces
    internal func availableInterfaces() -> [String] {
        var interfaces: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaces) == 0 else { return [] }
        defer { freeifaddrs(interfaces) }
        
        var result: [String] = []
        var cursor = interfaces
        
        while let info = cursor {
            let name = String(cString: info.pointee.ifa_name)
            let flags = Int32(info.pointee.ifa_flags)
            
            if (flags & IFF_UP) == IFF_UP && (flags & IFF_RUNNING) == IFF_RUNNING {
                if !result.contains(name) {
                    result.append(name)
                }
            }
            
            cursor = info.pointee.ifa_next
        }
        
        return result
    }
} 