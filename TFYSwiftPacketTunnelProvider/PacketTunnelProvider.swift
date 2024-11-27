//
//  PacketTunnelProvider.swift
//  TFYSwiftPacketTunnelProvider
//
//  Created by apple on 2024/11/27.
//

import NetworkExtension
import Foundation

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    // MARK: - Properties
    
    private var serverAddress: String?
    private var serverPort: Int?
    private var password: String?
    private var method: String?
    private var ssrProtocol: String?
    private var obfs: String?
    private var obfsParam: String?
    
    private var localSSRServer: TFYSSRLocalServer?
    private var performanceAnalyzer: TFYSSRPerformanceAnalyzer?
    private var memoryOptimizer: TFYSSRMemoryOptimizer?
    
    // MARK: - NEPacketTunnelProvider
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // 1. 获取配置
        guard let providerConfig = (protocolConfiguration as? NETunnelProviderProtocol)?.providerConfiguration else {
            completionHandler(NSError(domain: "VPNError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing provider configuration"]))
            return
        }
        
        // 2. 解析配置
        guard let serverAddress = providerConfig["serverAddress"] as? String,
              let serverPort = providerConfig["port"] as? Int,
              let password = providerConfig["password"] as? String,
              let method = providerConfig["method"] as? String,
              let ssrProtocol = providerConfig["protocol"] as? String,
              let obfs = providerConfig["obfs"] as? String else {
            completionHandler(NSError(domain: "VPNError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid configuration"]))
            return
        }
        
        self.serverAddress = serverAddress
        self.serverPort = serverPort
        self.password = password
        self.method = method
        self.ssrProtocol = ssrProtocol
        self.obfs = obfs
        self.obfsParam = providerConfig["obfsParam"] as? String
        
        // 3. 配置网络设置
        let networkSettings = createNetworkSettings()
        setTunnelNetworkSettings(networkSettings) { [weak self] error in
            if let error = error {
                completionHandler(error)
                return
            }
            
            // 4. 启动本地SSR服务器
            self?.startLocalServer(completionHandler: completionHandler)
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // 停止本地服务器
        localSSRServer?.stop {
            
        }
        localSSRServer = nil
        
        // 停止性能分析
        performanceAnalyzer?.stopMonitoring()
        performanceAnalyzer = nil
        
        // 清理内存
        memoryOptimizer?.optimize()
        memoryOptimizer = nil
        
        // 完成停止
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // 处理来自主应用的消息
        if let message = try? JSONDecoder().decode(VPNMessage.self, from: messageData) {
            handleVPNMessage(message, completionHandler: completionHandler)
        }
    }
    
    // MARK: - Private Methods
    
    private func createNetworkSettings() -> NEPacketTunnelNetworkSettings {
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: serverAddress!)
        
        // 配置DNS
        let dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "8.8.4.4"])
        dnsSettings.matchDomains = [""] // 匹配所有域名
        networkSettings.dnsSettings = dnsSettings
        
        // 配置IPv4
        let ipv4Settings = NEIPv4Settings(addresses: ["192.168.1.1"], subnetMasks: ["255.255.255.0"])
        let route = NEIPv4Route.default()
        route.gatewayAddress = "192.168.1.1"
        ipv4Settings.includedRoutes = [route]
        networkSettings.ipv4Settings = ipv4Settings
        
        // 配置MTU
        networkSettings.mtu = NSNumber(value: 1500)
        
        return networkSettings
    }
    
    private func startLocalServer(completionHandler: @escaping (Error?) -> Void) {
        // 创建SSR配置
        let config = TFYSSRConfiguration(
            serverAddress: serverAddress!,
            serverPort: serverPort!,
            password: password!,
            method: method,
            protocol: ssrProtocol,
            obfs: obfs,
            obfsParam: obfsParam
        
        )
        
        // 创建并启动本地服务器
        localSSRServer = TFYSSRLocalServer(config: config)
        localSSRServer?.delegate = self
        
        // 启动性能分析
        performanceAnalyzer = TFYSSRPerformanceAnalyzer()
        performanceAnalyzer?.start()
        
        // 启动内存优化
        memoryOptimizer = TFYSSRMemoryOptimizer()
        memoryOptimizer?.start()
        
        // 启动服务器
        localSSRServer?.start { [weak self] error in
            if let error = error {
                completionHandler(error as! Error)
                return
            }
            
            // 开始数据包处理
            self?.startPacketForwarding()
            completionHandler(nil)
        }
    }
    
    private func startPacketForwarding() {
        // 设置数据包读取回调
        packetFlow.readPackets { [weak self] packets, protocols in
            self?.handleIncomingPackets(packets, protocols: protocols)
        }
    }
    
    private func handleIncomingPackets(_ packets: [Data], protocols: [NSNumber]) {
        // 处理每个数据包
        for (index, packet) in packets.enumerated() {
            let protocolNumber = protocols[index]
            
            // 转发到本地SSR服务器
            localSSRServer?.processPacket(packet, protocolNumber: protocolNumber) { [weak self] processedPacket in
                if let processedPacket = processedPacket {
                    // 写回隧道
                    self?.packetFlow.writePackets([processedPacket], withProtocols: [protocolNumber])
                }
            }
        }
        
        // 继续读取下一批数据包
        startPacketForwarding()
    }
    
    private func handleVPNMessage(_ message: VPNMessage, completionHandler: ((Data?) -> Void)?) {
        switch message {
        case .getStatus:
            let status = localSSRServer?.status ?? .disconnected
            let response = ["status": status.rawValue]
            let responseData = try? JSONEncoder().encode(response)
            completionHandler?(responseData)
            
        case .getStatistics:
            let stats = performanceAnalyzer?.getCurrentStats()
            let responseData = try? JSONEncoder().encode(stats)
            completionHandler?(responseData)
            
        case .updateConfiguration(let newConfig):
            updateConfiguration(newConfig) { error in
                let response = ["success": error == nil]
                let responseData = try? JSONEncoder().encode(response)
                completionHandler?(responseData)
            }
        }
    }
    
    private func updateConfiguration(_ config: VPNConfiguration, completion: @escaping (Error?) -> Void) {
        // 停止当前服务器
        localSSRServer?.stop()
        
        // 更新配置
        serverAddress = config.serverAddress
        serverPort = config.port
        password = config.password
        method = config.method.rawValue
        ssrProtocol = config.ssrProtocol.rawValue
        obfs = config.obfs.rawValue
        obfsParam = config.obfsParam
        
        // 重新启动服务器
        startLocalServer { error in
            completion(error)
        }
    }
}

// MARK: - TFYSSRLocalServerDelegate

extension PacketTunnelProvider: TFYSSRLocalServerDelegate {
    func serverDidStart() {
        // 服务器启动成功
        NSLog("Local SSR server started")
    }
    
    func serverDidStop() {
        // 服务器停止
        NSLog("Local SSR server stopped")
    }
    
    func server(_ server: TFYSSRLocalServer, didFailWithError error: Error) {
        // 服务器错误
        NSLog("Local SSR server error: \(error.localizedDescription)")
        
        // 尝试重启服务器
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.startLocalServer { error in
                if let error = error {
                    NSLog("Failed to restart server: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Helper Types

enum VPNMessage: Codable {
    case getStatus
    case getStatistics
    case updateConfiguration(VPNConfiguration)
}
