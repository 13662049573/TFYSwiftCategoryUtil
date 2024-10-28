//
//  UIApplication+Chain.swift
//  TFYSwiftCategoryUtil
//
//  Created by 田风有 on 2022/5/18.
//

import Foundation
import UIKit

public extension TFY where Base: UIApplication {
    
    // cs.appDelegate: current AppDelegate
    static var appDelegate: UIApplicationDelegate {
        return UIApplication.shared.delegate!
    }
    
    // cs.currentViewController: current UIViewController
    static var currentViewController: UIViewController {
        let window = self.appDelegate.window
        var viewController = window!!.rootViewController
        while ((viewController?.presentedViewController) != nil) {
            viewController = viewController?.presentedViewController
            if ((viewController?.isKind(of: UINavigationController.classForCoder())) == true) {
                viewController = (viewController as! UINavigationController).visibleViewController
            } else if ((viewController?.isKind(of: UITabBarController.classForCoder())) == true) {
                viewController = (viewController as! UITabBarController).selectedViewController
            }
        }
        return viewController!
    }
}

// MARK: - App Version Related
public extension TFY where Base: UIApplication {
    /**
     'Documents' folder in app`s sandbox
     */
    static var documentsURL: URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    }
    static var documentsPath: String? {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    }
    
    /**
     'Caches' folder in this app`s sandbox
     */
    static var cachesURL: URL? {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last
    }
    static var cachesPath: String? {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    }
    
    /**
     'Library' folder in this app`s sandbox
     */
    static var libraryURL: URL? {
        return FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last
    }
    static var libraryPath: String? {
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first
    }
    
    /**
     Application`s Bundle Name
     */
    static var appBundleName: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
    }
    
    /// Application`s Bundle ID e.g 'com.yamex.app'
    static var appBundleID: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String
    }
    
    /// Application`s Bundle Version e.b '1.0.0'
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    /// Application`s Bundle Version e.b '12'
    static var appBuildVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }
    
}


// MARK: - snapShot

public extension UIApplication {
    
    static func snapShot(_ inView: UIView) -> UIImage {
        UIGraphicsBeginImageContext(inView.bounds.size)
        inView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let snapShot: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return snapShot
    }
    
    /// app商店链接
    static func appUrlWithID(_ appStoreID: String) -> String {
        let appStoreUrl = "itms-apps://itunes.apple.com/app/id\(appStoreID)?mt=8"
        return appStoreUrl
    }
    
    /// app详情链接
    static func appDetailUrlWithID(_ appStoreID: String) -> String {
        let detailUrl = "http://itunes.apple.com/cn/lookup?id=\(appStoreID)"
        return detailUrl
    }
    
    /// 版本升级
    static func updateVersionShow(appStoreID: String, isForce: Bool = false) {
        UIApplication.updateVersion(appStoreID: appStoreID) { (dic, appStoreVer, releaseNotes, isUpdate) in
            if isUpdate == false {
                return
            }
            DispatchQueue.main.async {
                let titles = isForce == false ? ["立即升级", "取消"] : ["立即升级"]
                //富文本效果
                let paraStyle = NSMutableParagraphStyle()
                    .tfy
                    .lineBreakModeChain(.byCharWrapping)
                    .lineSpacingChain(5)
                    .alignmentChain(.left)
                    .build
                
                let title = "新版本 v\(appStoreVer)"
                let message = "\n\(releaseNotes)"
                UIAlertController(title: title, message: message, preferredStyle: .alert)
                    .addActionTitles(titles) { (alertVC, action) in
                        if action.title == "立即升级" {
                            //去升级
                            UIApplication.openURLString(UIApplication.appUrlWithID(appStoreID))
                        }
                    }
                    .setTitleColor(UIColor.black)
                    .setMessageParaStyle(paraStyle)
                    .present()
            }
        }
    }
    
    /// 版本升级
    static func updateVersion(appStoreID: String, block:@escaping (([String: Any], String, String, Bool)->Void)) {
//        let path = "http://itunes.apple.com/cn/lookup?id=\(appStoreID)"
        let path =  UIApplication.appDetailUrlWithID(appStoreID)
        let request = URLRequest(url:NSURL(string: path)! as URL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 6)
        let dataTask = URLSession.shared.dataTask(with: request) { (data, respone, error) in
            guard let data = data,
                  let dic = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] else {
                print("字典不能为空")
                return
            }
            
            guard let resultCount = dic["resultCount"] as? NSNumber,
                  resultCount.intValue == 1 else {
                print("resultCount错误")
                return
            }
            
            guard let list = dic["results"] as? NSArray,
                let dicInfo = list[0] as? [String: Any],
                let appStoreVer = dicInfo["version"] as? String
            else {
                print("dicInfo错误")
                return
            }
                        
            let releaseNotes: String = (dicInfo["releaseNotes"] as? String) ?? ""
            let isUpdate = appStoreVer.compare(UIApplication.appVer, options: .numeric, range: nil, locale: nil) == .orderedDescending
            block(dicInfo, appStoreVer, releaseNotes, isUpdate)
        }
        dataTask.resume()
    }
    
    static var appVer: String {
        guard let infoDic = Bundle.main.infoDictionary,
            let version = infoDic["CFBundleShortVersionString"] as? String
        else { return "" }
        return version
    }
    
    /// 打开网络链接
    static func openURLString(_ string: String, prefix: String = "") {

        var tmp = string
        if string.hasPrefix(prefix) == false {
            tmp = prefix + string
        }
        if tmp.hasPrefix("tel") {
            tmp = tmp.replacingOccurrences(of: "-", with: "")
        }
        guard let url = URL(string: tmp) as URL? else {
            print("\(#function):链接无法打开!!!\n\(string)")
            return
        }

        if UIApplication.shared.canOpenURL(url) == false {
            print("\(#function):链接无法打开!!!\n\(string)")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    /// 远程推送deviceToken处理
    static func deviceTokenString(_ deviceToken: NSData) -> String{
        var deviceTokenString = String()
        if #available(iOS 13.0, *) {
            let bytes = [UInt8](deviceToken)
            for item in bytes {
                deviceTokenString += String(format:"%02x", item&0x000000FF)
            }
            
        } else {
            deviceTokenString = deviceToken.description.trimmingCharacters(in: CharacterSet(charactersIn: "<> "))
        }
#if DEBUG
        print("deviceToken：\(deviceTokenString)")
#endif
        return deviceTokenString
    }
    
    /// block内任务后台执行(block为空可填入AppDelegate.m方法 applicationDidEnterBackground中)
    static func didEnterBackground(_ block: (()->Void)? = nil) {
        let application: UIApplication = UIApplication.shared
        var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
        //注册一个后台任务，并提供一个在时间耗尽时执行的代码块
        bgTask = application.beginBackgroundTask(expirationHandler: {
            if bgTask != UIBackgroundTaskIdentifier.invalid {
                //当时间耗尽时调用这个代码块
                //如果在这个代码块返回之前没有调用endBackgroundTask
                //应用程序将被终止
                application.endBackgroundTask(bgTask)
                bgTask = UIBackgroundTaskIdentifier.invalid
            }
        })
        
        let backgroundQueue = OperationQueue()
        backgroundQueue.addOperation() {
            //完成一些工作。我们有几分钟的时间来完成它
            //在结束时，必须调用endBackgroundTask
            NSLog("Doing some background work!")
            block?()
            application.endBackgroundTask(bgTask)
            bgTask = UIBackgroundTaskIdentifier.invalid
        }
    }
    /// 配置app图标(传 nil 恢复默认)
    static func setAppIcon(name: String?) {
        //判断是否支持替换图标, false: 不支持
        if #available(iOS 10.3, *) {
            //判断是否支持替换图标, false: 不支持
            guard UIApplication.shared.supportsAlternateIcons else { return }
            
            //如果支持, 替换icon
            UIApplication.shared.setAlternateIconName(name) { (error) in
                //点击弹框的确认按钮后的回调
                if error != nil {
                    print("更换icon发生错误")
                }
            }
        }
    }
}

