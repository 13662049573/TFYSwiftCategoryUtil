import Foundation
import Security

// MARK: - Error Domain & Codes

public let GCDAsyncSocketErrorDomain = "GCDAsyncSocketErrorDomain"

public enum GCDAsyncSocketError: Int {
    case noError = 0           // Never used
    case badConfigError        // Invalid configuration
    case badParamError        // Invalid parameter was passed
    case connectTimeoutError   // A connect operation timed out
    case readTimeoutError      // A read operation timed out 
    case writeTimeoutError     // A write operation timed out
    case readMaxedOutError     // Reached set maxLength without completing
    case closedError           // The remote peer closed the connection
    case otherError           // Description provided in userInfo
}

// MARK: - Constants & Flags

private let SocketQueueName = "GCDAsyncSocket"
private let SocketThreadName = "GCDAsyncSocket-CFStream"

// Socket flags
internal struct SocketFlags: OptionSet {
    let rawValue: UInt32
    
    static let started = SocketFlags(rawValue: 1 << 0)
    static let connected = SocketFlags(rawValue: 1 << 1)
    static let forbidReadsWrites = SocketFlags(rawValue: 1 << 2)
    static let readsPaused = SocketFlags(rawValue: 1 << 3)
    static let writesPaused = SocketFlags(rawValue: 1 << 4)
    static let disconnectAfterReads = SocketFlags(rawValue: 1 << 5)
    static let disconnectAfterWrites = SocketFlags(rawValue: 1 << 6)
    static let socketCanAcceptBytes = SocketFlags(rawValue: 1 << 7)
    static let readSourceSuspended = SocketFlags(rawValue: 1 << 8)
    static let writeSourceSuspended = SocketFlags(rawValue: 1 << 9)
    static let queuedTLS = SocketFlags(rawValue: 1 << 10)
    static let startingReadTLS = SocketFlags(rawValue: 1 << 11)
    static let startingWriteTLS = SocketFlags(rawValue: 1 << 12)
    static let socketSecure = SocketFlags(rawValue: 1 << 13)
    static let socketHasReadEOF = SocketFlags(rawValue: 1 << 14)
    static let readStreamClosed = SocketFlags(rawValue: 1 << 15)
    static let dealloc = SocketFlags(rawValue: 1 << 16)
    static let connecting = SocketFlags(rawValue: 1 << 17)
}

// Socket config
internal struct SocketConfig: OptionSet {
    let rawValue: UInt32
    
    static let IPv4Disabled = SocketConfig(rawValue: 1 << 0)
    static let IPv6Disabled = SocketConfig(rawValue: 1 << 1)
    static let preferIPv6 = SocketConfig(rawValue: 1 << 2)
    static let allowHalfDuplexConnection = SocketConfig(rawValue: 1 << 3)
}

// MARK: - GCDAsyncSocket Class

public class GCDAsyncSocket: NSObject {
    
    // MARK: Properties
    
    internal weak var delegate: GCDAsyncSocketDelegate?
    internal var delegateQueue: DispatchQueue?
    internal var socketQueue: DispatchQueue
    
    internal var socket4FD: Int32 = -1
    internal var socket6FD: Int32 = -1
    internal var socketUN: Int32 = -1
    internal var socketUrl: URL?
    
    internal var flags = SocketFlags()
    internal var config = SocketConfig()
    
    internal var readQueue = [Any]()
    internal var writeQueue = [Any]()
    
    internal var currentRead: Any?
    internal var currentWrite: Any?
    
    internal var readTimer: DispatchSourceTimer?
    internal var writeTimer: DispatchSourceTimer?
    internal var connectTimer: DispatchSourceTimer?
    internal var stateIndex: Int = 0
    
    internal var socketFDBytesAvailable: Int = 0
    internal var connectInterface4: Data?
    internal var connectInterface6: Data?
    
    internal var alternateAddressDelay: TimeInterval = 0.3
    
    // SSL/TLS Properties
    internal var securityContext: SecurityContext?
    internal var sslPreBuffer: PreBuffer?
    internal var sslErrCode: OSStatus = noErr
    internal var lastSSLHandshakeError: OSStatus = noErr
    internal var sslWriteCachedLength: Int = 0
    internal var tlsSettings: [String: Any] = [:]
    
    // MARK: Initialization
    
    public override init() {
        socketQueue = DispatchQueue(label: SocketQueueName)
        super.init()
    }
    
    public init(delegate: GCDAsyncSocketDelegate?, delegateQueue: DispatchQueue?) {
        self.delegate = delegate
        self.delegateQueue = delegateQueue
        self.socketQueue = DispatchQueue(label: SocketQueueName)
        super.init()
    }
    
    public init(delegate: GCDAsyncSocketDelegate?, delegateQueue: DispatchQueue?, socketQueue: DispatchQueue?) {
        self.delegate = delegate
        self.delegateQueue = delegateQueue
        self.socketQueue = socketQueue ?? DispatchQueue(label: SocketQueueName)
        super.init()
    }
    
    deinit {
        socketQueue.sync {
            self.flags.insert(.dealloc)
            self.closeWithError(nil)
        }
    }
}

// MARK: - Public Interface

extension GCDAsyncSocket {
    
    public var isConnected: Bool {
        var result = false
        socketQueue.sync {
            result = self.flags.contains(.connected)
        }
        return result
    }
    
    public var isDisconnected: Bool {
        var result = false
        socketQueue.sync {
            result = !self.flags.contains(.started)
        }
        return result
    }
    
    public var connectedHost: String? {
        var result: String?
        socketQueue.sync {
            if self.socket4FD != -1 {
                result = self.connectedHost(fromSocket4: self.socket4FD)
            } else if self.socket6FD != -1 {
                result = self.connectedHost(fromSocket6: self.socket6FD)
            }
        }
        return result
    }
    
    public var connectedPort: UInt16 {
        var result: UInt16 = 0
        socketQueue.sync {
            if self.socket4FD != -1 {
                result = self.connectedPort(fromSocket4: self.socket4FD)
            } else if self.socket6FD != -1 {
                result = self.connectedPort(fromSocket6: self.socket6FD)
            }
        }
        return result
    }
}

// MARK: - Connecting

extension GCDAsyncSocket {
    
    public func connect(toHost host: String, onPort port: UInt16) throws {
        try connect(toHost: host, onPort: port, withTimeout: -1)
    }
    
    public func connect(toHost host: String, onPort port: UInt16, withTimeout timeout: TimeInterval) throws {
        try connect(toHost: host, onPort: port, viaInterface: nil, withTimeout: timeout)
    }
    
    public func connect(toHost host: String, onPort port: UInt16, viaInterface interface: String?, withTimeout timeout: TimeInterval) throws {
        // 参数检查
        guard !host.isEmpty else {
            throw NSError(domain: GCDAsyncSocketErrorDomain,
                         code: GCDAsyncSocketError.badParamError.rawValue,
                         userInfo: [NSLocalizedDescriptionKey: "Invalid host parameter (nil or empty string)"])
        }
        
        var preConnectError: Error?
        let semaphore = DispatchSemaphore(value: 0)
        
        socketQueue.async {
            do {
                try self.preConnect(withInterface: interface)
                
                self.flags.insert(.started)
                
                // 启动DNS查找
                let hostCopy = host
                let stateIndex = self.currentStateIndex
                
                DispatchQueue.global().async {
                    do {
                        let addresses = try GCDAsyncSocket.lookupHost(hostCopy, port: port)
                        
                        self.socketQueue.async {
                            self.lookup(stateIndex: stateIndex, didSucceedWithAddress4: addresses.v4Address, address6: addresses.v6Address)
                        }
                    } catch {
                        self.socketQueue.async {
                            self.lookup(stateIndex: stateIndex, didFail: error)
                        }
                    }
                }
                
                self.startConnectTimeout(timeout)
                
            } catch {
                preConnectError = error
            }
            
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        if let error = preConnectError {
            throw error
        }
    }
    
    private func preConnect(withInterface interface: String?) throws {
        // 检查代理和代理队列
        guard delegate != nil else {
            throw NSError(domain: GCDAsyncSocketErrorDomain,
                         code: GCDAsyncSocketError.badConfigError.rawValue,
                         userInfo: [NSLocalizedDescriptionKey: "Attempting to connect without a delegate"])
        }
        
        guard delegateQueue != nil else {
            throw NSError(domain: GCDAsyncSocketErrorDomain,
                         code: GCDAsyncSocketError.badConfigError.rawValue,
                         userInfo: [NSLocalizedDescriptionKey: "Attempting to connect without a delegate queue"])
        }
        
        // 检查是否已经连接
        guard isDisconnected else {
            throw NSError(domain: GCDAsyncSocketErrorDomain,
                         code: GCDAsyncSocketError.badConfigError.rawValue,
                         userInfo: [NSLocalizedDescriptionKey: "Socket is already connected"])
        }
        
        // 检查IPv4/IPv6配置
        let isIPv4Disabled = config.contains(.IPv4Disabled)
        let isIPv6Disabled = config.contains(.IPv6Disabled)
        
        guard !(isIPv4Disabled && isIPv6Disabled) else {
            throw NSError(domain: GCDAsyncSocketErrorDomain,
                         code: GCDAsyncSocketError.badConfigError.rawValue,
                         userInfo: [NSLocalizedDescriptionKey: "Both IPv4 and IPv6 have been disabled"])
        }
        
        // 处理接口
        if let interface = interface {
            var interface4: Data?
            var interface6: Data?
            
            getInterfaceAddress(interface4: &interface4, address6: &interface6, fromDescription: interface, port: 0)
            
            guard interface4 != nil || interface6 != nil else {
                throw NSError(domain: GCDAsyncSocketErrorDomain,
                            code: GCDAsyncSocketError.badParamError.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: "Unknown interface"])
            }
            
            if isIPv4Disabled && interface6 == nil {
                throw NSError(domain: GCDAsyncSocketErrorDomain,
                            code: GCDAsyncSocketError.badParamError.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: "IPv4 has been disabled and specified interface doesn't support IPv6"])
            }
            
            if isIPv6Disabled && interface4 == nil {
                throw NSError(domain: GCDAsyncSocketErrorDomain,
                            code: GCDAsyncSocketError.badParamError.rawValue,
                            userInfo: [NSLocalizedDescriptionKey: "IPv6 has been disabled and specified interface doesn't support IPv4"])
            }
            
            connectInterface4 = interface4
            connectInterface6 = interface6
        }
        
        // 清空读写队列
        readQueue.removeAll()
        writeQueue.removeAll()
    }
    
    private func doConnectTimeout() {
        endConnectTimeout()
        closeWithError(connectTimeoutError())
    }
}

// MARK: - DNS Lookup

extension GCDAsyncSocket {
    
    private static func lookupHost(_ host: String, port: UInt16) throws -> (v4Address: Data?, v6Address: Data?) {
        // 处理localhost和loopback特殊情况
        if host == "localhost" || host == "loopback" {
            var addr4 = sockaddr_in()
            addr4.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            addr4.sin_family = sa_family_t(AF_INET)
            addr4.sin_port = port.bigEndian
            addr4.sin_addr.s_addr = UInt32(INADDR_LOOPBACK).bigEndian
            
            var addr6 = sockaddr_in6()
            addr6.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
            addr6.sin6_family = sa_family_t(AF_INET6)
            addr6.sin6_port = port.bigEndian
            addr6.sin6_addr = in6addr_loopback
            
            let address4 = Data(bytes: &addr4, count: MemoryLayout<sockaddr_in>.size)
            let address6 = Data(bytes: &addr6, count: MemoryLayout<sockaddr_in6>.size)
            
            return (address4, address6)
        }
        
        // 正常DNS查找
        var hints = addrinfo()
        hints.ai_family = PF_UNSPEC
        hints.ai_socktype = SOCK_STREAM
        hints.ai_protocol = IPPROTO_TCP
        
        var result: UnsafeMutablePointer<addrinfo>?
        let error = getaddrinfo(host, String(port), &hints, &result)
        
        guard error == 0 else {
            throw NSError(domain: "kCFStreamErrorDomainNetDB",
                         code: Int(error),
                         userInfo: [NSLocalizedDescriptionKey: String(cString: gai_strerror(error))])
        }
        
        defer { freeaddrinfo(result) }
        
        var address4: Data?
        var address6: Data?
        
        var info = result
        while let currentInfo = info {
            let family = currentInfo.pointee.ai_family
            let addrLen = currentInfo.pointee.ai_addrlen
            
            if let addr = currentInfo.pointee.ai_addr {
                if family == AF_INET {
                    address4 = Data(bytes: addr, count: Int(addrLen))
                } else if family == AF_INET6 {
                    address6 = Data(bytes: addr, count: Int(addrLen))
                }
            }
            
            info = currentInfo.pointee.ai_next
        }
        
        return (address4, address6)
    }
}

// MARK: - Types & Properties

extension GCDAsyncSocket {
    // 读写类型
    internal class AsyncReadPacket {
        var buffer: NSMutableData
        var startOffset: Int
        var bytesDone: Int
        var maxLength: Int
        var timeout: TimeInterval
        var readLength: Int
        var term: Data?
        var tag: Int
        
        init(data: NSMutableData?, startOffset: Int, maxLength: Int, timeout: TimeInterval, readLength: Int, terminator: Data?, tag: Int) {
            self.buffer = data ?? NSMutableData()
            self.startOffset = startOffset
            self.bytesDone = 0
            self.maxLength = maxLength
            self.timeout = timeout
            self.readLength = readLength
            self.term = terminator
            self.tag = tag
        }
    }
    
    internal class AsyncWritePacket {
        var buffer: Data
        var bytesDone: Int
        var tag: Int
        var timeout: TimeInterval
        
        init(data: Data, timeout: TimeInterval, tag: Int) {
            self.buffer = data
            self.bytesDone = 0
            self.tag = tag
            self.timeout = timeout
        }
    }
}

// MARK: - Reading

extension GCDAsyncSocket {
    
    public func readData(withTimeout timeout: TimeInterval, tag: Int) {
        readData(toLength: 0, withTimeout: timeout, tag: tag)
    }
    
    public func readData(toLength length: Int, withTimeout timeout: TimeInterval, tag: Int) {
        guard length >= 0 else { return }
        
        socketQueue.async {
            guard self.isConnected else { return }
            
            let packet = AsyncReadPacket(data: nil,
                                       startOffset: 0,
                                       maxLength: 0,
                                       timeout: timeout,
                                       readLength: length,
                                       terminator: nil,
                                       tag: tag)
            
            self.readQueue.append(packet)
            self.maybeDequeueRead()
        }
    }
    
    public func readData(toData data: Data, withTimeout timeout: TimeInterval, tag: Int) {
        readData(toData: data, withTimeout: timeout, maxLength: 0, tag: tag)
    }
    
    public func readData(toData data: Data, withTimeout timeout: TimeInterval, maxLength: Int, tag: Int) {
        guard !data.isEmpty else { return }
        
        socketQueue.async {
            guard self.isConnected else { return }
            
            let packet = AsyncReadPacket(data: nil,
                                       startOffset: 0,
                                       maxLength: maxLength,
                                       timeout: timeout,
                                       readLength: 0,
                                       terminator: data,
                                       tag: tag)
            
            self.readQueue.append(packet)
            self.maybeDequeueRead()
        }
    }
    
    internal func maybeDequeueRead() {
        guard currentRead == nil,
              flags.contains(.connected),
              !readQueue.isEmpty else {
            return
        }
        
        currentRead = readQueue.removeFirst()
        
        if let packet = currentRead as? AsyncReadPacket {
            startReadTimeout(timeout: packet.timeout)
            doReadData()
        }
    }
    
    private func startReadTimeout(timeout: TimeInterval) {
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
    
    private func doReadTimeout() {
        flags.insert(.readsPaused)
        
        guard let packet = currentRead as? AsyncReadPacket,
              let delegate = delegate else {
            return
        }
        
        // 询问代理是否延长超时时间
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
    
    private func doReadTimeoutWithExtension(_ timeoutExtension: TimeInterval) {
        if timeoutExtension > 0 {
            // 延长超时时间
            if let packet = currentRead as? AsyncReadPacket {
                packet.timeout += timeoutExtension
            }
            
            // 重新调度定时器
            if let timer = readTimer {
                timer.schedule(deadline: .now() + timeoutExtension)
            }
            
            flags.remove(.readsPaused)
            doReadData()
            
        } else {
            closeWithError(readTimeoutError())
        }
    }
}

// MARK: - Writing

extension GCDAsyncSocket {
    
    public func writeData(_ data: Data, withTimeout timeout: TimeInterval, tag: Int) {
        guard !data.isEmpty else { return }
        
        socketQueue.async {
            guard self.flags.contains(.started) && !self.flags.contains(.forbidReadsWrites) else { return }
            
            let packet = AsyncWritePacket(data: data, timeout: timeout, tag: tag)
            self.writeQueue.append(packet)
            self.maybeDequeueWrite()
        }
    }
    
    internal func maybeDequeueWrite() {
        guard currentWrite == nil,
              flags.contains(.connected) else {
            return
        }
        
        if let packet = writeQueue.first {
            currentWrite = packet
            writeQueue.removeFirst()
            
            if let writePacket = currentWrite as? AsyncWritePacket {
                startWriteTimeout(timeout: writePacket.timeout)
                doWriteData()
            }
        } else if flags.contains(.disconnectAfterWrites) {
            if flags.contains(.disconnectAfterReads) {
                if readQueue.isEmpty && currentRead == nil {
                    closeWithError(nil)
                }
            } else {
                closeWithError(nil)
            }
        }
    }
    
    private func startWriteTimeout(timeout: TimeInterval) {
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
    
    private func doWriteTimeout() {
        flags.insert(.writesPaused)
        
        guard let packet = currentWrite as? AsyncWritePacket,
              let delegate = delegate else {
            return
        }
        
        // 询问代理是否延长超时时间
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
    
    private func doWriteTimeoutWithExtension(_ timeoutExtension: TimeInterval) {
        if timeoutExtension > 0 {
            // 延长超时时间
            if let packet = currentWrite as? AsyncWritePacket {
                packet.timeout += timeoutExtension
            }
            
            // 重新调度定时器
            if let timer = writeTimer {
                timer.schedule(deadline: .now() + timeoutExtension)
            }
            
            flags.remove(.writesPaused)
            doWriteData()
            
        } else {
            closeWithError(writeTimeoutError())
        }
    }

    // MARK: - Actual Read/Write Implementation
    
    internal func doReadData() {
        // 实现实际的读取操作
        guard let packet = currentRead as? AsyncReadPacket else { return }
        
        // 如果没有可用数据,等待readSource通知
        if socketFDBytesAvailable == 0 {
            resumeReadSource()
            return
        }
        
        // 获取socket文件描述符
        let socketFD = socket4FD != -1 ? socket4FD : socket6FD
        guard socketFD != -1 else { return }
        
        // 确定要读取的字节数
        var bytesToRead = socketFDBytesAvailable
        if packet.readLength > 0 {
            bytesToRead = min(bytesToRead, packet.readLength - packet.bytesDone)
        }
        
        // 准备缓冲区
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bytesToRead)
        defer { buffer.deallocate() }
        
        // 读取数据
        let bytesRead = read(socketFD, buffer, bytesToRead)
        
        if bytesRead < 0 {
            if errno == EWOULDBLOCK {
                // 需要等待更多数据
                resumeReadSource()
            } else {
                closeWithError(socketError(withErrno: errno, reason: "Error in read() function"))
            }
        } else if bytesRead == 0 {
            closeWithError(connectionClosedError())
        } else {
            // 成功读取数据
            let data = Data(bytes: buffer, count: bytesRead)
            packet.buffer.append(data)
            packet.bytesDone += bytesRead
            
            // 通知代理
            notifyDelegateOfReadProgress(packet: packet)
            
            // 检查是否完成读取
            if packet.readLength > 0 && packet.bytesDone >= packet.readLength {
                completeCurrentRead()
            } else {
                doReadData() // 继续读取
            }
        }
    }
    
    internal func doWriteData() {
        // 实现实际的写入操作
        guard let packet = currentWrite as? AsyncWritePacket else { return }
        
        // 如果socket不能接受字节,等待writeSource通知
        if !flags.contains(.socketCanAcceptBytes) {
            resumeWriteSource()
            return
        }
        
        // 获取socket文件描述符
        let socketFD = socket4FD != -1 ? socket4FD : socket6FD
        guard socketFD != -1 else { return }
        
        // 准备要写入的数据
        let remainingBytes = packet.buffer.count - packet.bytesDone
        let buffer = (packet.buffer as NSData).bytes.advanced(by: packet.bytesDone)
        
        // 写入数据
        let bytesWritten = write(socketFD, buffer, remainingBytes)
        
        if bytesWritten < 0 {
            if errno == EWOULDBLOCK {
                // 需要等待socket准备好
                flags.remove(.socketCanAcceptBytes)
                resumeWriteSource()
            } else {
                closeWithError(socketError(withErrno: errno, reason: "Error in write() function"))
            }
        } else {
            // 更新进度
            packet.bytesDone += bytesWritten
            
            // 通知代理
            notifyDelegateOfWriteProgress(packet: packet)
            
            // 检查是否完成写入
            if packet.bytesDone == packet.buffer.count {
                completeCurrentWrite()
            } else {
                doWriteData() // 继续写入
            }
        }
    }
}

// MARK: - Disconnecting

extension GCDAsyncSocket {
    
    public func disconnect() {
        socketQueue.async {
            if self.flags.contains(.started) {
                self.closeWithError(nil)
            }
        }
    }
    
    public func disconnectAfterReading() {
        socketQueue.async {
            if self.flags.contains(.started) {
                self.flags.insert(.disconnectAfterReads)
                self.flags.insert(.forbidReadsWrites)
                self.maybeClose()
            }
        }
    }
    
    public func disconnectAfterWriting() {
        socketQueue.async {
            if self.flags.contains(.started) {
                self.flags.insert(.disconnectAfterWrites)
                self.flags.insert(.forbidReadsWrites)
                self.maybeClose()
            }
        }
    }
    
    private func maybeClose() {
        var shouldClose = false
        
        if flags.contains(.disconnectAfterReads) {
            if readQueue.isEmpty && currentRead == nil {
                if flags.contains(.disconnectAfterWrites) {
                    if writeQueue.isEmpty && currentWrite == nil {
                        shouldClose = true
                    }
                } else {
                    shouldClose = true
                }
            }
        } else if flags.contains(.disconnectAfterWrites) {
            if writeQueue.isEmpty && currentWrite == nil {
                shouldClose = true
            }
        }
        
        if shouldClose {
            closeWithError(nil)
        }
    }
    
    
}

// MARK: - SSL/TLS

extension GCDAsyncSocket {
    
    public func startTLS(_ settings: [String: Any]) {
        socketQueue.async {
            guard self.flags.contains(.started),
                  !self.flags.contains(.queuedTLS),
                  !self.flags.contains(.forbidReadsWrites) else {
                return
            }
            
            // 保存 TLS 设置
            self.tlsSettings = settings
            
            let packet = AsyncSpecialPacket(tlsSettings: settings)
            self.readQueue.append(packet)
            self.writeQueue.append(packet)
            
            self.flags.insert(.queuedTLS)
            
            self.maybeDequeueRead()
            self.maybeDequeueWrite()
        }
    }
    
    private class AsyncSpecialPacket {
        let tlsSettings: [String: Any]
        
        init(tlsSettings: [String: Any]) {
            self.tlsSettings = tlsSettings
        }
    }
}

// MARK: - Delegate Notifications

extension GCDAsyncSocket {
    
    private func notifyDelegateOfReadProgress(packet: AsyncReadPacket) {
        guard let delegate = delegate,
              delegateQueue != nil,
              delegate.responds(to: #selector(GCDAsyncSocketDelegate.socket(_:didReadPartialDataOfLength:tag:))) else {
            return
        }
        
        let tag = packet.tag
        let length = UInt(packet.bytesDone)
        
        delegateQueue?.async { [weak self] in
            guard let self = self else { return }
            delegate.socket?(self, didReadPartialDataOfLength: length, tag: tag)
        }
    }
    
    private func notifyDelegateOfWriteProgress(packet: AsyncWritePacket) {
        guard let delegate = delegate,
              delegateQueue != nil,
              delegate.responds(to: #selector(GCDAsyncSocketDelegate.socket(_:didWritePartialDataOfLength:tag:))) else {
            return
        }
        
        let tag = packet.tag
        let length = UInt(packet.bytesDone)
        
        delegateQueue?.async { [weak self] in
            guard let self = self else { return }
            delegate.socket?(self, didWritePartialDataOfLength: length, tag: tag)
        }
    }
    
    private func completeCurrentRead() {
        guard let packet = currentRead as? AsyncReadPacket else { return }
        
        let result: Data
        if packet.buffer.length > 0 {
            result = packet.buffer as Data
        } else {
            result = Data()
        }
        
        endCurrentRead()
        
        // Notify delegate
        if let delegate = delegate, let delegateQueue = delegateQueue {
            let tag = packet.tag
            
            delegateQueue.async { [weak self] in
                guard let self = self else { return }
                delegate.socket(self, didRead: result, withTag: tag)
            }
        }
        
        // Maybe dequeue next read
        maybeDequeueRead()
    }
    
    private func completeCurrentWrite() {
        guard let packet = currentWrite as? AsyncWritePacket else { return }
        
        endCurrentWrite()
        
        // Notify delegate
        if let delegate = delegate, let delegateQueue = delegateQueue {
            let tag = packet.tag
            
            delegateQueue.async { [weak self] in
                guard let self = self else { return }
                delegate.socket(self, didWriteDataWithTag: tag)
            }
        }
        
        // Maybe dequeue next write
        maybeDequeueWrite()
    }
    
    internal func endCurrentRead() {
        if let timer = readTimer {
            timer.cancel()
            readTimer = nil
        }
        currentRead = nil
    }
    
    internal func endCurrentWrite() {
        if let timer = writeTimer {
            timer.cancel()
            writeTimer = nil
        }
        currentWrite = nil
    }
}

// MARK: - Utilities

extension GCDAsyncSocket {

    private func resumeReadSource() {
        if flags.contains(.readSourceSuspended) {
            flags.remove(.readSourceSuspended)
            // TODO: Resume read source
        }
    }
    
    private func resumeWriteSource() {
        if flags.contains(.writeSourceSuspended) {
            flags.remove(.writeSourceSuspended)
            // TODO: Resume write source
        }
    }
    
    private func suspendReadSource() {
        if !flags.contains(.readSourceSuspended) {
            flags.insert(.readSourceSuspended)
            // TODO: Suspend read source
        }
    }
    
    private func suspendWriteSource() {
        if !flags.contains(.writeSourceSuspended) {
            flags.insert(.writeSourceSuspended)
            // TODO: Suspend write source
        }
    }
}

// MARK: - SSL Read/Write Functions

extension GCDAsyncSocket {
    
    private func ssl_readData(buffer: UnsafeMutableRawPointer, length: UnsafeMutablePointer<Int>) -> OSStatus {
        // Implementation of SSLReadFunction
        // This is called by SecureTransport to read encrypted data
        
        if socketFDBytesAvailable == 0 && sslPreBuffer?.availableBytes == 0 {
            // No data available to read
            resumeReadSource()
            length.pointee = 0
            return errSSLWouldBlock
        }
        
        var totalBytesRead = 0
        var done = false
        var socketError = false
        
        // Read from SSL pre buffer if available
        if let preBuffer = sslPreBuffer, preBuffer.availableBytes > 0 {
            let bytesToCopy = min(preBuffer.availableBytes, length.pointee)
            memcpy(buffer, preBuffer.readBuffer(), bytesToCopy)
            preBuffer.didRead(bytesToCopy)
            
            totalBytesRead += bytesToCopy
            done = totalBytesRead == length.pointee
        }
        
        // Read from socket if needed
        if !done && socketFDBytesAvailable > 0 {
            let socketFD = socket4FD != -1 ? socket4FD : socket6FD
            let bytesToRead = length.pointee - totalBytesRead
            
            let result = read(socketFD, buffer.advanced(by: totalBytesRead), bytesToRead)
            
            if result < 0 {
                if errno != EWOULDBLOCK {
                    socketError = true
                }
                socketFDBytesAvailable = 0
            } else if result == 0 {
                socketError = true
                socketFDBytesAvailable = 0
            } else {
                totalBytesRead += result
                
                if socketFDBytesAvailable > result {
                    socketFDBytesAvailable -= result
                } else {
                    socketFDBytesAvailable = 0
                }
            }
        }
        
        length.pointee = totalBytesRead
        
        if totalBytesRead > 0 {
            return noErr
        }
        
        if socketError {
            return errSSLClosedAbort
        }
        
        return errSSLWouldBlock
    }
    
    private func ssl_writeData(buffer: UnsafeRawPointer, length: UnsafeMutablePointer<Int>) -> OSStatus {
        // Implementation of SSLWriteFunction
        // This is called by SecureTransport to write encrypted data
        
        if !flags.contains(.socketCanAcceptBytes) {
            // Unable to write
            resumeWriteSource()
            length.pointee = 0
            return errSSLWouldBlock
        }
        
        let socketFD = socket4FD != -1 ? socket4FD : socket6FD
        let bytesToWrite = length.pointee
        
        let result = write(socketFD, buffer, bytesToWrite)
        
        if result < 0 {
            if errno != EWOULDBLOCK {
                return errSSLClosedAbort
            }
            
            flags.remove(.socketCanAcceptBytes)
            length.pointee = 0
            return errSSLWouldBlock
        }
        
        length.pointee = result
        
        if result == bytesToWrite {
            return noErr
        }
        
        return errSSLWouldBlock
    }
}
