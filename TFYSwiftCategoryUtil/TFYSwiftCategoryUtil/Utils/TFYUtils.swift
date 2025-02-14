//
//  TFYUtils.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/12.
//

import Foundation
import UIKit
import StoreKit
import SystemConfiguration.CaptiveNetwork

/// 常用文件路径
public struct FilePath {
    /// 文档目录路径
    public static let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as NSString
    
    /// 缓存目录路径
    public static let cache = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last! as NSString
    
    /// 临时目录路径
    public static let temp = NSTemporaryDirectory() as NSString
}

// MARK: - 工具类
public struct TFYUtils {
    
    // MARK: - JSON操作
    
    /// 读取本地JSON文件
    /// - Parameter name: JSON文件名(不含扩展名)
    /// - Returns: 解析后的字典
    public static func getJSON(name: String) -> NSDictionary {
        guard let path = Bundle.main.path(forResource: name, ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let jsonData = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary else {
            print("读取本地JSON数据失败!")
            return NSDictionary()
        }
        return jsonData
    }
    
    // MARK: - 日志功能
    
    /// 自定义日志打印
    /// - Parameters:
    ///   - msg: 打印内容
    ///   - file: 文件路径
    ///   - line: 所在行
    ///   - column: 所在列
    ///   - fn: 函数名
    public static func log(_ msg: Any...,
                          file: NSString = #file,
                          line: Int = #line,
                          column: Int = #column,
                          fn: String = #function) {
        #if DEBUG
        // 构建日志内容
        let content = buildLogContent(msg: msg, file: file, line: line, column: column, fn: fn)
        // 打印到控制台
        print(content)
        // 写入日志文件
        writeToLogFile(content: content)
        #endif
    }
    
    /// 构建日志内容
    private static func buildLogContent(msg: [Any],
                                      file: NSString,
                                      line: Int,
                                      column: Int,
                                      fn: String) -> String {
        let msgStr = msg.map { "\($0)" }.joined(separator: "\n")
        return """
        ----------------######################----begin🚀----##################----------------
        当前时间：\(Date())
        文件路径：\(file)
        文件名：\(file.lastPathComponent)
        第 \(line) 行
        第 \(column) 列
        函数名：\(fn)
        打印内容：
        \(msgStr)
        ----------------######################----end😊----##################----------------
        """
    }
    
    /// 写入日志文件
    private static func writeToLogFile(content: String) {
        let logPath = FilePath.cache.appendingPathComponent("log.txt")
        let logURL = URL(fileURLWithPath: logPath)
        
        // 确保文件存在
        if !FileManager.default.fileExists(atPath: logPath) {
            FileManager.default.createFile(atPath: logPath, contents: nil)
        }
        
        // 追加写入
        if let handle = try? FileHandle(forWritingTo: logURL) {
            handle.seekToEndOfFile()
            handle.write("\n\(content)".data(using: .utf8)!)
            handle.closeFile()
        }
    }
    
    // MARK: - 系统功能
    
    /// 拨打电话
    /// - Parameters:
    ///   - phoneNumber: 电话号码
    ///   - complete: 完成回调
    public static func callPhone(phoneNumber: String, complete: @escaping ((Bool) -> Void)) {
        guard let encodedPhone = ("tel://" + phoneNumber).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedPhone),
              UIApplication.shared.canOpenURL(url) else {
            complete(false)
            return
        }
        openUrl(url: url, complete: complete)
    }
    
    /// App Store相关操作
    public struct AppStore {
        /// 跳转到App详情页
        /// - Parameters:
        ///   - vc: 当前控制器
        ///   - appId: App ID
        public static func showAppDetail(from vc: UIViewController, appId: String) {
            guard !appId.isEmpty else { return }
            
            let productVC = SKStoreProductViewController()
            productVC.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: appId]) { success, error in
                if !success {
                    productVC.dismiss(animated: true)
                }
            }
            vc.present(productVC, animated: true)
        }
        
        /// 前往App Store评分
        /// - Parameter appId: App ID
        public static func rateApp(appId: String) {
            let urlString = "https://itunes.apple.com/cn/app/id\(appId)?mt=12"
            guard let url = URL(string: urlString) else { return }
            TFYUtils.openUrl(url: url) { _ in }
        }
        
        /// 检查App更新
        /// - Parameters:
        ///   - appId: App ID
        ///   - completion: 完成回调(是否有更新,新版本号)
        public static func checkUpdate(appId: String, completion: @escaping (Bool, String?) -> Void) {
            let url = URL(string: "https://itunes.apple.com/lookup?id=\(appId)")!
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                DispatchQueue.main.async {
                    guard let data = data, error == nil,
                          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let results = json["results"] as? [[String: Any]],
                          let firstResult = results.first,
                          let storeVersion = firstResult["version"] as? String,
                          let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                        completion(false, nil)
                        return
                    }
                    
                    let hasUpdate = storeVersion.compare(currentVersion, options: .numeric) == .orderedDescending
                    completion(hasUpdate, storeVersion)
                }
            }.resume()
        }
    }
    
    // MARK: - 网络相关
    
    /// 获取设备网络信息
    public struct Network {
        /// 获取本机IP地址
        public static func getIPAddress() -> String? {
            var addresses = [String]()
            var ifaddr: UnsafeMutablePointer<ifaddrs>?
            
            guard getifaddrs(&ifaddr) == 0 else { return nil }
            defer { freeifaddrs(ifaddr) }
            
            var ptr = ifaddr
            while ptr != nil {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                            if let address = String(validatingUTF8: hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            
            return addresses.first
        }
        
        /// 获取WiFi信息
        /// - Returns: (WiFi名称, MAC地址)
        public static func getWiFiInfo() -> (name: String?, macAddress: String?) {
            guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
                return (nil, nil)
            }
            
            for interface in interfaces {
                guard let info = CFBridgingRetain(CNCopyCurrentNetworkInfo(interface as CFString)) as? [String: Any] else {
                    continue
                }
                return (info["SSID"] as? String, info["BSSID"] as? String)
            }
            
            return (nil, nil)
        }
    }
    
    // MARK: - 应用相关
    
    /// 打开系统设置
    public static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openUrl(url: url) { _ in }
    }
    
    /// 退出应用(模拟Home键)
    public static func exitApp() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
    }
    
    /// 通用URL打开方法
    /// - Parameters:
    ///   - url: URL
    ///   - complete: 完成回调
    public static func openUrl(url: URL, complete: @escaping ((Bool) -> Void)) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: complete)
        } else {
            complete(UIApplication.shared.openURL(url))
        }
    }
}
