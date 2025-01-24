import Foundation

// MARK: - GCDAsyncSocketDelegate Protocol

@objc public protocol GCDAsyncSocketDelegate: NSObjectProtocol {
    
    // MARK: Required Methods
    
    /// Called when a socket connects and is ready for reading and writing.
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16)
    
    /// Called when a socket has completed reading the requested data into memory.
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int)
    
    /// Called when a socket has completed writing the requested data.
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int)
    
    /// Called when a socket disconnects with or without error.
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?)
    
    // MARK: Optional Methods
    
    /// Called when a socket accepts a connection.
    @objc optional func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket)
    
    /// Called when a socket is about to connect.
    @objc optional func socket(_ sock: GCDAsyncSocket, willConnect toHost: String, port: UInt16) throws
    
    /// Called when a socket has completed SSL/TLS negotiation.
    @objc optional func socketDidSecure(_ sock: GCDAsyncSocket)
    
    /// Called when a socket has read in some data, but has not yet completed the read.
    @objc optional func socket(_ sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int)
    
    /// Called when a socket has written some data, but has not yet completed the entire write.
    @objc optional func socket(_ sock: GCDAsyncSocket, didWritePartialDataOfLength partialLength: UInt, tag: Int)
    
    /// Called if a read operation has reached its timeout without completing.
    @objc optional func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone: UInt) -> TimeInterval
    
    /// Called if a write operation has reached its timeout without completing.
    @objc optional func socket(_ sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: Int, elapsed: TimeInterval, bytesDone: UInt) -> TimeInterval
    
    /// Called when a socket securely connects and client needs to verify server certificate chain.
    @objc optional func socket(_ sock: GCDAsyncSocket, didReceiveTrust trust: SecTrust, completionHandler: @escaping (Bool) -> Void)
}

// MARK: - Delegate Response Checking

extension GCDAsyncSocketDelegate {
    func responds(to selector: Selector) -> Bool {
        return (self as AnyObject).responds(to: selector)
    }
} 