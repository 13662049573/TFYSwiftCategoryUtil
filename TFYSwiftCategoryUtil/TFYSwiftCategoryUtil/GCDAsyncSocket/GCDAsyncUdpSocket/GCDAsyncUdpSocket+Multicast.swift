import Foundation

extension GCDAsyncUdpSocket {
    
    // MARK: - Public Multicast Methods
    
    public func joinMulticastGroup(_ group: String) throws {
        try joinMulticastGroup(group, onInterface: nil)
    }
    
    public func joinMulticastGroup(_ group: String, onInterface interface: String?) throws {
        try performMulticastRequest(.join, forGroup: group, onInterface: interface)
    }
    
    public func leaveMulticastGroup(_ group: String) throws {
        try leaveMulticastGroup(group, onInterface: nil)
    }
    
    public func leaveMulticastGroup(_ group: String, onInterface interface: String?) throws {
        try performMulticastRequest(.leave, forGroup: group, onInterface: interface)
    }
    
    // MARK: - Multicast Interface Methods
    
    public func sendIPv4Multicast(onInterface interface: String) throws {
        var error: Error?
        
        performBlock {
            if !self.preOp(&error) {
                return
            }
            
            if (self.flags.rawValue & SocketFlags.didCreateSockets.rawValue) == 0 {
                do {
                    try self.createSockets()
                } catch let err {
                    error = err
                    return
                }
            }
            
            // Convert interface to address
            var interfaceAddr4: Data?
            var interfaceAddr6: Data?
            
            self.convertInterfaceDescription(interface, port: 0, intoAddress4: &interfaceAddr4, address6: &interfaceAddr6)
            
            if interfaceAddr4 == nil {
                error = self.badParamError("Unknown interface. Specify valid interface by IP address.")
                return
            }
            
            if self.socket4FD != SOCKET_NULL {
                interfaceAddr4?.withUnsafeBytes { rawBuffer in
                    let addr = rawBuffer.bindMemory(to: sockaddr_in.self)[0]
                    var interfaceAddr = addr.sin_addr
                    let status = setsockopt(self.socket4FD, 
                                          IPPROTO_IP, 
                                          IP_MULTICAST_IF, 
                                          &interfaceAddr, 
                                          socklen_t(MemoryLayout<in_addr>.size))
                    if status != 0 {
                        error = self.errnoError("Error in setsockopt() function")
                    }
                }
            }
        }
        
        if let error = error {
            throw error
        }
    }
    
    public func sendIPv6Multicast(onInterface interface: String) throws {
        var error: Error?
        
        performBlock {
            if !self.preOp(&error) {
                return
            }
            
            if (self.flags.rawValue & SocketFlags.didCreateSockets.rawValue) == 0 {
                do {
                    try self.createSockets()
                } catch let err {
                    error = err
                    return
                }
            }
            
            // Convert interface to address
            var interfaceAddr4: Data?
            var interfaceAddr6: Data?
            
            self.convertInterfaceDescription(interface, port: 0, intoAddress4: &interfaceAddr4, address6: &interfaceAddr6)
            
            if interfaceAddr6 == nil {
                error = self.badParamError("Unknown interface. Specify valid interface by name (e.g. \"en1\").")
                return
            }
            
            if self.socket6FD != SOCKET_NULL {
                var scopeId = self.indexOfInterfaceAddr6(interfaceAddr6!)
                let status = setsockopt(self.socket6FD, 
                                      IPPROTO_IPV6, 
                                      IPV6_MULTICAST_IF, 
                                      &scopeId, 
                                      socklen_t(MemoryLayout<UInt32>.size))
                if status != 0 {
                    error = self.errnoError("Error in setsockopt() function")
                }
            }
        }
        
        if let error = error {
            throw error
        }
    }
    
    // MARK: - Private Multicast Methods
    
    private enum MulticastRequestType {
        case join
        case leave
        
        var ipv4Option: Int32 {
            switch self {
            case .join: return IP_ADD_MEMBERSHIP
            case .leave: return IP_DROP_MEMBERSHIP
            }
        }
        
        var ipv6Option: Int32 {
            switch self {
            case .join: return IPV6_JOIN_GROUP
            case .leave: return IPV6_LEAVE_GROUP
            }
        }
    }
    
    private func performMulticastRequest(_ requestType: MulticastRequestType, 
                                       forGroup group: String, 
                                       onInterface interface: String?) throws {
        var error: Error?
        
        performBlock {
            if !self.preJoin(&error) {
                return
            }
            
            // Convert group to address
            var groupAddr4: Data?
            var groupAddr6: Data?
            
            self.convertNumericHost(group, port: 0, intoAddress4: &groupAddr4, address6: &groupAddr6)
            
            if groupAddr4 == nil && groupAddr6 == nil {
                error = self.badParamError("Unknown group. Specify valid group IP address.")
                return
            }
            
            // Convert interface to address
            var interfaceAddr4: Data?
            var interfaceAddr6: Data?
            
            self.convertInterfaceDescription(interface, port: 0, intoAddress4: &interfaceAddr4, address6: &interfaceAddr6)
            
            if interfaceAddr4 == nil && interfaceAddr6 == nil {
                error = self.badParamError("Unknown interface. Specify valid interface by name (e.g. \"en1\") or IP address.")
                return
            }
            
            // Perform join/leave
            if self.socket4FD != SOCKET_NULL && groupAddr4 != nil && interfaceAddr4 != nil {
                groupAddr4!.withUnsafeBytes { groupBuffer in
                    interfaceAddr4!.withUnsafeBytes { interfaceBuffer in
                        let groupAddr = groupBuffer.bindMemory(to: sockaddr_in.self)[0]
                        let interfaceAddr = interfaceBuffer.bindMemory(to: sockaddr_in.self)[0]
                        
                        var imreq = ip_mreq(imr_multiaddr: groupAddr.sin_addr,
                                          imr_interface: interfaceAddr.sin_addr)
                        
                        let status = setsockopt(self.socket4FD,
                                              IPPROTO_IP,
                                              requestType.ipv4Option,
                                              &imreq,
                                              socklen_t(MemoryLayout<ip_mreq>.size))
                        
                        if status != 0 {
                            error = self.errnoError("Error in setsockopt() function")
                            return
                        }
                    }
                }
                
                // Using IPv4 only
                self.closeSocket6()
                self.flags.insert(.ipv6Deactivated)
                
            } else if self.socket6FD != SOCKET_NULL && groupAddr6 != nil && interfaceAddr6 != nil {
                groupAddr6!.withUnsafeBytes { groupBuffer in
                    let groupAddr = groupBuffer.bindMemory(to: sockaddr_in6.self)[0]
                    
                    var imreq = ipv6_mreq(ipv6mr_multiaddr: groupAddr.sin6_addr,
                                        ipv6mr_interface: self.indexOfInterfaceAddr6(interfaceAddr6!))
                    
                    let status = setsockopt(self.socket6FD,
                                          IPPROTO_IPV6,
                                          requestType.ipv6Option,
                                          &imreq,
                                          socklen_t(MemoryLayout<ipv6_mreq>.size))
                    
                    if status != 0 {
                        error = self.errnoError("Error in setsockopt() function")
                        return
                    }
                }
                
                // Using IPv6 only
                self.closeSocket4()
                self.flags.insert(.ipv4Deactivated)
                
            } else {
                error = self.badParamError("Socket, group, and interface do not have matching IP versions")
            }
        }
        
        if let error = error {
            throw error
        }
    }
} 
