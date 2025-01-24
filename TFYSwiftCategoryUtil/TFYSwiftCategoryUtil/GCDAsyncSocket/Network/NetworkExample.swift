import Foundation

class NetworkExample {
    
    // TCP 客户端示例
    func tcpExample() {
        // 创建 TCP 网络管理器
        let tcpManager = NetworkManager(type: .tcp)
        
        // 连接服务器
        tcpManager.connect(to: "example.com", port: 8080) { result in
            switch result {
            case .success:
                print("TCP connected successfully")
                
                // 发送数据
                let data = "Hello TCP Server".data(using: .utf8)!
                tcpManager.send(data) { result in
                    switch result {
                    case .success:
                        print("TCP data sent successfully")
                    case .failure(let error):
                        print("TCP send failed: \(error)")
                    }
                }
                
                // 开始接收数据
                tcpManager.startReceiving { result in
                    switch result {
                    case .success(let data):
                        if let message = String(data: data, encoding: .utf8) {
                            print("TCP received: \(message)")
                        }
                    case .failure(let error):
                        print("TCP receive failed: \(error)")
                    }
                }
                
            case .failure(let error):
                print("TCP connection failed: \(error)")
            }
        }
        
        // 配置 TLS
        let tlsSettings = GCDAsyncSocket.SSLSettings.Builder()
            .isServer(false)
            .minimumProtocolVersion(.tlsProtocol12)
            .maximumProtocolVersion(.tlsProtocol13)
            .build()
        
        tcpManager.configureTLS(settings: tlsSettings)
    }
    
    // UDP 客户端示例
    func udpExample() {
        // 创建 UDP 网络管理器
        let udpManager = NetworkManager(type: .udp)
        
        // 设置目标服务器
        udpManager.connect(to: "example.com", port: 8081) { result in
            switch result {
            case .success:
                print("UDP target set successfully")
                
                // 发送数据
                let data = "Hello UDP Server".data(using: .utf8)!
                udpManager.send(data) { result in
                    switch result {
                    case .success:
                        print("UDP data sent successfully")
                    case .failure(let error):
                        print("UDP send failed: \(error)")
                    }
                }
                
                // 开始接收数据
                udpManager.startReceiving { result in
                    switch result {
                    case .success(let data):
                        if let message = String(data: data, encoding: .utf8) {
                            print("UDP received: \(message)")
                        }
                    case .failure(let error):
                        print("UDP receive failed: \(error)")
                    }
                }
                
            case .failure(let error):
                print("UDP target setting failed: \(error)")
            }
        }
    }
    
    // 使用示例
    func example() {
        // TCP 示例
        tcpExample()
        
        // UDP 示例
        udpExample()
    }
} 