import Foundation

// MARK: - Error Creation

extension GCDAsyncSocket {
    
    internal func closeWithError(_ error: Error?) {
        endConnectTimeout()
        
        if currentRead != nil { endCurrentRead() }
        if currentWrite != nil { endCurrentWrite() }
        
        readQueue.removeAll()
        writeQueue.removeAll()
        
        // Close socket
        if socket4FD != -1 {
            close(socket4FD)
            socket4FD = -1
        }
        if socket6FD != -1 {
            close(socket6FD)
            socket6FD = -1
        }
        if socketUN != -1 {
            close(socketUN)
            socketUN = -1
            if let path = socketUrl?.path {
                unlink(path)
            }
            socketUrl = nil
        }
        
        // Reset flags
        flags = []
        
        // Notify delegate
        if let delegate = delegate, let delegateQueue = delegateQueue {
            let isDealloc = flags.contains(.dealloc)
            let theSelf = isDealloc ? nil : self
            
            delegateQueue.async {
                delegate.socketDidDisconnect(theSelf ?? self, withError: error)
            }
        }
    }
    
    /// Create error for connect timeout
    internal func connectTimeoutError() -> NSError {
        return NSError(domain: GCDAsyncSocketErrorDomain,
                      code: GCDAsyncSocketError.connectTimeoutError.rawValue,
                      userInfo: [NSLocalizedDescriptionKey: "Connect operation timed out"])
    }
    
    /// Create error for read timeout
    internal func readTimeoutError() -> NSError {
        return NSError(domain: GCDAsyncSocketErrorDomain,
                      code: GCDAsyncSocketError.readTimeoutError.rawValue,
                      userInfo: [NSLocalizedDescriptionKey: "Read operation timed out"])
    }
    
    /// Create error for write timeout
    internal func writeTimeoutError() -> NSError {
        return NSError(domain: GCDAsyncSocketErrorDomain,
                      code: GCDAsyncSocketError.writeTimeoutError.rawValue,
                      userInfo: [NSLocalizedDescriptionKey: "Write operation timed out"])
    }
    
    /// Create error for bad configuration
    internal func badConfigError(_ message: String) -> NSError {
        return NSError(domain: GCDAsyncSocketErrorDomain,
                      code: GCDAsyncSocketError.badConfigError.rawValue,
                      userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    /// Create error for socket operations
    internal func socketError(withErrno code: Int32, reason: String) -> NSError {
        var userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: String(cString: strerror(code))
        ]
        
        if !reason.isEmpty {
            userInfo[NSLocalizedFailureReasonErrorKey] = reason
        }
        
        return NSError(domain: NSPOSIXErrorDomain, code: Int(code), userInfo: userInfo)
    }
    
    /// Create error for connection closed by peer
    internal func connectionClosedError() -> NSError {
        return NSError(domain: GCDAsyncSocketErrorDomain,
                      code: GCDAsyncSocketError.closedError.rawValue,
                      userInfo: [NSLocalizedDescriptionKey: "Socket closed by remote peer"])
    }
    
    /// Create error for SSL/TLS operations
    internal func sslError(_ status: OSStatus) -> NSError {
        let msg = "Error code definition can be found in Apple's SecureTransport.h"
        return NSError(domain: "kCFStreamErrorDomainSSL",
                      code: Int(status),
                      userInfo: [NSLocalizedRecoverySuggestionErrorKey: msg])
    }
    
    /// Create error for other operations
    internal func otherError(_ msg: String) -> NSError {
        return NSError(domain: GCDAsyncSocketErrorDomain,
                      code: GCDAsyncSocketError.otherError.rawValue,
                      userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    /// Create error for read maxed out
    internal func readMaxedOutError() -> NSError {
        return NSError(domain: GCDAsyncSocketErrorDomain,
                      code: GCDAsyncSocketError.readMaxedOutError.rawValue,
                      userInfo: [NSLocalizedDescriptionKey: "Read operation reached set maximum length"])
    }
    
    /// Create error for bad parameter
    internal func badParamError(_ message: String) -> NSError {
        return NSError(domain: GCDAsyncSocketErrorDomain,
                      code: GCDAsyncSocketError.badParamError.rawValue,
                      userInfo: [NSLocalizedDescriptionKey: message])
    }
} 
