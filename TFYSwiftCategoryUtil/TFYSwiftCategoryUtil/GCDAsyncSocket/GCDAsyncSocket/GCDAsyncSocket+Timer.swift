import Foundation

// MARK: - Timer Management

extension GCDAsyncSocket {
    
    /// End connect timeout timer
    internal func endConnectTimeout() {
        if let timer = connectTimer {
            timer.cancel()
            connectTimer = nil
        }
    }
    
    /// End read timeout timer
    internal func endReadTimeout() {
        if let timer = readTimer {
            timer.cancel()
            readTimer = nil
        }
    }
    
    /// End write timeout timer
    internal func endWriteTimeout() {
        if let timer = writeTimer {
            timer.cancel()
            writeTimer = nil
        }
    }
    
    /// Start connect timeout timer
    internal func startConnectTimeout(_ timeout: TimeInterval) {
        if timeout >= 0 {
            let timer = DispatchSource.makeTimerSource(queue: socketQueue)
            connectTimer = timer
            
            timer.setEventHandler { [weak self] in
                self?.doConnectTimeout()
            }
            
            timer.schedule(deadline: .now() + timeout)
            timer.resume()
        }
    }
    
    /// Start read timeout timer
    internal func startReadTimeout(_ timeout: TimeInterval) {
        if timeout >= 0 {
            let timer = DispatchSource.makeTimerSource(queue: socketQueue)
            readTimer = timer
            
            timer.setEventHandler { [weak self] in
                self?.doReadTimeout()
            }
            
            timer.schedule(deadline: .now() + timeout)
            timer.resume()
        }
    }
    
    /// Start write timeout timer
    internal func startWriteTimeout(_ timeout: TimeInterval) {
        if timeout >= 0 {
            let timer = DispatchSource.makeTimerSource(queue: socketQueue)
            writeTimer = timer
            
            timer.setEventHandler { [weak self] in
                self?.doWriteTimeout()
            }
            
            timer.schedule(deadline: .now() + timeout)
            timer.resume()
        }
    }
    
    /// Handle connect timeout
    private func doConnectTimeout() {
        endConnectTimeout()
        closeWithError(connectTimeoutError())
    }
    
    /// Handle read timeout
    private func doReadTimeout() {
        flags.insert(.readsPaused)
        
        guard let packet = currentRead as? AsyncReadPacket,
              let delegate = delegate else {
            return
        }
        
        // Ask delegate if timeout should be extended
        if delegate.responds(to: #selector(GCDAsyncSocketDelegate.socket(_:shouldTimeoutReadWithTag:elapsed:bytesDone:))) {
            delegateQueue?.async { [weak self] in
                guard let self = self else { return }
                
                let timeoutExtension = delegate.socket?(self,
                                                      shouldTimeoutReadWithTag: packet.tag,
                                                      elapsed: packet.timeout,
                                                      bytesDone: UInt(packet.bytesDone)) ?? 0
                
                self.socketQueue.async {
                    self.doReadTimeoutWithExtension(timeoutExtension)
                }
            }
        } else {
            doReadTimeoutWithExtension(0)
        }
    }
    
    /// Handle write timeout
    private func doWriteTimeout() {
        flags.insert(.writesPaused)
        
        guard let packet = currentWrite as? AsyncWritePacket,
              let delegate = delegate else {
            return
        }
        
        // Ask delegate if timeout should be extended
        if delegate.responds(to: #selector(GCDAsyncSocketDelegate.socket(_:shouldTimeoutWriteWithTag:elapsed:bytesDone:))) {
            delegateQueue?.async { [weak self] in
                guard let self = self else { return }
                
                let timeoutExtension = delegate.socket?(self,
                                                      shouldTimeoutWriteWithTag: packet.tag,
                                                      elapsed: packet.timeout,
                                                      bytesDone: UInt(packet.bytesDone)) ?? 0
                
                self.socketQueue.async {
                    self.doWriteTimeoutWithExtension(timeoutExtension)
                }
            }
        } else {
            doWriteTimeoutWithExtension(0)
        }
    }
    
    /// Handle read timeout with extension
    private func doReadTimeoutWithExtension(_ timeoutExtension: TimeInterval) {
        if timeoutExtension > 0 {
            // Extend timeout
            if let packet = currentRead as? AsyncReadPacket {
                packet.timeout += timeoutExtension
            }
            
            // Reset timer
            if let timer = readTimer {
                timer.schedule(deadline: .now() + timeoutExtension)
            }
            
            flags.remove(.readsPaused)
            doReadData()
            
        } else {
            closeWithError(readTimeoutError())
        }
    }
    
    /// Handle write timeout with extension
    private func doWriteTimeoutWithExtension(_ timeoutExtension: TimeInterval) {
        if timeoutExtension > 0 {
            // Extend timeout
            if let packet = currentWrite as? AsyncWritePacket {
                packet.timeout += timeoutExtension
            }
            
            // Reset timer
            if let timer = writeTimer {
                timer.schedule(deadline: .now() + timeoutExtension)
            }
            
            flags.remove(.writesPaused)
            doWriteData()
            
        } else {
            closeWithError(writeTimeoutError())
        }
    }
} 