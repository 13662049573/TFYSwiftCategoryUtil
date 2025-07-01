//
//  TFYNetstatManager.swift
//  SocialItem
//
//  Created by 田风有 on 2024/4/16.
//  用途：网络状态检测工具，支持 WiFi/蜂窝/无网络等类型判断。
//

import UIKit
import CoreTelephony
import SystemConfiguration

public class TFYNetstatManager {
    
    // MARK: - 网络类型枚举
    public enum NetworkType: String {
        case wifi = "WiFi"
        case cellular5G = "5G"
        case cellular4G = "4G"
        case cellular3G = "3G"
        case cellular2G = "2G"
        case notReachable = "notReachable"
    }
    
    // MARK: - 单例
    public static let shared = TFYNetstatManager()
    private init() {}
    
    // MARK: - 私有属性
    private let reachability: SCNetworkReachability? = {
        var zeroAddress = sockaddr_storage()
        bzero(&zeroAddress, MemoryLayout<sockaddr_storage>.size)
        zeroAddress.ss_len = __uint8_t(MemoryLayout<sockaddr_storage>.size)
        zeroAddress.ss_family = sa_family_t(AF_INET)
        
        return withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }
    }()
    
    private let cellularInfo = CTTelephonyNetworkInfo()
}

// MARK: - 公共方法
public extension TFYNetstatManager {
    /// 获取当前网络类型
    func getCurrentNetworkType() -> NetworkType {
        guard let reachability = reachability else {
            return .notReachable
        }
        
        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(reachability, &flags),
              flags.contains(.reachable),
              !flags.contains(.connectionRequired) else {
            return .notReachable
        }
        
        if flags.contains(.isWWAN) {
            return getCellularType()
        } else {
            return .wifi
        }
    }
    
    /// 检查是否有网络连接
    var isConnected: Bool {
        return getCurrentNetworkType() != .notReachable
    }
    
    /// 检查是否是WiFi连接
    var isWiFi: Bool {
        return getCurrentNetworkType() == .wifi
    }
    
    /// 检查是否是蜂窝网络连接
    var isCellular: Bool {
        let type = getCurrentNetworkType()
        return type == .cellular5G || type == .cellular4G || 
               type == .cellular3G || type == .cellular2G
    }
}

// MARK: - 私有方法
private extension TFYNetstatManager {
    /// 获取蜂窝网络类型
    func getCellularType() -> NetworkType {
        let radioTechnology: String? = {
            if #available(iOS 12.0, *) {
                return cellularInfo.serviceCurrentRadioAccessTechnology?.values.first
            } else {
                return cellularInfo.currentRadioAccessTechnology
            }
        }()
        
        guard let technology = radioTechnology else {
            return .notReachable
        }
        
        if #available(iOS 14.1, *) {
            if technology == CTRadioAccessTechnologyNR || 
               technology == CTRadioAccessTechnologyNRNSA {
                return .cellular5G
            }
        }
        
        switch technology {
        case CTRadioAccessTechnologyGPRS,
             CTRadioAccessTechnologyEdge,
             CTRadioAccessTechnologyCDMA1x:
            return .cellular2G
            
        case CTRadioAccessTechnologyWCDMA,
             CTRadioAccessTechnologyHSDPA,
             CTRadioAccessTechnologyHSUPA,
             CTRadioAccessTechnologyeHRPD,
             CTRadioAccessTechnologyCDMAEVDORev0,
             CTRadioAccessTechnologyCDMAEVDORevA,
             CTRadioAccessTechnologyCDMAEVDORevB:
            return .cellular3G
            
        case CTRadioAccessTechnologyLTE:
            return .cellular4G
            
        default:
            print("TFYNetstatManager: 未知蜂窝网络类型\(technology)")
            return .notReachable
        }
    }
}
