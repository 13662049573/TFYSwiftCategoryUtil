////
////  ExampleViewController.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import UIKit
//
//// 示例使用代码
//class SSRAcceleratorExample {
//    
//    // SSR加速器实例
//    private let accelerator = TFYVPNAccelerator.shared
//    
//    // 启动SSR加速
//    func startSSR() {
//        let ssrConfig = VPNConfiguration(
//            vpnName: "SSR加速器",
//            serverAddress: "your.ssr.server.com",
//            port: 8388,
//            method: .aes_256_cfb,
//            password: "your_password",
//            ssrProtocol: .origin,
//            obfs: .tls1_2_ticket_auth,
//            obfsParam: "your.domain.com",
//            dnsSettings: DNSSettings(
//                servers: ["8.8.8.8", "8.8.4.4"],
//                searchDomains: ["local"],
//                useSplitDNS: true
//            ),
//            mtu: 1500,
//            enableCompression: true,
//            maxReconnectAttempts: 3,
//            enableLogging: true,
//            logLevel: .debug,
//            logRetentionDays: 7,
//            autoReconnect: true,
//            autoReconnectDelay: 3.0,
//            connectionTimeout: 30.0  // 30秒连接超时
//        )
//        
//        // 2. 配置加速器
//        accelerator.configure(with: ssrConfig) { [weak self] result in
//            switch result {
//            case .success:
//                print("SSR配置成功")
//                // 配置成功后立即连接
//                self?.accelerator.connect()
//                
//            case .failure(let error):
//                print("SSR配置失败: \(error.localizedDescription)")
//            }
//        }
//        
//        // 3. 设置代理
//        accelerator.delegate = self
//    }
//    
//    // 停止SSR加速
//    func stopSSR() {
//        accelerator.disconnect()
//    }
//    
//    // 重新连接
//    func reconnectSSR() {
//        accelerator.disconnect()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
//            self?.accelerator.connect()
//        }
//    }
//    
//    // 重置流量统计
//    func resetTrafficStats() {
//        accelerator.resetTrafficStats()
//    }
//}
//
//// MARK: - VPN代理实现
//extension SSRAcceleratorExample: TFYVPNAcceleratorDelegate {
//    
//    func vpnStatusDidChange(_ status: VPNStatus) {
//        switch status {
//        case .disconnected:
//            print("SSR已断开连接")
//        case .connecting:
//            print("SSR正在连接...")
//        case .connected:
//            print("SSR已连接")
//        case .disconnecting:
//            print("SSR正在断开连接...")
//        case .reasserting:
//            print("SSR正在重新连接...")
//        case .invalid:
//            print("SSR状态无效")
//        }
//    }
//    
//    func vpnDidFail(with error: VPNError) {
//        print("SSR错误: \(error.localizedDescription)")
//        // 处理特定错误
//        switch error {
//        case .networkUnavailable:
//            print("网络不可用，请检查网络连接")
//        case .configurationError(let message):
//            print("配置错误: \(message)")
//        case .connectionError(let message):
//            print("连接错误: \(message)")
//        case .authenticationError(let message):
//            print("认证错误: \(message)")
//        case .protocolError(let message):
//            print("协议错误:\(message)")
//            break
//        case .encryptionError(let message):
//            print("加密错误:\(message)")
//            break
//        case .obfuscationError(let message):
//            print("混淆错误:\(message)")
//            break
//        case .timeoutError:
//            print("超时错误")
//            break
//        case .unknownError(let message):
//            print("未知错误:\(message)")
//            break
//        case .maxReconnectAttemptsReached:
//            print("达到最大重连次数")
//        }
//    }
//    
//    func vpnDidConnect() {
//        print("SSR连接成功")
//        // 可以在这里更新UI或执行其他操作
//    }
//    
//    func vpnDidDisconnect() {
//        print("SSR已断开")
//        // 可以在这里更新UI或执行其他操作
//    }
//    
//    func vpnWillReconnect(attempt: Int, maxAttempts: Int) {
//        print("SSR正在尝试重连 (\(attempt)/\(maxAttempts))")
//    }
//    
//    func vpnDidUpdateTraffic(received: Int64, sent: Int64) {
//        // 格式化流量数据
//        let receivedMB = Double(received) / 1024 / 1024
//        let sentMB = Double(sent) / 1024 / 1024
//        
//        print(String(format: "流量统计 - 下载: %.2f MB, 上传: %.2f MB", receivedMB, sentMB))
//    }
//}
//
//// MARK: - 使用示例
//class ExampleViewController: UIViewController {
//    
//    private let ssrAccelerator = SSRAcceleratorExample()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//    }
//    
//    // 连接按钮点击事件
//    func connectButtonTapped(_ sender: UIButton) {
//        ssrAccelerator.startSSR()
//    }
//    
//    // 断开按钮点击事件
//    func disconnectButtonTapped(_ sender: UIButton) {
//        ssrAccelerator.stopSSR()
//    }
//    
//    // 重连按钮点击事件
//    func reconnectButtonTapped(_ sender: UIButton) {
//        ssrAccelerator.reconnectSSR()
//    }
//    
//    // 重置流量统计按钮点击事件
//    func resetStatsButtonTapped(_ sender: UIButton) {
//        ssrAccelerator.resetTrafficStats()
//    }
//}
//
