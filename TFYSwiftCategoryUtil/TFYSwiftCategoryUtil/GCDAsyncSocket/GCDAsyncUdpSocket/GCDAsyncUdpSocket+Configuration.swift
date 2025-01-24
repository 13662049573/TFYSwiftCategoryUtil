import Foundation


// MARK: - Configuration Methods
extension GCDAsyncUdpSocket {
    
    // MARK: Delegate
    
    public func setDelegate(_ delegate: GCDAsyncUdpSocketDelegate?, delegateQueue: DispatchQueue?) {
        performBlock {
            self.delegate = delegate
            self.delegateQueue = delegateQueue
        }
    }
    
    public func synchronouslySetDelegate(_ delegate: GCDAsyncUdpSocketDelegate?, delegateQueue: DispatchQueue?) {
        performBlock {
            self.delegate = delegate
            self.delegateQueue = delegateQueue
        }
    }
    
    // MARK: IP Version Configuration
    
    public var isIPv4Enabled: Bool {
        get {
            var result = false
            performBlock {
                result = !self.config.contains(.ipv4Disabled)
            }
            return result
        }
        set {
            performBlock {
                if newValue {
                    self.config.remove(.ipv4Disabled)
                } else {
                    self.config.insert(.ipv4Disabled)
                }
            }
        }
    }
    
    public var isIPv6Enabled: Bool {
        get {
            var result = false
            performBlock {
                result = !self.config.contains(.ipv6Disabled)
            }
            return result
        }
        set {
            performBlock {
                if newValue {
                    self.config.remove(.ipv6Disabled)
                } else {
                    self.config.insert(.ipv6Disabled)
                }
            }
        }
    }
    
    public var isIPv4Preferred: Bool {
        var result = false
        performBlock {
            result = self.config.contains(.preferIPv4)
        }
        return result
    }
    
    public var isIPv6Preferred: Bool {
        var result = false
        performBlock {
            result = self.config.contains(.preferIPv6)
        }
        return result
    }
    
    public func setPreferIPv4() {
        performBlock {
            self.config.insert(.preferIPv4)
            self.config.remove(.preferIPv6)
        }
    }
    
    public func setPreferIPv6() {
        performBlock {
            self.config.remove(.preferIPv4)
            self.config.insert(.preferIPv6)
        }
    }
    
    public func setIPVersionNeutral() {
        performBlock {
            self.config.remove(.preferIPv4)
            self.config.remove(.preferIPv6)
        }
    }
    
    // MARK: Buffer Sizes
    
    public var maxReceiveIPv4BufferSize: UInt16 {
        get {
            var result: UInt16 = 0
            performBlock {
                result = self.max4ReceiveSize
            }
            return result
        }
        set {
            performBlock {
                self.max4ReceiveSize = newValue
            }
        }
    }
    
    public var maxReceiveIPv6BufferSize: UInt32 {
        get {
            var result: UInt32 = 0
            performBlock {
                result = self.max6ReceiveSize
            }
            return result
        }
        set {
            performBlock {
                self.max6ReceiveSize = newValue
            }
        }
    }
    
    public var maxSendBufferSize: UInt16 {
        get {
            var result: UInt16 = 0
            performBlock {
                result = self.maxSendSize
            }
            return result
        }
        set {
            performBlock {
                self.maxSendSize = newValue
            }
        }
    }
    
    // MARK: User Data
    
    public var userDataObject: Any? {
        get {
            var result: Any?
            performBlock {
                result = self.userData
            }
            return result
        }
        set {
            performBlock {
                self.userData = newValue
            }
        }
    }
    
    // MARK: Helper Methods
    
    public func performBlock(_ block: () -> Void) {
        if DispatchQueue.getSpecific(key: IsOnSocketQueueOrTargetQueueKey) != nil {
            block()
        } else {
            socketQueue.sync(execute: block)
        }
    }
} 
