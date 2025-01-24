import Foundation
import Darwin

// MARK: - Constants

let IsOnSocketQueueOrTargetQueueKey = DispatchSpecificKey<Void>()
let SOCKET_NULL: Int32 = -1

// MARK: - Socket Flags
extension GCDAsyncUdpSocket {
    struct SocketFlags: OptionSet {
        let rawValue: UInt32
        
        static let didCreateSockets = SocketFlags(rawValue: 1 << 0)
        static let didBind = SocketFlags(rawValue: 1 << 1)
        static let connecting = SocketFlags(rawValue: 1 << 2)
        static let didConnect = SocketFlags(rawValue: 1 << 3)
        static let receiveOnce = SocketFlags(rawValue: 1 << 4)
        static let receiveContinuous = SocketFlags(rawValue: 1 << 5)
        static let ipv4Deactivated = SocketFlags(rawValue: 1 << 6)
        static let ipv6Deactivated = SocketFlags(rawValue: 1 << 7)
        static let send4SourceSuspended = SocketFlags(rawValue: 1 << 8)
        static let send6SourceSuspended = SocketFlags(rawValue: 1 << 9)
        static let receive4SourceSuspended = SocketFlags(rawValue: 1 << 10)
        static let receive6SourceSuspended = SocketFlags(rawValue: 1 << 11)
        static let sock4CanAcceptBytes = SocketFlags(rawValue: 1 << 12)
        static let sock6CanAcceptBytes = SocketFlags(rawValue: 1 << 13)
        static let forbidSendReceive = SocketFlags(rawValue: 1 << 14)
        static let closeAfterSends = SocketFlags(rawValue: 1 << 15)
        static let flipFlop = SocketFlags(rawValue: 1 << 16)
        
        init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
    
    struct SocketConfig: OptionSet {
        let rawValue: UInt16
        
        static let ipv4Disabled = SocketConfig(rawValue: 1 << 0)
        static let ipv6Disabled = SocketConfig(rawValue: 1 << 1)
        static let preferIPv4 = SocketConfig(rawValue: 1 << 2)
        static let preferIPv6 = SocketConfig(rawValue: 1 << 3)
        
        init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Error Domain & Codes

public let GCDAsyncUdpSocketErrorDomain = "GCDAsyncUdpSocketErrorDomain"
public let GCDAsyncUdpSocketQueueName = "GCDAsyncUdpSocket"
public let GCDAsyncUdpSocketThreadName = "GCDAsyncUdpSocket-CFStream"

public enum GCDAsyncUdpSocketError: Int {
    case noError = 0
    case badConfigError
    case badParamError  
    case sendTimeoutError
    case closedError
    case otherError
}

// MARK: - Delegate Protocol

@objc public protocol GCDAsyncUdpSocketDelegate {
    @objc optional func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data)
    @objc optional func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?)
    @objc optional func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int)
    @objc optional func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?)
    @objc optional func udpSocket(_ sock: GCDAsyncUdpSocket, didReceiveData data: Data, fromAddress address: Data, withFilterContext filterContext: Any?)
    @objc optional func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?)
}

// MARK: - Filter Types

public typealias GCDAsyncUdpSocketReceiveFilterBlock = (_ data: Data, _ address: Data, _ context: UnsafeMutablePointer<Any?>) -> Bool
public typealias GCDAsyncUdpSocketSendFilterBlock = (_ data: Data, _ address: Data, _ tag: Int) -> Bool

// MARK: - Main Class

public class GCDAsyncUdpSocket: NSObject {
    
    // MARK: - Properties
    
    public weak var delegate: GCDAsyncUdpSocketDelegate?
    public var delegateQueue: DispatchQueue?
    
    internal var receiveFilterBlock: GCDAsyncUdpSocketReceiveFilterBlock?
    internal var receiveFilterQueue: DispatchQueue?
    internal var receiveFilterAsync = false
    
    internal var sendFilterBlock: GCDAsyncUdpSocketSendFilterBlock?
    internal var sendFilterQueue: DispatchQueue?
    internal var sendFilterAsync = false
    
    var flags: SocketFlags = []
    var config: SocketConfig = []
    
    internal var max4ReceiveSize: UInt16 = 65535
    internal var max6ReceiveSize: UInt32 = 65535
    internal var maxSendSize: UInt16 = 65535
    
    internal var socket4FD: Int32 = SOCKET_NULL
    internal var socket6FD: Int32 = SOCKET_NULL
    
    internal let socketQueue: DispatchQueue
    
    internal var send4Source: DispatchSource?
    internal var send6Source: DispatchSource?
    internal var receive4Source: DispatchSource?
    internal var receive6Source: DispatchSource?
    internal var sendTimer: DispatchSource?
    
    internal var currentSend: GCDAsyncUdpSendPacket?
    internal var sendQueue: [GCDAsyncUdpSendPacket] = []
    
    internal var socket4FDBytesAvailable: UInt = 0
    internal var socket6FDBytesAvailable: UInt = 0
    
    internal var pendingFilterOperations: UInt32 = 0
    
    internal var cachedLocalAddress4: Data?
    internal var cachedLocalHost4: String?
    internal var cachedLocalPort4: UInt16 = 0
    
    internal var cachedLocalAddress6: Data?
    internal var cachedLocalHost6: String?
    internal var cachedLocalPort6: UInt16 = 0
    
    internal var cachedConnectedAddress: Data?
    internal var cachedConnectedHost: String?
    internal var cachedConnectedPort: UInt16 = 0
    internal var cachedConnectedFamily: Int32 = 0
    
    internal var userData: Any?
    
    // MARK: - Initialization
    
    public override init() {
        socketQueue = GCDAsyncUdpSocket.newSocketQueue()
        super.init()
        
        // 设置队列特定键
        socketQueue.setSpecific(key: IsOnSocketQueueOrTargetQueueKey, value: ())
    }
    
    public init(delegate: GCDAsyncUdpSocketDelegate?, delegateQueue: DispatchQueue?) {
        self.socketQueue = GCDAsyncUdpSocket.newSocketQueue()
        super.init()
        
        // 设置队列特定键
        socketQueue.setSpecific(key: IsOnSocketQueueOrTargetQueueKey, value: ())
        
        self.delegate = delegate
        self.delegateQueue = delegateQueue
    }
    
    private static func newSocketQueue() -> DispatchQueue {
        return DispatchQueue(label: GCDAsyncUdpSocketQueueName)
    }
    
    deinit {
        // Close socket if needed
        if socket4FD != SOCKET_NULL || socket6FD != SOCKET_NULL {
            closeWithError(nil)
        }
    }
    
    internal func closeWithError(_ error: Error?) {
        // 如果当前有发送操作，结束它
        if currentSend != nil {
            endCurrentSend()
        }
        
        // 清空发送队列
        sendQueue.removeAll()
        
        // 检查是否需要通知代理
        let shouldCallDelegate = flags.contains(.didCreateSockets)
        
        // 关闭所有 socket 和资源
        closeSockets()
        
        // 清除所有标位
        flags = []
        
        // 通知代理
        if shouldCallDelegate {
            notifyDidClose(withError: error)
        }
    }
    
    internal func endCurrentSend() {
        if let timer = sendTimer {
            timer.cancel()
            sendTimer = nil
        }
        currentSend = nil
    }
    
    public func closeSockets() {
        if socket4FD != SOCKET_NULL {
            Darwin.close(socket4FD)
            socket4FD = SOCKET_NULL
        }
        
        if socket6FD != SOCKET_NULL {
            Darwin.close(socket6FD)
            socket6FD = SOCKET_NULL
        }
        
        // 清理发送源
        if let source = send4Source {
            source.cancel()
            send4Source = nil
        }
        if let source = send6Source {
            source.cancel()
            send6Source = nil
        }
        
        // 清理接收源
        if let source = receive4Source {
            source.cancel()
            receive4Source = nil
        }
        if let source = receive6Source {
            source.cancel()
            receive6Source = nil
        }
    }
    
    private func notifyDidClose(withError error: Error?) {
        guard let delegate = delegate, let delegateQueue = delegateQueue else {
            return
        }
        
        delegateQueue.async {
            delegate.udpSocketDidClose?(self, withError: error)
        }
    }
    
    // 在 GCDAsyncUdpSocket 类中添加
    internal func preOp(_ error: inout Error?) -> Bool {
        // 必须设置代理
        if delegate == nil {
            error = badConfigError("Attempting to use socket without a delegate. Set a delegate first.")
            return false
        }
        
        // 必须设置代理队列
        if delegateQueue == nil {
            error = badConfigError("Attempting to use socket without a delegate queue. Set a delegate queue first.")
            return false
        }
        
        return true
    }
    
    // 同时添加 preJoin 方法，用于多播操作的预检查
    internal func preJoin(_ error: inout Error?) -> Bool {
        // 首先执行基本检查
        if !preOp(&error) {
            return false
        }
        
        // 检查是否已经创建了 socket
        if (flags.rawValue & SocketFlags.didCreateSockets.rawValue) == 0 {
            do {
                try createSockets()
            } catch let err {
                error = err
                return false
            }
        }
        
        return true
    }
    
    // 添加 createSockets 方法
    internal func createSockets() throws {
        // 这里需要实现创建 socket 的逻辑
        // 暂时留空，后续实现
        // 成功创建后设置标志位
        flags.insert(.didCreateSockets)
    }
    
    // MARK: - Source Management
    
    internal func suspendReceive4Source() {
        if let source = receive4Source {
            source.suspend()
            flags.insert(.receive4SourceSuspended)
        }
    }
    
    internal func suspendReceive6Source() {
        if let source = receive6Source {
            source.suspend()
            flags.insert(.receive6SourceSuspended)
        }
    }
    
    internal func resumeReceive4Source() {
        if let source = receive4Source {
            source.resume()
            flags.remove(.receive4SourceSuspended)
        }
    }
    
    internal func resumeReceive6Source() {
        if let source = receive6Source {
            source.resume()
            flags.remove(.receive6SourceSuspended)
        }
    }
    
    internal func suspendSend4Source() {
        if let source = send4Source {
            source.suspend()
            flags.insert(.send4SourceSuspended)
        }
    }
    
    internal func suspendSend6Source() {
        if let source = send6Source {
            source.suspend()
            flags.insert(.send6SourceSuspended)
        }
    }
    
    internal func resumeSend4Source() {
        if let source = send4Source {
            source.resume()
            flags.remove(.send4SourceSuspended)
        }
    }
    
    internal func resumeSend6Source() {
        if let source = send6Source {
            source.resume()
            flags.remove(.send6SourceSuspended)
        }
    }
    
    // 在 GCDAsyncUdpSocket 类中添加
    internal func maybeConnect() {
        guard let specialPacket = currentSend as? GCDAsyncUdpSpecialPacket else {
            return
        }
        
        flags.insert(.connecting)
        
        // 如果已经在解析中，等待解析完成
        if specialPacket.resolveInProgress {
            if flags.contains(.sock4CanAcceptBytes) {
                suspendSend4Source()
            }
            if flags.contains(.sock6CanAcceptBytes) {
                suspendSend6Source()
            }
            return
        }
        
        // 如果解析出错，通知错误
        if let error = specialPacket.resolveError {
            notifyDidNotConnect(error)
            flags.remove(.connecting)
            endCurrentSend()
            maybeDequeueSend()
            return
        }
        
        // 如果没有地址，报错
        guard let addresses = specialPacket.resolvedAddresses, !addresses.isEmpty else {
            notifyDidNotConnect(badParamError("No valid addresses to connect to."))
            flags.remove(.connecting)
            endCurrentSend()
            maybeDequeueSend()
            return
        }
        
        // 尝试连接到合适的地址
        do {
            let (address, family) = try getAddress(from: addresses)
            var error: Error?
            
            if family == AF_INET {
                if !connectWithAddress4(address, error: &error) {
                    notifyDidNotConnect(error)
                    flags.remove(.connecting)
                    endCurrentSend()
                    maybeDequeueSend()
                }
            } else {
                if !connectWithAddress6(address, error: &error) {
                    notifyDidNotConnect(error)
                    flags.remove(.connecting)
                    endCurrentSend()
                    maybeDequeueSend()
                }
            }
        } catch {
            notifyDidNotConnect(error)
            flags.remove(.connecting)
            endCurrentSend()
            maybeDequeueSend()
        }
    }
    
    private func connectWithAddress4(_ address4: Data, error: inout Error?) -> Bool {
        // 确保地址大小正确
        guard address4.count >= MemoryLayout<sockaddr_in>.size else {
            error = badParamError("Invalid address")
            return false
        }
        
        // 如果 IPv4 被禁用，报错
        if config.contains(.ipv4Disabled) {
            error = badConfigError("IPv4 has been disabled")
            return false
        }
        
        // 如果需要，创建 socket
        if socket4FD == SOCKET_NULL {
            socket4FD = Darwin.socket(AF_INET, SOCK_DGRAM, 0)
            if socket4FD == SOCKET_NULL {
                error = errnoError("Error in socket() function")
                return false
            }
        }
        
        // 进行连接
        let result = address4.withUnsafeBytes { buffer in
            connect(socket4FD, buffer.bindMemory(to: sockaddr.self).baseAddress, socklen_t(address4.count))
        }
        
        if result != 0 {
            error = errnoError("Error in connect() function")
            return false
        }
        
        // 连接成功，关闭 IPv6 socket
        closeSocket6()
        flags.insert(.ipv6Deactivated)
        
        // 缓存连接信息
        cachedConnectedAddress = address4
        cachedConnectedFamily = AF_INET
        
        // 通知连接成功
        flags.insert(.didConnect)
        flags.remove(.connecting)
        notifyDidConnect(to: address4)
        
        endCurrentSend()
        maybeDequeueSend()
        
        return true
    }
    
    private func connectWithAddress6(_ address6: Data, error: inout Error?) -> Bool {
        // 确保地址大小正确
        guard address6.count >= MemoryLayout<sockaddr_in6>.size else {
            error = badParamError("Invalid address")
            return false
        }
        
        // 如果 IPv6 被禁用，报错
        if config.contains(.ipv6Disabled) {
            error = badConfigError("IPv6 has been disabled")
            return false
        }
        
        // 如果需要，创建 socket
        if socket6FD == SOCKET_NULL {
            socket6FD = Darwin.socket(AF_INET6, SOCK_DGRAM, 0)
            if socket6FD == SOCKET_NULL {
                error = errnoError("Error in socket() function")
                return false
            }
        }
        
        // 进行连接
        let result = address6.withUnsafeBytes { buffer in
            connect(socket6FD, buffer.bindMemory(to: sockaddr.self).baseAddress, socklen_t(address6.count))
        }
        
        if result != 0 {
            error = errnoError("Error in connect() function")
            return false
        }
        
        // 连接成功，关闭 IPv4 socket
        closeSocket4()
        flags.insert(.ipv4Deactivated)
        
        // 缓存连接信息
        cachedConnectedAddress = address6
        cachedConnectedFamily = AF_INET6
        
        // 通知连接成功
        flags.insert(.didConnect)
        flags.remove(.connecting)
        notifyDidConnect(to: address6)
        
        endCurrentSend()
        maybeDequeueSend()
        
        return true
    }
    
    private func notifyDidConnect(to address: Data) {
        guard let delegate = delegate, let delegateQueue = delegateQueue else {
            return
        }
        
        delegateQueue.async {
            delegate.udpSocket?(self, didConnectToAddress: address)
        }
    }
    
    private func notifyDidNotConnect(_ error: Error?) {
        guard let delegate = delegate, let delegateQueue = delegateQueue else {
            return
        }
        
        delegateQueue.async {
            delegate.udpSocket?(self, didNotConnect: error)
        }
    }
    
    // 在 GCDAsyncUdpSocket 类中添加
    internal func notifyDidSendDataWithTag(_ tag: Int) {
        guard let delegate = delegate, let delegateQueue = delegateQueue else {
            return
        }
        
        delegateQueue.async {
            delegate.udpSocket?(self, didSendDataWithTag: tag)
        }
    }
    
    internal func notifyDidNotSendDataWithTag(_ tag: Int, error: Error?) {
        guard let delegate = delegate, let delegateQueue = delegateQueue else {
            return
        }
        
        delegateQueue.async {
            delegate.udpSocket?(self, didNotSendDataWithTag: tag, dueToError: error)
        }
    }
    
    internal func setupSendTimer(timeout: TimeInterval) {
        // 创建一个定时器源
        let timer = DispatchSource.makeTimerSource(queue: socketQueue)
        
        // 设置定时器
        timer.schedule(deadline: .now() + timeout)
        
        // 设置定时器事件处理
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            
            // 定时器触发，说明发送超时
            if let currentSend = self.currentSend {
                self.notifyDidNotSendDataWithTag(currentSend.tag, error: self.sendTimeoutError())
                self.endCurrentSend()
                self.maybeDequeueSend()
            }
        }
        
        // 设置取消处理
        timer.setCancelHandler { [weak self] in
            self?.sendTimer = nil
        }
        
        // 保存定时器并启动
        sendTimer = timer as? DispatchSource
        timer.resume()
    }
} 
