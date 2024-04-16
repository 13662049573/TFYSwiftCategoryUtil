//
//  TFYNetstatManager.swift
//  SocialItem
//
//  Created by 田风有 on 2024/4/16.
//

import UIKit
import CoreTelephony
import SystemConfiguration

public class TFYNetstatManager: NSObject {
    /// 无网络返回字样
    private static var notReachable: String {
            get {
                return "notReachable"
            }
      }

    /// 获取网络类型
    static func getNetworkType() -> String {
            var zeroAddress = sockaddr_storage()
            bzero(&zeroAddress, MemoryLayout<sockaddr_storage>.size)
            zeroAddress.ss_len = __uint8_t(MemoryLayout<sockaddr_storage>.size)
            zeroAddress.ss_family = sa_family_t(AF_INET)
            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { address in
                    SCNetworkReachabilityCreateWithAddress(nil, address)
                }
            }
            guard let defaultRouteReachability = defaultRouteReachability else {
                return notReachable
            }
            var flags = SCNetworkReachabilityFlags()
            let didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags)
            
            guard didRetrieveFlags == true,
                  (flags.contains(.reachable) && !flags.contains(.connectionRequired)) == true
            else {
                return notReachable
            }
            if flags.contains(.connectionRequired) {
                return notReachable
            } else if flags.contains(.isWWAN) {
                return self.cellularType()
            } else {
                return "WiFi"
            }
        }
        
        /// 获取蜂窝数据类型
        private static func cellularType() -> String {
            let info = CTTelephonyNetworkInfo()
            var status: String
            
            if #available(iOS 12.0, *) {
                guard let dict = info.serviceCurrentRadioAccessTechnology,
                      let firstKey = dict.keys.first,
                      let statusTemp = dict[firstKey] else {
                    return notReachable
                }
                status = statusTemp
            } else {
                guard let statusTemp = info.currentRadioAccessTechnology else {
                    return notReachable
                }
                status = statusTemp
            }
            
            if #available(iOS 14.1, *) {
                if status == CTRadioAccessTechnologyNR || status == CTRadioAccessTechnologyNRNSA {
                    return "5G"
                }
            }
            
            switch status {
            case CTRadioAccessTechnologyGPRS,
                CTRadioAccessTechnologyEdge,
            CTRadioAccessTechnologyCDMA1x:
                return "2G"
            case CTRadioAccessTechnologyWCDMA,
                CTRadioAccessTechnologyHSDPA,
                CTRadioAccessTechnologyHSUPA,
                CTRadioAccessTechnologyeHRPD,
                CTRadioAccessTechnologyCDMAEVDORev0,
                CTRadioAccessTechnologyCDMAEVDORevA,
            CTRadioAccessTechnologyCDMAEVDORevB:
                return "3G"
            case CTRadioAccessTechnologyLTE:
                return "4G"
            default:
                return notReachable
            }
        }
}
