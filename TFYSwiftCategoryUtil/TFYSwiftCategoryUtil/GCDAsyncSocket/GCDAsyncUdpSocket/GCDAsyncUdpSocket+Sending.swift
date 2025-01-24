import Foundation

extension GCDAsyncUdpSocket {
    
    // MARK: - Public Send Methods
    
    public func sendData(_ data: Data, withTimeout timeout: TimeInterval, tag: Int) {
        guard !data.isEmpty else {
            return
        }
        
        let packet = GCDAsyncUdpSendPacket(data: data, timeout: timeout, tag: tag)
        
        socketQueue.async {
            self.sendQueue.append(packet)
            self.maybeDequeueSend()
        }
    }
    
    public func sendData(_ data: Data, toHost host: String, port: UInt16, withTimeout timeout: TimeInterval, tag: Int) {
        guard !data.isEmpty else {
            return
        }
        
        let packet = GCDAsyncUdpSendPacket(data: data, timeout: timeout, tag: tag)
        packet.resolveInProgress = true
        
        asyncResolveHost(host, port: port) { addresses, error in
            packet.resolveInProgress = false
            packet.resolvedAddresses = addresses
            packet.resolveError = error
            
            if packet === self.currentSend {
                self.doPreSend()
            }
        }
        
        socketQueue.async {
            self.sendQueue.append(packet)
            self.maybeDequeueSend()
        }
    }
    
    public func sendData(_ data: Data, toAddress address: Data, withTimeout timeout: TimeInterval, tag: Int) {
        guard !data.isEmpty else {
            return
        }
        
        let packet = GCDAsyncUdpSendPacket(data: data, timeout: timeout, tag: tag)
        packet.addressFamily = GCDAsyncUdpSocket.family(fromAddress: address)
        packet.address = address
        
        socketQueue.async {
            self.sendQueue.append(packet)
            self.maybeDequeueSend()
        }
    }
    
    // MARK: - Send Filter
    
    public func setSendFilter(_ filterBlock: GCDAsyncUdpSocketSendFilterBlock?, withQueue filterQueue: DispatchQueue?) {
        setSendFilter(filterBlock, withQueue: filterQueue, isAsynchronous: true)
    }
    
    public func setSendFilter(_ filterBlock: GCDAsyncUdpSocketSendFilterBlock?, 
                            withQueue filterQueue: DispatchQueue?, 
                            isAsynchronous: Bool) {
        socketQueue.async {
            self.sendFilterBlock = filterBlock
            self.sendFilterQueue = filterQueue
            self.sendFilterAsync = isAsynchronous
        }
    }
    
    // MARK: - Private Send Methods
    
    internal func maybeDequeueSend() {
        guard currentSend == nil else {
            return
        }
        
        // Create sockets if needed
        if (flags.rawValue & SocketFlags.didCreateSockets.rawValue) == 0 {
            do {
                try createSockets()
            } catch {
                closeWithError(error)
                return
            }
        }
        
        while !sendQueue.isEmpty {
            currentSend = sendQueue.removeFirst()
            
            if let specialPacket = currentSend as? GCDAsyncUdpSpecialPacket {
                maybeConnect()
                return
            } else if currentSend?.resolveError != nil {
                notifyDidNotSendDataWithTag(currentSend!.tag, error: currentSend!.resolveError!)
                currentSend = nil
                continue
            } else {
                doPreSend()
                break
            }
        }
        
        if currentSend == nil && (flags.rawValue & SocketFlags.closeAfterSends.rawValue) != 0 {
            closeWithError(nil)
        }
    }
    
    private func doPreSend() {
        var waitingForResolve = false
        var error: Error?
        
        if (flags.rawValue & SocketFlags.didConnect.rawValue) != 0 {
            // Connected socket
            if currentSend?.resolveInProgress == true || 
               currentSend?.resolvedAddresses != nil || 
               currentSend?.resolveError != nil {
                error = badConfigError("Cannot specify destination for connected socket")
            } else {
                currentSend?.address = cachedConnectedAddress
                currentSend?.addressFamily = cachedConnectedFamily
            }
        } else {
            // Non-connected socket
            if currentSend?.resolveInProgress == true {
                waitingForResolve = true
            } else if let resolveError = currentSend?.resolveError {
                error = resolveError
            } else if currentSend?.address == nil {
                if currentSend?.resolvedAddresses == nil {
                    error = badConfigError("Must specify destination for non-connected socket")
                } else {
                    // Pick proper address from resolved addresses
                    do {
                        let (address, family) = try getAddress(from: currentSend!.resolvedAddresses!)
                        currentSend?.address = address
                        currentSend?.addressFamily = family
                    } catch let err {
                        error = err
                    }
                }
            }
        }
        
        if waitingForResolve {
            if (flags.rawValue & SocketFlags.sock4CanAcceptBytes.rawValue) != 0 {
                suspendSend4Source()
            }
            if (flags.rawValue & SocketFlags.sock6CanAcceptBytes.rawValue) != 0 {
                suspendSend6Source()
            }
            return
        }
        
        if let error = error {
            notifyDidNotSendDataWithTag(currentSend!.tag, error: error)
            endCurrentSend()
            maybeDequeueSend()
            return
        }
        
        // Handle send filter if set
        if let filterBlock = sendFilterBlock, let filterQueue = sendFilterQueue {
            if sendFilterAsync {
                currentSend?.filterInProgress = true
                let packet = currentSend!
                
                filterQueue.async {
                    let allowed = filterBlock(packet.buffer, packet.address!, packet.tag)
                    
                    self.socketQueue.async {
                        packet.filterInProgress = false
                        if packet === self.currentSend {
                            if allowed {
                                self.doSend()
                            } else {
                                self.notifyDidSendDataWithTag(packet.tag)
                                self.endCurrentSend()
                                self.maybeDequeueSend()
                            }
                        }
                    }
                }
            } else {
                var allowed = true
                filterQueue.sync {
                    allowed = filterBlock(currentSend!.buffer, currentSend!.address!, currentSend!.tag)
                }
                
                if allowed {
                    doSend()
                } else {
                    notifyDidSendDataWithTag(currentSend!.tag)
                    endCurrentSend()
                    maybeDequeueSend()
                }
            }
        } else {
            doSend()
        }
    }
    
    private func doSend() {
        guard let currentSend = currentSend else {
            return
        }
        
        var result: Int = 0
        
        if flags.contains(.didConnect) {
            // Connected socket
            let buffer = currentSend.buffer
            
            if currentSend.addressFamily == AF_INET {
                result = send(socket4FD, buffer.withUnsafeBytes { $0.baseAddress }, buffer.count, 0)
            } else {
                result = send(socket6FD, buffer.withUnsafeBytes { $0.baseAddress }, buffer.count, 0)
            }
        } else {
            // Non-connected socket
            let buffer = currentSend.buffer
            let address = currentSend.address!
            
            if currentSend.addressFamily == AF_INET {
                result = sendto(socket4FD, buffer.withUnsafeBytes { $0.baseAddress }, buffer.count, 0,
                              address.withUnsafeBytes { $0.bindMemory(to: sockaddr.self).baseAddress },
                              socklen_t(address.count))
            } else {
                result = sendto(socket6FD, buffer.withUnsafeBytes { $0.baseAddress }, buffer.count, 0,
                              address.withUnsafeBytes { $0.bindMemory(to: sockaddr.self).baseAddress },
                              socklen_t(address.count))
            }
        }
        
        // Update flags
        if !flags.contains(.didBind) {
            flags.insert(.didBind)
        }
        
        // Check results
        var waitingForSocket = false
        var socketError: Error?
        
        if result == 0 {
            waitingForSocket = true
        } else if result < 0 {
            if errno == EAGAIN {
                waitingForSocket = true
            } else {
                socketError = errnoError("Error in send() function")
            }
        }
        
        if waitingForSocket {
            if !flags.contains(.sock4CanAcceptBytes) {
                resumeSend4Source()
            }
            if !flags.contains(.sock6CanAcceptBytes) {
                resumeSend6Source()
            }
            
            if sendTimer == nil && currentSend.timeout >= 0.0 {
                setupSendTimer(timeout: currentSend.timeout)
            }
        } else if let error = socketError {
            closeWithError(error)
        } else {
            notifyDidSendDataWithTag(currentSend.tag)
            endCurrentSend()
            maybeDequeueSend()
        }
    }
} 
