import Foundation

extension GCDAsyncUdpSocket {
    
    // MARK: - Public Receiving Methods
    
    public func receiveOnce() throws {
        var error: Error?
        
        performBlock {
            if !self.flags.contains(.receiveOnce) {
                if !self.flags.contains(.didCreateSockets) {
                    error = self.badConfigError("Must bind socket before you can receive data. " +
                                              "You can do this explicitly via bind, or implicitly via connect or by sending data.")
                    return
                }
                
                self.flags.insert(.receiveOnce)
                self.flags.remove(.receiveContinuous)
                
                self.socketQueue.async {
                    self.doReceive()
                }
            }
        }
        
        if let error = error {
            throw error
        }
    }
    
    public func beginReceiving() throws {
        var error: Error?
        
        performBlock {
            if !self.flags.contains(.receiveContinuous) {
                if !self.flags.contains(.didCreateSockets) {
                    error = self.badConfigError("Must bind socket before you can receive data. " +
                                              "You can do this explicitly via bind, or implicitly via connect or by sending data.")
                    return
                }
                
                self.flags.insert(.receiveContinuous)
                self.flags.remove(.receiveOnce)
                
                self.socketQueue.async {
                    self.doReceive()
                }
            }
        }
        
        if let error = error {
            throw error
        }
    }
    
    public func pauseReceiving() {
        performBlock {
            self.flags.remove(.receiveOnce)
            self.flags.remove(.receiveContinuous)
            
            if self.socket4FDBytesAvailable > 0 {
                self.suspendReceive4Source()
            }
            if self.socket6FDBytesAvailable > 0 {
                self.suspendReceive6Source()
            }
        }
    }
    
    // MARK: - Receive Filter
    
    public func setReceiveFilter(_ filterBlock: GCDAsyncUdpSocketReceiveFilterBlock?, withQueue filterQueue: DispatchQueue?) {
        setReceiveFilter(filterBlock, withQueue: filterQueue, isAsynchronous: true)
    }
    
    public func setReceiveFilter(_ filterBlock: GCDAsyncUdpSocketReceiveFilterBlock?,
                               withQueue filterQueue: DispatchQueue?,
                               isAsynchronous: Bool) {
        socketQueue.async {
            self.receiveFilterBlock = filterBlock
            self.receiveFilterQueue = filterQueue
            self.receiveFilterAsync = isAsynchronous
        }
    }
    
    // MARK: - Private Receiving Methods
    
    private func doReceive() {
        // Check if receiving is paused
        if !flags.contains(.receiveOnce) && !flags.contains(.receiveContinuous) {
            if socket4FDBytesAvailable > 0 {
                suspendReceive4Source()
            }
            if socket6FDBytesAvailable > 0 {
                suspendReceive6Source()
            }
            return
        }
        
        // Check if we're waiting for receive filter operations to complete
        if flags.contains(.receiveOnce) && pendingFilterOperations > 0 {
            if socket4FDBytesAvailable > 0 {
                suspendReceive4Source()
            }
            if socket6FDBytesAvailable > 0 {
                suspendReceive6Source()
            }
            return
        }
        
        // Check if any data is available
        if socket4FDBytesAvailable == 0 && socket6FDBytesAvailable == 0 {
            if socket4FDBytesAvailable == 0 {
                resumeReceive4Source()
            }
            if socket6FDBytesAvailable == 0 {
                resumeReceive6Source()
            }
            return
        }
        
        // Determine which socket to receive from
        let doReceive4: Bool
        
        if flags.contains(.didConnect) {
            // Connected socket
            doReceive4 = (socket4FD != SOCKET_NULL)
        } else {
            // Non-connected socket
            if socket4FDBytesAvailable > 0 {
                if socket6FDBytesAvailable > 0 {
                    // Bytes available on both sockets - flip flop between them
                    doReceive4 = flags.contains(.flipFlop)
                    flags.insert(.flipFlop)
                    flags.remove(.flipFlop)
                } else {
                    // Only bytes available on socket4
                    doReceive4 = true
                }
            } else {
                // Only bytes available on socket6
                doReceive4 = false
            }
        }
        
        // Receive the data
        var data: Data?
        var addr4: Data?
        var addr6: Data?
        
        if doReceive4 {
            var sockaddr4 = sockaddr_in()
            var sockaddr4len = socklen_t(MemoryLayout<sockaddr_in>.size)
            
            let bufferSize = Int(max4ReceiveSize)
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            defer { buffer.deallocate() }
            
            let result = withUnsafeMutablePointer(to: &sockaddr4) { pointer in
                pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { pointer in
                    recvfrom(socket4FD, buffer, bufferSize, 0, pointer, &sockaddr4len)
                }
            }
            
            if result > 0 {
                if UInt(result) >= socket4FDBytesAvailable {
                    socket4FDBytesAvailable = 0
                } else {
                    socket4FDBytesAvailable -= UInt(result)
                }
                
                data = Data(bytes: buffer, count: result)
                addr4 = Data(bytes: &sockaddr4, count: Int(sockaddr4len))
            } else {
                socket4FDBytesAvailable = 0
            }
            
        } else {
            var sockaddr6 = sockaddr_in6()
            var sockaddr6len = socklen_t(MemoryLayout<sockaddr_in6>.size)
            
            let bufferSize = Int(max6ReceiveSize)
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            defer { buffer.deallocate() }
            
            let result = withUnsafeMutablePointer(to: &sockaddr6) { pointer in
                pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) { pointer in
                    recvfrom(socket6FD, buffer, bufferSize, 0, pointer, &sockaddr6len)
                }
            }
            
            if result > 0 {
                if UInt(result) >= socket6FDBytesAvailable {
                    socket6FDBytesAvailable = 0
                } else {
                    socket6FDBytesAvailable -= UInt(result)
                }
                
                data = Data(bytes: buffer, count: result)
                addr6 = Data(bytes: &sockaddr6, count: Int(sockaddr6len))
            } else {
                socket6FDBytesAvailable = 0
            }
        }
        
        // Process the received data
        var waitingForSocket = false
        var notifiedDelegate = false
        var ignored = false
        
        if let data = data {
            let addr = addr4 ?? addr6
            
            if flags.contains(.didConnect) {
                // Check if packet is from connected address
                if let addr4 = addr4, !isConnectedToAddress4(addr4) {
                    ignored = true
                }
                if let addr6 = addr6, !isConnectedToAddress6(addr6) {
                    ignored = true
                }
            }
            
            if !ignored {
                if let filterBlock = receiveFilterBlock, let filterQueue = receiveFilterQueue {
                    // Run data through filter
                    var filterContext: Any?
                    
                    if receiveFilterAsync {
                        pendingFilterOperations += 1
                        
                        filterQueue.async {
                            let allowed = filterBlock(data, addr!, &filterContext)
                            
                            self.socketQueue.async {
                                self.pendingFilterOperations -= 1
                                
                                if allowed {
                                    self.notifyDidReceiveData(data, fromAddress: addr!, withFilterContext: filterContext)
                                }
                                
                                if self.flags.contains(.receiveOnce) {
                                    if allowed {
                                        self.flags.remove(.receiveOnce)
                                    } else if self.pendingFilterOperations == 0 {
                                        self.doReceive()
                                    }
                                }
                            }
                        }
                    } else {
                        var allowed = false
                        filterQueue.sync {
                            allowed = filterBlock(data, addr!, &filterContext)
                        }
                        
                        if allowed {
                            notifyDidReceiveData(data, fromAddress: addr!, withFilterContext: filterContext)
                            notifiedDelegate = true
                        } else {
                            ignored = true
                        }
                    }
                } else {
                    notifyDidReceiveData(data, fromAddress: addr!, withFilterContext: nil)
                    notifiedDelegate = true
                }
            }
        } else {
            waitingForSocket = true
        }
        
        // Check if we should continue receiving
        if waitingForSocket {
            if socket4FDBytesAvailable == 0 {
                resumeReceive4Source()
            }
            if socket6FDBytesAvailable == 0 {
                resumeReceive6Source()
            }
        } else {
            if flags.contains(.receiveContinuous) {
                // Continuous receive mode
                doReceive()
            } else {
                // One-at-a-time receive mode
                if notifiedDelegate {
                    flags.remove(.receiveOnce)
                } else if ignored {
                    doReceive()
                }
            }
        }
    }
} 
