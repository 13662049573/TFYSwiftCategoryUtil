import Foundation

/// 网络通信管理器
public class NetworkManager: NSObject {
    
    // MARK: - Types
    
    /// 网络连接类型
    public enum ConnectionType {
        case tcp
        case udp 
    }
    
    /// 网络错误类型
    public enum NetworkError: Error {
        case invalidConfiguration
        case connectionFailed
        case sendFailed
        case receiveFailed
    }
    
    // MARK: - Properties
    
    private var tcpSocket: GCDAsyncSocket?
    private var udpSocket: GCDAsyncUdpSocket?
    private let type: ConnectionType
    private let delegateQueue = DispatchQueue(label: "com.network.manager.queue")
    
    // MARK: - Initialization
    
    public override init() {
        self.type = .tcp  // 默认使用 TCP
        super.init()
        setupSocket()
    }
    
    public init(type: ConnectionType) {
        self.type = type
        super.init()
        setupSocket()
    }
    
    private func setupSocket() {
        switch type {
        case .tcp:
            tcpSocket = GCDAsyncSocket(delegate: self, delegateQueue: delegateQueue)
        case .udp:
            udpSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: delegateQueue)
        }
    }
    
    // MARK: - Public Methods
    
    /// 连接到服务器
    /// - Parameters:
    ///   - host: 服务器地址
    ///   - port: 端口号
    ///   - timeout: 超时时间
    ///   - completion: 完成回调
    public func connect(to host: String, 
                       port: UInt16,
                       timeout: TimeInterval = 30.0,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        
        switch type {
        case .tcp:
            guard let socket = tcpSocket else {
                completion(.failure(NetworkError.invalidConfiguration))
                return
            }
            
            do {
                try socket.connect(toHost: host, onPort: port, withTimeout: timeout)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
            
        case .udp:
            guard let socket = udpSocket else {
                completion(.failure(NetworkError.invalidConfiguration))
                return
            }
            
            // UDP 不需要真正的连接,只需要设置目标地址和端口
            socket.sendData(Data(), toHost: host, port: port, withTimeout: timeout, tag: 0)
            completion(.success(()))
        }
    }
    
    /// 发送数据
    /// - Parameters:
    ///   - data: 要发送的数据
    ///   - timeout: 超时时间
    ///   - completion: 完成回调
    public func send(_ data: Data,
                    timeout: TimeInterval = 30.0,
                    completion: @escaping (Result<Void, Error>) -> Void) {
        
        switch type {
        case .tcp:
            guard let socket = tcpSocket else {
                completion(.failure(NetworkError.invalidConfiguration))
                return
            }
            
            socket.writeData(data, withTimeout: timeout, tag: 0)
            completion(.success(()))
            
        case .udp:
            guard let socket = udpSocket else {
                completion(.failure(NetworkError.invalidConfiguration))
                return
            }
            
            socket.sendData(data, withTimeout: timeout, tag: 0)
            completion(.success(()))
        }
    }
    
    /// 开始接收数据
    /// - Parameter completion: 接收到数据的回调
    public func startReceiving(completion: @escaping (Result<Data, Error>) -> Void) {
        switch type {
        case .tcp:
            guard let socket = tcpSocket else {
                completion(.failure(NetworkError.invalidConfiguration))
                return
            }
            
            socket.readData(withTimeout: -1, tag: 0)
            
        case .udp:
            guard let socket = udpSocket else {
                completion(.failure(NetworkError.invalidConfiguration))
                return
            }
            
            do {
                try socket.beginReceiving()
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    /// 断开连接
    public func disconnect() {
        switch type {
        case .tcp:
            tcpSocket?.disconnect()
        case .udp:
            udpSocket?.closeSockets()
        }
    }
    
    /// 配置 SSL/TLS
    /// - Parameter settings: SSL/TLS 设置
    public func configureTLS(settings: [String: Any]) {
        switch type {
        case .tcp:
            tcpSocket?.startTLS(settings)
        case .udp:
            // UDP 不支持 TLS
            break
        }
    }
}

// MARK: - GCDAsyncSocketDelegate
extension NetworkManager: GCDAsyncSocketDelegate {
    
    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("TCP connected to \(host):\(port)")
    }
    
    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("TCP received \(data.count) bytes")
    }
    
    public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        print("TCP data sent")
    }
    
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        if let error = err {
            print("TCP disconnected with error: \(error)")
        } else {
            print("TCP disconnected")
        }
    }
}

// MARK: - GCDAsyncUdpSocketDelegate
extension NetworkManager: GCDAsyncUdpSocketDelegate {
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        print("UDP connected")
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        if let error = error {
            print("UDP failed to connect: \(error)")
        }
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didReceiveData data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        print("UDP received \(data.count) bytes")
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        print("UDP data sent")
    }
    
    public func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        if let error = error {
            print("UDP closed with error: \(error)")
        } else {
            print("UDP closed")
        }
    }
} 
